# Gelmäth Backend API

Django REST API for the Gelmäth CMAM system.

## Setup

```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
python manage.py migrate
python manage.py shell < seed_data.py
python manage.py runserver
```

## API Endpoints

### Authentication
- `POST /api/auth/login/` - Login (get JWT tokens)
- `POST /api/auth/refresh/` - Refresh access token

### Users
- `GET /api/users/` - List users (filtered by role)
- `POST /api/users/` - Create user (MoH Admin only)
- `GET /api/users/me/` - Get current user
- `POST /api/users/{id}/change_password/` - Change password
- `POST /api/users/{id}/deactivate/` - Deactivate user (MoH Admin only)

### Facilities
- `GET /api/facilities/` - List facilities
- `POST /api/facilities/` - Create facility (MoH Admin only)
- `GET /api/facilities/{id}/` - Get facility details

### Assessments
- `GET /api/assessments/` - List assessments (filtered by role)
- `POST /api/assessments/` - Create assessment (CHW)
- `GET /api/assessments/{id}/` - Get assessment details

### Treatment Records
- `GET /api/treatments/` - List treatments (Doctor/MoH)
- `POST /api/treatments/` - Create treatment record (Doctor)

### Analytics
- `GET /api/analytics/national-summary/` - National statistics
- `GET /api/analytics/state-trends/` - State-level breakdown
- `GET /api/analytics/time-series/?period=daily` - Time series data
- `GET /api/analytics/facility/{id}/` - Facility statistics

## Default Credentials

- **MoH Admin**: `moh_admin` / `admin123`
- **Doctor**: `dr_john` / `doctor123`
- **CHW**: `chw_james` / `chw123`

## Testing with cURL

```bash
# Login
curl -X POST http://localhost:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"username":"moh_admin","password":"admin123"}'

# Get national summary (use token from login)
curl http://localhost:8000/api/analytics/national-summary/ \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

## Role-Based Access

- **MOH_ADMIN**: Full access to all data and user management
- **DOCTOR**: Access to facility-specific patients and treatments
- **CHW**: Access to own assessments only, mobile app access
