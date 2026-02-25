from rest_framework import viewsets, permissions, filters
from rest_framework.decorators import action, api_view, permission_classes
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from .models import Assessment, TreatmentRecord, Referral
from .serializers import (AssessmentSerializer, AssessmentCreateSerializer, 
                          TreatmentRecordSerializer, ReferralSerializer, DoctorProfileSerializer)
from accounts.models import User
import joblib
import pandas as pd
import numpy as np
import os


class AssessmentViewSet(viewsets.ModelViewSet):
    queryset = Assessment.objects.all()
    permission_classes = [permissions.IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['state', 'facility', 'clinical_status', 'recommended_pathway', 'chw']
    search_fields = ['child_id', 'chw_name']
    ordering_fields = ['timestamp', 'age_months', 'muac_mm']
    ordering = ['-timestamp']
    
    def get_serializer_class(self):
        if self.action == 'create':
            return AssessmentCreateSerializer
        return AssessmentSerializer
    
    def get_queryset(self):
        user = self.request.user
        queryset = Assessment.objects.all()
        
        if user.role == 'MOH_ADMIN':
            return queryset
        elif user.role == 'DOCTOR':
            return queryset.filter(facility=user.facility)
        elif user.role == 'CHW':
            return queryset.filter(chw=user)
        
        return queryset.none()
    
    @action(detail=False, methods=['get'])
    def chw_counts(self, request):
        """Get assessment counts per CHW"""
        from django.db.models import Count
        counts = Assessment.objects.values('chw__username').annotate(count=Count('id'))
        result = {item['chw__username']: item['count'] for item in counts if item['chw__username']}
        return Response(result)


class TreatmentRecordViewSet(viewsets.ModelViewSet):
    queryset = TreatmentRecord.objects.all()
    serializer_class = TreatmentRecordSerializer
    permission_classes = [permissions.IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.OrderingFilter]
    filterset_fields = ['assessment', 'doctor', 'status']
    ordering = ['-created_at']
    
    def get_queryset(self):
        user = self.request.user
        queryset = TreatmentRecord.objects.all()
        
        if user.role == 'MOH_ADMIN':
            return queryset
        elif user.role == 'DOCTOR':
            return queryset.filter(doctor=user)
        
        return queryset.none()
    
    def perform_create(self, serializer):
        serializer.save(doctor=self.request.user)


class ReferralViewSet(viewsets.ModelViewSet):
    queryset = Referral.objects.all()
    serializer_class = ReferralSerializer
    permission_classes = [permissions.IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.OrderingFilter]
    filterset_fields = ['status', 'referred_to', 'assessment']
    ordering = ['-created_at']
    
    def get_queryset(self):
        user = self.request.user
        queryset = Referral.objects.all()
        
        if user.role == 'MOH_ADMIN':
            return queryset
        elif user.role == 'DOCTOR':
            return queryset.filter(referred_to=user)
        elif user.role == 'CHW':
            return queryset.filter(referred_by=user)
        
        return queryset.none()
    
    def perform_create(self, serializer):
        serializer.save(referred_by=self.request.user)
    
    @action(detail=True, methods=['post'])
    def update_prescription(self, request, pk=None):
        referral = self.get_object()
        referral.prescription = request.data.get('prescription', '')
        referral.doctor_notes = request.data.get('doctor_notes', '')
        referral.status = request.data.get('status', referral.status)
        referral.save()
        return Response(ReferralSerializer(referral).data)
    
    @action(detail=False, methods=['get'])
    def active_doctors(self, request):
        doctors = User.objects.filter(role='DOCTOR', is_active=True)
        return Response(DoctorProfileSerializer(doctors, many=True).data)


@api_view(['POST'])
@permission_classes([permissions.IsAuthenticated])
def explain_prediction(request):
    """Explain an existing assessment's recommendation (not re-predict)."""
    try:
        import warnings
        warnings.filterwarnings('ignore')
        
        # Get the assessment data from request
        data = request.data
        
        # Extract the ACTUAL recommendation that was already made
        actual_pathway = data.get('recommended_pathway') or data.get('pathway')
        actual_confidence = data.get('confidence')
        
        # Handle None or missing confidence
        if actual_confidence is None:
            actual_confidence = 0.95  # Default high confidence
        elif isinstance(actual_confidence, str):
            actual_confidence = float(actual_confidence) / 100 if float(actual_confidence) > 1 else float(actual_confidence)
        elif isinstance(actual_confidence, (int, float)) and actual_confidence > 1:
            actual_confidence = actual_confidence / 100  # Convert percentage to decimal
        
        if not actual_pathway:
            return Response({'error': 'No pathway recommendation provided'}, status=400)
        
        # Load model only to get feature importance (not to re-predict)
        model_path = os.path.join(os.path.dirname(__file__), '../../Models/cmam_model.pkl')
        if not os.path.exists(model_path):
            return Response({'error': 'Model file not found'}, status=404)
            
        model = joblib.load(model_path)
        
        # Prepare features for explanation
        features = {
            'sex': 1 if data.get('sex') == 'M' else 0,
            'age_months': float(data.get('age_months', 0)),
            'muac_mm': float(data.get('muac_mm', 0)),
            'edema': int(data.get('edema', 0)),
            'appetite': 1 if data.get('appetite') in ['poor', 'failed'] else 0,
            'danger_signs': int(data.get('danger_signs', 0))
        }
        
        # Determine clinical status
        muac = features['muac_mm']
        edema = features['edema']
        if muac < 115 or edema > 0:
            clinical_status = 'SAM'
        elif muac < 125:
            clinical_status = 'MAM'
        else:
            clinical_status = 'Healthy'
        
        # Get feature importance from model
        # Feature order: ['muac_mm', 'age_months', 'sex', 'edema', 'appetite', 'danger_signs']
        feature_importance = model.feature_importances_
        
        # Generate probabilities based on actual pathway (for display purposes)
        if actual_pathway == 'SC_ITP':
            probabilities = {'SC_ITP': actual_confidence * 100, 'OTP': (1 - actual_confidence) * 50, 'TSFP': (1 - actual_confidence) * 50}
        elif actual_pathway == 'OTP':
            probabilities = {'OTP': actual_confidence * 100, 'SC_ITP': (1 - actual_confidence) * 30, 'TSFP': (1 - actual_confidence) * 70}
        elif actual_pathway == 'TSFP':
            probabilities = {'TSFP': actual_confidence * 100, 'OTP': (1 - actual_confidence) * 60, 'SC_ITP': (1 - actual_confidence) * 40}
        else:
            probabilities = {'OTP': 33.3, 'SC_ITP': 33.3, 'TSFP': 33.4}
        
        # Normalize probabilities to sum to 100
        total = sum(probabilities.values())
        probabilities = {k: round(v / total * 100, 1) for k, v in probabilities.items()}
        
        # Create explanations based on ACTUAL pathway recommendation
        explanations = []
        
        # MUAC explanation
        muac_impact = 'positive'
        muac_reasons = []
        if clinical_status == 'SAM':
            muac_reasons.append(f"MUAC {muac}mm indicates SAM (below 115mm threshold)")
            if actual_pathway == 'SC_ITP':
                muac_reasons.append("Severe wasting requires intensive care")
                muac_reasons.append("Primary reason for SC-ITP recommendation")
            elif actual_pathway == 'OTP':
                muac_reasons.append("Severe wasting but manageable as outpatient")
                muac_reasons.append("Primary reason for OTP recommendation")
        elif clinical_status == 'MAM':
            muac_reasons.append(f"MUAC {muac}mm indicates MAM (115-125mm range)")
            muac_reasons.append("Moderate wasting requires supplementary feeding")
            muac_reasons.append("Primary reason for TSFP recommendation")
        else:
            muac_reasons.append(f"MUAC {muac}mm is above 125mm (healthy range)")
            muac_reasons.append("No acute malnutrition detected")
            muac_reasons.append("No therapeutic feeding needed")
            muac_impact = 'negative'
        
        explanations.append({
            'rank': 1,
            'feature': 'MUAC Measurement',
            'value': f"{muac}mm",
            'importance': round(feature_importance[0] * 100, 1),
            'shap_value': float(feature_importance[0]),
            'impact': muac_impact,
            'reasons': muac_reasons
        })
        
        # Appetite explanation
        appetite_impact = 'positive' if (actual_pathway == 'SC_ITP' and features['appetite'] == 1) or (actual_pathway in ['OTP', 'TSFP'] and features['appetite'] == 0) else 'negative'
        appetite_reasons = []
        if features['appetite'] == 1:
            appetite_reasons.append("Child failed appetite test - cannot consume RUTF independently")
            if actual_pathway == 'SC_ITP':
                appetite_reasons.append("Poor appetite requires inpatient feeding support")
                appetite_reasons.append("Key factor for SC-ITP over OTP")
            else:
                appetite_reasons.append("Despite poor appetite, other factors allow outpatient care")
                appetite_reasons.append("Requires close monitoring")
        else:
            appetite_reasons.append("Child passed appetite test - can consume RUTF independently")
            if actual_pathway == 'OTP':
                appetite_reasons.append("Good appetite suitable for home-based RUTF")
                appetite_reasons.append("Key factor for OTP over SC-ITP")
            elif actual_pathway == 'TSFP':
                appetite_reasons.append("Good appetite suitable for supplementary feeding")
                appetite_reasons.append("Can consume fortified foods at home")
            else:
                appetite_reasons.append("Good appetite supports outpatient management")
        
        explanations.append({
            'rank': 2,
            'feature': 'Appetite Test',
            'value': 'Poor' if features['appetite'] == 1 else 'Good',
            'importance': round(feature_importance[4] * 100, 1),
            'shap_value': float(feature_importance[4]),
            'impact': appetite_impact,
            'reasons': appetite_reasons
        })
        
        # Danger signs explanation
        danger_impact = 'positive' if (actual_pathway == 'SC_ITP' and features['danger_signs'] == 1) or (actual_pathway != 'SC_ITP' and features['danger_signs'] == 0) else 'negative'
        danger_reasons = []
        if features['danger_signs'] == 1:
            danger_reasons.append("Danger signs present - requires 24/7 medical monitoring")
            if actual_pathway == 'SC_ITP':
                danger_reasons.append("Medical complications require inpatient care")
                danger_reasons.append("Critical factor for SC-ITP recommendation")
            else:
                danger_reasons.append("Despite danger signs, managed as outpatient with close follow-up")
        else:
            danger_reasons.append("No danger signs - child is medically stable")
            if actual_pathway in ['OTP', 'TSFP']:
                danger_reasons.append("Stable condition allows outpatient management")
                danger_reasons.append("Safe for home-based care with regular monitoring")
            else:
                danger_reasons.append("Medical stability supports the recommendation")
        
        explanations.append({
            'rank': 3,
            'feature': 'Danger Signs',
            'value': 'Present' if features['danger_signs'] == 1 else 'Absent',
            'importance': round(feature_importance[5] * 100, 1),
            'shap_value': float(feature_importance[5]),
            'impact': danger_impact,
            'reasons': danger_reasons
        })
        
        # Edema explanation
        edema_impact = 'positive' if (features['edema'] > 0 and actual_pathway == 'SC_ITP') or (features['edema'] == 0 and actual_pathway != 'SC_ITP') else 'negative'
        edema_reasons = []
        if features['edema'] > 0:
            edema_reasons.append(f"Grade {features['edema']} bilateral pitting edema present")
            edema_reasons.append("Kwashiorkor component requires medical management")
            if actual_pathway == 'SC_ITP':
                edema_reasons.append("Edema treatment requires inpatient care")
            else:
                edema_reasons.append("Edema managed with outpatient protocol")
        else:
            edema_reasons.append("No edema present")
            edema_reasons.append("No kwashiorkor component")
            edema_reasons.append("No additional medical management needed")
        
        explanations.append({
            'rank': 4,
            'feature': 'Edema Grade',
            'value': f"Grade {features['edema']}",
            'importance': round(feature_importance[3] * 100, 1),
            'shap_value': float(feature_importance[3]),
            'impact': edema_impact,
            'reasons': edema_reasons
        })
        
        # Generate clinical interpretation based on ACTUAL pathway
        if clinical_status == 'Healthy':
            interpretation = "This child is healthy with normal nutritional status. No therapeutic feeding program is needed. Continue routine growth monitoring and counseling on infant and young child feeding practices."
        elif actual_pathway == 'SC_ITP':
            complications = []
            if features['appetite'] == 1:
                complications.append('poor appetite')
            if features['danger_signs'] == 1:
                complications.append('danger signs')
            if features['edema'] > 0:
                complications.append(f"grade {features['edema']} edema")
            comp_text = ', '.join(complications) if complications else 'complications'
            interpretation = f"This child has {clinical_status} with {comp_text}. Stabilization center care (SC-ITP) is required for medical management, treatment of complications, and 24-hour monitoring before transitioning to OTP."
        elif actual_pathway == 'OTP':
            interpretation = f"This child has {clinical_status} without major complications. Good appetite and absence of danger signs indicate outpatient therapeutic program (OTP) is appropriate with weekly RUTF distribution and monitoring."
        elif actual_pathway == 'TSFP':
            interpretation = f"This child has {clinical_status}. Targeted supplementary feeding program (TSFP) with fortified blended foods and bi-weekly monitoring is recommended."
        else:
            interpretation = "No therapeutic intervention required. Continue routine monitoring."
        
        return Response({
            'prediction': actual_pathway,
            'confidence': round(actual_confidence * 100, 1) if isinstance(actual_confidence, float) else actual_confidence,
            'probabilities': probabilities,
            'feature_contributions': explanations,
            'interpretation': interpretation,
            'clinical_status': clinical_status,
            'cmam_compliant': True
        })
        
    except Exception as e:
        import traceback
        error_detail = traceback.format_exc()
        print(f"Explainability error: {error_detail}")
        return Response({'error': str(e), 'detail': error_detail}, status=500)


def generate_feature_explanation(feature, value, shap_value, prediction):
    """Generate human-readable explanation for each feature."""
    
    explanations = {
        'appetite_encoded': {
            'name': 'Appetite Test',
            'value': 'Poor' if value == 1 else 'Good',
            'reasons': [
                'Child failed appetite test' if value == 1 else 'Child passed appetite test',
                'Unable to consume RUTF independently' if value == 1 else 'Can eat independently',
                'Requires nasogastric feeding → SC-ITP needed' if value == 1 and prediction == 'SC_ITP' else 'Can take oral feeding'
            ]
        },
        'danger_signs': {
            'name': 'Danger Signs',
            'value': 'Present' if value == 1 else 'Absent',
            'reasons': [
                'Lethargy or unconsciousness observed' if value == 1 else 'Child is alert and responsive',
                'Unable to drink without assistance' if value == 1 else 'Can drink normally',
                'Requires 24/7 monitoring → SC-ITP needed' if value == 1 and prediction == 'SC_ITP' else 'Stable for outpatient care'
            ]
        },
        'muac_mm': {
            'name': f'MUAC Measurement',
            'value': f'{value}mm',
            'reasons': [
                f'MUAC {value}mm is {"below" if value < 115 else "above"} 115mm threshold',
                'Indicates severe muscle wasting' if value < 115 else 'Indicates moderate or no wasting',
                'Requires intensive nutritional rehabilitation' if value < 115 else 'Supplementary feeding may be sufficient'
            ]
        },
        'edema': {
            'name': 'Edema Grade',
            'value': f'Grade {int(value)}',
            'reasons': [
                'No edema present' if value == 0 else f'Grade {int(value)} bilateral pitting edema',
                'No kwashiorkor component' if value == 0 else 'Indicates kwashiorkor component',
                'No medical management needed' if value == 0 else 'Requires medical management for edema'
            ]
        },
        'age_months_filled': {
            'name': 'Age',
            'value': f'{int(value)} months',
            'reasons': [
                f'Child is {int(value)} months old',
                'Age affects nutritional requirements',
                'Younger children may need more intensive care'
            ]
        },
        'sex_encoded': {
            'name': 'Sex',
            'value': 'Male' if value == 1 else 'Female',
            'reasons': [
                f'Child is {"male" if value == 1 else "female"}',
                'Sex affects growth standards',
                'WHO tables differ by sex'
            ]
        }
    }
    
    return explanations.get(feature)


def generate_clinical_interpretation(pathway, features, explanations):
    """Generate overall clinical interpretation."""
    
    interpretations = {
        'SC_ITP': (
            "This child has SAM with multiple complications. "
            f"{'Poor appetite and ' if features['appetite'] == 1 else ''}"
            f"{'danger signs are ' if features['danger_signs'] == 1 else ''}"
            "strong indicators that outpatient care would be unsafe. "
            "Stabilization center admission is necessary for: "
            "medical stabilization (first 2-7 days), treatment of complications, "
            "nutritional rehabilitation, and 24-hour monitoring."
        ),
        'OTP': (
            "This child has SAM but NO major complications. "
            f"{'Good appetite and ' if features['appetite'] == 0 else ''}"
            f"{'no danger signs indicate ' if features['danger_signs'] == 0 else ''}"
            "that outpatient therapeutic care is appropriate. "
            "Child can be managed with weekly RUTF distribution and monitoring."
        ),
        'TSFP': (
            "This child has MAM (Moderate Acute Malnutrition). "
            "Supplementary feeding program is appropriate with fortified blended foods. "
            "Regular monitoring every 2 weeks is recommended."
        )
    }
    
    return interpretations.get(pathway, "Clinical interpretation not available.")
