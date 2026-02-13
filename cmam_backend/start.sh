#!/bin/bash

PORT=${1:-8001}

echo "🚀 Starting CMAM Backend Server on port $PORT..."
echo ""

cd "$(dirname "$0")"

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "📦 Creating virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
source venv/bin/activate

# Install dependencies
echo "📥 Installing dependencies..."
pip install -q -r requirements.txt

# Run migrations
echo "🗄️  Running database migrations..."
python manage.py migrate --no-input

# Check if superuser exists, if not prompt to create
echo ""
echo "👤 Admin user setup:"
python manage.py shell -c "from django.contrib.auth import get_user_model; User = get_user_model(); print('Admin exists' if User.objects.filter(is_superuser=True).exists() else 'No admin user found')"

echo ""
echo "✅ Backend ready!"
echo ""
echo "📍 Server: http://localhost:$PORT"
echo "📍 Admin: http://localhost:$PORT/admin"
echo "📍 API: http://localhost:$PORT/api/"
echo ""
echo "To create admin user: python manage.py createsuperuser"
echo ""

# Start server
python manage.py runserver $PORT
