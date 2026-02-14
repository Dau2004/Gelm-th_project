# User Creation Error Fix

## Errors
1. `Not Found: /api/assessments/chw-counts/` - 404
2. `Bad Request: /api/users/` - 400 (User creation failed)

## Root Causes

### 1. CHW Counts Endpoint (404)
Backend code was updated but server wasn't restarted. The new `chw_counts` action needs server restart to be available.

### 2. User Creation (400)
Backend requires fields that frontend wasn't sending:
- `password2` (password confirmation) - REQUIRED
- Password must be at least 8 characters
- `facility` must be facility ID (integer), not name (string)

## Fixes Applied

### Frontend: UserModal.js
1. **Added password confirmation field**:
```javascript
<input
  type="password"
  name="password2"
  value={formData.password2 || ''}
  required={!isEditing}
  minLength="8"
/>
```

2. **Made first_name/last_name optional** (since existing users don't have them)

3. **Fixed facility selection** to use real facilities from API:
```javascript
// Fetch facilities from API
useEffect(() => {
  fetch('http://127.0.0.1:8000/api/facilities/', {
    headers: { 'Authorization': `Bearer ${localStorage.getItem('access_token')}` }
  })
    .then(res => res.json())
    .then(data => setAllFacilities(data.results || []));
}, []);

// Filter by state
const stateFacilities = allFacilities.filter(f => f.state === formData.state);

// Use facility ID
<option key={f.id} value={f.id}>{f.name}</option>
```

### Frontend: MoHDashboard.js
Added `password2` to userFormData state initialization.

## Required Actions

### 1. Restart Backend Server
```bash
cd gelmath_backend
# Stop current server (Ctrl+C)
python3 manage.py runserver
```

This will make the `/api/assessments/chw-counts/` endpoint available.

### 2. Restart Frontend
```bash
cd gelmath_web
# Stop current server (Ctrl+C)
npm start
```

### 3. Test User Creation
1. Login to dashboard
2. Go to Users tab
3. Click "Add New User"
4. Fill form:
   - Username: test_user
   - Password: SecurePass123 (min 8 chars)
   - Confirm Password: SecurePass123
   - First Name: (optional)
   - Last Name: (optional)
   - State: Select any
   - Facility: Select from dropdown (filtered by state)
   - Role: CHW/DOCTOR/MOH_ADMIN
5. Click Create User

## Expected Results

### After Backend Restart
- `/api/assessments/chw-counts/` returns: `{"chw1": 25, "chw2": 28}` (or similar)
- Dashboard loads without 404 errors

### After User Creation
Success response:
```json
{
  "id": 10,
  "username": "test_user",
  "email": "",
  "first_name": "",
  "last_name": "",
  "role": "CHW",
  "phone": "",
  "facility": 1,
  "facility_name": "Central Equatoria Health Center",
  "state": "Central Equatoria",
  "is_active": true,
  "created_at": "2026-02-13T23:45:00Z"
}
```

User appears in the table immediately.

## Password Requirements
- Minimum 8 characters
- Cannot be too common (e.g., "password", "12345678")
- Must match confirmation field
- Django validates against common passwords list

## Facility Selection
Facilities are now loaded from database and filtered by selected state:
- Central Equatoria: Central Equatoria Health Center
- Eastern Equatoria: Eastern Equatoria Health Center
- Jonglei: Jonglei Health Center
- Unity: Unity Health Center
- Western Equatoria: Western Equatoria Health Center
