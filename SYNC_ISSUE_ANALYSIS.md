# 🔍 Mobile App to MoH Dashboard Sync Issue - Root Cause Analysis

## ❌ CRITICAL ISSUE IDENTIFIED

**Problem**: Assessments created in the mobile app are NOT appearing on the MoH dashboard.

**Root Cause**: **BACKEND MISMATCH** - Mobile app is syncing to the WRONG backend server.

---

## 🎯 The Core Problem

### Two Separate Backend Systems Exist:

1. **`cmam_backend/`** - Simple ML prediction backend (Port 8000)
   - Used by mobile app for sync
   - Has basic Assessment model
   - NO authentication required
   - NO connection to MoH dashboard

2. **`gelmath_backend/`** - Full MoH system backend (Port 8000)
   - Used by MoH web dashboard
   - Has complete Assessment model with CHW/Doctor/Facility relationships
   - Requires JWT authentication
   - Connected to analytics and dashboard

### Current Data Flow (BROKEN):

```
Mobile App → cmam_backend (Port 8000) → SQLite DB #1
                                         ❌ NOT CONNECTED

MoH Dashboard → gelmath_backend (Port 8000) → SQLite DB #2
```

**Result**: Data goes to different databases, so dashboard shows nothing!

---

## 🔎 Evidence of the Issue

### 1. Mobile App API Configuration
**File**: `cmam_mobile_app/lib/services/api_service.dart`
```dart
static const String baseUrl = 'http://localhost:8000/api';
```
- Points to `cmam_backend` (simple ML backend)
- No authentication setup
- Basic endpoints only

### 2. MoH Dashboard API Configuration
**File**: `gelmath_web/src/services/api.js`
```javascript
const API_URL = 'http://127.0.0.1:8000/api';
```
- Points to `gelmath_backend` (full system)
- JWT authentication required
- Complete analytics endpoints

### 3. Backend Model Mismatch

**cmam_backend/assessments/models.py** (Simple):
```python
class Assessment(models.Model):
    child_id = models.CharField(max_length=50)
    sex = models.CharField(max_length=1)
    age_months = models.IntegerField()
    muac_mm = models.IntegerField()
    # ... basic fields only
    # NO facility relationship
    # NO CHW relationship
    # NO authentication
```

**gelmath_backend/assessments/models.py** (Complete):
```python
class Assessment(models.Model):
    # ... all basic fields PLUS:
    facility = models.ForeignKey(Facility, ...)
    chw = models.ForeignKey(User, ...)
    assigned_doctor = models.ForeignKey(User, ...)
    state = models.CharField(max_length=100)
    # ... full tracking system
```

### 4. Authentication Mismatch

**cmam_backend**: NO authentication
- `AssessmentViewSet` has no permission classes
- Anyone can POST without login

**gelmath_backend**: JWT required
- `permission_classes = [permissions.IsAuthenticated]`
- Requires valid JWT token
- Role-based access control

---

## 🚨 Why Sync Appears to Work But Doesn't

### In `result_screen.dart`:
```dart
Future<void> _syncToBackend() async {
  setState(() => _isSyncing = true);
  final result = await ApiService.syncAssessment(widget.assessment);
  
  if (result != null) {
    // Shows success message ✓
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ Assessment synced to MoH Dashboard'),
        backgroundColor: Color(0xFF2ECC71),
      ),
    );
  }
}
```

**What Actually Happens**:
1. ✅ Mobile app successfully POSTs to `cmam_backend`
2. ✅ Data saved to `cmam_backend/db.sqlite3`
3. ✅ Success message shown to user
4. ❌ MoH dashboard reads from `gelmath_backend/db.sqlite3`
5. ❌ Dashboard shows NO data (different database!)

---

## 📊 Impact Analysis

### What Works:
- ✅ Mobile app assessment form
- ✅ Quality checks (Model 2)
- ✅ ML predictions (Model 1)
- ✅ Local storage in mobile app
- ✅ Sync to cmam_backend succeeds
- ✅ MoH dashboard UI loads

### What's Broken:
- ❌ Assessments don't appear in MoH dashboard
- ❌ Doctors can't see patient referrals
- ❌ Analytics show zero data
- ❌ State trends are empty
- ❌ Facility stats are empty
- ❌ CHW tracking doesn't work

---

## 🔧 SOLUTION OPTIONS

### Option 1: Use gelmath_backend Only (RECOMMENDED)

**Action**: Point mobile app to gelmath_backend

**Changes Required**:

1. **Update mobile app API endpoint**:
   ```dart
   // cmam_mobile_app/lib/services/api_service.dart
   static const String baseUrl = 'http://localhost:8000/api'; // Keep same
   // But ensure gelmath_backend is running, not cmam_backend
   ```

2. **Add authentication to mobile app**:
   - Mobile app already has login screen
   - Already stores JWT tokens
   - Just needs to use them for sync

3. **Update sync method**:
   ```dart
   // Already implemented! Just needs correct backend
   final headers = await _getHeaders(); // Gets JWT token
   ```

4. **Start correct backend**:
   ```bash
   cd gelmath_backend  # NOT cmam_backend
   python manage.py runserver
   ```

**Pros**:
- ✅ Single source of truth
- ✅ All features work
- ✅ Minimal code changes
- ✅ Authentication already implemented

**Cons**:
- ⚠️ Need to ensure gelmath_backend has ML models

---

### Option 2: Merge Backends (COMPLEX)

**Action**: Combine cmam_backend ML features into gelmath_backend

**Changes Required**:
1. Copy ML models to gelmath_backend
2. Add quality check endpoint
3. Add prediction endpoint
4. Migrate any unique features
5. Deprecate cmam_backend

**Pros**:
- ✅ Clean architecture
- ✅ Single codebase

**Cons**:
- ❌ Time-consuming
- ❌ Risk of breaking changes
- ❌ Need thorough testing

---

### Option 3: Sync Between Backends (NOT RECOMMENDED)

**Action**: Make cmam_backend forward data to gelmath_backend

**Cons**:
- ❌ Complex architecture
- ❌ Double database writes
- ❌ Sync failures possible
- ❌ Maintenance nightmare

---

## ✅ RECOMMENDED FIX (Quick Solution)

### Step 1: Verify Which Backend is Running
```bash
# Check what's on port 8000
lsof -i :8000

# If cmam_backend is running, stop it
# Start gelmath_backend instead
cd gelmath_backend
python manage.py runserver
```

### Step 2: Test Mobile App Login
```dart
// Mobile app should login first
// This gets JWT token needed for sync
ApiService.login('chw1', 'chw123')
```

### Step 3: Verify Sync Endpoint
```bash
# Test that gelmath_backend accepts assessments
curl -X POST http://localhost:8000/api/assessments/ \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "child_id": "CH001",
    "sex": "M",
    "age_months": 24,
    "muac_mm": 110,
    "edema": 0,
    "appetite": "good",
    "danger_signs": 0,
    "clinical_status": "SAM",
    "recommended_pathway": "OTP",
    "confidence": 0.95
  }'
```

### Step 4: Copy ML Models to gelmath_backend
```bash
# Copy trained models
cp cmam_backend/model2_quality_classifier.pkl gelmath_backend/
cp cmam_model.pkl gelmath_backend/

# Copy quality service
cp cmam_backend/assessments/quality_service.py gelmath_backend/assessments/
```

### Step 5: Add Quality Check Endpoint to gelmath_backend
```python
# gelmath_backend/assessments/views.py
from .quality_service import get_quality_service

@api_view(['POST'])
def check_quality(request):
    """Model 2: Check measurement quality."""
    # Copy implementation from cmam_backend
    pass
```

### Step 6: Update gelmath_backend URLs
```python
# gelmath_backend/gelmath_api/urls.py
from assessments.views import check_quality

urlpatterns = [
    # ... existing paths
    path('api/check-quality/', check_quality, name='check_quality'),
]
```

---

## 🧪 Testing Checklist

### Backend Verification:
- [ ] gelmath_backend running on port 8000
- [ ] Can login via API: `POST /api/auth/login/`
- [ ] Can create assessment: `POST /api/assessments/`
- [ ] Assessment appears in database
- [ ] Dashboard shows assessment

### Mobile App Verification:
- [ ] Login works and stores JWT token
- [ ] Assessment form submits
- [ ] Sync shows success message
- [ ] Check gelmath_backend database for data

### Dashboard Verification:
- [ ] Login to MoH dashboard
- [ ] Overview shows assessment count
- [ ] Analytics tab shows data
- [ ] State trends populated
- [ ] Facility stats show data

---

## 📝 Files That Need Changes

### Critical:
1. ✅ **No changes needed** - Mobile app already configured correctly
2. ⚠️ **gelmath_backend** - Add ML model endpoints
3. ⚠️ **Start script** - Ensure correct backend runs

### Optional:
1. **Documentation** - Update CONNECTION_GUIDE.md
2. **Deprecation** - Mark cmam_backend as deprecated
3. **Migration** - Script to move data if needed

---

## 🎯 Quick Fix Summary

**The issue is NOT in the code - it's in which backend is running!**

### Immediate Action:
```bash
# 1. Stop cmam_backend if running
pkill -f "manage.py runserver"

# 2. Start gelmath_backend
cd gelmath_backend
python manage.py runserver

# 3. Test mobile app sync
# Login first, then create assessment
# Check MoH dashboard - data should appear!
```

### Why This Works:
- Mobile app API endpoint is correct
- Authentication is already implemented
- Models are compatible
- Just need the RIGHT backend running

---

## 🚀 Long-term Solution

1. **Merge backends** into single `backend/` directory
2. **Deprecate** cmam_backend completely
3. **Update documentation** to clarify single backend
4. **Add startup script** that ensures correct backend runs
5. **Add health check** endpoint to verify correct backend

---

## 📞 Verification Commands

### Check which backend is running:
```bash
curl http://localhost:8000/api/users/
# If returns 401 (auth required) → gelmath_backend ✓
# If returns 404 → cmam_backend ✗
```

### Check database:
```bash
# gelmath_backend database
sqlite3 gelmath_backend/db.sqlite3 "SELECT COUNT(*) FROM assessments;"

# cmam_backend database
sqlite3 cmam_backend/db.sqlite3 "SELECT COUNT(*) FROM assessments_assessment;"
```

---

## ✅ Success Criteria

After fix, you should see:
1. ✅ Mobile app creates assessment
2. ✅ Sync succeeds with authentication
3. ✅ MoH dashboard shows assessment immediately
4. ✅ Analytics update with new data
5. ✅ Doctor can see referral
6. ✅ State trends show data

---

## 🎉 Conclusion

**Root Cause**: Two separate backends with separate databases

**Solution**: Use gelmath_backend only, ensure it's running on port 8000

**Complexity**: LOW - mostly configuration, not code changes

**Time to Fix**: 15-30 minutes

**Risk**: LOW - mobile app already has correct implementation
