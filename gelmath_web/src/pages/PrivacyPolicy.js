import React from 'react';
import { Shield, Lock, Heart, AlertCircle, FileText, Users } from 'lucide-react';
import './PolicyPages.css';

function PrivacyPolicy() {
  return (
    <div className="policy-container">
      <div className="policy-header">
        <Shield size={48} />
        <h1>Privacy Policy & Terms of Use</h1>
        <p className="policy-subtitle">Gelmëth - Community-based Management of Acute Malnutrition System</p>
      </div>

      <div className="policy-content">
        <section className="policy-section">
          <div className="section-icon"><Heart /></div>
          <h2>1. Ethical Considerations & Overview</h2>
          <p>
            This application is a <strong>Community-based Management of Acute Malnutrition (CMAM) System</strong> designed 
            to support Community Health Workers (CHWs), doctors, and Ministry of Health officials in identifying and managing 
            acute malnutrition in children aged 6-59 months in South Sudan.
          </p>
          <p>
            The system utilizes anthropometric measurements, clinical observations, and WHO-compliant Z-score calculations 
            to generate predictive care pathway recommendations (SC-ITP, OTP, TSFP) and quality assessments of measurements.
          </p>
        </section>

        <section className="policy-section">
          <div className="section-icon"><Lock /></div>
          <h2>2. Data Privacy & Confidentiality</h2>
          
          <h3>2.1 Data Minimization & Anonymization</h3>
          <p>The system processes only essential clinical data:</p>
          <ul>
            <li><strong>Anthropometric:</strong> MUAC, Age (6-59 months), Sex</li>
            <li><strong>Clinical:</strong> Edema grade, Appetite status, Danger signs</li>
            <li><strong>Metadata:</strong> Assessment date, location, CHW identifier</li>
          </ul>
          <p>Child anonymity is protected through unique Child IDs—no names or national IDs required.</p>

          <h3>2.2 Security Measures</h3>
          <ul>
            <li><strong>Encryption:</strong> AES-256 (at rest), TLS 1.3 (in transit)</li>
            <li><strong>Authentication:</strong> PBKDF2-SHA256 password hashing, JWT tokens</li>
            <li><strong>Access Control:</strong> Role-based permissions (CHW, Doctor, MoH Admin)</li>
            <li><strong>Offline Security:</strong> Local SQLite encryption with secure sync</li>
          </ul>

          <h3>2.3 Legal Compliance</h3>
          <ul>
            <li>South Sudan Data Protection Regulations</li>
            <li>WHO Guidelines on Health Data Management</li>
            <li>CMAM South Sudan 2017 Guidelines (Ministry of Health)</li>
          </ul>
        </section>

        <section className="policy-section">
          <div className="section-icon"><Users /></div>
          <h2>3. Child Welfare & Clinical Sensitivity</h2>
          
          <div className="highlight-box">
            <p><strong>Support, Not Stigmatization:</strong> This system is a clinical decision support tool, 
            not a punitive or discriminatory instrument.</p>
          </div>

          <h3>Labeling & Interpretation</h3>
          <ul>
            <li><strong>Probabilistic Outputs:</strong> Confidence scores (0-100%), not absolute diagnoses</li>
            <li><strong>Clinical Override:</strong> Healthcare providers retain full authority to override recommendations</li>
            <li><strong>Quality Gatekeeper:</strong> Model 2 flags suspicious measurements to prevent errors</li>
            <li><strong>Child Safety First:</strong> Danger signs trigger immediate referral protocols</li>
          </ul>
        </section>

        <section className="policy-section">
          <div className="section-icon"><FileText /></div>
          <h2>4. Regulatory Frameworks</h2>
          
          <div className="frameworks-grid">
            <div className="framework-box">
              <h4>Local Frameworks</h4>
              <ul>
                <li>Ministry of Health, South Sudan - CMAM Guidelines 2017</li>
                <li>South Sudan National Health Policy</li>
                <li>Community Health Worker Protocols</li>
              </ul>
            </div>
            <div className="framework-box">
              <h4>International Frameworks</h4>
              <ul>
                <li>WHO Guidelines on Management of SAM (2013)</li>
                <li>UNICEF Programming Guidance (2019)</li>
                <li>UNESCO Recommendation on Ethics of AI (2021)</li>
                <li>OECD Principles on AI (2019)</li>
              </ul>
            </div>
          </div>
        </section>

        <section className="policy-section warning-section">
          <div className="section-icon"><AlertCircle /></div>
          <h2>5. Disclaimer & Limitations</h2>
          
          <div className="critical-warning">
            <h3>System Imperfection & Human Oversight</h3>
            <p>
              <strong>CRITICAL:</strong> This system is not perfect and should be used with care. 
              The predictions are useful indicators, not absolute medical diagnoses.
            </p>
            <p>
              <strong>Never make clinical decisions based solely on system output.</strong> Healthcare providers must 
              use professional judgment, consider complete context, and prioritize child safety over system recommendations.
            </p>
          </div>

          <h3>Specific Limitations</h3>
          <ul>
            <li><strong>Measurement Dependency:</strong> Accuracy depends on correct MUAC technique and equipment calibration</li>
            <li><strong>Feature Limitations:</strong> Does not incorporate household food security, maternal health, or comorbidities</li>
            <li><strong>Offline Constraints:</strong> Static models—cannot learn from new cases without retraining</li>
          </ul>
        </section>

        <section className="policy-section">
          <h2>6. Terms of Use</h2>
          
          <h3>For Healthcare Providers</h3>
          <ul>
            <li>Maintain strict confidentiality of all child health data</li>
            <li>Use predictions as decision support, not replacement for clinical assessment</li>
            <li>Ensure accurate data entry with calibrated equipment</li>
            <li>Act promptly on danger signs and severe cases</li>
            <li>Report system errors or ethical concerns immediately</li>
          </ul>

          <h3>For Ministry of Health Officials</h3>
          <ul>
            <li>Use aggregated data for program monitoring, not individual case management</li>
            <li>Ensure non-discriminatory use of system outputs</li>
            <li>Support ongoing CHW training and equipment maintenance</li>
            <li>Share system performance metrics transparently</li>
          </ul>

          <h3>Prohibited Uses</h3>
          <div className="prohibited-box">
            <ul>
              <li>De-anonymization of child identities</li>
              <li>Unauthorized credential sharing or data export</li>
              <li>Commercial use without explicit approval</li>
              <li>Discrimination based on system outputs</li>
            </ul>
          </div>
        </section>

        <section className="policy-section">
          <h2>7. Contact & Support</h2>
          <div className="contact-grid">
            <div className="contact-box">
              <h4>Technical Support</h4>
              <p>Email: support@gelmath-southsudan.org</p>
            </div>
            <div className="contact-box">
              <h4>Data Privacy Concerns</h4>
              <p>Email: privacy@gelmath-southsudan.org</p>
            </div>
            <div className="contact-box">
              <h4>Clinical Questions</h4>
              <p>Refer to CMAM Guidelines or facility supervisor</p>
            </div>
            <div className="contact-box">
              <h4>Ethical Concerns</h4>
              <p>Ministry of Health Ethics Committee</p>
            </div>
          </div>
        </section>
      </div>

      <div className="policy-footer">
        <p><strong>Last Updated:</strong> February 14, 2026 | <strong>Version:</strong> 1.0.0</p>
        <p>© 2026 Gelmëth. All rights reserved.</p>
      </div>
    </div>
  );
}

export default PrivacyPolicy;
