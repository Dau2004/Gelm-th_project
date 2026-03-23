import React, { useState, useEffect } from 'react';
import { explainPrediction, getAssessments } from '../services/api';
import { BarChart, Bar, XAxis, YAxis, Tooltip, Cell, ResponsiveContainer, Legend } from 'recharts';
import './ExplainabilityDashboard.css';

const ExplainabilityDashboard = () => {
  const [assessments, setAssessments] = useState([]);
  const [selectedAssessment, setSelectedAssessment] = useState(null);
  const [explanation, setExplanation] = useState(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    loadAssessments();
  }, []);

  const loadAssessments = async () => {
    try {
      const response = await getAssessments({ limit: 50 });
      setAssessments(response.data.results || response.data);
    } catch (error) {
      console.error('Error loading assessments:', error);
    }
  };

  const handleExplain = async (assessment) => {
    setLoading(true);
    setSelectedAssessment(assessment);
    
    try {
      const response = await explainPrediction({
        sex: assessment.sex,
        age_months: assessment.age_months,
        muac_mm: assessment.muac_mm,
        edema: assessment.edema,
        appetite: assessment.appetite,
        danger_signs: assessment.danger_signs ? 1 : 0,
        recommended_pathway: assessment.recommended_pathway,
        confidence: assessment.confidence
      });
      
      setExplanation(response.data);
    } catch (error) {
      console.error('Error explaining prediction:', error);
      alert('Failed to generate explanation');
    } finally {
      setLoading(false);
    }
  };

  const chartData = explanation ? explanation.feature_contributions.map(fc => ({
    feature: fc.feature,
    importance: fc.importance,
    impact: fc.impact
  })) : [];

  return (
    <div className="explainability-dashboard">
      <div className="dashboard-header">
        <h2>ML Explainability Dashboard</h2>
        <p>Understand why the AI made each recommendation</p>
      </div>

      <div className="dashboard-content">
        <div className="assessments-panel">
          <h3>Recent Assessments</h3>
          <div className="assessment-list">
            {assessments.map(assessment => (
              <div 
                key={assessment.id} 
                className={`assessment-card ${selectedAssessment?.id === assessment.id ? 'selected' : ''}`}
                onClick={() => handleExplain(assessment)}
              >
                <div className="assessment-header">
                  <span className="child-id">{assessment.child_id}</span>
                  <span className={`pathway-badge ${assessment.recommended_pathway}`}>
                    {assessment.recommended_pathway}
                  </span>
                </div>
                <div className="assessment-details">
                  <span>MUAC: {assessment.muac_mm}mm</span>
                  <span>Age: {assessment.age_months}mo</span>
                  <span>Status: {assessment.clinical_status}</span>
                </div>
              </div>
            ))}
          </div>
        </div>

        <div className="explanation-panel">
          {loading && (
            <div className="loading-state">
              <div className="spinner"></div>
              <p>Generating explanation...</p>
            </div>
          )}

          {!loading && !explanation && (
            <div className="empty-state">
              <p>Select an assessment to see ML explanation</p>
            </div>
          )}

          {!loading && explanation && (
            <>
              <div className="prediction-summary">
                <h3>AI Recommendation</h3>
                <div className="prediction-box">
                  <div className="prediction-main">
                    <span className="label">Predicted Pathway:</span>
                    <span className={`value pathway-${explanation.prediction}`}>
                      {explanation.prediction}
                    </span>
                  </div>
                  <div className="confidence-meter">
                    <span className="label">Confidence:</span>
                    <div className="meter-bar">
                      <div 
                        className="meter-fill" 
                        style={{ width: `${explanation.confidence}%` }}
                      ></div>
                    </div>
                    <span className="value">{explanation.confidence}%</span>
                  </div>
                </div>

                <div className="probabilities">
                  <h4>All Pathway Probabilities:</h4>
                  {Object.entries(explanation.probabilities).map(([pathway, prob]) => (
                    <div key={pathway} className="prob-row">
                      <span className="pathway-name">{pathway}</span>
                      <div className="prob-bar">
                        <div 
                          className="prob-fill" 
                          style={{ width: `${prob}%` }}
                        ></div>
                      </div>
                      <span className="prob-value">{prob}%</span>
                    </div>
                  ))}
                </div>
              </div>

              <div className="feature-importance">
                <h3>Why This Recommendation?</h3>
                <p className="subtitle">Features ranked by importance</p>
                
                <ResponsiveContainer width="100%" height={300}>
                  <BarChart data={chartData} layout="vertical">
                    <XAxis type="number" domain={[0, 100]} />
                    <YAxis type="category" dataKey="feature" width={150} />
                    <Tooltip />
                    <Legend />
                    <Bar dataKey="importance" name="Importance (%)">
                      {chartData.map((entry, index) => (
                        <Cell 
                          key={`cell-${index}`} 
                          fill={entry.impact === 'positive' ? '#E74C3C' : '#2ECC71'} 
                        />
                      ))}
                    </Bar>
                  </BarChart>
                </ResponsiveContainer>

                <div className="legend-info">
                  <span className="legend-item">
                    <span className="color-box red"></span>
                    Positive impact (pushes toward predicted pathway)
                  </span>
                  <span className="legend-item">
                    <span className="color-box green"></span>
                    Negative impact (pushes away from predicted pathway)
                  </span>
                </div>
              </div>

              <div className="detailed-explanations">
                <h3>Detailed Feature Analysis</h3>
                {explanation.feature_contributions.map((fc, index) => (
                  <div key={index} className="feature-card">
                    <div className="feature-header">
                      <span className="rank">#{fc.rank}</span>
                      <span className="feature-name">{fc.feature}</span>
                      <span className="importance-badge">{fc.importance}% influence</span>
                    </div>
                    <div className="feature-value">
                      <strong>Value:</strong> {fc.value}
                    </div>
                    <div className="feature-reasons">
                      {fc.reasons.map((reason, idx) => (
                        <div key={idx} className="reason-item">
                          <span className="bullet">├─</span>
                          <span>{reason}</span>
                        </div>
                      ))}
                    </div>
                  </div>
                ))}
              </div>

              <div className="clinical-interpretation">
                <h3>Clinical Interpretation</h3>
                <div className="interpretation-box">
                  <p>{explanation.interpretation}</p>
                </div>
                <div className="cmam-compliance">
                  <span className={`compliance-badge ${explanation.cmam_compliant ? 'approved' : 'flagged'}`}>
                    {explanation.cmam_compliant ? 'OK CMAM GUIDELINE COMPLIANT' : 'WARNING REQUIRES REVIEW'}
                  </span>
                </div>
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  );
};

export default ExplainabilityDashboard;
