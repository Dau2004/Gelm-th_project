# Referral Feature - Troubleshooting Guide

## Issue: "Sent successful" but no doctors showing

### Root Cause
The mobile app needs to be **logged in** before it can fetch the list of doctors.

### Solution Steps

#### 1. Ensure User is Logged In
The mobile app MUST login before creating assessments:

**Test Login:**
```
1. Open mobile app
2. Go to login screen
3. Login with:
   - Username: doctor1
   - Password: doctor123
```

#### 2. Verify Doctors Exist
Doctors are already in the system:
```bash
sqlite3 gelmath_backend/db.sqlite3 "SELECT id, username, email FROM users WHERE role='DOCTOR';"
```

Output:
```
7|doctor1|doctor1@gelmath.org
8|doctor2|doctor2@gelmath.org  
9|doctor3|doctor3@gelmath.org
```

#### 3. Test API Directly
```bash
# Login
curl -X POST http://localhost:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"username":"doctor1","password":"doctor123"}'

# Get doctors (use token from above)
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:8000/api/referrals/active_doctors/
```

#### 4. Check Mobile App Logs
After rebuilding, check console for:
```
🔑 Token for doctors: Present/Missing
📤 Fetching doctors from: ...
📥 Doctors response: 200
✅ Doctors loaded: 3
```

If you see "Token: Missing", the user is not logged in.

### Common Issues

#### Issue 1: User Not Logged In
**Symptom**: Empty doctor list
**Solution**: Login before creating assessment

#### Issue 2: Wrong Backend Running
**Symptom**: 404 error
**Solution**: Ensure gelmath_backend is running on port 8000

#### Issue 3: Token Expired
**Symptom**: 401 error
**Solution**: Logout and login again

### Correct Flow

1. **Login** → Stores JWT token
2. **Create Assessment** → Uses token for sync
3. **Tap "Refer to Doctor"** → Uses token to fetch doctors
4. **Select Doctor** → Uses token to create referral

### Quick Test

```bash
# 1. Start backend
cd gelmath_backend
python manage.py runserver

# 2. Rebuild mobile app
cd cmam_mobile_app
flutter run

# 3. In app:
#    - Login with doctor1/doctor123
#    - Create SC_ITP assessment
#    - Tap "Refer to Doctor"
#    - Should see 3 doctors
```

### Debug Checklist

- [ ] Backend running on port 8000
- [ ] User logged in (check SharedPreferences)
- [ ] Token stored (check console logs)
- [ ] API returns 200 (check console logs)
- [ ] Doctors list not empty (check console logs)

### Expected Console Output

```
🔑 Token for doctors: Present
📤 Fetching doctors from: http://localhost:8000/api/referrals/active_doctors/
📥 Doctors response: 200
✅ Doctors loaded: 3
🔍 Loading doctors...
📋 Doctors received: 3
```

### If Still Not Working

1. Clear app data
2. Uninstall and reinstall app
3. Login again
4. Try creating referral

The issue is **authentication** - the app needs to be logged in to fetch doctors!
