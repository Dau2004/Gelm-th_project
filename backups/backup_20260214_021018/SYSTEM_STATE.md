# Complete System State - January 2025

## 🎯 What's Working

### ✅ Backend (Port 8000)
- JWT authentication with custom login returning user info
- Assessment API with CHW filtering and chw_counts endpoint
- Referral API with active_doctors and update_prescription endpoints
- Analytics API with 5 endpoints (national_summary, state_trends, time_series, chw_performance, doctor_performance)
- User API with role-based permissions
- Auto-creates facilities from facility_input string

### ✅ Web Dashboard (Port 3000)
- MoH Dashboard with live data from analytics endpoints
- Doctor Dashboard with medical document viewer and prescription editor
- User creation with facility auto-creation
- Login with JWT token storage
- All sections display real backend data (no mock data)

### ✅ Mobile App
- Assessment creation with local SQLite storage
- Individual sync to backend (converts facility names to IDs)
- Doctor selection for SC_ITP referrals
- Medical document viewer with Gelmäth branding
- Referral creation using child_id lookup
- Unified token storage via AuthService

## 📊 Database State

**File**: `gelmath_backend/db.sqlite3` (~200KB)

### Data Counts:
- **Assessments**: 57+ (53 old + 4 newly synced)
- **Users**: 10+ (doctors: doctor1-3, majok; CHWs: chw1-5, bol, chol, bul)
- **Facilities**: 9+
- **Referrals**: Multiple SC_ITP referrals

### User Credentials:
```
doctor1 / doctor123 (DOCTOR)
doctor2 / doctor123 (DOCTOR)
doctor3 / doctor123 (DOCTOR)
majok / doctor123 (DOCTOR)
moh_admin / admin123 (MOH_ADMIN)
chw1 / chw123 (CHW)
chw2 / chw123 (CHW)
bol / chw123 (CHW)
chol / chw123 (CHW)
bul / chw123 (CHW)
```

## 🔧 Key Configurations

### Backend URLs (Port 8000):
```
/api/auth/login/ - Custom JWT login with user info
/api/users/ - User management
/api/assessments/ - Assessment CRUD + chw_counts action
/api/referrals/ - Referral CRUD + active_doctors action
/api/analytics/national-summary/ - Total/SAM/MAM/healthy counts
/api/analytics/state-trends/ - State breakdown
/api/analytics/time-series/ - Daily data
/api/analytics/chw-performance/ - CHW metrics
/api/analytics/doctor-performance/ - Doctor metrics
```

### Frontend URLs (Port 3000):
```
/ - Login page
/moh-dashboard - MoH admin dashboard
/doctor-dashboard - Doctor interface
```

### Mobile App:
```
Base URL: http://10.0.2.2:8000/api/ (Android emulator)
Token Storage: flutter_secure_storage via AuthService
Local DB: SQLite for offline assessments
```

## 🏗️ Architecture

### Authentication Flow:
1. User logs in → Backend returns JWT + user info
2. Token stored in localStorage (web) or flutter_secure_storage (mobile)
3. All API calls include: `Authorization: Bearer <token>`
4. Backend validates token and filters data by user role

### Referral Flow:
1. CHW creates SC_ITP assessment → Medical Document Screen
2. "Refer to Doctor" → Doctor Selection Screen
3. Select doctor + add notes → Create referral (using child_id)
4. Backend looks up assessment by child_id → Creates referral
5. Doctor sees in dashboard → Can edit prescription/notes

### Sync Flow:
1. Mobile app stores assessments in local SQLite
2. Sync button → Loops through unsynced assessments
3. For each: Convert facility name to ID → POST to /api/assessments/
4. Backend auto-sets chw field from authenticated user
5. Mark as synced in local DB

## 📁 Critical Files

### Backend:
```
gelmath_backend/
├── db.sqlite3 ⭐ DATABASE
├── assessments/
│   ├── models.py (Assessment, Referral, Facility)
│   ├── views.py (AssessmentViewSet, ReferralViewSet)
│   ├── serializers.py (Auto-sets chw field)
│   └── analytics_views.py ⭐ ANALYTICS ENDPOINTS
├── accounts/
│   ├── models.py (Custom User with role)
│   ├── views.py (UserViewSet)
│   ├── serializers.py (Facility auto-creation)
│   └── auth_views.py (Custom JWT login)
└── gelmath_api/
    └── urls.py (All route registrations)
```

### Web Dashboard:
```
gelmath_web/src/
├── pages/
│   ├── MoHDashboard.js ⭐ LIVE DATA DASHBOARD
│   └── DoctorDashboard.js (Medical document viewer)
├── services/
│   └── api.js ⭐ API INTEGRATION
└── components/
    └── UserModal.js (User creation)
```

### Mobile App:
```
cmam_mobile_app/lib/
├── services/
│   ├── api_service.dart (API calls, uses AuthService for tokens)
│   ├── auth_service.dart ⭐ TOKEN STORAGE
│   └── sync_service.dart (Individual sync with facility lookup)
└── screens/
    ├── doctor_selection_screen.dart
    └── medical_document_screen.dart
```

## 🚀 Startup Commands

```bash
# Terminal 1: Backend
cd /Users/ram/Downloads/MUAC_DEVELOPMENT/gelmath_backend
source venv/bin/activate
python manage.py runserver 8000

# Terminal 2: Web Dashboard
cd /Users/ram/Downloads/MUAC_DEVELOPMENT/gelmath_web
npm start

# Terminal 3: Mobile App (if needed)
cd /Users/ram/Downloads/MUAC_DEVELOPMENT/cmam_mobile_app
flutter run
```

## 🐛 Known Issues & Solutions

### Issue: Dashboard shows zeros
**Solution**: Login first! Dashboard requires authentication.

### Issue: Mobile app can't fetch doctors
**Solution**: Check token is valid. Logout/login if expired.

### Issue: Sync fails
**Solution**: Ensure backend running on port 8000, not 8001.

### Issue: Referral creation fails
**Solution**: System uses child_id to lookup assessment, not local SQLite ID.

### Issue: Users show blank names
**Solution**: Database has empty first_name/last_name. Dashboard shows username as fallback.

## 📝 Recent Changes

### Latest Updates (January 2025):
1. ✅ Created analytics_views.py with 5 endpoints
2. ✅ Updated MoHDashboard.js to use live data
3. ✅ Replaced all mock data with real backend data
4. ✅ Added CHW and doctor performance metrics
5. ✅ Fixed status filtering in DoctorDashboard.js
6. ✅ Added doctor signature field to Referral model
7. ✅ Unified token storage in mobile app
8. ✅ Fixed sync to use individual POST requests
9. ✅ Added facility name to ID conversion in sync

## 🔐 Security Notes

- JWT tokens expire after 24 hours
- Passwords stored with Django's PBKDF2 hashing
- Backend filters data by user role automatically
- Mobile app stores tokens in secure storage
- No sensitive data in git (db.sqlite3 in .gitignore)

## 📞 Quick Reference

### Test API:
```bash
# Get token
curl -X POST http://localhost:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"username":"doctor1","password":"doctor123"}'

# Use token
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:8000/api/analytics/national-summary/
```

### Check database:
```bash
sqlite3 gelmath_backend/db.sqlite3
SELECT COUNT(*) FROM assessments_assessment;
SELECT COUNT(*) FROM accounts_user;
SELECT COUNT(*) FROM assessments_referral;
```

### Check services:
```bash
lsof -i :8000  # Backend
lsof -i :3000  # Dashboard
```

## 🎯 Next Steps (When You Resume)

1. Run backup script: `./backup.sh`
2. Start backend: `cd gelmath_backend && python manage.py runserver 8000`
3. Start dashboard: `cd gelmath_web && npm start`
4. Login with doctor1/doctor123
5. Verify data loads correctly
6. Continue development!

---

**Last Updated**: January 2025
**Status**: ✅ All systems working
**Database**: 57+ assessments, 10+ users, 9+ facilities
