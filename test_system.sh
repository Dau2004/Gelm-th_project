#!/bin/bash

# CMAM System Test Script
# Tests the complete 3-step flow via backend API

echo "=========================================="
echo "CMAM SYSTEM TEST SUITE"
echo "=========================================="
echo ""

API_URL="http://localhost:8000/api/check-quality/"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
PASS=0
FAIL=0

# Function to test quality check
test_quality() {
    local test_name=$1
    local data=$2
    local expected_status=$3
    
    echo "Testing: $test_name"
    
    response=$(curl -s -X POST $API_URL \
        -H "Content-Type: application/json" \
        -d "$data")
    
    status=$(echo $response | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
    
    if [ "$status" == "$expected_status" ]; then
        echo -e "${GREEN}✓ PASS${NC} - Status: $status"
        ((PASS++))
    else
        echo -e "${RED}✗ FAIL${NC} - Expected: $expected_status, Got: $status"
        ((FAIL++))
    fi
    
    echo "Response: $response"
    echo ""
}

echo "Starting tests..."
echo ""

# TEST 1: Normal measurement (should pass)
test_quality "TEST 1: Normal SAM case" \
    '{"muac_mm": 114, "age_months": 24, "sex": "M", "edema": 0, "appetite": "good", "danger_signs": 0}' \
    "OK"

# TEST 2: Unit error (should block)
test_quality "TEST 2: Unit error (11.4mm)" \
    '{"muac_mm": 11.4, "age_months": 24, "sex": "M", "edema": 0, "appetite": "good", "danger_signs": 0}' \
    "SUSPICIOUS"

# TEST 3: Normal SAM with complications
test_quality "TEST 3: SAM with danger signs" \
    '{"muac_mm": 105, "age_months": 18, "sex": "F", "edema": 0, "appetite": "good", "danger_signs": 1}' \
    "OK"

# TEST 4: MAM case
test_quality "TEST 4: MAM case" \
    '{"muac_mm": 120, "age_months": 30, "sex": "F", "edema": 0, "appetite": "good", "danger_signs": 0}' \
    "OK"

# TEST 5: Age error (should block)
test_quality "TEST 5: Age error (240 months)" \
    '{"muac_mm": 114, "age_months": 240, "sex": "M", "edema": 0, "appetite": "good", "danger_signs": 0}' \
    "SUSPICIOUS"

# TEST 6: Near threshold
test_quality "TEST 6: Near threshold (115mm)" \
    '{"muac_mm": 115, "age_months": 24, "sex": "M", "edema": 0, "appetite": "good", "danger_signs": 0}' \
    "OK"

# TEST 7: SAM with edema
test_quality "TEST 7: SAM with edema" \
    '{"muac_mm": 120, "age_months": 24, "sex": "M", "edema": 1, "appetite": "good", "danger_signs": 0}' \
    "OK"

# TEST 8: Impossible combination (should block)
test_quality "TEST 8: Impossible combo (high MUAC + severe edema)" \
    '{"muac_mm": 145, "age_months": 24, "sex": "M", "edema": 3, "appetite": "good", "danger_signs": 0}' \
    "SUSPICIOUS"

# TEST 9: Healthy child
test_quality "TEST 9: Healthy child" \
    '{"muac_mm": 145, "age_months": 36, "sex": "F", "edema": 0, "appetite": "good", "danger_signs": 0}' \
    "OK"

# TEST 10: SAM with poor appetite
test_quality "TEST 10: SAM with poor appetite" \
    '{"muac_mm": 110, "age_months": 20, "sex": "M", "edema": 0, "appetite": "poor", "danger_signs": 0}' \
    "OK"

# Summary
echo "=========================================="
echo "TEST SUMMARY"
echo "=========================================="
echo -e "${GREEN}Passed: $PASS${NC}"
echo -e "${RED}Failed: $FAIL${NC}"
echo ""

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}✓ ALL TESTS PASSED!${NC}"
    exit 0
else
    echo -e "${RED}✗ SOME TESTS FAILED${NC}"
    exit 1
fi
