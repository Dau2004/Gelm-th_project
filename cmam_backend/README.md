# CMAM Backend API

Django REST API for CMAM mobile application with ML model integration.

## Features

- RESTful API for assessment data
- SQLite database (easily upgradable to PostgreSQL)
- CORS enabled for mobile app
- Admin dashboard for data management
- Statistics endpoint for monitoring

## Setup

### Prerequisites
- Python 3.8+
- pip
- virtualenv

### Installation

```bash
cd cmam_backend

# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install django djangorestframework django-cors-headers joblib scikit-learn numpy pandas

# Run migrations
python manage.py makemigrations
python manage.py migrate

# Create superuser for admin
python manage.py createsuperuser

# Run development server
python manage.py runserver
```

Server runs at: `http://localhost:8000`

## API Endpoints

### Health Check
```
GET /api/health/
Response: {"status": "healthy", "service": "CMAM API"}
```

### Assessments
```
GET    /api/assessments/          # List all assessments
POST   /api/assessments/          # Create new assessment
GET    /api/assessments/{id}/     # Get specific assessment
PUT    /api/assessments/{id}/     # Update assessment
DELETE /api/assessments/{id}/     # Delete assessment
```

### Statistics
```
GET /api/statistics/
Response: {
  "total_assessments": 150,
  "by_pathway": {
    "SC_ITP": 20,
    "OTP": 50,
    "TSFP": 70,
    "None": 10
  }
}
```

## Data Model

```python
Assessment:
  - child_id: str
  - sex: str (M/F)
  - age_months: int
  - muac_mm: int
  - edema: int (0/1)
  - appetite: str
  - danger_signs: int (0/1)
  - muac_z_score: float
  - clinical_status: str
  - recommended_pathway: str
  - confidence: float
  - timestamp: datetime
  - synced: bool
```

## Admin Dashboard

Access at: `http://localhost:8000/admin`

Features:
- View all assessments
- Filter by pathway, status, sex
- Search by child ID
- Export data

## Production Deployment

### Environment Variables
```bash
export SECRET_KEY='your-secret-key'
export DEBUG=False
export ALLOWED_HOSTS='your-domain.com'
export DATABASE_URL='postgresql://...'
```

### Using PostgreSQL
```python
# settings.py
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'cmam_db',
        'USER': 'cmam_user',
        'PASSWORD': 'password',
        'HOST': 'localhost',
        'PORT': '5432',
    }
}
```

### Using Gunicorn
```bash
pip install gunicorn
gunicorn cmam_project.wsgi:application --bind 0.0.0.0:8000
```

### Using Docker
```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["gunicorn", "cmam_project.wsgi:application", "--bind", "0.0.0.0:8000"]
```

## Testing

```bash
python manage.py test
```

## API Usage Examples

### Create Assessment (cURL)
```bash
curl -X POST http://localhost:8000/api/assessments/ \
  -H "Content-Type: application/json" \
  -d '{
    "child_id": "CH001234",
    "sex": "M",
    "age_months": 24,
    "muac_mm": 105,
    "edema": 0,
    "appetite": "good",
    "danger_signs": 0,
    "muac_z_score": -2.8,
    "clinical_status": "SAM",
    "recommended_pathway": "OTP",
    "confidence": 0.92
  }'
```

### Get All Assessments (Python)
```python
import requests

response = requests.get('http://localhost:8000/api/assessments/')
data = response.json()
print(f"Total: {len(data)}")
```

## Monitoring

### Database Size
```bash
python manage.py dbshell
.databases  # SQLite
SELECT COUNT(*) FROM assessments_assessment;
```

### Logs
```bash
# Development
python manage.py runserver --verbosity 2

# Production
tail -f /var/log/cmam/error.log
```

## Security

- Change SECRET_KEY in production
- Use HTTPS
- Enable authentication for production
- Rate limiting for API endpoints
- Regular database backups

## Next Steps

- [ ] Add user authentication (JWT)
- [ ] Implement role-based access control
- [ ] Add data export (CSV, Excel)
- [ ] Real-time notifications
- [ ] Analytics dashboard
- [ ] Integration with national HMIS

## License

MIT License

## Support

For issues and questions, contact the development team.
