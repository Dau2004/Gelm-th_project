# Phase 3: Backend Sync - Complete

## Overview
Implemented backend API for receiving assessment data from mobile app and automatic sync functionality.

## Backend Changes

### 1. Assessment Model Updates
**File**: `cmam_backend/assessments/models.py`

Added CHW traceability fields:
- `chw_user` - ForeignKey to CHWUser
- `chw_username` - Username of CHW who performed assessment
- `chw_name` - Full name of CHW
- `chw_phone` - CHW phone number
- `chw_facility` - Facility where CHW works
- `chw_state` - State where CHW works
- `chw_notes` - Additional notes from CHW
- `chw_signature` - Digital signature
- `assessment_date` - When assessment was performed
- `created_at` - When record was created in backend

### 2. API Endpoints
**File**: `cmam_backend/assessments/views.py`

#### Authentication Required
All endpoints now require JWT authentication.

#### Endpoints:
- `GET /api/assessments/` - List assessments (filtered by role)
- `POST /api/assessments/` - Create single assessment
- `POST /api/assessments/bulk_create/` - Bulk upload assessments
- `GET /api/assessments/<id>/` - Get assessment details
- `PUT /api/assessments/<id>/` - Update assessment
- `DELETE /api/assessments/<id>/` - Delete assessment
- `GET /api/statistics/` - Get assessment statistics (filtered by role)

#### Role-Based Access:
- **CHW**: Can only see/create their own assessments
- **MoH Admin**: Can see all assessments from all CHWs

### 3. Bulk Upload
**Endpoint**: `POST /api/assessments/bulk_create/`

Accepts array of assessment objects:
```json
[
  {
    "child_id": "CH001",
    "sex": "M",
    "age_months": 24,
    "muac_mm": 115,
    "edema": 0,
    "appetite": "good",
    "danger_signs": 0,
    "muac_z_score": -2.1,
    "clinical_status": "MAM",
    "recommended_pathway": "TSFP",
    "confidence": 0.95,
    "chw_username": "chw1",
    "chw_name": "Daniel Chol",
    "chw_phone": "+211924778090",
    "chw_facility": "Bor State Hospital",
    "chw_state": "Jonglei",
    "chw_notes": "Child cooperative",
    "chw_signature": "Daniel Chol",
    "assessment_date": "2025-01-13T10:30:00"
  }
]
```

Response:
```json
{
  "message": "5 assessments synced successfully",
  "count": 5
}
```

## Mobile App Changes

### 1. Sync Service
**File**: `cmam_mobile_app/lib/services/sync_service.dart`

New service for syncing assessments:
- `syncAssessments()` - Upload unsynced assessments to backend
- `checkConnection()` - Test backend connectivity

### 2. Database Service Updates
**File**: `cmam_mobile_app/lib/services/database_service.dart`

Added:
- `markAsSynced(id)` - Mark assessment as synced after successful upload

### 3. Settings Screen
**File**: `cmam_mobile_app/lib/screens/settings_screen.dart`

Added "Data Sync" section with:
- Sync button to manually trigger upload
- Loading indicator during sync
- Success/error messages

## Testing

### 1. Start Backend
```bash
cd cmam_backend
./start.sh 8001
```

### 2. Create Test Assessment in Mobile App
1. Login as `chw1` / `chw123`
2. Go to "New Assessment"
3. Fill in child data and submit
4. Assessment saved locally with `synced=0`

### 3. Sync Data
1. Go to Settings screen (last tab)
2. Tap "Sync Assessments"
3. Should see success message: "X assessments synced successfully"

### 4. Verify in Backend
```bash
# Check database
cd cmam_backend
python3 manage.py shell

from assessments.models import Assessment
Assessment.objects.all()
# Should see synced assessments with CHW information
```

### 5. Test API Directly
```bash
# Get access token
curl -X POST http://localhost:8001/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"username": "chw1", "password": "chw123"}'

# List assessments (use token from above)
curl -X GET http://localhost:8001/api/assessments/ \
  -H "Authorization: Bearer <ACCESS_TOKEN>"

# Get statistics
curl -X GET http://localhost:8001/api/statistics/ \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

## Data Flow

1. **Assessment Creation** (Mobile)
   - CHW fills assessment form
   - Data saved to local SQLite with `synced=0`
   - CHW info auto-populated from logged-in user

2. **Sync Trigger** (Mobile)
   - Manual: CHW taps "Sync Assessments" in Settings
   - Automatic: Can be triggered on app start or periodically

3. **Data Upload** (Mobile → Backend)
   - Get unsynced assessments from local database
   - Send to `/api/assessments/bulk_create/`
   - Include JWT token for authentication

4. **Backend Processing**
   - Validate JWT token
   - Link assessment to CHW user account
   - Save to PostgreSQL/SQLite
   - Return success response

5. **Mark as Synced** (Mobile)
   - Update local records: `synced=1`
   - Show success message to CHW

## Security

- All endpoints require JWT authentication
- CHWs can only access their own data
- MoH admins can access all data
- Tokens expire after 7 days (access) / 30 days (refresh)

## Next Steps

### Phase 4: Real-time Sync & Offline Support
- Auto-sync on network availability
- Conflict resolution for offline edits
- Background sync service
- Sync status indicators

### Phase 5: Analytics Dashboard
- MoH admin dashboard
- Assessment trends by state/facility
- CHW performance metrics
- Malnutrition hotspot mapping
