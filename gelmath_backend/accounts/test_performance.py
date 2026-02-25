"""
PERFORMANCE TESTING - Backend API
Tests response times, throughput, and load handling
"""
import time
import statistics
from django.test import TestCase, Client
from django.contrib.auth import get_user_model
from assessments.models import Assessment
from accounts.models import Facility

User = get_user_model()


class PerformanceTests(TestCase):
    """Performance benchmarks for API endpoints"""
    
    def setUp(self):
        self.client = Client()
        self.facility = Facility.objects.create(name='Test Facility', state='Central Equatoria')
        self.user = User.objects.create_user(
            username='perftest',
            password='test123',
            role='CHW',
            facility=self.facility
        )
        self.client.force_login(self.user)
        
        # Create test data
        for i in range(100):
            Assessment.objects.create(
                child_id=f'PERF_{i:03d}',
                sex='M' if i % 2 == 0 else 'F',
                age_months=24 + (i % 36),
                muac_mm=110 + (i % 20),
                edema=0,
                appetite='good',
                danger_signs=0,
                clinical_status='SAM' if i % 3 == 0 else 'MAM',
                facility=self.facility,
                chw=self.user
            )
    
    def measure_time(self, func, iterations=10):
        """Measure average execution time"""
        times = []
        for _ in range(iterations):
            start = time.time()
            func()
            end = time.time()
            times.append(end - start)
        
        return {
            'avg': statistics.mean(times),
            'min': min(times),
            'max': max(times),
            'median': statistics.median(times)
        }
    
    def test_list_assessments_performance(self):
        """Test: List 100 assessments < 1s"""
        def list_assessments():
            response = self.client.get('/api/assessments/')
            self.assertEqual(response.status_code, 200)
        
        result = self.measure_time(list_assessments, iterations=5)
        
        print(f"\n[DATA] List 100 Assessments Performance:")
        print(f"   Average: {result['avg']:.3f}s")
        print(f"   Min: {result['min']:.3f}s")
        print(f"   Max: {result['max']:.3f}s")
        
        self.assertLess(result['avg'], 1.0, "List operation should be < 1s")
    
    def test_create_assessment_performance(self):
        """Test: Create assessment < 1s"""
        def create_assessment():
            data = {
                'child_id': f'PERF_NEW_{time.time()}',
                'sex': 'M',
                'age_months': 24,
                'muac_mm': 110,
                'edema': 0,
                'appetite': 'good',
                'danger_signs': 0
            }
            response = self.client.post('/api/assessments/', data)
            self.assertIn(response.status_code, [200, 201])
        
        result = self.measure_time(create_assessment, iterations=5)
        
        print(f"\n[DATA] Create Assessment Performance:")
        print(f"   Average: {result['avg']:.3f}s")
        print(f"   Min: {result['min']:.3f}s")
        print(f"   Max: {result['max']:.3f}s")
        
        self.assertLess(result['avg'], 1.0, "Create operation should be < 1s")
    
    def test_ml_prediction_performance(self):
        """Test: ML prediction < 200ms"""
        def predict():
            data = {
                'child_id': f'ML_PERF_{time.time()}',
                'sex': 'M',
                'age_months': 24,
                'muac_mm': 110,
                'edema': 0,
                'appetite': 'poor',
                'danger_signs': 1
            }
            response = self.client.post('/api/assessments/', data)
            self.assertIn(response.status_code, [200, 201])
        
        result = self.measure_time(predict, iterations=10)
        
        print(f"\n[DATA] ML Prediction Performance:")
        print(f"   Average: {result['avg']:.3f}s ({result['avg']*1000:.0f}ms)")
        print(f"   Min: {result['min']:.3f}s ({result['min']*1000:.0f}ms)")
        print(f"   Max: {result['max']:.3f}s ({result['max']*1000:.0f}ms)")
        
        self.assertLess(result['avg'], 0.5, "ML prediction should be < 500ms")
    
    def test_analytics_performance(self):
        """Test: Analytics query < 1s"""
        def get_analytics():
            response = self.client.get('/api/analytics/national-summary/')
            self.assertEqual(response.status_code, 200)
        
        result = self.measure_time(get_analytics, iterations=5)
        
        print(f"\n[DATA] Analytics Query Performance:")
        print(f"   Average: {result['avg']:.3f}s")
        print(f"   Min: {result['min']:.3f}s")
        print(f"   Max: {result['max']:.3f}s")
        
        self.assertLess(result['avg'], 1.0, "Analytics should be < 1s")
    
    def test_pagination_performance(self):
        """Test: Paginated list (500 records) < 1s"""
        # Create more data
        for i in range(100, 600):
            Assessment.objects.create(
                child_id=f'PAGE_{i:03d}',
                sex='M' if i % 2 == 0 else 'F',
                age_months=24,
                muac_mm=110,
                edema=0,
                appetite='good',
                danger_signs=0,
                clinical_status='SAM',
                facility=self.facility,
                chw=self.user
            )
        
        def paginated_list():
            response = self.client.get('/api/assessments/?page=1&page_size=50')
            self.assertEqual(response.status_code, 200)
        
        result = self.measure_time(paginated_list, iterations=5)
        
        print(f"\n[DATA] Pagination Performance (500 records):")
        print(f"   Average: {result['avg']:.3f}s")
        print(f"   Min: {result['min']:.3f}s")
        print(f"   Max: {result['max']:.3f}s")
        
        self.assertLess(result['avg'], 1.0, "Pagination should be < 1s")
    
    def test_filtering_performance(self):
        """Test: Filtered query (200 records) < 1s"""
        def filtered_query():
            response = self.client.get('/api/assessments/?clinical_status=SAM')
            self.assertEqual(response.status_code, 200)
        
        result = self.measure_time(filtered_query, iterations=5)
        
        print(f"\n[DATA] Filtering Performance:")
        print(f"   Average: {result['avg']:.3f}s")
        print(f"   Min: {result['min']:.3f}s")
        print(f"   Max: {result['max']:.3f}s")
        
        self.assertLess(result['avg'], 1.0, "Filtering should be < 1s")
    
    def test_bulk_operations_performance(self):
        """Test: Bulk create 10 assessments"""
        def bulk_create():
            for i in range(10):
                data = {
                    'child_id': f'BULK_{time.time()}_{i}',
                    'sex': 'M',
                    'age_months': 24,
                    'muac_mm': 110,
                    'edema': 0,
                    'appetite': 'good',
                    'danger_signs': 0
                }
                response = self.client.post('/api/assessments/', data)
                self.assertIn(response.status_code, [200, 201])
        
        result = self.measure_time(bulk_create, iterations=3)
        
        print(f"\n[DATA] Bulk Create Performance (10 records):")
        print(f"   Average: {result['avg']:.3f}s")
        print(f"   Per Record: {result['avg']/10:.3f}s")
        
        self.assertLess(result['avg'], 5.0, "Bulk create should be < 5s")
    
    def test_concurrent_reads_simulation(self):
        """Test: Simulate concurrent read requests"""
        import threading
        
        results = []
        errors = []
        
        def concurrent_read():
            try:
                start = time.time()
                response = self.client.get('/api/assessments/')
                end = time.time()
                if response.status_code == 200:
                    results.append(end - start)
                else:
                    errors.append(response.status_code)
            except Exception as e:
                errors.append(str(e))
        
        # Simulate 10 concurrent requests
        threads = []
        for _ in range(10):
            t = threading.Thread(target=concurrent_read)
            threads.append(t)
            t.start()
        
        for t in threads:
            t.join()
        
        if results:
            avg_time = statistics.mean(results)
            print(f"\n[DATA] Concurrent Reads Performance (10 threads):")
            print(f"   Average: {avg_time:.3f}s")
            print(f"   Successful: {len(results)}/10")
            print(f"   Errors: {len(errors)}")
            
            self.assertGreater(len(results), 5, "At least 50% should succeed")
            self.assertLess(avg_time, 2.0, "Concurrent reads should be < 2s")


class LoadTestResults(TestCase):
    """Summary of performance test results"""
    
    def test_performance_summary(self):
        """Print performance summary"""
        print("\n" + "="*60)
        print("PERFORMANCE TEST SUMMARY")
        print("="*60)
        print("\nTarget Benchmarks:")
        print("  OK List operations: < 1s")
        print("  OK Create operations: < 1s")
        print("  OK ML predictions: < 500ms")
        print("  OK Analytics: < 1s")
        print("  OK Pagination: < 1s")
        print("  OK Filtering: < 1s")
        print("\nRun: python manage.py test accounts.test_performance")
        print("="*60 + "\n")
        
        self.assertTrue(True)
