# MoH Dashboard Showing Zero Data - Fix

## Issue
Dashboard shows all zeros despite database having 50+ assessments.

## Root Cause
**User is not logged in** - The dashboard requires authentication to fetch data from the API.

## Solution

### Step 1: Login to Dashboard
1. Open http://localhost:3000
2. You should see a login screen
3. Login with:
   - Username: `doctor1` or `moh_admin`
   - Password: `doctor123` or `admin123`

### Step 2: Verify Token
Open browser console (F12) and check for:
```
API Request: /analytics/national-summary/ Token: Present
API Response: /analytics/national-summary/ Status: 200
```

If you see "Token: Missing", you're not logged in.

### Step 3: Check Data
After login, the dashboard should show:
- Total Assessments: 53
- SAM Cases: 27
- MAM Cases: 12
- Healthy: 14

## Quick Test

```bash
# Test API directly (should return data)
curl -s -X POST http://localhost:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"username":"doctor1","password":"doctor123"}' \
  | python3 -c "import sys, json; print(json.load(sys.stdin)['access'][:50])"

# Use token to get data
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:8000/api/analytics/national-summary/
```

## Common Issues

### Issue 1: Not Logged In
**Symptom**: All metrics show 0
**Solution**: Login at http://localhost:3000/login

### Issue 2: Token Expired
**Symptom**: Was working, now shows 0
**Solution**: Logout and login again

### Issue 3: Wrong Backend
**Symptom**: 404 errors in console
**Solution**: Ensure gelmath_backend running on port 8000

## Verification

1. **Backend running**: `lsof -i :8000`
2. **Dashboard running**: `lsof -i :3000`
3. **Database has data**: `sqlite3 gelmath_backend/db.sqlite3 "SELECT COUNT(*) FROM assessments;"`
4. **API works**: Test with curl (see above)
5. **Logged in**: Check localStorage in browser DevTools

## Browser Console Checks

Press F12 and look for:
- ✅ "Token: Present" = Logged in
- ❌ "Token: Missing" = Not logged in
- ❌ "Status: 401" = Token expired
- ❌ "Status: 404" = Wrong backend

## The Fix

**Just login to the dashboard!** The data is there, you just need authentication to see it.

1. Go to http://localhost:3000
2. Login with doctor1/doctor123
3. Dashboard will load with real data

That's it!
