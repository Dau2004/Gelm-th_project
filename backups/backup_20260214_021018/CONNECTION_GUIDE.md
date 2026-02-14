# 🚀 Gelmäth System - Connection Guide

## ✅ System Status

**Backend**: ✅ Ready (Django + SQLite)
**Web Frontend**: ✅ Ready (React)
**Mobile App**: ✅ Ready (Flutter)
**ML Models**: ✅ Trained and saved

---

## 🎯 Quick Start (3 Steps)

### Step 1: Start Backend
```bash
cd gelmath_backend
python3 manage.py runserver
```
Backend runs on: **http://localhost:8000**

### Step 2: Start Web Dashboard
```bash
cd gelmath_web
npm start
```
Web runs on: **http://localhost:3000**

### Step 3: Test Login
- Open http://localhost:3000
- Select role: **MoH Admin** or **Doctor**
- Username: `admin`
- Password: `admin123`

---

## 🔧 Backend Setup (Already Done!)

✅ Django installed
✅ Database migrated (SQLite)
✅ Superuser created (admin/admin123)
✅ API endpoints configured
✅ CORS enabled for frontend

---

## 📡 API Endpoints Available

### Authentication
```
POST /api/auth/login/
Body: { "username": "admin", "password": "admin123" }
Response: { "access": "token...", "refresh": "token..." }
```

### Users
```
GET  /api/users/              # List all users
POST /api/users/              # Create user
GET  /api/users/{id}/         # Get user details
PUT  /api/users/{id}/         # Update user
DELETE /api/users/{id}/       # Delete user
```

### Facilities
```
GET  /api/facilities/         # List all facilities
POST /api/facilities/         # Create facility
GET  /api/facilities/{id}/    # Get facility details
```

### Assessments
```
GET  /api/assessments/        # List all assessments
POST /api/assessments/        # Create assessment
GET  /api/assessments/{id}/   # Get assessment details
```

### Analytics
```
GET /api/analytics/national-summary/    # National statistics
GET /api/analytics/state-trends/        # State-level trends
GET /api/analytics/time-series/         # Time series data
GET /api/analytics/facility/{id}/       # Facility statistics
```

---

## 🧪 Test API with curl

### 1. Login
```bash
curl -X POST http://localhost:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

### 2. Get Users (with token)
```bash
TOKEN="your_access_token_here"
curl http://localhost:8000/api/auth/users/ \
  -H "Authorization: Bearer $TOKEN"
```

---

## 🌐 Frontend Configuration

### Web Dashboard (React)
**File**: `gelmath_web/src/services/api.js`
```javascript
const API_URL = 'http://127.0.0.1:8000/api';  // ✅ Already configured
```

**Features**:
- ✅ JWT authentication
- ✅ Token interceptors
- ✅ Role-based routing (MOH_ADMIN / DOCTOR)
- ✅ All API methods defined

### Mobile App (Flutter)
**File**: `cmam_mobile_app/lib/services/api_service.dart`
```dart
static const String baseUrl = 'http://localhost:8000/api';  // Update for device
```

**For iOS Simulator**: `http://localhost:8000`
**For Android Emulator**: `http://10.0.2.2:8000`
**For Physical Device**: `http://YOUR_COMPUTER_IP:8000`

---

## 📊 Data Flow Example

### CHW Assessment Flow:
```
1. CHW opens mobile app
2. Fills assessment form
3. Quality check (Model 2) validates
4. ML prediction (Model 1) recommends pathway
5. POST /api/assessments/ → Backend saves
6. Backend assigns to doctor (if needed)
7. Doctor sees in dashboard
8. MoH sees in analytics
```

### API Call:
```javascript
// Mobile app submits assessment
POST /api/assessments/
{
  "child_id": "CH001",
  "sex": "M",
  "age_months": 24,
  "muac_mm": 110,
  "edema": 0,
  "appetite": "good",
  "danger_signs": 0,
  "recommended_pathway": "OTP",
  "confidence": 0.95,
  "state": "Central Equatoria",
  "chw_name": "John Doe",
  "chw_phone": "+211..."
}
```

---

## 🔐 User Roles & Access

### MOH_ADMIN
- Full dashboard access
- View all analytics
- Manage users and facilities
- Export reports
- Geographic heatmap

### DOCTOR
- View assigned patients
- Manage treatments
- Accept referrals
- Update patient status
- Schedule management

### CHW
- Mobile app only
- Submit assessments
- View history
- Create referrals
- Offline sync

---

## 🎨 Design System (Emerald Medical)

**Colors**:
- Primary: `#0E4D34` (Dark Green)
- Background: `#F4F7F6` (Mint White)
- Cards: `#FFFFFF` (Pure White)
- Accent: `#2ECC71` (Emerald)
- Warning: `#E67E22` (Orange)
- Danger: `#E74C3C` (Red)

**Consistent across**:
- ✅ MoH Dashboard
- ✅ Doctor Dashboard
- ✅ Mobile App
- ✅ Login Pages

---

## 🐛 Troubleshooting

### Backend won't start
```bash
# Check if port 8000 is in use
lsof -i :8000

# Kill process if needed
kill -9 <PID>

# Restart
python3 manage.py runserver
```

### Frontend can't connect
1. Check backend is running: `http://localhost:8000/admin`
2. Check CORS is enabled (already done in settings.py)
3. Check browser console for errors
4. Verify API_URL in `api.js`

### Mobile app can't connect
1. Update baseUrl to correct IP
2. Check firewall allows connections
3. Use `http://` not `https://` for local
4. Test with Postman first

### Login fails
1. Check credentials: admin/admin123
2. Check backend logs for errors
3. Verify JWT tokens in response
4. Check localStorage in browser DevTools

---

## 📝 Next Steps

### Immediate:
1. ✅ Backend running
2. ✅ Frontend configured
3. ⏳ Test login flow
4. ⏳ Test data fetching
5. ⏳ Seed sample data

### Short-term:
1. Create sample users (CHW, Doctor)
2. Create sample facilities
3. Submit test assessments
4. Verify analytics display
5. Test mobile app sync

### Production:
1. Switch to PostgreSQL
2. Configure production settings
3. Set up proper authentication
4. Deploy to cloud servers
5. Configure SSL/HTTPS

---

## 🎯 Testing Checklist

### Backend
- [ ] Server starts without errors
- [ ] Admin panel accessible: http://localhost:8000/admin
- [ ] Login endpoint returns JWT tokens
- [ ] API endpoints return data
- [ ] CORS headers present

### Web Frontend
- [ ] App loads on http://localhost:3000
- [ ] Login page displays
- [ ] Role selection works
- [ ] Login succeeds with admin/admin123
- [ ] Dashboard loads after login
- [ ] Tabs switch correctly
- [ ] Logout works

### Mobile App
- [ ] App builds successfully
- [ ] Login screen displays
- [ ] Assessment form works
- [ ] Quality checks trigger
- [ ] ML predictions work
- [ ] Offline storage works

---

## 📞 Support

**Documentation**: See INTEGRATION_STATUS.md
**Backend**: Django REST Framework docs
**Frontend**: React + Recharts docs
**Mobile**: Flutter docs

---

## 🎉 Success Indicators

✅ Backend server running on port 8000
✅ Web dashboard accessible on port 3000
✅ Login successful with test credentials
✅ JWT tokens stored in localStorage
✅ API calls return data (not 401/403)
✅ Charts and tables display data
✅ Role-based routing works
✅ Mobile app connects to backend

**System is ready for integration testing!** 🚀
