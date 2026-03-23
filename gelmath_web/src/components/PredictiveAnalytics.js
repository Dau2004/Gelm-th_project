import React, { useState, useEffect } from 'react';
import { LineChart, Line, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer, Area, AreaChart } from 'recharts';
import { TrendingUp, TrendingDown, AlertTriangle, Package, Users, Bed, Activity } from 'lucide-react';
import { getForecast } from '../services/api';
import './PredictiveAnalytics.css';

function PredictiveAnalytics() {
  const [forecast, setForecast] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadForecast();
  }, []);

  const loadForecast = async () => {
    try {
      const response = await getForecast();
      setForecast(response.data);
    } catch (error) {
      console.error('Error loading forecast:', error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="loading-state">
        <div className="spinner"></div>
        <p>Generating forecast...</p>
      </div>
    );
  }

  if (!forecast) {
    return <div className="empty-state">No forecast data available</div>;
  }

  // Combine historical and forecast data
  const combinedData = [
    ...forecast.historical.months.map((month, idx) => ({
      month,
      sam: forecast.historical.sam_counts[idx],
      mam: forecast.historical.mam_counts[idx],
      type: 'historical'
    })),
    ...forecast.forecast.months.map((month, idx) => ({
      month,
      sam: forecast.forecast.sam_forecast[idx],
      mam: forecast.forecast.mam_forecast[idx],
      type: 'forecast'
    }))
  ];

  return (
    <div className="predictive-analytics">
      <div className="analytics-header">
        <div>
          <h2>Predictive Analytics & Early Warning System</h2>
          <p>3-month forecast based on historical trends • Confidence: {forecast.confidence}</p>
        </div>
        <button className="refresh-button" onClick={loadForecast}>
          <Activity size={18} /> Refresh Forecast
        </button>
      </div>

      {/* Alerts Section */}
      {forecast.alerts && forecast.alerts.length > 0 && (
        <div className="alerts-section">
          <h3><AlertTriangle size={20} /> Early Warning Alerts</h3>
          <div className="alerts-grid">
            {forecast.alerts.map((alert, idx) => (
              <div key={idx} className={`alert-card ${alert.severity}`}>
                <div className="alert-header">
                  <AlertTriangle size={24} />
                  <span className="alert-type">{alert.type.replace('_', ' ')}</span>
                </div>
                <p className="alert-message">{alert.message}</p>
                <p className="alert-recommendation"><strong>Action:</strong> {alert.recommendation}</p>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Trend Indicators */}
      <div className="trends-section">
        <div className="trend-card">
          <div className="trend-header">
            <h4>SAM Trend</h4>
            {forecast.trends.sam_direction === 'increasing' ? 
              <TrendingUp className="trend-icon up" size={24} /> : 
              <TrendingDown className="trend-icon down" size={24} />
            }
          </div>
          <div className="trend-value">
            {Math.abs(forecast.trends.sam_trend)}%
          </div>
          <div className="trend-label">{forecast.trends.sam_direction}</div>
        </div>

        <div className="trend-card">
          <div className="trend-header">
            <h4>MAM Trend</h4>
            {forecast.trends.mam_direction === 'increasing' ? 
              <TrendingUp className="trend-icon up" size={24} /> : 
              <TrendingDown className="trend-icon down" size={24} />
            }
          </div>
          <div className="trend-value">
            {Math.abs(forecast.trends.mam_trend)}%
          </div>
          <div className="trend-label">{forecast.trends.mam_direction}</div>
        </div>
      </div>

      {/* Forecast Chart */}
      <div className="chart-container">
        <h3>Historical Data & 3-Month Forecast</h3>
        <ResponsiveContainer width="100%" height={400}>
          <AreaChart data={combinedData}>
            <defs>
              <linearGradient id="samGradient" x1="0" y1="0" x2="0" y2="1">
                <stop offset="5%" stopColor="#E74C3C" stopOpacity={0.8}/>
                <stop offset="95%" stopColor="#E74C3C" stopOpacity={0.1}/>
              </linearGradient>
              <linearGradient id="mamGradient" x1="0" y1="0" x2="0" y2="1">
                <stop offset="5%" stopColor="#E67E22" stopOpacity={0.8}/>
                <stop offset="95%" stopColor="#E67E22" stopOpacity={0.1}/>
              </linearGradient>
            </defs>
            <CartesianGrid strokeDasharray="3 3" stroke="#e0e0e0" />
            <XAxis dataKey="month" />
            <YAxis />
            <Tooltip 
              content={({ active, payload }) => {
                if (active && payload && payload.length) {
                  const data = payload[0].payload;
                  return (
                    <div className="custom-tooltip">
                      <p className="label">{data.month}</p>
                      <p className="type">{data.type === 'forecast' ? '[DATA] Forecast' : '[ANALYTICS] Historical'}</p>
                      <p style={{color: '#E74C3C'}}>SAM: {data.sam}</p>
                      <p style={{color: '#E67E22'}}>MAM: {data.mam}</p>
                    </div>
                  );
                }
                return null;
              }}
            />
            <Legend />
            <Area 
              type="monotone" 
              dataKey="sam" 
              stroke="#E74C3C" 
              fill="url(#samGradient)" 
              strokeWidth={2}
              name="SAM Cases"
              strokeDasharray={(entry) => entry.type === 'forecast' ? '5 5' : '0'}
            />
            <Area 
              type="monotone" 
              dataKey="mam" 
              stroke="#E67E22" 
              fill="url(#mamGradient)" 
              strokeWidth={2}
              name="MAM Cases"
              strokeDasharray={(entry) => entry.type === 'forecast' ? '5 5' : '0'}
            />
          </AreaChart>
        </ResponsiveContainer>
        <div className="chart-legend">
          <span className="legend-item"><span className="line solid"></span> Historical Data</span>
          <span className="legend-item"><span className="line dashed"></span> Forecast (3 months)</span>
        </div>
      </div>

      {/* Resource Planning */}
      <div className="resources-section">
        <h3>Resource Requirements (Next 3 Months)</h3>
        <div className="resources-grid">
          <div className="resource-card">
            <Package size={32} className="resource-icon" />
            <div className="resource-value">{forecast.resources.rutf_sachets.toLocaleString()}</div>
            <div className="resource-label">RUTF Sachets</div>
            <div className="resource-note">For SAM treatment</div>
          </div>

          <div className="resource-card">
            <Package size={32} className="resource-icon" />
            <div className="resource-value">{forecast.resources.csb_kg.toLocaleString()} kg</div>
            <div className="resource-label">CSB+ Supplement</div>
            <div className="resource-note">For MAM treatment</div>
          </div>

          <div className="resource-card">
            <Users size={32} className="resource-icon" />
            <div className="resource-value">{forecast.resources.chw_needed}</div>
            <div className="resource-label">CHWs Needed</div>
            <div className="resource-note">1 CHW per 50 cases</div>
          </div>

          <div className="resource-card">
            <Bed size={32} className="resource-icon" />
            <div className="resource-value">{forecast.resources.sc_itp_beds}</div>
            <div className="resource-label">SC-ITP Beds</div>
            <div className="resource-note">For complicated SAM</div>
          </div>

          <div className="resource-card">
            <Activity size={32} className="resource-icon" />
            <div className="resource-value">{forecast.resources.otp_capacity}</div>
            <div className="resource-label">OTP Capacity</div>
            <div className="resource-note">Outpatient slots</div>
          </div>
        </div>
      </div>

      {/* Forecast Table */}
      <div className="forecast-table-container">
        <h3>Detailed Forecast Breakdown</h3>
        <table className="forecast-table">
          <thead>
            <tr>
              <th>Month</th>
              <th>SAM Forecast</th>
              <th>MAM Forecast</th>
              <th>Total Cases</th>
              <th>CHWs Required</th>
            </tr>
          </thead>
          <tbody>
            {forecast.forecast.months.map((month, idx) => (
              <tr key={idx}>
                <td><strong>{month}</strong></td>
                <td><span className="badge danger">{forecast.forecast.sam_forecast[idx]}</span></td>
                <td><span className="badge warning">{forecast.forecast.mam_forecast[idx]}</span></td>
                <td>{forecast.forecast.total_forecast[idx]}</td>
                <td>{Math.ceil(forecast.forecast.total_forecast[idx] / 50)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

export default PredictiveAnalytics;
