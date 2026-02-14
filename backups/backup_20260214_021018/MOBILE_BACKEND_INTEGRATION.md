# Mobile App to Backend Integration

## Changes Made

### 1. API Service (`lib/services/api_service.dart`)
- Added JWT authentication with token storage
- Added `login()` method for user authentication
- Updated `syncAssessment()` to include auth headers
- Updated `fetchAssessments()` to handle paginated responses
- Added `logout()` method to clear tokens

### 2. Login Screen (`lib/screens/login_screen.dart`)
- Integrated with backend API for authentication
- Stores JWT tokens in SharedPreferences
- Shows error messages on failed login

### 3. Result Screen (`lib/screens/result_screen.dart`)
- Automatically syncs assessment to backend on result display
- Shows sync status indicator in app bar
- Displays success message when synced to MoH Dashboard

## How It Works

1. **CHW Login**: CHW logs in with credentials (e.g., `chw1` / `chw123`)
2. **Create Assessment**: CHW completes assessment form
3. **Auto-Sync**: When result is displayed, assessment automatically syncs to backend
4. **MoH Dashboard**: Data immediately appears on MoH Dashboard

## Testing

### Backend Setup
```bash
cd gelmath_backend
python3 manage.py runserver
```

### Mobile App Setup

#### For Android Emulator:
- API URL is already set to `http://10.0.2.2:8000/api`
- No changes needed

#### For iOS Simulator:
Update `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'http://localhost:8000/api';
```

#### For Physical Device:
1. Find your computer's IP address:
   - Mac: System Preferences → Network
   - Windows: `ipconfig`
   - Linux: `ifconfig`

2. Update `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'http://YOUR_IP:8000/api';
// Example: 'http://192.168.1.100:8000/api'
```

3. Update Django settings (`gelmath_backend/gelmath_api/settings.py`):
```python
ALLOWED_HOSTS = ['localhost', '127.0.0.1', 'YOUR_IP']
```

### Test Credentials
- CHW: `chw1` / `chw123` (or chw2-5)
- Doctor: `doctor1` / `doctor123` (or doctor2-3)
- Admin: `admin` / `admin123`

## Data Flow

```
Mobile App → Backend API → Database → MoH Dashboard
```

1. Mobile creates assessment
2. API receives POST request to `/api/assessments/`
3. Assessment saved to SQLite database
4. MoH Dashboard fetches data from `/api/analytics/national-summary/`
5. Dashboard displays updated counts and charts

## Verification

1. Login to mobile app as CHW
2. Create a new assessment
3. View result screen (auto-syncs)
4. Refresh MoH Dashboard in browser
5. See updated assessment count and data
