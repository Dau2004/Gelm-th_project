#!/bin/bash

# Gelmäth Backend Quick Start Script

echo "🚀 Starting Gelmäth Backend..."
echo ""

cd gelmath_backend

# Check if virtual environment exists
if [ ! -d ".venv" ]; then
    echo "📦 Creating virtual environment..."
    python3 -m venv .venv
fi

# Activate virtual environment
echo "🔧 Activating virtual environment..."
source .venv/bin/activate

# Install dependencies
echo "📥 Installing dependencies..."
pip install Django==4.2.7 djangorestframework==3.14.0 djangorestframework-simplejwt==5.3.0 django-cors-headers==4.3.1 django-filter

# Run migrations
echo "🗄️  Running migrations..."
python3 manage.py migrate

# Create superuser if doesn't exist
echo "👤 Creating superuser (admin/admin123)..."
python3 manage.py shell << EOF
from accounts.models import User
if not User.objects.filter(username='admin').exists():
    User.objects.create_superuser('admin', 'admin@gelmath.org', 'admin123', role='MOH_ADMIN')
    print('✅ Superuser created')
else:
    print('ℹ️  Superuser already exists')
EOF

echo ""
echo "✅ Backend setup complete!"
echo ""
echo "🌐 Starting Django server on http://localhost:8000"
echo ""
echo "📋 Available endpoints:"
echo "   POST http://localhost:8000/api/auth/login/"
echo "   GET  http://localhost:8000/api/users/"
echo "   GET  http://localhost:8000/api/facilities/"
echo "   GET  http://localhost:8000/api/assessments/"
echo "   GET  http://localhost:8000/api/analytics/national-summary/"
echo ""
echo "🔑 Test credentials:"
echo "   Username: admin"
echo "   Password: admin123"
echo ""

# Start server
python3 manage.py runserver
