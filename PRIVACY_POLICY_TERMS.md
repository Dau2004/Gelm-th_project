# Privacy Policy & Terms of Use
**Gelmëth - Community-based Management of Acute Malnutrition System**

Ethical guidelines, data protection, and usage agreement for the Gelmëth CMAM ML System.

---

## 1. Ethical Considerations & Overview

This application is a **Community-based Management of Acute Malnutrition (CMAM) System** designed to support Community Health Workers (CHWs), doctors, and Ministry of Health officials in identifying and managing acute malnutrition in children aged 6-59 months in South Sudan. The system utilizes anthropometric measurements, clinical observations, and WHO-compliant Z-score calculations to generate predictive care pathway recommendations (SC-ITP, OTP, TSFP) and quality assessments of measurements.

Because this system handles sensitive child health data and influences critical medical decisions, these ethical considerations are central to ensuring privacy, fairness, clinical accuracy, and social accountability throughout the system's operation.

---

## 2. Data Privacy, Management, and Confidentiality

### 2.1 Data Minimization & Anonymization
The data processed by this system does not require direct personal identifiers such as full names, national IDs, or contact information. Child anonymity is protected through the use of unique Child IDs assigned at the point of care. The system processes the following variables:

**Anthropometric Measurements:**
- MUAC (Mid-Upper Arm Circumference in mm)
- Age (in months, 6-59 range)
- Sex (Male/Female)

**Clinical Observations:**
- Edema grade (0-3)
- Appetite status (good/poor)
- Danger signs checklist

**Metadata:**
- Assessment date and location
- CHW/facility identifier
- Care pathway assignment

### 2.2 Security Measures
All sensitive data is stored securely using industry-standard encryption:
- **At Rest:** AES-256 encryption for database storage
- **In Transit:** TLS 1.3 for API communications
- **Authentication:** PBKDF2-SHA256 password hashing, JWT tokens
- **Access Control:** Role-based permissions (CHW, Doctor, MoH Admin)

Access is strictly restricted to authorized healthcare personnel under signed confidentiality agreements. The mobile application supports offline-first operation with local SQLite encryption, syncing only when secure connectivity is available.

### 2.3 Legal Compliance
Our data handling procedures comply with:
- **South Sudan Data Protection Regulations**
- **WHO Guidelines on Health Data Management**
- **CMAM South Sudan 2017 Guidelines** (Ministry of Health)
- **International Health Data Standards** (HL7, FHIR principles)

---

## 3. Child Welfare & Clinical Sensitivity

### Support, Not Stigmatization
The system is designed exclusively as a **clinical decision support tool** to facilitate timely, evidence-based interventions. It is not a punitive or discriminatory tool.

### Labeling & Interpretation
We acknowledge the ethical concern regarding malnutrition categorization (SAM/MAM). To mitigate negative labeling effects:

- **Probabilistic Outputs:** Model predictions include confidence scores (0-100%), not absolute diagnoses
- **Clinical Override:** Healthcare providers retain full authority to override system recommendations based on clinical judgment
- **Quality Gatekeeper:** Model 2 flags suspicious measurements to prevent errors from influencing care decisions
- **Contextual Awareness:** System prompts CHWs to consider social, economic, and environmental factors beyond measurements

### Vulnerable Population Protection
Children under 5 are a highly vulnerable population. The system:
- Prioritizes **child safety** above all metrics
- Flags danger signs immediately for urgent referral
- Provides clear action protocols aligned with WHO emergency triage guidelines
- Never delays care based on data quality concerns—when in doubt, refer

---

## 4. Clinical & Professional Integrity

### Evidence-Based Algorithms
The predictive models are built upon:
- **WHO LMS Reference Tables** for Z-score calculation
- **CMAM South Sudan 2017 Guidelines** for pathway classification
- **Open-source ML algorithms** (Random Forest Classifier, scikit-learn)
- **Peer-reviewed methodologies** for malnutrition assessment

All reused code, datasets, and clinical protocols are properly cited in accordance with open-source licensing and medical research standards.

### Ethical Clearance
The system development has been conducted in alignment with:
- **Ministry of Health, South Sudan** approval for CMAM implementation
- **WHO ethical guidelines** for health technology deployment
- **Research ethics principles** for vulnerable populations

Any anomalies or inefficiencies revealed by the system in existing healthcare processes will be treated with discretion and shared constructively with the Ministry of Health to improve child nutrition programs.

---

## 5. Regulatory Frameworks

### Local Frameworks
- **Ministry of Health, South Sudan** - CMAM Guidelines 2017
- **South Sudan National Health Policy**
- **Community Health Worker Protocols**

### International Frameworks
- **WHO Guidelines on Management of Severe Acute Malnutrition** (2013)
- **UNICEF Programming Guidance on Nutrition** (2019)
- **UNESCO Recommendation on the Ethics of AI** (2021)
- **OECD Principles on Artificial Intelligence** (2019)
- **The Belmont Report** (1979) - Respect, Beneficence, Justice

---

## 6. Disclaimer & Limitations

### System Imperfection & Human Oversight
**CRITICAL:** This system is not perfect and should be used with care. Similar to any prediction tool, it contains its own set of built-in biases based on the data it has learned and will be incorrect sometimes. The predictions are useful indicators, not absolute medical diagnoses.

**Never make clinical decisions based solely on system output.** Healthcare providers must:
- Use professional clinical judgment
- Consider the complete context of each child's situation
- View the system as one tool among many, not the definitive solution
- Verify measurements when quality flags are raised
- Prioritize child safety over system recommendations when conflicts arise

Relying too heavily on automated scores without critical thinking could result in inappropriate care pathways or missed cases requiring urgent intervention.

### Specific Limitations

**Data Scope:**
- Model trained on 4,000 synthetic samples based on CMAM guidelines
- May not generalize perfectly to all regions with different malnutrition patterns or measurement practices
- Limited representation of rare conditions (e.g., severe edema grade 3)

**Measurement Dependency:**
- System accuracy depends entirely on correct MUAC measurement technique
- CHW training quality directly impacts prediction reliability
- Equipment calibration (MUAC tapes) must be maintained

**Binary Pathway Classification:**
- Current framework assigns one primary pathway (SC-ITP/OTP/TSFP)
- May not capture complex cases requiring multiple interventions
- Does not predict treatment outcomes or recovery timelines

**Feature Availability:**
- Model relies on 6 core features (MUAC, age, sex, edema, appetite, danger signs)
- Lacks richer context such as household food security, maternal health, or comorbidities
- Does not incorporate longitudinal data (growth trends over time)

**Offline Limitations:**
- Mobile app operates offline but requires periodic sync for data backup
- ML models are static—cannot learn from new cases without retraining
- No real-time model updates in the field

---

## 7. Terms of Use

By accessing and using this application, you agree to:

### For Healthcare Providers (CHWs, Doctors, Nurses):
1. **Confidentiality:** Maintain strict confidentiality of all child health data accessed through the system
2. **Clinical Judgment:** Use predictive insights solely as decision support, not as replacement for clinical assessment
3. **Accurate Data Entry:** Ensure measurements are taken correctly using calibrated equipment and proper technique
4. **Timely Action:** Act promptly on system recommendations, especially for danger signs and severe cases
5. **Reporting:** Report any system errors, data breaches, or ethical concerns immediately to system administrators

### For Ministry of Health Officials:
1. **Oversight:** Use aggregated data for program monitoring and resource allocation, not individual case management
2. **Non-Discrimination:** Ensure system outputs are not used to discriminate against communities or facilities
3. **Quality Assurance:** Support ongoing CHW training and equipment maintenance programs
4. **Transparency:** Share system performance metrics and limitations with stakeholders

### For System Administrators:
1. **Security:** Implement and maintain robust data security measures
2. **Access Control:** Grant system access only to authorized, trained personnel
3. **Audit Trails:** Maintain logs of system access and data modifications
4. **Incident Response:** Have protocols in place for data breaches or system failures

### Prohibited Uses:
- **De-anonymization:** Do not attempt to reverse-engineer child identities from aggregated data
- **Unauthorized Sharing:** Do not share login credentials or export data outside approved channels
- **Commercial Use:** Do not use system data for commercial purposes or non-humanitarian research without explicit approval
- **Discrimination:** Do not use system outputs to deny care or stigmatize children/families

---

## 8. Data Retention & Deletion

- **Active Records:** Child assessment data retained for duration of treatment episode plus 2 years for follow-up analysis
- **Aggregated Analytics:** De-identified statistics retained indefinitely for program evaluation
- **Right to Deletion:** Families may request deletion of child records by contacting facility administrators
- **Automatic Purging:** Inactive records (no assessments for 3+ years) automatically archived and anonymized

---

## 9. User Rights & Responsibilities

### Healthcare Provider Rights:
- Access to training materials and system documentation
- Technical support for system issues
- Feedback channels for system improvements

### Healthcare Provider Responsibilities:
- Complete mandatory training before system use
- Follow CMAM clinical protocols
- Report adverse events or system-related incidents

### Child/Family Rights:
- Right to informed consent for data collection
- Right to access child's health records
- Right to request data correction or deletion
- Right to refuse system-based assessment (standard care still provided)

---

## 10. System Updates & Changes

This Privacy Policy and Terms of Use may be updated periodically to reflect:
- Changes in data protection regulations
- System feature enhancements
- Feedback from healthcare providers and communities

Users will be notified of significant changes via in-app notifications and email. Continued use of the system after updates constitutes acceptance of revised terms.

---

## 11. Contact & Support

**For Technical Support:**
- Email: support@gelmath-southsudan.org
- Phone: +211 XXX XXX XXX

**For Data Privacy Concerns:**
- Email: privacy@gelmath-southsudan.org
- Ministry of Health Data Protection Officer

**For Clinical Questions:**
- Refer to CMAM South Sudan 2017 Guidelines
- Contact facility medical supervisor

**For Ethical Concerns:**
- Ministry of Health Ethics Committee
- WHO Country Office - South Sudan

---

**Last Updated:** February 14, 2026

**Version:** 1.0.0

© 2026 Gelmëth. All rights reserved.

---

**Acknowledgments:**
- Ministry of Health, South Sudan
- World Health Organization (WHO)
- UNICEF South Sudan
- Community Health Workers of South Sudan
