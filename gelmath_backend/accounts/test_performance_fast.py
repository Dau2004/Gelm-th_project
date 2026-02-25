"""
FAST PERFORMANCE TESTING - Backend API
Quick performance benchmarks
"""
import time
from django.test import TestCase, Client
from django.contrib.auth import get_user_model
from assessments.models import Assessment
from accounts.models import Facility

User = get_user_model()


class FastPerformanceTests(TestCase):
    """Quick performance benchmarks"""
    
    @classmethod
    def setUpTestData(cls):
        """Setup test data once for all tests"""
        cls.facility = Facility.objects.create(name='Perf Test', state='Central Equatoria')
        cls.user = User.objects.create_user(
            username='perftest',
            password='test123',
            role='CHW',
            facility=cls.facility
        )
        
        # Create 50 test records
        for i in range(50):
            Assessment.objects.create(
                child_id=f'PERF_{i:03d}',
                sex='M' if i % 2 == 0 else 'F',
                age_months=24,
                muac_mm=110,
                edema=0,
                appetite='good',
                danger_signs=0,
                clinical_status='SAM' if i % 3 == 0 else 'MAM',
                facility=cls.facility,
                chw=cls.user
            )
    
    def setUp(self):
        self.client = Client()
        self.client.force_login(self.__class__.user)
    
    def test_list_performance(self):
        """List 50 assessments - should be fast"""
        start = time.time()
        response = self.client.get('/api/assessments/')
        duration = time.time() - start
        
        print(f"\nOK List 50 records: {duration:.3f}s")
        self.assertEqual(response.status_code, 200)
        self.assertLess(duration, 1.0, f"Too slow: {duration:.3f}s")
    
    def test_create_performance(self):
        """Create single assessment"""
        data = {
            'child_id': 'PERF_NEW',
            'sex': 'M',
            'age_months': 24,
            'muac_mm': 110,
            'edema': 0,
            'appetite': 'good',
            'danger_signs': 0
        }
        
        start = time.time()
        response = self.client.post('/api/assessments/', data)
        duration = time.time() - start
        
        print(f"OK Create record: {duration:.3f}s ({duration*1000:.0f}ms)")
        self.assertIn(response.status_code, [200, 201])
        self.assertLess(duration, 1.0, f"Too slow: {duration:.3f}s")
    
    def test_ml_prediction_speed(self):
        """ML prediction with pathway classification"""
        data = {
            'child_id': 'ML_PERF',
            'sex': 'M',
            'age_months': 24,
            'muac_mm': 110,
            'edema': 0,
            'appetite': 'poor',
            'danger_signs': 1
        }
        
        start = time.time()
        response = self.client.post('/api/assessments/', data)
        duration = time.time() - start
        
        print(f"OK ML prediction: {duration:.3f}s ({duration*1000:.0f}ms)")
        self.assertIn(response.status_code, [200, 201])
        self.assertLess(duration, 0.5, f"ML too slow: {duration:.3f}s")
    
    def test_analytics_speed(self):
        """Analytics query performance"""
        start = time.time()
        response = self.client.get('/api/analytics/national-summary/')
        duration = time.time() - start
        
        print(f"OK Analytics: {duration:.3f}s")
        self.assertEqual(response.status_code, 200)
        self.assertLess(duration, 1.0, f"Too slow: {duration:.3f}s")
    
    def test_filter_performance(self):
        """Filtered query performance"""
        start = time.time()
        response = self.client.get('/api/assessments/?clinical_status=SAM')
        duration = time.time() - start
        
        print(f"OK Filter query: {duration:.3f}s")
        self.assertEqual(response.status_code, 200)
        self.assertLess(duration, 1.0, f"Too slow: {duration:.3f}s")
    
    def test_multiple_creates(self):
        """Create 5 records sequentially"""
        start = time.time()
        
        for i in range(5):
            data = {
                'child_id': f'MULTI_{i}',
                'sex': 'M',
                'age_months': 24,
                'muac_mm': 110,
                'edema': 0,
                'appetite': 'good',
                'danger_signs': 0
            }
            response = self.client.post('/api/assessments/', data)
            self.assertIn(response.status_code, [200, 201])
        
        duration = time.time() - start
        avg = duration / 5
        
        print(f"OK 5 creates: {duration:.3f}s (avg: {avg:.3f}s each)")
        self.assertLess(duration, 3.0, f"Bulk too slow: {duration:.3f}s")
    
    def test_performance_summary(self):
        """Print summary"""
        print("\n" + "="*50)
        print("PERFORMANCE BENCHMARKS")
        print("="*50)
        print("Target: All operations < 1s")
        print("ML predictions: < 500ms")
        print("="*50)
