# Referral System Implementation

## Overview
Implemented a complete referral system where CHWs can send referrals to doctors, and doctors can view and manage them through their dashboard.

## Backend Implementation

### 1. Referral Model (`cmam_backend/referrals/models.py`)
- **Fields**:
  - `assessment`: Link to assessment
  - `child_id`, `pathway`, `status`, `notes`
  - **CHW Info**: `chw_user`, `chw_username`, `chw_name`, `chw_facility`, `chw_state`
  - **Doctor Info**: `doctor_user`, `doctor_notes`
  - Timestamps: `created_at`, `updated_at`
- **Status Choices**: pending, accepted, in_progress, completed, rejected

### 2. API Endpoints (`/api/referrals/`)
- `GET /api/referrals/` - List referrals (filtered by role)
- `POST /api/referrals/` - Create single referral
- `POST /api/referrals/bulk_create/` - Bulk create referrals (for mobile sync)
- `GET /api/referrals/{id}/` - Get referral details
- `PATCH /api/referrals/{id}/update_status/` - Update referral status

### 3. Role-Based Access
- **CHWs**: Can only see referrals they created
- **Doctors**: Can see all referrals from their state
- **MoH Admins**: Can see all referrals

### 4. Auto-Population
- CHW info automatically populated from authenticated user during bulk_create
- Doctor info automatically set when doctor updates referral status

## Mobile App Implementation

### 1. Referral Model Updates (`lib/models/referral.dart`)
- Added `toApiMap()` method for backend sync
- Fields: child_id, pathway, status, notes, synced flag

### 2. Database Service (`lib/services/database_service.dart`)
- `getUnsyncedReferrals()` - Get referrals not yet synced
- `markReferralAsSynced(id)` - Mark referral as synced after upload

### 3. Sync Service (`lib/services/sync_service.dart`)
- `syncReferrals()` - Upload unsynced referrals to backend
- Bulk upload endpoint: `/api/referrals/bulk_create/`
- Auto-marks as synced after successful upload

### 4. Profile Screen (`lib/screens/profile_screen.dart`)
- Added "Sync Data to Server" button
- Syncs both assessments and referrals
- Shows sync results in dialog

### 5. Automatic Referral Creation
- SC_ITP pathway cases automatically create referrals
- Status: "pending"
- Notes: "URGENT: SAM with complications - requires immediate stabilization centre admission"

## Web Dashboard Implementation

### 1. Doctor Dashboard (`gelmath_web/src/pages/DoctorDashboard.js`)
- **Features**:
  - View all referrals from CHWs in doctor's state
  - Filter by status: pending, accepted, in_progress, completed, all
  - View detailed referral information including assessment data
  - Update referral status with notes
  - Color-coded pathways and statuses

- **Status Workflow**:
  1. **Pending** → Accept or Reject
  2. **Accepted** → Start Treatment (in_progress)
  3. **In Progress** → Mark as Completed
  4. **Completed/Rejected** → Final states

- **Referral Card Shows**:
  - Child ID, pathway, status
  - CHW name and facility
  - Referral date
  - CHW notes
  - Assessment data (sex, age, MUAC, pathway)

### 2. API Service (`gelmath_web/src/services/api.js`)
- `getReferrals()` - Fetch all referrals for logged-in doctor
- `updateReferralStatus(referralId, data)` - Update status and add doctor notes

### 3. Routing (`gelmath_web/src/App.js`)
- `/doctor` route for doctor dashboard
- Role-based authentication (DOCTOR role)
- Auto-redirect based on user role

## Test Users

### CHW Users
- **chw1** / chw123 - Daniel Chol (Bor State Hospital, Jonglei)
- **chw2** / chw123 - Mary Akech (Juba Teaching Hospital, Central Equatoria)
- **Bol** / chw123
- **chol** / chw123 - Deng Chol (Malakal Teaching Hospital, Upper Nile)

### Doctor User
- **doctor1** / doctor123 - Dr. James Maker (Juba Teaching Hospital, Central Equatoria)

### Admin User
- **admin** / admin123 - MoH Admin

## Usage Flow

### CHW Workflow
1. CHW performs assessment on mobile app
2. If pathway is SC_ITP, referral is automatically created
3. CHW can view referrals in Referrals screen
4. CHW syncs data using "Sync Data to Server" button in Profile
5. Referrals are uploaded to backend with CHW info

### Doctor Workflow
1. Doctor logs into web dashboard (username: doctor1, password: doctor123)
2. Automatically redirected to `/doctor` route
3. Views all pending referrals from CHWs in their state
4. Clicks "View Details" to see full referral information
5. Can Accept/Reject pending referrals
6. Can Start Treatment for accepted referrals
7. Can Mark as Completed for in-progress cases
8. All actions include doctor notes for documentation

### Data Flow
```
Mobile App (CHW)
  ↓ Assessment with SC_ITP pathway
  ↓ Auto-create referral locally
  ↓ Sync to backend
Backend API
  ↓ Store referral with CHW info
  ↓ Filter by doctor's state
Doctor Dashboard
  ↓ View and manage referrals
  ↓ Update status with notes
Backend API
  ↓ Update referral status
  ↓ Record doctor info
```

## Database Schema

### Referrals Table
```sql
CREATE TABLE referrals (
  id INTEGER PRIMARY KEY,
  assessment_id INTEGER FOREIGN KEY,
  child_id VARCHAR(50),
  pathway VARCHAR(50),
  status VARCHAR(20) DEFAULT 'pending',
  notes TEXT,
  
  -- CHW Info
  chw_user_id INTEGER FOREIGN KEY,
  chw_username VARCHAR(150),
  chw_name VARCHAR(255),
  chw_facility VARCHAR(255),
  chw_state VARCHAR(100),
  
  -- Doctor Info
  doctor_user_id INTEGER FOREIGN KEY,
  doctor_notes TEXT,
  
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
```

## Key Features

1. **Automatic Referral Creation**: SC_ITP cases auto-generate referrals
2. **Offline-First**: Mobile app stores referrals locally, syncs when online
3. **Role-Based Access**: CHWs see their referrals, doctors see state referrals
4. **Complete Audit Trail**: Tracks CHW and doctor info, timestamps
5. **Status Workflow**: Clear progression from pending to completed
6. **Real-Time Sync**: Mobile app syncs both assessments and referrals
7. **Rich UI**: Color-coded pathways and statuses, detailed views
8. **Doctor Notes**: Doctors can add notes at each status change

## API Examples

### Sync Referrals (Mobile → Backend)
```bash
POST /api/referrals/bulk_create/
Authorization: Bearer <chw_token>
Content-Type: application/json

[
  {
    "child_id": "CH001234",
    "pathway": "SC_ITP",
    "status": "pending",
    "notes": "URGENT: SAM with complications"
  }
]
```

### Get Referrals (Doctor)
```bash
GET /api/referrals/
Authorization: Bearer <doctor_token>

Response:
[
  {
    "id": 1,
    "child_id": "CH001234",
    "pathway": "SC_ITP",
    "status": "pending",
    "notes": "URGENT: SAM with complications",
    "chw_name": "Daniel Chol",
    "chw_facility": "Bor State Hospital",
    "chw_state": "Jonglei",
    "assessment_data": {
      "sex": "M",
      "age_months": 18,
      "muac_mm": 105,
      "pathway": "SC_ITP"
    },
    "created_at": "2025-02-09T10:30:00Z"
  }
]
```

### Update Referral Status
```bash
PATCH /api/referrals/1/update_status/
Authorization: Bearer <doctor_token>
Content-Type: application/json

{
  "status": "accepted",
  "doctor_notes": "Referral accepted for review"
}
```

## Next Steps

1. **Notifications**: Add push notifications when referral status changes
2. **Medical Documents**: Attach medical documents to referrals
3. **Treatment Plans**: Add treatment plan tracking
4. **Follow-ups**: Schedule and track follow-up appointments
5. **Analytics**: Add referral analytics to MoH dashboard
6. **Export**: Export referral reports for documentation
