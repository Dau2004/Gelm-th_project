from rest_framework import serializers
from .models import Assessment, TreatmentRecord, Referral
from accounts.models import User
import joblib
import pandas as pd
import os


class AssessmentSerializer(serializers.ModelSerializer):
    facility_name = serializers.CharField(source='facility.name', read_only=True)
    chw_username = serializers.CharField(source='chw.username', read_only=True)
    doctor_name = serializers.CharField(source='assigned_doctor.get_full_name', read_only=True)
    
    class Meta:
        model = Assessment
        fields = '__all__'
        read_only_fields = ['id', 'created_at', 'updated_at', 'timestamp']


class AssessmentCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Assessment
        fields = ['child_id', 'sex', 'age_months', 'muac_mm', 'muac_z_score', 
                  'edema', 'appetite', 'danger_signs', 'clinical_status', 
                  'recommended_pathway', 'confidence', 'facility', 'state', 
                  'county', 'chw_name', 'chw_phone', 'chw_notes', 'chw_signature']
    
    def create(self, validated_data):
        user = self.context['request'].user
        if user.role == 'CHW':
            validated_data['chw'] = user
        
        # Run ML prediction if not provided
        if not validated_data.get('clinical_status') or not validated_data.get('recommended_pathway'):
            try:
                model_path = os.path.join(os.path.dirname(__file__), '../../Models/cmam_model.pkl')
                if os.path.exists(model_path):
                    model = joblib.load(model_path)
                    
                    # Prepare features in correct order
                    features = pd.DataFrame([{
                        'muac_mm': validated_data.get('muac_mm', 0),
                        'age_months': validated_data.get('age_months', 0),
                        'sex': 1 if validated_data.get('sex') == 'M' else 0,
                        'edema': validated_data.get('edema', 0),
                        'appetite': 1 if validated_data.get('appetite') in ['poor', 'failed'] else 0,
                        'danger_signs': validated_data.get('danger_signs', 0)
                    }])
                    
                    # Predict
                    prediction = model.predict(features)[0]
                    confidence = model.predict_proba(features).max()
                    
                    # Determine clinical status
                    muac = validated_data.get('muac_mm', 0)
                    edema = validated_data.get('edema', 0)
                    if muac < 115 or edema > 0:
                        clinical_status = 'SAM'
                    elif muac < 125:
                        clinical_status = 'MAM'
                    else:
                        clinical_status = 'Healthy'
                        prediction = 'None'  # Override for healthy
                    
                    validated_data['clinical_status'] = clinical_status
                    validated_data['recommended_pathway'] = prediction
                    validated_data['confidence'] = round(confidence * 100, 1)
            except Exception as e:
                print(f"ML prediction error: {e}")
        
        return super().create(validated_data)


class TreatmentRecordSerializer(serializers.ModelSerializer):
    doctor_name = serializers.CharField(source='doctor.get_full_name', read_only=True)
    child_id = serializers.CharField(source='assessment.child_id', read_only=True)
    
    class Meta:
        model = TreatmentRecord
        fields = '__all__'
        read_only_fields = ['id', 'created_at', 'updated_at']


class DoctorProfileSerializer(serializers.ModelSerializer):
    full_name = serializers.SerializerMethodField()
    facility_name = serializers.CharField(source='facility.name', read_only=True)
    
    class Meta:
        model = User
        fields = ['id', 'username', 'full_name', 'email', 'phone', 'facility', 'facility_name', 'state']
    
    def get_full_name(self, obj):
        return f"Dr. {obj.first_name} {obj.last_name}" if obj.first_name else obj.username


class ReferralSerializer(serializers.ModelSerializer):
    referred_by_name = serializers.CharField(source='referred_by.username', read_only=True)
    referred_to_name = serializers.SerializerMethodField()
    child_id = serializers.CharField(source='assessment.child_id', read_only=True)
    assessment_details = AssessmentSerializer(source='assessment', read_only=True)
    
    class Meta:
        model = Referral
        fields = '__all__'
        read_only_fields = ['id', 'created_at', 'updated_at']
    
    def get_referred_to_name(self, obj):
        if obj.referred_to:
            return f"Dr. {obj.referred_to.first_name} {obj.referred_to.last_name}" if obj.referred_to.first_name else obj.referred_to.username
        return None
