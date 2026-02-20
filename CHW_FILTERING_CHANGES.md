# CHW-Specific Data Filtering Implementation

## Overview
Implemented user-specific filtering so each CHW (Community Health Worker) only sees their own assessments and referrals.

## Changes Made

### 1. **Referral Model** (`lib/models/referral.dart`)
- Added `chwUsername` field to track which CHW created the referral
- Updated `toMap()` to include `chw_username`
- Updated `fromMap()` to read `chw_username`

### 2. **Database Service** (`lib/services/database_service.dart`)
- Upgraded database version from 5 to 6
- Added migration to add `chw_username` column to `referrals` table
- Updated `_createDB()` to include `chw_username` in new installations
- Added new method: `getReferralsByUsername(String username)` to filter referrals by CHW

### 3. **Home Screen** (`lib/screens/new_home_screen.dart`)
- Updated `_loadStats()` to use `getReferralsByUsername()` instead of `getAllReferrals()`
- Now shows only the logged-in CHW's referral count

### 4. **Referrals Screen** (`lib/screens/referrals_screen.dart`)
- Added import for `AuthService`
- Updated `_loadData()` to:
  - Get current user from `AuthService`
  - Filter referrals using `getReferralsByUsername()`
  - Filter assessments using `getAssessmentsByUsername()`
- Now displays only referrals created by the logged-in CHW

### 5. **Processing Screen** (`lib/screens/processing_screen.dart`)
- Updated auto-referral creation for SC_ITP cases to include `chwUsername`
- Uses `AuthService.getCurrentUser()` to get the username

### 6. **Result Screen** (`lib/screens/result_screen.dart`)
- Added import for `AuthService`
- Updated manual referral creation to include `chwUsername`
- Uses `AuthService.getCurrentUser()` to get the username

## How It Works

### Data Flow
1. **Login**: CHW logs in with username (e.g., "chol")
2. **Assessment**: When CHW creates an assessment, `chwUsername` is saved
3. **Referral**: When referral is created, `chwUsername` is saved
4. **Display**: Dashboard and referrals screen filter by `chwUsername`

### Example
If "chol" logs in:
- **Total Assessments**: Shows only assessments where `chw_username = 'chol'`
- **SAM Cases**: Counts only chol's SAM cases
- **MAM Cases**: Counts only chol's MAM cases
- **Referrals**: Shows only referrals where `chw_username = 'chol'`

## Database Schema Changes

### Before (Version 5)
```sql
CREATE TABLE referrals (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  assessment_id TEXT NOT NULL,
  child_id TEXT NOT NULL,
  pathway TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending',
  notes TEXT,
  timestamp TEXT NOT NULL,
  synced INTEGER NOT NULL DEFAULT 0
);
```

### After (Version 6)
```sql
CREATE TABLE referrals (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  assessment_id TEXT NOT NULL,
  child_id TEXT NOT NULL,
  pathway TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending',
  notes TEXT,
  timestamp TEXT NOT NULL,
  synced INTEGER NOT NULL DEFAULT 0,
  chw_username TEXT  -- NEW FIELD
);
```

## Testing Checklist

- [ ] Login as CHW "chol"
- [ ] Create 2-3 assessments
- [ ] Verify home screen shows correct counts
- [ ] Create referrals
- [ ] Verify referrals screen shows only chol's referrals
- [ ] Logout and login as different CHW
- [ ] Verify new CHW sees empty dashboard (no chol's data)
- [ ] Create assessments as new CHW
- [ ] Verify each CHW sees only their own data

## Migration Notes

- Existing referrals without `chw_username` will have NULL value
- They won't appear in any CHW's filtered view
- This is expected behavior for legacy data
- New referrals will always have `chw_username` populated

## Files Modified

1. `/lib/models/referral.dart`
2. `/lib/services/database_service.dart`
3. `/lib/screens/new_home_screen.dart`
4. `/lib/screens/referrals_screen.dart`
5. `/lib/screens/processing_screen.dart`
6. `/lib/screens/result_screen.dart`

## Benefits

✅ **Privacy**: CHWs can't see each other's data
✅ **Accuracy**: Statistics reflect individual CHW performance
✅ **Accountability**: Clear ownership of assessments and referrals
✅ **Scalability**: Works with unlimited number of CHWs
