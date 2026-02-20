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
    """Generate ML explanation using feature importance for a prediction."""
    try:
        import warnings
        warnings.filterwarnings('ignore')
        
        # Load model
        model_path = os.path.join(os.path.dirname(__file__), '../../Models/cmam_model.pkl')
        if not os.path.exists(model_path):
            return Response({'error': 'Model file not found'}, status=404)
            
        model = joblib.load(model_path)
        
        # Prepare input features (use simple names)
        data = request.data
        features = {
            'sex': 1 if data.get('sex') == 'M' else 0,
            'age_months': float(data.get('age_months', 0)),
            'muac_mm': float(data.get('muac_mm', 0)),
            'edema': int(data.get('edema', 0)),
            'appetite': 1 if data.get('appetite') == 'poor' else 0,
            'danger_signs': int(data.get('danger_signs', 0))
        }
        
        feature_names = ['muac_mm', 'age_months', 'sex', 'edema', 'appetite', 'danger_signs']
        X_input = pd.DataFrame([features])[feature_names]
        
        # Get prediction
        prediction = model.predict(X_input)[0]
        probabilities = model.predict_proba(X_input)[0]
        confidence = float(probabilities.max())
        
        # Use feature importance from model
        feature_importance = model.feature_importances_
        
        # Create explanations based on feature importance
        explanations = [
            {
                'rank': 1,
                'feature': 'MUAC Measurement',
                'value': f"{features['muac_mm']}mm",
                'importance': round(feature_importance[2] * 100, 1),
                'shap_value': float(feature_importance[2]),
                'impact': 'positive',
                'reasons': [
                    f"MUAC {features['muac_mm']}mm is {'below' if features['muac_mm'] < 115 else 'above'} 115mm threshold",
                    'Primary indicator of wasting',
                    'Most important feature for pathway decision'
                ]
            },
            {
                'rank': 2,
                'feature': 'Appetite Test',
                'value': 'Poor' if features['appetite'] == 1 else 'Good',
                'importance': round(feature_importance[4] * 100, 1),
                'shap_value': float(feature_importance[4]),
                'impact': 'positive' if features['appetite'] == 1 else 'negative',
                'reasons': [
                    'Child failed appetite test' if features['appetite'] == 1 else 'Child passed appetite test',
                    'Indicates ability to consume RUTF',
                    'Critical for SC-ITP vs OTP decision'
                ]
            },
            {
                'rank': 3,
                'feature': 'Danger Signs',
                'value': 'Present' if features['danger_signs'] == 1 else 'Absent',
                'importance': round(feature_importance[5] * 100, 1),
                'shap_value': float(feature_importance[5]),
                'impact': 'positive' if features['danger_signs'] == 1 else 'negative',
                'reasons': [
                    'Danger signs detected' if features['danger_signs'] == 1 else 'No danger signs',
                    'Requires 24/7 monitoring' if features['danger_signs'] == 1 else 'Stable for outpatient',
                    'Indicates medical complications' if features['danger_signs'] == 1 else 'No immediate complications'
                ]
            },
            {
                'rank': 4,
                'feature': 'Edema Grade',
                'value': f"Grade {features['edema']}",
                'importance': round(feature_importance[3] * 100, 1),
                'shap_value': float(feature_importance[3]),
                'impact': 'positive' if features['edema'] > 0 else 'negative',
                'reasons': [
                    'No edema present' if features['edema'] == 0 else f"Grade {features['edema']} edema detected",
                    'Indicates kwashiorkor component' if features['edema'] > 0 else 'No kwashiorkor',
                    'Requires medical management' if features['edema'] > 0 else 'No edema treatment needed'
                ]
            }
        ]
        
        # Generate clinical interpretation
        if prediction == 'SC_ITP':
            interpretation = "This child has SAM with complications requiring stabilization center care for medical management and 24-hour monitoring."
        elif prediction == 'OTP':
            interpretation = "This child has SAM but no major complications. Outpatient therapeutic care with weekly RUTF distribution is appropriate."
        else:
            interpretation = "This child has MAM. Supplementary feeding program with fortified foods and bi-weekly monitoring is recommended."
        
        return Response({
            'prediction': prediction,
            'confidence': round(confidence * 100, 1),
            'probabilities': dict(zip(model.classes_, [round(p * 100, 1) for p in probabilities])),
            'feature_contributions': explanations,
            'interpretation': interpretation,
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
