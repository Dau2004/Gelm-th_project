#!/bin/bash

# System Integration Test Script
# Tests mobile app → backend → dashboard flow

echo "🔍 MUAC System Integration Test"
echo "================================"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
PASSED=0
FAILED=0

# Function to test endpoint
test_endpoint() {
    local name=$1
    local url=$2
    local expected_code=$3
    
    echo -n "Testing $name... "
    response=$(curl -s -o /dev/null -w "%{http_code}" "$url")
    
    if [ "$response" -eq "$expected_code" ]; then
        echo -e "${GREEN}✓ PASS${NC} (HTTP $response)"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC} (Expected $expected_code, got $response)"
        ((FAILED++))
        return 1
    fi
}

# Function to test with auth
test_auth_endpoint() {
    local name=$1
    local url=$2
    local token=$3
    
    echo -n "Testing $name... "
    response=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: Bearer $token" "$url")
    
    if [ "$response" -eq 200 ]; then
        echo -e "${GREEN}✓ PASS${NC} (HTTP $response)"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC} (HTTP $response)"
        ((FAILED++))
        return 1
    fi
}

echo "1️⃣  Backend Tests (Port 8000)"
echo "------------------------------"

# Test backend is running
test_endpoint "Backend health" "http://localhost:8000/admin/" 302

# Test login endpoint
echo -n "Testing login endpoint... "
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"username":"moh_admin","password":"admin123"}')

if echo "$LOGIN_RESPONSE" | grep -q "access"; then
    echo -e "${GREEN}✓ PASS${NC}"
    ((PASSED++))
    TOKEN=$(echo "$LOGIN_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin)['access'])" 2>/dev/null)
else
    echo -e "${RED}✗ FAIL${NC}"
    ((FAILED++))
    TOKEN=""
fi

# Test authenticated endpoints
if [ -n "$TOKEN" ]; then
    test_auth_endpoint "Users endpoint" "http://localhost:8000/api/users/" "$TOKEN"
    test_auth_endpoint "Facilities endpoint" "http://localhost:8000/api/facilities/" "$TOKEN"
    test_auth_endpoint "Assessments endpoint" "http://localhost:8000/api/assessments/" "$TOKEN"
fi

echo ""
echo "2️⃣  Dashboard Tests (Port 3000)"
echo "--------------------------------"

# Test dashboard is running
test_endpoint "Dashboard accessible" "http://localhost:3000/" 200

echo ""
echo "3️⃣  Database Tests"
echo "------------------"

# Test database
echo -n "Testing database connection... "
if sqlite3 gelmath_backend/db.sqlite3 "SELECT 1;" &>/dev/null; then
    echo -e "${GREEN}✓ PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}✗ FAIL${NC}"
    ((FAILED++))
fi

# Count assessments
echo -n "Checking assessments in DB... "
ASSESSMENT_COUNT=$(sqlite3 gelmath_backend/db.sqlite3 "SELECT COUNT(*) FROM assessments;" 2>/dev/null)
if [ -n "$ASSESSMENT_COUNT" ]; then
    echo -e "${GREEN}✓ PASS${NC} ($ASSESSMENT_COUNT assessments found)"
    ((PASSED++))
else
    echo -e "${RED}✗ FAIL${NC}"
    ((FAILED++))
fi

# Count users
echo -n "Checking users in DB... "
USER_COUNT=$(sqlite3 gelmath_backend/db.sqlite3 "SELECT COUNT(*) FROM users;" 2>/dev/null)
if [ -n "$USER_COUNT" ]; then
    echo -e "${GREEN}✓ PASS${NC} ($USER_COUNT users found)"
    ((PASSED++))
else
    echo -e "${RED}✗ FAIL${NC}"
    ((FAILED++))
fi

echo ""
echo "4️⃣  Mobile App Integration Test"
echo "--------------------------------"

# Test creating assessment via API
echo -n "Testing assessment creation... "
CREATE_RESPONSE=$(curl -s -X POST http://localhost:8000/api/assessments/ \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "child_id": "TEST001",
    "sex": "M",
    "age_months": 24,
    "muac_mm": 110,
    "edema": 0,
    "appetite": "good",
    "danger_signs": 0,
    "clinical_status": "SAM",
    "recommended_pathway": "OTP",
    "confidence": 0.95,
    "chw_name": "Test CHW",
    "chw_phone": "+211123456789"
  }' 2>/dev/null)

if echo "$CREATE_RESPONSE" | grep -q "child_id"; then
    echo -e "${GREEN}✓ PASS${NC}"
    ((PASSED++))
    
    # Verify it's in database
    echo -n "Verifying in database... "
    if sqlite3 gelmath_backend/db.sqlite3 "SELECT child_id FROM assessments WHERE child_id='TEST001';" | grep -q "TEST001"; then
        echo -e "${GREEN}✓ PASS${NC}"
        ((PASSED++))
        
        # Clean up test data
        sqlite3 gelmath_backend/db.sqlite3 "DELETE FROM assessments WHERE child_id='TEST001';" 2>/dev/null
    else
        echo -e "${RED}✗ FAIL${NC}"
        ((FAILED++))
    fi
else
    echo -e "${RED}✗ FAIL${NC}"
    ((FAILED++))
fi

echo ""
echo "5️⃣  System Status"
echo "-----------------"

# Check processes
echo -n "Backend process (port 8000)... "
if lsof -i :8000 | grep -q LISTEN; then
    echo -e "${GREEN}✓ RUNNING${NC}"
    ((PASSED++))
else
    echo -e "${RED}✗ NOT RUNNING${NC}"
    ((FAILED++))
fi

echo -n "Dashboard process (port 3000)... "
if lsof -i :3000 | grep -q LISTEN; then
    echo -e "${GREEN}✓ RUNNING${NC}"
    ((PASSED++))
else
    echo -e "${RED}✗ NOT RUNNING${NC}"
    ((FAILED++))
fi

echo ""
echo "6️⃣  Data Summary"
echo "----------------"

# Show recent assessments
echo "Recent assessments:"
sqlite3 gelmath_backend/db.sqlite3 "SELECT child_id, chw_name, recommended_pathway, substr(timestamp,1,19) as time FROM assessments ORDER BY timestamp DESC LIMIT 3;" 2>/dev/null | while read line; do
    echo "  • $line"
done

echo ""
echo "Available users:"
sqlite3 gelmath_backend/db.sqlite3 "SELECT username, role FROM users LIMIT 5;" 2>/dev/null | while read line; do
    echo "  • $line"
done

echo ""
echo "================================"
echo "📊 Test Results"
echo "================================"
echo -e "Passed: ${GREEN}$PASSED${NC}"
echo -e "Failed: ${RED}$FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ ALL TESTS PASSED!${NC}"
    echo ""
    echo "🎉 System is fully operational!"
    echo ""
    echo "Next steps:"
    echo "1. Open mobile app and login with CHW credentials"
    echo "2. Create an assessment"
    echo "3. Verify it appears at http://localhost:3000"
    echo ""
    exit 0
else
    echo -e "${RED}❌ SOME TESTS FAILED${NC}"
    echo ""
    echo "Please check the failed tests above."
    exit 1
fi
