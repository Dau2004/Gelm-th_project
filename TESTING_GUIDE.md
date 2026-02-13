# 🧪 Testing Guide: Mobile App → MoH Dashboard

## Current System Status

✅ **Backend**: Running on http://localhost:8000  
✅ **Database**: PostgreSQL with 50 assessments  
✅ **CHWs**: 5 users ready (chw1-chw5 / chw123)  
✅ **Facilities**: 5 facilities configured  

## Step-by-Step Test

### 1. Check Current Dashboard Count

**Open MoH Dashboard:**
```
http://localhost:3000
```

**Login:**
- Username: `admin`
- Password: `admin123`

**Note the current count:**
- Total Assessments: **50**
- SAM Cases: **17**
- MAM Cases: **17**
- Healthy: **16**

### 2. Create Assessment on Mobile App

**A. Configure Mobile App**

For **Android Emulator** (already configured):
- API URL: `http://10.0.2.2:8000/api` ✅

For **iOS Simulator**:
```dart
// lib/services/api_service.dart
static const String baseUrl = 'http://localhost:8000/api';
```

For **Physical Device**:
```dart
// Find your computer's IP: ifconfig | grep "inet "
static const String baseUrl = 'http://YOUR_IP:8000/api';
```

**B. Login to Mobile App**
- Username: `chw1`
- Password: `chw123`

**C. Create New Assessment**

Fill in the form:
```
State: Central Equatoria
Facility: Central Equatoria Health Center
CHW Name: John Doe
CHW Phone: +211123456789
Sex: Boy
Age: 24 months
MUAC: 110 mm (SAM case)
Edema: No
Appetite: Good
Danger Signs: No
```

**D. Submit & View Result**

Watch for:
- ✅ "Assessment synced to MoH Dashboard" message
- Processing screen
- Result screen with pathway

### 3. Verify on MoH Dashboard

**Refresh Dashboard** (Cmd+R / Ctrl+R)

**Expected Changes:**
- Total Assessments: **51** (+1) ✅
- SAM Cases: **18** (+1) ✅
- Central Equatoria: **18** (+1) ✅

**Check Facilities Tab:**
- Central Equatoria Health Center: **18 assessments** (+1)

### 4. Verify in Database

```bash
cd gelmath_backend
python3 manage.py shell -c "
from assessments.models import Assessment
latest = Assessment.objects.latest('timestamp')
print(f'Latest Assessment:')
print(f'  Child ID: {latest.child_id}')
print(f'  MUAC: {latest.muac_mm}mm')
print(f'  Status: {latest.clinical_status}')
print(f'  Facility: {latest.facility.name if latest.facility else \"None\"}')
print(f'  CHW: {latest.chw.username if latest.chw else \"None\"}')
print(f'  Timestamp: {latest.timestamp}')
"
```

## Troubleshooting

### Mobile App Can't Connect

**Check backend is running:**
```bash
ps aux | grep "manage.py runserver"
```

**Restart if needed:**
```bash
cd gelmath_backend
python3 manage.py runserver
```

### Authentication Failed

**Verify CHW exists:**
```bash
cd gelmath_backend
python3 manage.py shell -c "
from accounts.models import User
chw = User.objects.get(username='chw1')
print(f'CHW: {chw.username}, Active: {chw.is_active}')
"
```

### Data Not Appearing

**Check API logs:**
```bash
# Backend terminal shows POST requests
# Look for: POST /api/assessments/ 201
```

**Verify assessment was created:**
```bash
cd gelmath_backend
python3 manage.py shell -c "
from assessments.models import Assessment
print(f'Total: {Assessment.objects.count()}')
print(f'Latest: {Assessment.objects.latest(\"timestamp\").child_id}')
"
```

## Expected Results

### Before Mobile Assessment
```
Dashboard: 50 assessments
Database: 50 records
```

### After Mobile Assessment
```
Dashboard: 51 assessments (+1) ✅
Database: 51 records (+1) ✅
Facility: +1 assessment ✅
State: +1 assessment ✅
```

## Success Indicators

✅ Mobile app shows "Assessment synced" message  
✅ Dashboard count increases by 1  
✅ New assessment appears in database  
✅ Facility count increases  
✅ State statistics update  
✅ Charts reflect new data  

## Quick Verification Command

```bash
# Run this before and after mobile assessment
cd gelmath_backend
python3 manage.py shell -c "
from assessments.models import Assessment
from django.utils import timezone
from datetime import timedelta

recent = Assessment.objects.filter(
    timestamp__gte=timezone.now() - timedelta(minutes=5)
).count()

print(f'Total assessments: {Assessment.objects.count()}')
print(f'Created in last 5 min: {recent}')
"
```

## Test Credentials

| Role | Username | Password | Facility |
|------|----------|----------|----------|
| Admin | admin | admin123 | - |
| CHW | chw1 | chw123 | Central Equatoria HC |
| CHW | chw2 | chw123 | Eastern Equatoria HC |
| CHW | chw3 | chw123 | Western Equatoria HC |
| CHW | chw4 | chw123 | Jonglei HC |
| CHW | chw5 | chw123 | Unity HC |

## Data Flow Diagram

```
Mobile App (CHW creates assessment)
    ↓
API POST /api/assessments/
    ↓
Backend validates & saves
    ↓
PostgreSQL stores data
    ↓
MoH Dashboard fetches via API
    ↓
Dashboard displays updated count
```

**Result**: Real-time data flow from field to dashboard! 🎉
