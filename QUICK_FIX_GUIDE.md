# 🔧 QUICK FIX: Mobile App to MoH Dashboard Sync Issue

## ✅ ISSUE IDENTIFIED

**Problem**: Mobile app assessments not showing on MoH dashboard

**Root Cause**: Mobile app sync fails due to authentication requirement

**Status**: gelmath_backend is running correctly ✓

---

## 🎯 THE REAL ISSUE

Looking at the code flow:

1. **Mobile app creates assessment** → Saves locally ✓
2. **Calls `ApiService.syncAssessment()`** → Attempts to sync
3. **Sync requires JWT token** → Gets token from SharedPreferences
4. **BUT**: Token is NULL if user hasn't logged in!
5. **Result**: Sync fails silently, shows warning message

### Evidence from `result_screen.dart`:
```dart
Future<void> _syncToBackend() async {
  final result = await ApiService.syncAssessment(widget.assessment);
  
  if (result != null) {
    // Success message
  } else {
    // Shows: "⚠ Sync failed - Please login first"
  }
}
```

### Evidence from `api_service.dart`:
```dart
static Future<Map<String, dynamic>?> syncAssessment(...) async {
  final token = await _getToken();
  
  if (token == null) {
    print('❌ Sync failed: No authentication token found');
    return null;  // SYNC FAILS HERE!
  }
  // ... rest of sync code
}
```

---

## 🔍 VERIFICATION

### Check if user is logged in:
The mobile app needs to login BEFORE creating assessments.

### Current Flow (BROKEN):
```
1. Open app → Skip login
2. Create assessment
3. Try to sync → NO TOKEN → FAILS
4. Shows warning but user might miss it
```

### Correct Flow:
```
1. Open app → LOGIN REQUIRED
2. Get JWT token
3. Create assessment
4. Sync with token → SUCCESS
5. Appears on dashboard
```

---

## ✅ SOLUTION 1: Force Login (RECOMMENDED)

### Make login mandatory before using the app

**File**: `cmam_mobile_app/lib/main.dart`

Check if the app allows skipping login. If yes, modify to require login.

---

## ✅ SOLUTION 2: Test with Login

### Manual Testing Steps:

1. **Start gelmath_backend** (already running ✓)
   ```bash
   cd gelmath_backend
   python manage.py runserver
   ```

2. **Create test CHW user** (if not exists)
   ```bash
   cd gelmath_backend
   python manage.py shell
   ```
   ```python
   from accounts.models import User
   
   # Create CHW user
   chw = User.objects.create_user(
       username='chw_test',
       password='test123',
       email='chw@test.com',
       role='CHW',
       phone='+211123456789'
   )
   print(f"Created CHW: {chw.username}")
   ```

3. **Test login via API**:
   ```bash
   curl -X POST http://localhost:8000/api/auth/login/ \
     -H "Content-Type: application/json" \
     -d '{"username":"chw_test","password":"test123"}'
   ```
   
   Should return:
   ```json
   {
     "access": "eyJ0eXAiOiJKV1QiLCJhbGc...",
     "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc...",
     "user": {
       "id": 1,
       "username": "chw_test",
       "role": "CHW"
     }
   }
   ```

4. **Test assessment creation with token**:
   ```bash
   TOKEN="<paste_access_token_here>"
   
   curl -X POST http://localhost:8000/api/assessments/ \
     -H "Authorization: Bearer $TOKEN" \
     -H "Content-Type: application/json" \
     -d '{
       "child_id": "CH999",
       "sex": "M",
       "age_months": 24,
       "muac_mm": 110,
       "edema": 0,
       "appetite": "good",
       "danger_signs": 0,
       "clinical_status": "SAM",
       "recommended_pathway": "OTP",
       "confidence": 0.95,
       "chw_name": "Test CHW",
       "chw_phone": "+211123456789"
     }'
   ```

5. **Verify in dashboard**:
   - Open http://localhost:3000
   - Login as MOH_ADMIN (admin/admin123)
   - Check Overview tab → Should show new assessment

6. **Test mobile app**:
   - Open mobile app
   - **LOGIN FIRST** with chw_test/test123
   - Create assessment
   - Check sync message (should be green ✓)
   - Verify in dashboard

---

## ✅ SOLUTION 3: Check Mobile App Main Flow

Let me check if login is enforced:

**File to check**: `cmam_mobile_app/lib/main.dart`

Look for:
- Initial route
- Authentication check
- Whether login can be skipped

---

## 🔍 DIAGNOSTIC COMMANDS

### 1. Check if assessments are in gelmath_backend:
```bash
sqlite3 gelmath_backend/db.sqlite3 "SELECT child_id, chw_name, timestamp FROM assessments ORDER BY timestamp DESC LIMIT 5;"
```

### 2. Check if assessments are in cmam_backend:
```bash
sqlite3 cmam_backend/db.sqlite3 "SELECT child_id, timestamp FROM assessments_assessment ORDER BY timestamp DESC LIMIT 5;"
```

### 3. Check CHW users:
```bash
sqlite3 gelmath_backend/db.sqlite3 "SELECT id, username, role FROM accounts_user WHERE role='CHW';"
```

### 4. Test backend health:
```bash
# Should return 401 (auth required) - means gelmath_backend is running
curl http://localhost:8000/api/assessments/

# Should return login endpoint
curl http://localhost:8000/api/auth/login/
```

---

## 🎯 MOST LIKELY ISSUE

**The mobile app is NOT logging in before creating assessments!**

### Why this happens:
1. App might allow "guest" mode
2. Login screen might be skippable
3. User creates assessment without logging in
4. Sync fails due to missing token
5. Warning message shown but easy to miss

### Fix:
**Enforce login before allowing assessment creation**

---

## 📝 CODE CHANGES NEEDED

### Option A: Enforce Login in Main

**File**: `cmam_mobile_app/lib/main.dart`

```dart
// Check if token exists on app start
Future<bool> _checkAuth() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token');
  return token != null;
}

// In build method:
initialRoute: await _checkAuth() ? '/main' : '/login',
```

### Option B: Check Auth Before Assessment

**File**: `cmam_mobile_app/lib/screens/assessment_screen.dart`

```dart
@override
void initState() {
  super.initState();
  _checkAuthentication();
}

Future<void> _checkAuthentication() async {
  final token = await ApiService._getToken();
  if (token == null) {
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text('Login Required'),
          content: Text('Please login to create assessments'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text('Go to Login'),
            ),
          ],
        ),
      );
    }
  }
}
```

---

## ✅ IMMEDIATE ACTION ITEMS

1. **Check mobile app main.dart** - Does it enforce login?
2. **Test login flow** - Can user skip login?
3. **Create test CHW user** - Use script above
4. **Test full flow** - Login → Create → Verify dashboard
5. **Add auth check** - Before assessment creation

---

## 🎉 SUCCESS CRITERIA

After fix:
- ✅ User MUST login before creating assessments
- ✅ Token is stored in SharedPreferences
- ✅ Sync succeeds with green message
- ✅ Assessment appears in MoH dashboard immediately
- ✅ Analytics update with new data

---

## 📊 CURRENT STATUS

| Component | Status | Issue |
|-----------|--------|-------|
| gelmath_backend | ✅ Running | None |
| Backend Auth | ✅ Working | Requires JWT |
| Mobile App Sync | ⚠️ Implemented | Needs token |
| Mobile App Login | ❓ Unknown | May be skippable |
| Dashboard | ✅ Working | Shows data if synced |

**Next Step**: Check if mobile app enforces login!
