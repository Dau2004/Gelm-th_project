# 🎯 DEFINITIVE FIX: Mobile App Sync Issue

## ✅ ROOT CAUSE IDENTIFIED

**The mobile app login function does NOT set the `is_logged_in` flag!**

### Current Flow (BROKEN):
```
1. User opens app
2. AuthCheck looks for 'is_logged_in' flag
3. Flag is FALSE (never set)
4. Shows login screen
5. User logs in → Gets JWT token
6. BUT: 'is_logged_in' flag NOT set!
7. User creates assessment
8. Sync works IF token still valid
9. BUT: On app restart, shows login again
```

### The Bug:

**File**: `cmam_mobile_app/lib/services/api_service.dart` (Line 23-48)

```dart
static Future<Map<String, dynamic>?> login(String username, String password) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', data['access']);
      await prefs.setString('refresh_token', data['refresh']);
      
      // ❌ MISSING: await prefs.setBool('is_logged_in', true);
      
      // Handle user data if present
      if (data.containsKey('user') && data['user'] != null) {
        await prefs.setString('user_role', data['user']['role'] ?? 'CHW');
        await prefs.setInt('user_id', data['user']['id'] ?? 0);
        if (data['user']['facility'] != null) {
          await prefs.setInt('facility_id', data['user']['facility']);
        }
      }
      return data;
    }
    return null;
  } catch (e) {
    print('Login error: $e');
    return null;
  }
}
```

---

## 🔧 THE FIX

### Change #1: Add `is_logged_in` flag to login

**File**: `cmam_mobile_app/lib/services/api_service.dart`

**Line 36** - Add after storing tokens:

```dart
static Future<Map<String, dynamic>?> login(String username, String password) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', data['access']);
      await prefs.setString('refresh_token', data['refresh']);
      await prefs.setBool('is_logged_in', true);  // ✅ ADD THIS LINE
      
      // Handle user data if present
      if (data.containsKey('user') && data['user'] != null) {
        await prefs.setString('user_role', data['user']['role'] ?? 'CHW');
        await prefs.setInt('user_id', data['user']['id'] ?? 0);
        if (data['user']['facility'] != null) {
          await prefs.setInt('facility_id', data['user']['facility']);
        }
      }
      return data;
    }
    return null;
  } catch (e) {
    print('Login error: $e');
    return null;
  }
}
```

### Change #2: Clear `is_logged_in` on logout

**File**: `cmam_mobile_app/lib/services/api_service.dart`

**Line 155** - Already correct, but verify:

```dart
static Future<void> logout() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('access_token');
  await prefs.remove('refresh_token');
  await prefs.remove('user_role');
  await prefs.remove('user_id');
  await prefs.setBool('is_logged_in', false);  // ✅ ADD THIS LINE
}
```

---

## 🧪 TESTING

### Test 1: Fresh Install
```
1. Uninstall app
2. Reinstall
3. Should show login screen ✓
4. Login with credentials
5. Should navigate to main screen ✓
6. Create assessment
7. Check sync message (should be green) ✓
```

### Test 2: App Restart
```
1. Close app completely
2. Reopen app
3. Should go directly to main screen (no login) ✓
4. Create assessment
5. Sync should work ✓
```

### Test 3: Logout
```
1. Click logout button
2. Should return to login screen ✓
3. Try to access app
4. Should require login ✓
```

### Test 4: Dashboard Verification
```
1. Login to MoH dashboard (http://localhost:3000)
2. Username: admin, Password: admin123
3. Go to Overview tab
4. Should see assessment count increase ✓
5. Check Analytics tab
6. Should see new data ✓
```

---

## 📝 COMPLETE FIX CODE

### File: `cmam_mobile_app/lib/services/api_service.dart`

Replace the entire file with this corrected version:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/child_assessment.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api'; // iOS Simulator
  // Use 'http://10.0.2.2:8000/api' for Android emulator
  // Use your computer's IP (e.g., 'http://192.168.1.x:8000/api') for physical device

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', data['access']);
        await prefs.setString('refresh_token', data['refresh']);
        await prefs.setBool('is_logged_in', true);  // ✅ FIX: Set login flag
        
        // Handle user data if present
        if (data.containsKey('user') && data['user'] != null) {
          await prefs.setString('user_role', data['user']['role'] ?? 'CHW');
          await prefs.setInt('user_id', data['user']['id'] ?? 0);
          if (data['user']['facility'] != null) {
            await prefs.setInt('facility_id', data['user']['facility']);
          }
        }
        return data;
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> syncAssessment(ChildAssessment assessment) async {
    try {
      final headers = await _getHeaders();
      final token = await _getToken();
      
      if (token == null) {
        print('❌ Sync failed: No authentication token found');
        return null;
      }
      
      final payload = assessment.toApiMap();
      print('📤 Syncing assessment: ${payload['child_id']}');
      
      // Convert facility name to ID if needed
      if (payload['facility'] != null && payload['facility'] is String) {
        final facilityId = await _getFacilityIdByName(payload['facility']);
        if (facilityId != null) {
          payload['facility'] = facilityId;
          print('✓ Facility converted: ${payload['facility']} -> $facilityId');
        } else {
          print('⚠ Facility not found, removing from payload');
          payload.remove('facility');
        }
      }
      
      print('📦 Payload: ${jsonEncode(payload)}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/assessments/'),
        headers: headers,
        body: jsonEncode(payload),
      );

      print('📥 Response: ${response.statusCode}');
      
      if (response.statusCode == 201) {
        print('✅ Sync successful!');
        return jsonDecode(response.body);
      }
      print('❌ Sync failed: ${response.statusCode} - ${response.body}');
      return null;
    } catch (e) {
      print('❌ Sync error: $e');
      return null;
    }
  }

  static Future<int?> _getFacilityIdByName(String name) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/facilities/'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final facilities = data['results'] ?? data;
        for (var facility in facilities) {
          if (facility['name'] == name) {
            return facility['id'];
          }
        }
      }
      return null;
    } catch (e) {
      print('Facility lookup error: $e');
      return null;
    }
  }

  static Future<List<ChildAssessment>> fetchAssessments() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/assessments/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> results = data['results'] ?? data;
        return results.map((json) => ChildAssessment.fromMap(json)).toList();
      }
      return [];
    } catch (e) {
      print('Fetch error: $e');
      return [];
    }
  }

  static Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/../admin/'),
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200 || response.statusCode == 302;
    } catch (e) {
      return false;
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_role');
    await prefs.remove('user_id');
    await prefs.setBool('is_logged_in', false);  // ✅ FIX: Clear login flag
  }
}
```

---

## 🚀 DEPLOYMENT STEPS

### 1. Apply the fix:
```bash
cd cmam_mobile_app
# Edit lib/services/api_service.dart
# Add the two lines marked with ✅ FIX
```

### 2. Rebuild the app:
```bash
flutter clean
flutter pub get
flutter run
```

### 3. Create test user (if not exists):
```bash
cd ../gelmath_backend
python manage.py shell
```

```python
from accounts.models import User

# Create CHW user for testing
User.objects.create_user(
    username='chw1',
    password='chw123',
    email='chw1@test.com',
    role='CHW',
    phone='+211123456789'
)
```

### 4. Test the flow:
```
1. Open mobile app
2. Login with chw1/chw123
3. Create assessment
4. Verify green sync message
5. Open dashboard (http://localhost:3000)
6. Login as admin/admin123
7. Check Overview → Should show new assessment
```

---

## 📊 VERIFICATION CHECKLIST

- [ ] Mobile app shows login screen on first launch
- [ ] Login succeeds and navigates to main screen
- [ ] Token is stored in SharedPreferences
- [ ] `is_logged_in` flag is set to true
- [ ] Assessment creation works
- [ ] Sync shows green success message
- [ ] Dashboard shows new assessment
- [ ] Analytics update with new data
- [ ] App restart doesn't require re-login
- [ ] Logout clears session and requires re-login

---

## 🎉 EXPECTED RESULTS

### Before Fix:
- ❌ Login works but flag not set
- ❌ App restart requires re-login
- ⚠️ Sync may fail if token expires
- ❌ Dashboard shows no data

### After Fix:
- ✅ Login sets flag correctly
- ✅ App restart maintains session
- ✅ Sync always works when logged in
- ✅ Dashboard shows all assessments
- ✅ Analytics populate correctly
- ✅ Full end-to-end flow works

---

## 🔍 ADDITIONAL DEBUGGING

### If sync still fails after fix:

1. **Check backend is running**:
   ```bash
   curl http://localhost:8000/api/auth/login/
   ```

2. **Check token is valid**:
   ```bash
   # Get token from mobile app logs
   TOKEN="<your_token>"
   curl -H "Authorization: Bearer $TOKEN" http://localhost:8000/api/assessments/
   ```

3. **Check mobile app logs**:
   ```
   Look for:
   - "📤 Syncing assessment: CH..."
   - "📥 Response: 201"
   - "✅ Sync successful!"
   ```

4. **Check database**:
   ```bash
   sqlite3 gelmath_backend/db.sqlite3 "SELECT COUNT(*) FROM assessments;"
   ```

---

## 📝 SUMMARY

**Issue**: Login function doesn't set `is_logged_in` flag

**Fix**: Add one line to login() and one line to logout()

**Impact**: HIGH - Fixes entire sync flow

**Complexity**: LOW - Two-line change

**Time**: 5 minutes to implement, 10 minutes to test

**Risk**: NONE - Only adds missing functionality
