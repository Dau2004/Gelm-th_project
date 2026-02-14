# MoH Dashboard Zero Data Issue - FIXED

## Problem
MoH Dashboard showing all zeros despite user being logged in and database containing 53 assessments.

## Root Causes Identified

### 1. Wrong API Endpoint in Frontend
**Issue**: Frontend was calling `/api/auth/chw-users/` but backend endpoint is `/api/users/`
**Location**: `gelmath_web/src/services/api.js`
**Impact**: All user-related API calls were failing with 404 errors

### 2. Missing CHW Counts Endpoint
**Issue**: Dashboard was calling `/api/assessments/chw-counts/` which didn't exist
**Location**: Backend `assessments/views.py`
**Impact**: CHW assessment counts were not being displayed

### 3. Login Not Returning User Role
**Issue**: Login endpoint only returned JWT tokens, not user info
**Location**: Backend authentication
**Impact**: Frontend couldn't determine user role automatically

## Fixes Applied

### Fix 1: Corrected API Endpoints (gelmath_web/src/services/api.js)
```javascript
// BEFORE
export const getUsers = () => api.get('/auth/chw-users/');
export const createUser = (userData) => api.post('/auth/chw-users/', userData);
export const updateUser = (userId, userData) => api.put(`/auth/chw-users/${userId}/`, userData);
export const deleteUser = (userId) => api.delete(`/auth/chw-users/${userId}/`);

// AFTER
export const getUsers = () => api.get('/users/');
export const createUser = (userData) => api.post('/users/', userData);
export const updateUser = (userId, userData) => api.put(`/users/${userId}/`, userData);
export const deleteUser = (userId) => api.delete(`/users/${userId}/`);
```

### Fix 2: Added CHW Counts Endpoint (gelmath_backend/assessments/views.py)
```python
@action(detail=False, methods=['get'])
def chw_counts(self, request):
    """Get assessment counts per CHW"""
    from django.db.models import Count
    counts = Assessment.objects.values('chw__username').annotate(count=Count('id'))
    result = {item['chw__username']: item['count'] for item in counts if item['chw__username']}
    return Response(result)
```

### Fix 3: Custom Login View with User Info (gelmath_backend/accounts/auth_views.py)
Created new file with custom JWT serializer that includes user info:
```python
class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    def validate(self, attrs):
        data = super().validate(attrs)
        user_serializer = UserSerializer(self.user)
        data['user'] = user_serializer.data
        return data
```

Updated `gelmath_backend/gelmath_api/urls.py` to use custom view.

### Fix 4: Updated Frontend Login (gelmath_web/src/services/api.js)
```javascript
export const login = async (username, password) => {
  const response = await axios.post(`${API_URL}/auth/login/`, { username, password });
  const { access, refresh, user } = response.data;
  localStorage.setItem('access_token', access);
  localStorage.setItem('refresh_token', refresh);
  if (user) {
    localStorage.setItem('user_role', user.role);
    localStorage.setItem('user_info', JSON.stringify(user));
  }
  return response.data;
};
```

### Fix 5: Updated Login Component (gelmath_web/src/pages/Login.js)
```javascript
const response = await login(username, password);
const userRole = response.user?.role || role;
onLogin(userRole);
```

## Testing Steps

### 1. Restart Backend Server
```bash
cd gelmath_backend
python3 manage.py runserver
```

### 2. Restart Frontend Server
```bash
cd gelmath_web
npm start
```

### 3. Test Login
1. Navigate to http://localhost:3000
2. Login with credentials:
   - Username: `admin`
   - Password: `admin123`
   - Role: MoH Admin

### 4. Verify Dashboard Data
After login, dashboard should show:
- Total Assessments: 53
- SAM Cases: 27 (50.94%)
- MAM Cases: 12 (22.64%)
- Healthy: 14
- Active CHWs: 2
- Total Facilities: 5

### 5. Test API Endpoints Manually
```bash
# Login
curl -X POST http://127.0.0.1:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}'

# Use the access token from response
TOKEN="<your_access_token>"

# Test analytics
curl -X GET http://127.0.0.1:8000/api/analytics/national-summary/ \
  -H "Authorization: Bearer $TOKEN"

# Test users
curl -X GET http://127.0.0.1:8000/api/users/ \
  -H "Authorization: Bearer $TOKEN"

# Test CHW counts
curl -X GET http://127.0.0.1:8000/api/assessments/chw-counts/ \
  -H "Authorization: Bearer $TOKEN"
```

## Expected Results

### Login Response (New)
```json
{
  "refresh": "eyJ...",
  "access": "eyJ...",
  "user": {
    "id": 1,
    "username": "admin",
    "role": "MOH_ADMIN",
    "email": "admin@gelmath.org",
    "first_name": "",
    "last_name": "",
    "is_active": true
  }
}
```

### National Summary Response
```json
{
  "total_assessments": 53,
  "sam_count": 27,
  "mam_count": 12,
  "healthy_count": 14,
  "sam_prevalence": 50.94,
  "mam_prevalence": 22.64,
  "active_chws": 2,
  "recent_assessments": 53,
  "total_facilities": 5
}
```

### Users Response
```json
{
  "count": 9,
  "results": [
    {
      "id": 1,
      "username": "admin",
      "role": "MOH_ADMIN",
      ...
    },
    ...
  ]
}
```

### CHW Counts Response
```json
{
  "chw1": 25,
  "chw2": 28
}
```

## Browser Console Debugging

After fixes, you should see in browser console:
```
API Request: /analytics/national-summary/ Token: Present
API Response: /analytics/national-summary/ Status: 200
API Request: /users/ Token: Present
API Response: /users/ Status: 200
API Request: /assessments/chw-counts/ Token: Present
API Response: /assessments/chw-counts/ Status: 200
```

## Common Issues

### Issue: Still showing zeros after restart
**Solution**: Clear browser localStorage and login again
```javascript
// In browser console
localStorage.clear();
// Then refresh and login again
```

### Issue: Token expired
**Solution**: Login again to get new token

### Issue: CORS errors
**Solution**: Verify backend CORS settings in `gelmath_backend/gelmath_api/settings.py`

## Files Modified

1. `gelmath_web/src/services/api.js` - Fixed API endpoints and login function
2. `gelmath_backend/assessments/views.py` - Added chw_counts action
3. `gelmath_backend/accounts/auth_views.py` - Created custom login view (NEW FILE)
4. `gelmath_backend/gelmath_api/urls.py` - Updated to use custom login view
5. `gelmath_web/src/pages/Login.js` - Updated to use role from API response

## Summary

The dashboard was showing zeros because:
1. API calls to `/api/auth/chw-users/` were failing (404)
2. Missing CHW counts endpoint
3. All failed API calls were caught by error handlers that set default values to 0

After fixes, all API endpoints work correctly and dashboard displays real data from database.
