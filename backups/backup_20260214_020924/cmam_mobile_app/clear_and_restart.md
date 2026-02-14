# Clear App Data and Restart

## The Issue
You logged in before the profile screen was updated. The old user data is still stored in secure storage.

## Solution - Choose ONE:

### Option 1: Logout and Login Again (Easiest)
1. In the app, go to Profile screen
2. Click "Logout"
3. Login again with: `chw1` / `chw123`
4. Go back to Profile screen - it should now show correct data

### Option 2: Hot Restart Flutter App
1. In your terminal running Flutter, press `R` (capital R) for hot restart
2. This will restart the app and reload the profile

### Option 3: Uninstall and Reinstall (Most thorough)
```bash
# Stop the app
# Then run:
cd /Users/ram/Downloads/MUAC_DEVELOPMENT/cmam_mobile_app
flutter clean
flutter pub get
flutter run
```

## What to Look For
After logging in again, check the console output for these debug messages:
- `Login response status: 200`
- `Stored user data: username=chw1, full_name=Daniel Chol`
- `getCurrentUser: username=chw1, full_name=Daniel Chol, facility=Bor State Hospital`
- `Profile: Set state - username: chw1, fullName: Daniel Chol, facility: Bor State Hospital`

## Expected Profile Screen Display
- **Full Name**: Daniel Chol
- **Username**: @chw1
- **Facility**: Bor State Hospital
- **State**: Jonglei
- **Phone**: +211924778090
- **Role**: Community Health Worker
