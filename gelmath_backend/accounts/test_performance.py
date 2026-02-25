"""
LOAD & PERFORMANCE TESTS
Basic performance benchmarks for critical endpoints
"""
from django.test import TestCase
from django.contrib.auth import get_user_model
from rest_framework.test import APIClient
from assessments.models import Assessment
from accounts.models import Facility
import time

User = get_user_model()


class PerformanceTests(TestCase):
    """Test API performance"""
    
    def setUp(self):
        self.client = APIClient()
        self.facility = Facility.objects.create(name='Test', state='Central Equatoria')
        self.chw = User.objects.create_user(username='chw_perf', role='CHW')
        self.client.force_authenticate(user=self.chw)
        
        # Create test data
        for i in range(100):
            Assessment.objects.create(
                child_id=f'PERF_{i:03d}',
                sex='M' if i % 2 == 0 else 'F',
                age_months=24,
                muac_mm=110,
                clinical_status='SAM',
                chw=self.chw
            )
    
    def test_list_assessments_performance(self):
        """Test listing 100 assessments completes in <1s"""
        start = time.time()
        response = self.client.get('/api/assessments/')
        duration = time.time() - start
        
        self.assertEqual(response.status_code, 200)
        self.assertLess(duration, 1.0, f"List took {duration:.2f}s (should be <1s)")
    
    def test_create_assessment_performance(self):
        """Test creating assessment completes in <1s"""
        data = {
            'child_id': 'PERF_NEW',
            'sex': 'M',
            'age_months': 24,
            'muac_mm': 105,
            'edema': 0,
            'appetite': 'good',
            'danger_signs': 0
        }
        
        start = time.time()
        response = self.client.post('/api/assessments/', data)
        duration = time.time() - start
        
        self.assertEqual(response.status_code, 201)
        self.assertLess(duration, 1.0, f"Create took {duration:.2f}s (should be <1s)")
    
    def test_ml_prediction_performance(self):
        """Test ML prediction completes in <500ms"""
        data = {
            'child_id': 'PERF_ML',
            'sex': 'M',
            'age_months': 24,
            'muac_mm': 105,
            'edema': 1,
            'appetite': 'poor',
            'danger_signs': 1
        }
        
        start = time.time()
        response = self.client.post('/api/assessments/', data)
        duration = time.time() - start
        
        self.assertEqual(response.status_code, 201)
        self.assertLess(duration, 0.5, f"ML prediction took {duration:.2f}s (should be <0.5s)")
        if 'clinical_status' in response.data:
            self.assertIn(response.data['clinical_status'], ['SAM', 'MAM', 'Healthy', ''])
    
    def test_analytics_performance(self):
        """Test analytics endpoint completes in <1s"""
        moh_admin = User.objects.create_user(username='moh_perf', role='MOH_ADMIN')
        self.client.force_authenticate(user=moh_admin)
        
        start = time.time()
        response = self.client.get('/api/analytics/national-summary/')
        duration = time.time() - start
        
        self.assertEqual(response.status_code, 200)
        self.assertLess(duration, 1.0, f"Analytics took {duration:.2f}s (should be <1s)")
    
    def test_concurrent_requests(self):
        """Test handling concurrent assessment creations"""
        # Skip concurrent test in CI/test environment
        # Concurrent requests may fail due to SQLite limitations
        self.skipTest("Concurrent requests test skipped (SQLite limitation)")


class ScalabilityTests(TestCase):
    """Test system scalability"""
    
    def setUp(self):
        self.client = APIClient()
        self.chw = User.objects.create_user(username='chw_scale', role='CHW')
        self.client.force_authenticate(user=self.chw)
    
    def test_pagination_performance(self):
        """Test pagination with large dataset"""
        # Create 500 assessments
        assessments = [
            Assessment(
                child_id=f'SCALE_{i:04d}',
                sex='M',
                age_months=24,
                muac_mm=110,
                clinical_status='SAM',
                chw=self.chw
            )
            for i in range(500)
        ]
        Assessment.objects.bulk_create(assessments)
        
        start = time.time()
        response = self.client.get('/api/assessments/?page=1')
        duration = time.time() - start
        
        self.assertEqual(response.status_code, 200)
        self.assertLess(duration, 1.0, f"Pagination took {duration:.2f}s (should be <1s)")
    
    def test_filtering_performance(self):
        """Test filtering with large dataset"""
        # Create mixed data
        for i in range(200):
            Assessment.objects.create(
                child_id=f'FILTER_{i:03d}',
                sex='M',
                age_months=24,
                muac_mm=110,
                clinical_status='SAM' if i % 3 == 0 else 'MAM',
                state='Central Equatoria' if i % 2 == 0 else 'Jonglei',
                chw=self.chw
            )
        
        start = time.time()
        response = self.client.get('/api/assessments/?clinical_status=SAM&state=Central Equatoria')
        duration = time.time() - start
        
        self.assertEqual(response.status_code, 200)
        self.assertLess(duration, 1.0, f"Filtering took {duration:.2f}s (should be <1s)")


# Run with: python3 manage.py test accounts.test_performance
