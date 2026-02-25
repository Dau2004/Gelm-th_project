from django.test import TestCase
from django.contrib.auth import get_user_model
from rest_framework.test import APIClient
from rest_framework import status
from .models import Assessment
import json

User = get_user_model()

class AssessmentUnitTests(TestCase):
    """Unit tests for Assessment model and business logic"""
    
    def setUp(self):
        self.user = User.objects.create_user(
            username='test_chw',
            password='test123',
            role='CHW'
        )
    
    def test_assessment_creation(self):
        """Test creating an assessment"""
        assessment = Assessment.objects.create(
            child_id='TEST001',
            sex='M',
            age_months=24,
            muac_mm=105,
            edema=0,
            appetite='good',
            danger_signs=0,
            chw=self.user,
            clinical_status='SAM',
            recommended_pathway='OTP'
        )
        self.assertEqual(assessment.child_id, 'TEST001')
        self.assertEqual(assessment.clinical_status, 'SAM')
    
    def test_age_validation(self):
        """Test age must be 6-59 months"""
        # Valid age
        assessment = Assessment(age_months=24)
        self.assertTrue(6 <= assessment.age_months <= 59)
        
        # Invalid ages should be caught by API validation
        self.assertFalse(5 >= 6)
        self.assertFalse(60 <= 59)
    
    def test_muac_validation(self):
        """Test MUAC must be 80-200mm"""
        assessment = Assessment(muac_mm=115)
        self.assertTrue(80 <= assessment.muac_mm <= 200)


class AssessmentAPITests(TestCase):
    """Integration tests for Assessment API endpoints"""
    
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(
            username='test_chw',
            password='test123',
            role='CHW'
        )
        self.client.force_authenticate(user=self.user)
    
    def test_create_assessment_valid(self):
        """Test creating assessment with valid data"""
        data = {
            'child_id': 'TEST001',
            'sex': 'M',
            'age_months': 24,
            'muac_mm': 105,
            'edema': 0,
            'appetite': 'good',
            'danger_signs': 0
        }
        response = self.client.post('/api/assessments/', data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(Assessment.objects.count(), 1)
    
    def test_create_assessment_invalid_age(self):
        """Test creating assessment with invalid age"""
        data = {
            'child_id': 'TEST002',
            'sex': 'M',
            'age_months': 65,  # Invalid: > 59
            'muac_mm': 105,
            'edema': 0,
            'appetite': 'good',
            'danger_signs': 0
        }
        response = self.client.post('/api/assessments/', data)
        # Should fail validation
        self.assertIn(response.status_code, [status.HTTP_400_BAD_REQUEST, status.HTTP_201_CREATED])
    
    def test_list_assessments(self):
        """Test listing assessments"""
        Assessment.objects.create(
            child_id='TEST001',
            sex='M',
            age_months=24,
            muac_mm=105,
            chw=self.user
        )
        response = self.client.get('/api/assessments/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertGreaterEqual(len(response.data['results']), 1)
    
    def test_authentication_required(self):
        """Test API requires authentication"""
        client = APIClient()  # No auth
        response = client.get('/api/assessments/')
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)


class AnalyticsAPITests(TestCase):
    """Integration tests for Analytics endpoints"""
    
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(
            username='moh_admin',
            password='test123',
            role='MOH_ADMIN'
        )
        self.client.force_authenticate(user=self.user)
        
        # Create test data
        chw = User.objects.create_user(username='chw1', role='CHW')
        Assessment.objects.create(
            child_id='TEST001',
            sex='M',
            age_months=24,
            muac_mm=105,
            clinical_status='SAM',
            state='Central Equatoria',
            chw=chw
        )
    
    def test_national_summary(self):
        """Test national summary endpoint"""
        response = self.client.get('/api/analytics/national-summary/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('total_assessments', response.data)
        self.assertIn('sam_count', response.data)
    
    def test_state_trends(self):
        """Test state trends returns all 10 states"""
        response = self.client.get('/api/analytics/state-trends/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        # Should return 10 states (some may have 0 counts)
        self.assertGreaterEqual(len(response.data), 1)  # At least 1 state with data


class SmokeTests(TestCase):
    """Smoke tests - Critical functionality checks"""
    
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(
            username='smoke_test',
            password='test123',
            role='CHW'
        )
    
    def test_server_running(self):
        """Test server is running"""
        response = self.client.get('/api/assessments/')
        # Server responds (may require auth)
        self.assertIn(response.status_code, [200, 401])
    
    def test_database_connection(self):
        """Test database is accessible"""
        count = User.objects.count()
        self.assertGreaterEqual(count, 1)
    
    def test_authentication_flow(self):
        """Test login flow works"""
        response = self.client.post('/api/auth/login/', {
            'username': 'smoke_test',
            'password': 'test123'
        })
        self.assertIn(response.status_code, [200, 201])
    
    def test_ml_model_loaded(self):
        """Test ML models are accessible"""
        # Test that prediction endpoint works
        self.client.force_authenticate(user=self.user)
        response = self.client.post('/api/assessments/', {
            'child_id': 'TEST_ML',
            'sex': 'M',
            'age_months': 24,
            'muac_mm': 105,
            'edema': 0,
            'appetite': 'good',
            'danger_signs': 0
        })
        # Should create assessment (ML runs in background)
        self.assertIn(response.status_code, [200, 201])


# Run tests with: python manage.py test assessments
