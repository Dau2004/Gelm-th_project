# User Display Issue - FIXED

## Problem
Users showing with blank names in the dashboard:
- CHWs showing as just numbers (5, 2, 2, 3, 1)
- Doctors showing as just numbers (1, 4, 1)
- Facility column showing facility IDs instead of names

## Root Cause
Database users have **empty first_name and last_name fields**. Dashboard was displaying `{first_name} {last_name}` which resulted in blank spaces.

## Database Reality
```
Username: chw1     | First: (empty) | Last: (empty) | Facility: 1 | State: Unity
Username: chw2     | First: (empty) | Last: (empty) | Facility: 3 | State: Unity
Username: chw3     | First: (empty) | Last: (empty) | Facility: 2 | State: Unity
Username: chw4     | First: (empty) | Last: (empty) | Facility: 2 | State: Western Equatoria
Username: chw5     | First: (empty) | Last: (empty) | Facility: 5 | State: Unity
Username: doctor1  | First: (empty) | Last: (empty) | Facility: 1 | State: Jonglei
Username: doctor2  | First: (empty) | Last: (empty) | Facility: 4 | State: Jonglei
Username: doctor3  | First: (empty) | Last: (empty) | Facility: 1 | State: Unity
```

## Fixes Applied

### 1. Display username when names are empty
```javascript
// BEFORE
<strong>{chw.first_name} {chw.last_name}</strong>

// AFTER
<strong>{chw.first_name && chw.last_name ? `${chw.first_name} ${chw.last_name}` : chw.username}</strong>
```

### 2. Fix avatar to use username
```javascript
// BEFORE
<span className="user-avatar">{chw.first_name?.[0]}{chw.last_name?.[0]}</span>

// AFTER
<span className="user-avatar">{chw.username[0].toUpperCase()}</span>
```

### 3. Fix facility display
```javascript
// BEFORE
<td>{chw.facility || 'N/A'}</td>  // Shows facility ID

// AFTER
<td>{chw.facility_name || 'N/A'}</td>  // Shows facility name
```

## Expected Display After Fix

### CHWs Table
| Name  | Facility                        | State             | Phone | Assessments | Status |
|-------|--------------------------------|-------------------|-------|-------------|--------|
| chw5  | (facility name from API)       | Unity             |       | 0           | Active |
| chw4  | (facility name from API)       | Western Equatoria |       | 0           | Active |
| chw3  | (facility name from API)       | Unity             |       | 0           | Active |
| chw2  | (facility name from API)       | Unity             |       | 0           | Active |
| chw1  | (facility name from API)       | Unity             |       | 0           | Active |

### Doctors Table
| Name     | Facility                  | State   | Phone | Patients | Status |
|----------|--------------------------|---------|-------|----------|--------|
| doctor3  | Central Equatoria HC     | Unity   |       | (random) | Active |
| doctor2  | Jonglei Health Center    | Jonglei |       | (random) | Active |
| doctor1  | Central Equatoria HC     | Jonglei |       | (random) | Active |

## How to Add Names to Users

Users can be updated with proper names through:

1. **Dashboard UI**: Click Edit button on any user
2. **API**: Update user via `/api/users/{id}/`
3. **Django Admin**: http://127.0.0.1:8000/admin/

Example update:
```bash
curl -X PUT http://127.0.0.1:8000/api/users/1/ \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "chw1",
    "first_name": "John",
    "last_name": "Doe",
    "role": "CHW",
    "state": "Unity"
  }'
```

## Summary
- All users exist in database with correct roles and states
- Names are empty, so dashboard now shows usernames as fallback
- Facility names will display correctly (from facility_name field in API response)
- Users can be edited to add proper first/last names
