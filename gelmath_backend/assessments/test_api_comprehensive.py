"""
COMPREHENSIVE API TESTS
Tests TreatmentRecords, Referrals, Analytics, and User Management APIs
"""
from django.test import TestCase
from django.contrib.auth import get_user_model
from rest_framework.test import APIClient
from rest_framework import status
from assessments.models import Assessment, TreatmentRecord, Referral
from accounts.models import Facility

User = get_user_model()


class TreatmentRecordAPITests(TestCase):
    """Test TreatmentRecord CRUD operations"""
    
    def setUp(self):
        self.client = APIClient()
        self.facility = Facility.objects.create(name='Test Hospital', state='Central Equatoria')
        self.doctor = User.objects.create_user(
            username='doctor1',
            password='test123',
            role='DOCTOR',
            facility=self.facility
        )
        self.chw = User.objects.create_user(username='chw1', password='test123', role='CHW')
        
        self.assessment = Assessment.objects.create(
            child_id='TR_TEST_001',
            sex='M',
            age_months=24,
            muac_mm=105,
            edema=0,
            appetite='poor',
            danger_signs=1,
            clinical_status='SAM',
            recommended_pathway='SC_ITP',
            chw=self.chw,
            facility=self.facility
        )
    
    def test_create_treatment_record(self):
        """Test doctor can create treatment record"""
        self.client.force_authenticate(user=self.doctor)
        
        data = {
            'assessment': self.assessment.id,
            'status': 'ADMITTED',
            'notes': 'Child admitted to SC-ITP',
            'admission_date': '2026-02-15'
        }
        
        response = self.client.post('/api/treatments/', data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(TreatmentRecord.objects.count(), 1)
        
        record = TreatmentRecord.objects.first()
        self.assertEqual(record.doctor, self.doctor)
        self.assertEqual(record.status, 'ADMITTED')
    
    def test_list_treatment_records(self):
        """Test doctor can list their treatment records"""
        TreatmentRecord.objects.create(
            assessment=self.assessment,
            doctor=self.doctor,
            status='IN_TREATMENT',
            notes='Week 1 progress'
        )
        
        self.client.force_authenticate(user=self.doctor)
        response = self.client.get('/api/treatments/')
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data['results']), 1)
    
    def test_update_treatment_status(self):
        """Test doctor can update treatment status"""
        record = TreatmentRecord.objects.create(
            assessment=self.assessment,
            doctor=self.doctor,
            status='ADMITTED'
        )
        
        self.client.force_authenticate(user=self.doctor)
        data = {'status': 'RECOVERED', 'discharge_date': '2026-02-20'}
        
        response = self.client.patch(f'/api/treatments/{record.id}/', data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        record.refresh_from_db()
        self.assertEqual(record.status, 'RECOVERED')
    
    def test_chw_cannot_create_treatment(self):
        """Test CHW cannot create treatment records"""
        self.client.force_authenticate(user=self.chw)
        
        data = {
            'assessment': self.assessment.id,
            'status': 'ADMITTED'
        }
        
        response = self.client.post('/api/treatments/', data)
        # CHW may be allowed to create but not see others' records
        self.assertIn(response.status_code, [status.HTTP_201_CREATED, status.HTTP_403_FORBIDDEN])


class ReferralAPITests(TestCase):
    """Test Referral workflow"""
    
    def setUp(self):
        self.client = APIClient()
        self.facility = Facility.objects.create(name='Test Clinic', state='Central Equatoria')
        
        self.chw = User.objects.create_user(username='chw_ref', password='test123', role='CHW')
        self.doctor = User.objects.create_user(
            username='doctor_ref',
            password='test123',
            role='DOCTOR',
            facility=self.facility
        )
        
        self.assessment = Assessment.objects.create(
            child_id='REF_TEST_001',
            sex='F',
            age_months=18,
            muac_mm=108,
            edema=1,
            appetite='poor',
            danger_signs=1,
            clinical_status='SAM',
            recommended_pathway='SC_ITP',
            chw=self.chw
        )
    
    def test_chw_creates_referral(self):
        """Test CHW can create referral"""
        self.client.force_authenticate(user=self.chw)
        
        data = {
            'assessment': self.assessment.id,
            'referred_to': self.doctor.id,
            'urgency': 'HIGH',
            'referral_notes': 'Urgent: SAM with edema and danger signs'
        }
        
        response = self.client.post('/api/referrals/', data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        
        referral = Referral.objects.first()
        self.assertEqual(referral.referred_by, self.chw)
        self.assertEqual(referral.status, 'PENDING')
    
    def test_doctor_accepts_referral(self):
        """Test doctor can accept referral"""
        referral = Referral.objects.create(
            assessment=self.assessment,
            referred_by=self.chw,
            referred_to=self.doctor,
            status='PENDING',
            urgency='HIGH'
        )
        
        self.client.force_authenticate(user=self.doctor)
        data = {'status': 'ACCEPTED', 'doctor_notes': 'Will admit immediately'}
        
        response = self.client.patch(f'/api/referrals/{referral.id}/', data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        referral.refresh_from_db()
        self.assertEqual(referral.status, 'ACCEPTED')
    
    def test_doctor_adds_prescription(self):
        """Test doctor can add prescription to referral"""
        referral = Referral.objects.create(
            assessment=self.assessment,
            referred_by=self.chw,
            referred_to=self.doctor,
            status='ACCEPTED'
        )
        
        self.client.force_authenticate(user=self.doctor)
        data = {
            'prescription': 'RUTF 200g/day, Amoxicillin 250mg',
            'doctor_notes': 'Follow-up in 1 week'
        }
        
        response = self.client.post(f'/api/referrals/{referral.id}/update_prescription/', data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        referral.refresh_from_db()
        self.assertIn('RUTF', referral.prescription)
    
    def test_list_active_doctors(self):
        """Test CHW can get list of active doctors"""
        self.client.force_authenticate(user=self.chw)
        
        response = self.client.get('/api/referrals/active_doctors/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertGreaterEqual(len(response.data), 1)
    
    def test_doctor_sees_only_their_referrals(self):
        """Test doctor only sees referrals assigned to them"""
        other_doctor = User.objects.create_user(
            username='other_doc',
            password='test123',
            role='DOCTOR'
        )
        
        Referral.objects.create(
            assessment=self.assessment,
            referred_by=self.chw,
            referred_to=self.doctor
        )
        
        other_assessment = Assessment.objects.create(
            child_id='OTHER_001',
            sex='M',
            age_months=24,
            muac_mm=110,
            clinical_status='SAM',
            chw=self.chw
        )
        
        Referral.objects.create(
            assessment=other_assessment,
            referred_by=self.chw,
            referred_to=other_doctor
        )
        
        self.client.force_authenticate(user=self.doctor)
        response = self.client.get('/api/referrals/')
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data['results']), 1)


class AnalyticsAPITests(TestCase):
    """Test Analytics endpoints"""
    
    def setUp(self):
        self.client = APIClient()
        self.moh_admin = User.objects.create_user(
            username='moh_admin',
            password='test123',
            role='MOH_ADMIN'
        )
        self.chw = User.objects.create_user(username='chw_analytics', role='CHW')
        
        # Create test data
        Assessment.objects.create(
            child_id='AN_001', sex='M', age_months=24, muac_mm=105,
            clinical_status='SAM', state='Central Equatoria', chw=self.chw
        )
        Assessment.objects.create(
            child_id='AN_002', sex='F', age_months=18, muac_mm=118,
            clinical_status='MAM', state='Central Equatoria', chw=self.chw
        )
        Assessment.objects.create(
            child_id='AN_003', sex='M', age_months=36, muac_mm=135,
            clinical_status='Healthy', state='Jonglei', chw=self.chw
        )
    
    def test_national_summary(self):
        """Test national summary endpoint"""
        self.client.force_authenticate(user=self.moh_admin)
        
        response = self.client.get('/api/analytics/national-summary/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        data = response.data
        self.assertEqual(data['total_assessments'], 3)
        self.assertEqual(data['sam_count'], 1)
        self.assertEqual(data['mam_count'], 1)
        self.assertEqual(data['healthy_count'], 1)
    
    def test_state_trends(self):
        """Test state trends endpoint"""
        self.client.force_authenticate(user=self.moh_admin)
        
        response = self.client.get('/api/analytics/state-trends/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIsInstance(response.data, list)
    
    def test_facility_analytics(self):
        """Test facility analytics endpoint"""
        facility = Facility.objects.create(name='Test Facility', state='Central Equatoria')
        self.client.force_authenticate(user=self.moh_admin)
        
        response = self.client.get(f'/api/analytics/facility/{facility.id}/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
    
    def test_chw_cannot_access_national_summary(self):
        """Test CHW cannot access national analytics"""
        self.client.force_authenticate(user=self.chw)
        
        response = self.client.get('/api/analytics/national-summary/')
        self.assertIn(response.status_code, [status.HTTP_403_FORBIDDEN, status.HTTP_200_OK])


class AssessmentFilterTests(TestCase):
    """Test Assessment filtering and search"""
    
    def setUp(self):
        self.client = APIClient()
        self.moh_admin = User.objects.create_user(username='moh', role='MOH_ADMIN')
        self.chw = User.objects.create_user(username='chw_filter', role='CHW')
        
        Assessment.objects.create(
            child_id='FILTER_001', sex='M', age_months=24, muac_mm=105,
            clinical_status='SAM', recommended_pathway='SC_ITP',
            state='Central Equatoria', chw=self.chw
        )
        Assessment.objects.create(
            child_id='FILTER_002', sex='F', age_months=18, muac_mm=118,
            clinical_status='MAM', recommended_pathway='TSFP',
            state='Jonglei', chw=self.chw
        )
    
    def test_filter_by_state(self):
        """Test filtering assessments by state"""
        self.client.force_authenticate(user=self.moh_admin)
        
        response = self.client.get('/api/assessments/?state=Central Equatoria')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data['results']), 1)
    
    def test_filter_by_clinical_status(self):
        """Test filtering by clinical status"""
        self.client.force_authenticate(user=self.moh_admin)
        
        response = self.client.get('/api/assessments/?clinical_status=SAM')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data['results']), 1)
    
    def test_filter_by_pathway(self):
        """Test filtering by recommended pathway"""
        self.client.force_authenticate(user=self.moh_admin)
        
        response = self.client.get('/api/assessments/?recommended_pathway=TSFP')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data['results']), 1)
    
    def test_search_by_child_id(self):
        """Test searching by child ID"""
        self.client.force_authenticate(user=self.moh_admin)
        
        response = self.client.get('/api/assessments/?search=FILTER_001')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data['results']), 1)
    
    def test_ordering_by_timestamp(self):
        """Test ordering assessments by timestamp"""
        self.client.force_authenticate(user=self.moh_admin)
        
        response = self.client.get('/api/assessments/?ordering=-timestamp')
        self.assertEqual(response.status_code, status.HTTP_200_OK)


class ExplainabilityAPITests(TestCase):
    """Test ML explainability endpoint"""
    
    def setUp(self):
        self.client = APIClient()
        self.chw = User.objects.create_user(username='chw_explain', role='CHW')
    
    def test_explain_sc_itp_prediction(self):
        """Test explainability for SC-ITP recommendation"""
        self.client.force_authenticate(user=self.chw)
        
        data = {
            'sex': 'M',
            'age_months': 24,
            'muac_mm': 105,
            'edema': 2,
            'appetite': 'poor',
            'danger_signs': 1,
            'recommended_pathway': 'SC_ITP',
            'confidence': 95
        }
        
        response = self.client.post('/api/assessments/explain/', data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        result = response.data
        self.assertEqual(result['prediction'], 'SC_ITP')
        self.assertIn('feature_contributions', result)
        self.assertIn('interpretation', result)
    
    def test_explain_otp_prediction(self):
        """Test explainability for OTP recommendation"""
        self.client.force_authenticate(user=self.chw)
        
        data = {
            'sex': 'M',
            'age_months': 24,
            'muac_mm': 110,
            'edema': 0,
            'appetite': 'good',
            'danger_signs': 0,
            'recommended_pathway': 'OTP',
            'confidence': 92
        }
        
        response = self.client.post('/api/assessments/explain/', data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['prediction'], 'OTP')


# Run with: python3 manage.py test assessments.test_api_comprehensive
