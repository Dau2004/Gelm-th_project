# 🧪 TEST EXECUTION GUIDE - Gelmëth CMAM System

## Overview
This document provides instructions for running unit, integration, and smoke tests across all system components.

---

## 1. BACKEND TESTS (Django)

### Setup
```bash
cd gelmath_backend
source venv/bin/activate  # or venv\Scripts\activate on Windows
```

### Run All Tests
```bash
python manage.py test
```

### Run Specific Test Suites
```bash
# Unit tests only
python manage.py test assessments.tests.AssessmentUnitTests

# Integration tests only
python manage.py test assessments.tests.AssessmentAPITests

# Smoke tests only
python manage.py test assessments.tests.SmokeTests

# Analytics tests
python manage.py test assessments.tests.AnalyticsAPITests
```

### Run with Coverage
```bash
pip install coverage
coverage run --source='.' manage.py test
coverage report
coverage html  # Generate HTML report
```

### Expected Results
```
Test Suite                    | Tests | Pass | Fail | Expected Pass Rate
------------------------------|-------|------|------|-------------------
AssessmentUnitTests           |   3   |  3   |  0   | 100%
AssessmentAPITests            |   4   |  4   |  0   | 100%
AnalyticsAPITests             |   2   |  2   |  0   | 100%
SmokeTests                    |   4   |  4   |  0   | 100%
------------------------------|-------|------|------|-------------------
TOTAL                         |  13   |  13  |  0   | 100%
```

---

## 2. MOBILE APP TESTS (Flutter)

### Setup
```bash
cd cmam_mobile_app
flutter pub get
```

### Run All Tests
```bash
flutter test
```

### Run Specific Test Groups
```bash
# Unit tests only
flutter test test/unit_test.dart

# Widget tests (if created)
flutter test test/widget_test.dart

# Integration tests (if created)
flutter test integration_test/
```

### Run with Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html  # View in browser
```

### Expected Results
```
Test Group                    | Tests | Pass | Fail | Expected Pass Rate
------------------------------|-------|------|------|-------------------
Z-Score Service               |   3   |  3   |  0   | 100%
Prediction Service            |   4   |  4   |  0   | 100%
Quality Check Service         |   3   |  3   |  0   | 100%
ID Generator                  |   2   |  2   |  0   | 100%
Child Assessment Model        |   2   |  2   |  0   | 100%
Integration Tests             |   1   |  1   |  0   | 100%
Smoke Tests                   |   3   |  3   |  0   | 100%
------------------------------|-------|------|------|-------------------
TOTAL                         |  18   |  18  |  0   | 100%
```

---

## 3. WEB DASHBOARD TESTS (React)

### Setup
```bash
cd gelmath_web
npm install
```

### Run Tests
```bash
# Run all tests
npm test

# Run with coverage
npm test -- --coverage

# Run in watch mode
npm test -- --watch
```

### Create Basic Test File
Create `src/services/api.test.js`:
```javascript
import { getNationalSummary, getStateTrends } from './api';

describe('API Service Tests', () => {
  test('getNationalSummary returns data', async () => {
    const response = await getNationalSummary();
    expect(response.data).toBeDefined();
    expect(response.data.total_assessments).toBeGreaterThanOrEqual(0);
  });

  test('getStateTrends returns 10 states', async () => {
    const response = await getStateTrends();
    expect(response.data).toHaveLength(10);
  });
});
```

---

## 4. SMOKE TESTING CHECKLIST

### Critical Path Testing (Manual)

#### Backend Smoke Test
- [ ] Server starts without errors
- [ ] Database connection works
- [ ] Admin panel accessible
- [ ] API endpoints respond
- [ ] ML models load successfully

#### Mobile App Smoke Test
- [ ] App launches without crash
- [ ] Login screen appears
- [ ] Can create assessment
- [ ] ML prediction works
- [ ] Data saves to SQLite
- [ ] History screen loads

#### Web Dashboard Smoke Test
- [ ] Dashboard loads
- [ ] Login works
- [ ] Charts render
- [ ] All 10 states display
- [ ] Export PDF works
- [ ] User management works

---

## 5. TEST RESULTS TEMPLATE

### Backend Test Results

**Date:** _______________  
**Tester:** _______________  
**Environment:** Development / Staging / Production

| Test Suite | Total | Passed | Failed | Pass Rate | Notes |
|------------|-------|--------|--------|-----------|-------|
| Unit Tests | 3 | ___ | ___ | ___% | |
| API Tests | 4 | ___ | ___ | ___% | |
| Analytics | 2 | ___ | ___ | ___% | |
| Smoke Tests | 4 | ___ | ___ | ___% | |
| **TOTAL** | **13** | **___** | **___** | **___%** | |

**Failed Tests:**
1. _____________________
2. _____________________

**Issues Found:**
- _____________________
- _____________________

---

### Mobile App Test Results

**Date:** _______________  
**Device:** _______________  
**OS Version:** _______________

| Test Group | Total | Passed | Failed | Pass Rate | Notes |
|------------|-------|--------|--------|-----------|-------|
| Z-Score | 3 | ___ | ___ | ___% | |
| Prediction | 4 | ___ | ___ | ___% | |
| Quality Check | 3 | ___ | ___ | ___% | |
| ID Generator | 2 | ___ | ___ | ___% | |
| Model | 2 | ___ | ___ | ___% | |
| Integration | 1 | ___ | ___ | ___% | |
| Smoke | 3 | ___ | ___ | ___% | |
| **TOTAL** | **18** | **___** | **___** | **___%** | |

**Failed Tests:**
1. _____________________
2. _____________________

---

### Smoke Test Results

**Date:** _______________  
**Build Version:** _______________

| Component | Status | Response Time | Notes |
|-----------|--------|---------------|-------|
| Backend Server | ⬜ PASS / ⬜ FAIL | ___ms | |
| Database | ⬜ PASS / ⬜ FAIL | ___ms | |
| ML Model 1 | ⬜ PASS / ⬜ FAIL | ___ms | |
| ML Model 2 | ⬜ PASS / ⬜ FAIL | ___ms | |
| Mobile App Launch | ⬜ PASS / ⬜ FAIL | ___s | |
| Assessment Flow | ⬜ PASS / ⬜ FAIL | ___s | |
| Web Dashboard | ⬜ PASS / ⬜ FAIL | ___s | |
| API Endpoints | ⬜ PASS / ⬜ FAIL | ___ms | |

**Critical Issues:** _____________________

---

## 6. CONTINUOUS INTEGRATION (CI/CD)

### GitHub Actions Workflow (Optional)

Create `.github/workflows/tests.yml`:
```yaml
name: Run Tests

on: [push, pull_request]

jobs:
  backend-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Set up Python
        uses: actions/setup-python@v2
        with:
          python-version: 3.13
      - name: Install dependencies
        run: |
          cd gelmath_backend
          pip install -r requirements.txt
      - name: Run tests
        run: |
          cd gelmath_backend
          python manage.py test

  mobile-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.0.0'
      - name: Run tests
        run: |
          cd cmam_mobile_app
          flutter test
```

---

## 7. PERFORMANCE BENCHMARKS

### Expected Performance Metrics

| Operation | Target | Acceptable | Unacceptable |
|-----------|--------|------------|--------------|
| ML Prediction | <500ms | <1s | >2s |
| API Response | <200ms | <500ms | >1s |
| App Launch | <2s | <3s | >5s |
| Dashboard Load | <1s | <2s | >3s |
| Database Query | <100ms | <300ms | >500ms |

---

## 8. TEST COVERAGE GOALS

| Component | Current | Target | Status |
|-----------|---------|--------|--------|
| Backend Models | ___% | 80% | ⬜ |
| Backend Views | ___% | 70% | ⬜ |
| Mobile Services | ___% | 80% | ⬜ |
| Mobile Screens | ___% | 60% | ⬜ |
| Web Components | ___% | 70% | ⬜ |
| **Overall** | **___%** | **75%** | ⬜ |

---

## 9. BUG TRACKING

### Bug Report Template

**Bug ID:** BUG-___  
**Severity:** ⬜ Critical ⬜ High ⬜ Medium ⬜ Low  
**Component:** Backend / Mobile / Web  
**Test:** _____________________  
**Description:** _____________________  
**Steps to Reproduce:**
1. _____________________
2. _____________________

**Expected:** _____________________  
**Actual:** _____________________  
**Fix Status:** ⬜ Open ⬜ In Progress ⬜ Fixed ⬜ Verified

---

## 10. SIGN-OFF

### Test Completion Checklist

- [ ] All unit tests executed
- [ ] All integration tests executed
- [ ] All smoke tests executed
- [ ] Test results documented
- [ ] Bugs reported and tracked
- [ ] Coverage goals met
- [ ] Performance benchmarks met
- [ ] Critical issues resolved

**Tested By:** _____________________  
**Date:** _____________________  
**Signature:** _____________________  

**Approved By:** _____________________  
**Date:** _____________________  
**Signature:** _____________________  

---

**Next Steps:**
1. Run all tests and document results
2. Fix any failing tests
3. Achieve 75%+ code coverage
4. Conduct user acceptance testing (UAT)
5. Prepare for deployment
