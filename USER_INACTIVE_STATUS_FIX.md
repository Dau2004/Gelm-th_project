# User Status Display Issue - FIXED

## Question
"User section list of CHW and Doctors showing inactive - does it mean users we added into the system before are no longer in the database?"

## Answer
**NO - All users are still in the database and are ACTIVE.** The "inactive" display was a bug in the dashboard code.

## Root Cause
The dashboard was checking for a field called `is_active_chw` which **does not exist** in the User model.

### User Model Fields (accounts/models.py)
```python
class User(AbstractUser):
    role = models.CharField(...)
    phone = models.CharField(...)
    facility = models.ForeignKey(...)
    state = models.CharField(...)
    is_active = models.BooleanField(default=True)  # ✓ This exists
    # is_active_chw does NOT exist ✗
```

### Dashboard Bug (MoHDashboard.js)
```javascript
// WRONG - was checking non-existent field
{users.filter(u => u.role === 'CHW' && u.is_active_chw).length}
{chw.is_active_chw ? 'Active' : 'Inactive'}

// CORRECT - now checking actual field
{users.filter(u => u.role === 'CHW' && u.is_active).length}
{chw.is_active ? 'Active' : 'Inactive'}
```

## Database Verification
All 9 users in database are ACTIVE:

| Username | Role       | is_active |
|----------|------------|-----------|
| doctor3  | DOCTOR     | True      |
| doctor2  | DOCTOR     | True      |
| doctor1  | DOCTOR     | True      |
| chw5     | CHW        | True      |
| chw4     | CHW        | True      |
| chw3     | CHW        | True      |
| chw2     | CHW        | True      |
| chw1     | CHW        | True      |
| admin    | MOH_ADMIN  | True      |

## Fix Applied
Changed all occurrences of `is_active_chw` to `is_active` in MoHDashboard.js:

1. **Overview metrics** - Active CHWs and Doctors count
2. **Users tab metrics** - Total active counts
3. **CHW table** - Status column display
4. **Doctor table** - Status column display

## Result After Fix
- All CHWs will show as "Active" (green badge)
- All Doctors will show as "Active" (green badge)
- Metrics will show correct counts:
  - Total CHWs: 5 (5 active)
  - Total Doctors: 3 (3 active)
  - Inactive Users: 0

## How to Verify
1. Restart frontend: `cd gelmath_web && npm start`
2. Login to dashboard
3. Go to "Users" tab
4. Check CHW and Doctor tables - all should show "Active" status

## Note
The `is_active` field is the standard Django user field that controls whether a user can login. When `is_active=False`, the user is deactivated and cannot access the system.
