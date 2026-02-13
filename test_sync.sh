#!/bin/bash

echo "=== Testing Gelmath Data Flow ==="
echo ""

# Login
echo "1. Logging in as admin..."
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}')

TOKEN=$(echo $LOGIN_RESPONSE | python3 -c "import sys, json; print(json.load(sys.stdin)['access'])" 2>/dev/null)

if [ -z "$TOKEN" ]; then
  echo "❌ Login failed"
  exit 1
fi

echo "✅ Login successful"
echo ""

# Check current count
echo "2. Checking current assessment count..."
SUMMARY=$(curl -s http://localhost:8000/api/analytics/national-summary/ \
  -H "Authorization: Bearer $TOKEN")

CURRENT_COUNT=$(echo $SUMMARY | python3 -c "import sys, json; print(json.load(sys.stdin)['total_assessments'])" 2>/dev/null)

echo "Current assessments: $CURRENT_COUNT"
echo ""

# Create new assessment
echo "3. Creating new assessment..."
NEW_ASSESSMENT=$(curl -s -X POST http://localhost:8000/api/assessments/ \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "child_id": "TEST_SYNC_'$(date +%s)'",
    "sex": "M",
    "age_months": 20,
    "muac_mm": 112,
    "edema": 0,
    "appetite": "good",
    "danger_signs": 0,
    "muac_z_score": -1.8,
    "clinical_status": "SAM",
    "recommended_pathway": "OTP",
    "confidence": 0.95,
    "facility": 1,
    "state": "Central Equatoria"
  }')

CHILD_ID=$(echo $NEW_ASSESSMENT | python3 -c "import sys, json; print(json.load(sys.stdin)['child_id'])" 2>/dev/null)

if [ -z "$CHILD_ID" ]; then
  echo "❌ Assessment creation failed"
  exit 1
fi

echo "✅ Assessment created: $CHILD_ID"
echo ""

# Check new count
echo "4. Checking updated assessment count..."
SUMMARY=$(curl -s http://localhost:8000/api/analytics/national-summary/ \
  -H "Authorization: Bearer $TOKEN")

NEW_COUNT=$(echo $SUMMARY | python3 -c "import sys, json; print(json.load(sys.stdin)['total_assessments'])" 2>/dev/null)

echo "New assessments: $NEW_COUNT"
echo ""

if [ "$NEW_COUNT" -gt "$CURRENT_COUNT" ]; then
  echo "✅ SUCCESS! Dashboard will show updated count: $NEW_COUNT"
else
  echo "❌ FAILED! Count did not increase"
fi
