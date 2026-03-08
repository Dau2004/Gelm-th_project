# CMAM ML System - System Architecture

## Table of Contents
1. [Overview](#overview)
2. [High-Level Architecture](#high-level-architecture)
3. [Component Architecture](#component-architecture)
4. [Data Flow Architecture](#data-flow-architecture)
5. [Deployment Architecture](#deployment-architecture)
6. [Security Architecture](#security-architecture)
7. [Technology Stack](#technology-stack)

---

## Overview

The **Gelmëth CMAM ML System** is a three-tier distributed application designed for offline-first malnutrition screening in resource-constrained environments.

### Design Principles
- **Offline-First**: Mobile app functions without internet connectivity
- **Progressive Sync**: Automatic data synchronization when online
- **Edge Computing**: ML models run locally on mobile devices
- **Scalability**: Cloud backend supports multiple facilities
- **WHO Compliance**: Adheres to CMAM South Sudan 2017 guidelines

---

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        PRESENTATION LAYER                        │
├──────────────────────────────┬──────────────────────────────────┤
│   Mobile App (Flutter)       │   Web Dashboard (React)          │
│   - Offline SQLite           │   - Real-time Analytics          │
│   - Local ML Models          │   - Interactive Charts           │
│   - Auto-sync Queue          │   - Geographic Mapping           │
└──────────────┬───────────────┴──────────────┬───────────────────┘
               │                               │
               │         HTTPS/REST            │
               │                               │
┌──────────────┴───────────────────────────────┴───────────────────┐
│                      APPLICATION LAYER                            │
│                   Django REST Framework                           │
├───────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌──────────────┐  ┌────────────────────────┐  │
│  │ Assessment  │  │  Analytics   │  │  User Management       │  │
│  │   API       │  │     API      │  │       API              │  │
│  └─────────────┘  └──────────────┘  └────────────────────────┘  │
│  ┌─────────────┐  ┌──────────────┐  ┌────────────────────────┐  │
│  │  Referral   │  │   Facility   │  │  Authentication        │  │
│  │    API      │  │     API      │  │    (JWT)               │  │
│  └─────────────┘  └──────────────┘  └────────────────────────┘  │
└───────────────────────────┬───────────────────────────────────────┘
                            │
┌───────────────────────────┴───────────────────────────────────────┐
│                       BUSINESS LOGIC LAYER                        │
├───────────────────────────────────────────────────────────────────┤
│  ┌──────────────────┐  ┌──────────────────┐  ┌────────────────┐ │
│  │   Model 1        │  │   Model 2        │  │  WHO Z-Score   │ │
│  │   Pathway        │  │   Quality        │  │  Calculator    │ │
│  │   Classifier     │  │   Checker        │  │                │ │
│  │   (94% acc)      │  │   (89% acc)      │  │  LMS Tables    │ │
│  └──────────────────┘  └──────────────────┘  └────────────────┘ │
│  ┌──────────────────┐  ┌──────────────────┐  ┌────────────────┐ │
│  │  CMAM Rules      │  │  Validation      │  │  Sync Manager  │ │
│  │  Engine          │  │  Engine          │  │                │ │
│  └──────────────────┘  └──────────────────┘  └────────────────┘ │
└───────────────────────────┬───────────────────────────────────────┘
                            │
┌───────────────────────────┴───────────────────────────────────────┐
│                         DATA LAYER                                │
├───────────────────────────────────────────────────────────────────┤
│  ┌──────────────────┐  ┌──────────────────┐  ┌────────────────┐ │
│  │  PostgreSQL      │  │  SQLite          │  │  Redis Cache   │ │
│  │  (Production)    │  │  (Mobile)        │  │  (Optional)    │ │
│  └──────────────────┘  └──────────────────┘  └────────────────┘ │
│  ┌──────────────────┐  ┌──────────────────┐                     │
│  │  Model Files     │  │  Static Assets   │                     │
│  │  (.pkl)          │  │  (S3/Local)      │                     │
│  └──────────────────┘  └──────────────────┘                     │
└───────────────────────────────────────────────────────────────────┘
```

---

## Component Architecture

### 1. Mobile Application (Flutter)

```
cmam_mobile_app/
├── Presentation Layer
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── assessment_form_screen.dart
│   │   ├── result_screen.dart
│   │   ├── history_screen.dart
│   │   └── referral_screen.dart
│   └── widgets/
│       ├── custom_input_field.dart
│       └── result_card.dart
│
├── Business Logic Layer
│   ├── services/
│   │   ├── ml_service.dart          # Local ML inference
│   │   ├── api_service.dart         # REST API client
│   │   ├── auth_service.dart        # JWT authentication
│   │   ├── sync_service.dart        # Background sync
│   │   └── zscore_service.dart      # WHO calculations
│   └── providers/
│       └── assessment_provider.dart
│
├── Data Layer
│   ├── models/
│   │   ├── child_assessment.dart
│   │   ├── user.dart
│   │   └── referral.dart
│   └── database/
│       └── database_helper.dart     # SQLite operations
│
└── Assets
    ├── models/
    │   ├── cmam_model.tflite
    │   └── quality_model.tflite
    └── data/
        └── who_lms_tables.json
```

**Key Features:**
- **Offline Storage**: SQLite database for local persistence
- **ML Inference**: TensorFlow Lite models embedded in app
- **Sync Queue**: Background job for uploading assessments
- **JWT Auth**: Secure token-based authentication
- **State Management**: Provider pattern for reactive UI

### 2. Backend API (Django)

```
cmam_backend/
├── assessments/
│   ├── models.py              # Assessment data model
│   ├── serializers.py         # DRF serializers
│   ├── views.py               # API endpoints
│   └── ml_predictor.py        # Model inference
│
├── analytics/
│   ├── views.py               # Analytics endpoints
│   └── aggregations.py        # Data aggregation
│
├── users/
│   ├── models.py              # User/CHW profiles
│   └── views.py               # User management
│
├── referrals/
│   ├── models.py              # Referral system
│   └── views.py               # Referral API
│
└── cmam_project/
    ├── settings.py            # Django configuration
    ├── urls.py                # URL routing
    └── wsgi.py                # WSGI application
```

**API Endpoints:**

```
POST   /api/auth/login/                    # User authentication
POST   /api/auth/refresh/                  # Token refresh
POST   /api/assessments/                   # Create assessment
GET    /api/assessments/                   # List assessments
GET    /api/assessments/{id}/              # Get assessment
GET    /api/analytics/summary/             # National summary
GET    /api/analytics/trends/              # Time series data
GET    /api/referrals/active_doctors/      # List doctors
POST   /api/referrals/                     # Create referral
GET    /api/facilities/                    # List facilities
```

### 3. Web Dashboard (React)

```
gelmath_web/
├── src/
│   ├── components/
│   │   ├── Dashboard/
│   │   │   ├── SummaryCards.jsx
│   │   │   ├── TrendChart.jsx
│   │   │   └── GeographicMap.jsx
│   │   ├── Analytics/
│   │   │   ├── AgeDistribution.jsx
│   │   │   └── GenderBreakdown.jsx
│   │   └── Users/
│   │       └── UserManagement.jsx
│   │
│   ├── pages/
│   │   ├── DashboardPage.jsx
│   │   ├── AnalyticsPage.jsx
│   │   └── UsersPage.jsx
│   │
│   ├── services/
│   │   ├── api.js                # Axios API client
│   │   └── auth.js               # Authentication
│   │
│   └── utils/
│       └── chartConfig.js        # Recharts configuration
│
└── public/
    └── index.html
```

**Technology Stack:**
- **React 19.2**: UI framework
- **Recharts**: Data visualization
- **Leaflet**: Geographic mapping
- **Axios**: HTTP client
- **React Router**: Navigation

---

## Data Flow Architecture

### Assessment Flow (Offline → Online)

```
┌─────────────────────────────────────────────────────────────────┐
│                    MOBILE APP (OFFLINE)                          │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│ STEP 1: Data Collection                                          │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ Input: child_id, sex, age, MUAC, edema, appetite, danger   │ │
│ │ Validation: Range checks, required fields                   │ │
│ └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│ STEP 2: Quality Check (Model 2)                                  │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ Input: [muac, age, sex, edema, appetite, danger_signs,     │ │
│ │         near_threshold, unit_suspect, age_suspect]          │ │
│ │ Output: OK / SUSPICIOUS                                     │ │
│ │ Action: Flag if SUSPICIOUS, allow override                  │ │
│ └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│ STEP 3: WHO Z-Score Calculation                                  │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ Input: sex, age_months, MUAC                                │ │
│ │ Lookup: WHO LMS tables (L, M, S parameters)                 │ │
│ │ Formula: Z = ((MUAC/M)^L - 1) / (L * S)                     │ │
│ │ Output: muac_z_score                                        │ │
│ └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│ STEP 4: Clinical Status Determination                            │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ Rules (CMAM Guidelines):                                    │ │
│ │ - SAM: MUAC < 115mm OR edema ≥ 1                           │ │
│ │ - MAM: 115mm ≤ MUAC < 125mm AND edema = 0                  │ │
│ │ - Healthy: MUAC ≥ 125mm AND edema = 0                      │ │
│ │ Output: clinical_status                                     │ │
│ └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│ STEP 5: Pathway Prediction (Model 1)                             │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ Input: [sex, age, muac, edema, appetite, danger_signs]     │ │
│ │ Output: SC-ITP / OTP / TSFP + confidence score              │ │
│ └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│ STEP 6: CMAM Gate Validation                                     │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ Verify pathway matches clinical status:                     │ │
│ │ - SAM + complications → SC-ITP                              │ │
│ │ - SAM + no complications → OTP                              │ │
│ │ - MAM → TSFP                                                │ │
│ │ Override if mismatch detected                               │ │
│ └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│ STEP 7: Local Storage (SQLite)                                   │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ Save to local database with sync_status = 'pending'         │ │
│ │ Display results to CHW                                      │ │
│ └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼ (When online)
┌─────────────────────────────────────────────────────────────────┐
│ STEP 8: Background Sync                                          │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ POST /api/assessments/                                      │ │
│ │ Headers: Authorization: Bearer <JWT_TOKEN>                  │ │
│ │ Body: JSON assessment data                                  │ │
│ │ Update sync_status = 'synced' on success                    │ │
│ └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                    BACKEND (DJANGO)                              │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ - Validate JWT token                                        │ │
│ │ - Save to PostgreSQL                                        │ │
│ │ - Trigger analytics update                                  │ │
│ │ - Return 201 Created                                        │ │
│ └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                    WEB DASHBOARD                                 │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ - Real-time dashboard update                                │ │
│ │ - Analytics recalculation                                   │ │
│ │ - Geographic map refresh                                    │ │
│ └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

---

## Deployment Architecture

### Production Environment (AWS)

```
┌─────────────────────────────────────────────────────────────────┐
│                         INTERNET                                 │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Route 53 (DNS)                                │
│              cmam-southsudan.org                                 │
│              api.cmam-southsudan.org                             │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                CloudFront (CDN) + SSL                            │
│                  Let's Encrypt                                   │
└────────────┬───────────────────────────┬────────────────────────┘
             │                           │
             ▼                           ▼
┌────────────────────────┐  ┌───────────────────────────────────┐
│   S3 Bucket            │  │   Application Load Balancer       │
│   (Static Assets)      │  │   (api.cmam-southsudan.org)       │
│   - React build        │  └───────────┬───────────────────────┘
│   - Images             │              │
└────────────────────────┘              ▼
                         ┌──────────────────────────────────────┐
                         │   EC2 Instance (t3.medium)           │
                         │   Ubuntu 22.04 LTS                   │
                         ├──────────────────────────────────────┤
                         │  ┌────────────────────────────────┐  │
                         │  │  Nginx (Reverse Proxy)         │  │
                         │  │  Port 80/443                   │  │
                         │  └────────────┬───────────────────┘  │
                         │               ▼                      │
                         │  ┌────────────────────────────────┐  │
                         │  │  Gunicorn (WSGI Server)        │  │
                         │  │  Workers: 4                    │  │
                         │  │  Port: 8000                    │  │
                         │  └────────────┬───────────────────┘  │
                         │               ▼                      │
                         │  ┌────────────────────────────────┐  │
                         │  │  Django Application            │  │
                         │  │  - REST API                    │  │
                         │  │  - ML Models                   │  │
                         │  └────────────┬───────────────────┘  │
                         └───────────────┼────────────────────────┘
                                         │
                                         ▼
┌─────────────────────────────────────────────────────────────────┐
│              RDS PostgreSQL (db.t3.micro)                        │
│              - Multi-AZ deployment                               │
│              - Automated backups                                 │
│              - Encryption at rest                                │
└─────────────────────────────────────────────────────────────────┘
```

### Mobile App Distribution

```
┌─────────────────────────────────────────────────────────────────┐
│                    DISTRIBUTION CHANNELS                         │
├──────────────────────────────┬──────────────────────────────────┤
│   Google Play Store          │   Direct APK Distribution        │
│   - Public release           │   - Internal testing             │
│   - Auto-updates             │   - Offline installation         │
│   - Version management       │   - No Play Store required       │
└──────────────────────────────┴──────────────────────────────────┘
```

---

## Security Architecture

### Authentication Flow

```
┌─────────────────────────────────────────────────────────────────┐
│ STEP 1: Login Request                                            │
│ POST /api/auth/login/                                            │
│ Body: {"username": "chw001", "password": "***"}                  │
└────────────────────────┬────────────────────────────────────────┘
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│ STEP 2: Credential Verification                                  │
│ - Django authenticate()                                          │
│ - Password hashing (PBKDF2)                                      │
└────────────────────────┬────────────────────────────────────────┘
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│ STEP 3: JWT Token Generation                                     │
│ Response: {                                                      │
│   "access": "eyJ0eXAiOiJKV1QiLCJhbGc...",  # 5 min expiry       │
│   "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc...", # 24 hour expiry     │
│   "user": {...}                                                  │
│ }                                                                │
└────────────────────────┬────────────────────────────────────────┘
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│ STEP 4: Token Storage (Mobile)                                   │
│ - Secure storage (flutter_secure_storage)                        │
│ - Encrypted at rest                                              │
└────────────────────────┬────────────────────────────────────────┘
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│ STEP 5: Authenticated Requests                                   │
│ Headers: {                                                       │
│   "Authorization": "Bearer eyJ0eXAiOiJKV1QiLCJhbGc...",          │
│   "Content-Type": "application/json"                             │
│ }                                                                │
└────────────────────────┬────────────────────────────────────────┘
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│ STEP 6: Token Validation (Backend)                               │
│ - Verify signature                                               │
│ - Check expiration                                               │
│ - Extract user identity                                          │
└────────────────────────┬────────────────────────────────────────┘
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│ STEP 7: Token Refresh (When expired)                             │
│ POST /api/auth/refresh/                                          │
│ Body: {"refresh": "eyJ0eXAiOiJKV1QiLCJhbGc..."}                  │
│ Response: {"access": "new_token"}                                │
└─────────────────────────────────────────────────────────────────┘
```

### Data Security

```
┌─────────────────────────────────────────────────────────────────┐
│                    SECURITY LAYERS                               │
├─────────────────────────────────────────────────────────────────┤
│ 1. Transport Layer                                               │
│    - TLS 1.3 encryption                                          │
│    - HTTPS only (HSTS enabled)                                   │
│    - Certificate pinning (mobile app)                            │
├─────────────────────────────────────────────────────────────────┤
│ 2. Application Layer                                             │
│    - JWT authentication                                          │
│    - Role-based access control (RBAC)                            │
│    - Input validation & sanitization                             │
│    - SQL injection prevention (ORM)                              │
│    - XSS protection                                              │
│    - CSRF tokens                                                 │
├─────────────────────────────────────────────────────────────────┤
│ 3. Data Layer                                                    │
│    - Database encryption at rest                                 │
│    - Secure password hashing (PBKDF2)                            │
│    - PII anonymization in logs                                   │
│    - Automated backups (encrypted)                               │
├─────────────────────────────────────────────────────────────────┤
│ 4. Network Layer                                                 │
│    - VPC isolation                                               │
│    - Security groups (firewall rules)                            │
│    - DDoS protection (CloudFront)                                │
│    - Rate limiting                                               │
└─────────────────────────────────────────────────────────────────┘
```

---

## Technology Stack

### Mobile App
```yaml
Framework: Flutter 3.0+
Language: Dart 3.0+
Database: SQLite (sqflite 2.3.0)
ML: TensorFlow Lite
HTTP: http 1.1.0
Auth: flutter_secure_storage 9.0.0
State: Provider 6.1.1
Charts: fl_chart 0.66.0
```

### Backend
```yaml
Framework: Django 4.2+
API: Django REST Framework 3.14+
Database: PostgreSQL 15+ / SQLite
Auth: djangorestframework-simplejwt 5.3+
ML: scikit-learn 1.3+, joblib 1.3+
Server: Gunicorn 21.2+
Proxy: Nginx 1.24+
Python: 3.13+
```

### Web Dashboard
```yaml
Framework: React 19.2+
Language: JavaScript ES6+
HTTP: Axios 1.6+
Charts: Recharts 2.10+
Maps: Leaflet 1.9+
Router: React Router 6.20+
Build: Vite 5.0+
```

### DevOps
```yaml
Cloud: AWS (EC2, RDS, S3, Route 53)
CI/CD: GitHub Actions
Monitoring: CloudWatch
Backup: Automated daily snapshots
SSL: Let's Encrypt
```

---

## Performance Specifications

### Mobile App
- **App Size**: ~25 MB (with ML models)
- **Offline Storage**: Up to 10,000 assessments
- **ML Inference**: <100ms per prediction
- **Sync Speed**: ~50 assessments/minute
- **Battery Impact**: <5% per hour active use

### Backend API
- **Response Time**: <200ms (95th percentile)
- **Throughput**: 1000 requests/minute
- **Concurrent Users**: 500+
- **Database**: 1M+ assessments capacity
- **Uptime**: 99.9% SLA

### Web Dashboard
- **Load Time**: <2 seconds
- **Chart Rendering**: <500ms
- **Real-time Updates**: 30-second polling
- **Browser Support**: Chrome, Firefox, Safari, Edge

---

**Document Version**: 1.0.0  
**Last Updated**: February 2026  
**Maintained By**: CMAM Development Team
