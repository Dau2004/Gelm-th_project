"""
CMAM System Test Suite
Tests the complete 3-step flow: Model 2 → Z-score → Model 1
"""

import requests
import json

API_URL = "http://localhost:8000/api/check-quality/"

# Test cases
TEST_CASES = [
    {
        "name": "TEST 1: Normal SAM case",
        "data": {
            "muac_mm": 114,
            "age_months": 24,
            "sex": "M",
            "edema": 0,
            "appetite": "good",
            "danger_signs": 0
        },
        "expected_status": "OK",
        "description": "Should pass quality check and proceed to OTP"
    },
    {
        "name": "TEST 2: Unit error (11.4mm)",
        "data": {
            "muac_mm": 11.4,
            "age_months": 24,
            "sex": "M",
            "edema": 0,
            "appetite": "good",
            "danger_signs": 0
        },
        "expected_status": "SUSPICIOUS",
        "description": "Should be blocked - unit conversion error"
    },
    {
        "name": "TEST 3: SAM with danger signs",
        "data": {
            "muac_mm": 105,
            "age_months": 18,
            "sex": "F",
            "edema": 0,
            "appetite": "good",
            "danger_signs": 1
        },
        "expected_status": "OK",
        "description": "Should pass and proceed to SC-ITP"
    },
    {
        "name": "TEST 4: MAM case",
        "data": {
            "muac_mm": 120,
            "age_months": 30,
            "sex": "F",
            "edema": 0,
            "appetite": "good",
            "danger_signs": 0
        },
        "expected_status": "OK",
        "description": "Should pass and proceed to TSFP"
    },
    {
        "name": "TEST 5: Age error (240 months)",
        "data": {
            "muac_mm": 114,
            "age_months": 240,
            "sex": "M",
            "edema": 0,
            "appetite": "good",
            "danger_signs": 0
        },
        "expected_status": "SUSPICIOUS",
        "description": "Should be blocked - age out of range"
    },
    {
        "name": "TEST 6: Near threshold (115mm)",
        "data": {
            "muac_mm": 115,
            "age_months": 24,
            "sex": "M",
            "edema": 0,
            "appetite": "good",
            "danger_signs": 0
        },
        "expected_status": "OK",
        "description": "Should pass with warning"
    },
    {
        "name": "TEST 7: SAM with edema",
        "data": {
            "muac_mm": 120,
            "age_months": 24,
            "sex": "M",
            "edema": 1,
            "appetite": "good",
            "danger_signs": 0
        },
        "expected_status": "OK",
        "description": "Should pass and proceed to SC-ITP"
    },
    {
        "name": "TEST 8: Impossible combo",
        "data": {
            "muac_mm": 145,
            "age_months": 24,
            "sex": "M",
            "edema": 3,
            "appetite": "good",
            "danger_signs": 0
        },
        "expected_status": "SUSPICIOUS",
        "description": "Should be blocked - high MUAC with severe edema"
    },
    {
        "name": "TEST 9: Healthy child",
        "data": {
            "muac_mm": 145,
            "age_months": 36,
            "sex": "F",
            "edema": 0,
            "appetite": "good",
            "danger_signs": 0
        },
        "expected_status": "OK",
        "description": "Should pass - no intervention needed"
    },
    {
        "name": "TEST 10: SAM with poor appetite",
        "data": {
            "muac_mm": 110,
            "age_months": 20,
            "sex": "M",
            "edema": 0,
            "appetite": "poor",
            "danger_signs": 0
        },
        "expected_status": "OK",
        "description": "Should pass and proceed to SC-ITP"
    }
]


def run_tests():
    """Run all test cases."""
    print("=" * 70)
    print("CMAM SYSTEM TEST SUITE")
    print("=" * 70)
    print()
    
    passed = 0
    failed = 0
    
    for i, test in enumerate(TEST_CASES, 1):
        print(f"{test['name']}")
        print(f"Description: {test['description']}")
        
        try:
            # Make API request
            response = requests.post(API_URL, json=test['data'], timeout=5)
            result = response.json()
            
            # Check status
            actual_status = result.get('status')
            expected_status = test['expected_status']
            
            if actual_status == expected_status:
                print(f"✓ PASS - Status: {actual_status}")
                passed += 1
            else:
                print(f"✗ FAIL - Expected: {expected_status}, Got: {actual_status}")
                failed += 1
            
            # Show details
            print(f"  Confidence: {result.get('confidence', 'N/A')}")
            print(f"  Flags: {result.get('flags', [])}")
            print(f"  Recommendation: {result.get('recommendation', 'N/A')}")
            
        except requests.exceptions.ConnectionError:
            print(f"✗ FAIL - Cannot connect to API at {API_URL}")
            print("  Make sure the backend server is running:")
            print("  cd cmam_backend && python manage.py runserver")
            failed += 1
        except Exception as e:
            print(f"✗ FAIL - Error: {str(e)}")
            failed += 1
        
        print()
    
    # Summary
    print("=" * 70)
    print("TEST SUMMARY")
    print("=" * 70)
    print(f"Passed: {passed}")
    print(f"Failed: {failed}")
    print()
    
    if failed == 0:
        print("✓ ALL TESTS PASSED!")
        return 0
    else:
        print("✗ SOME TESTS FAILED")
        return 1


if __name__ == "__main__":
    exit(run_tests())
