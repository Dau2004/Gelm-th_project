from rest_framework import serializers
from .models import Assessment, TreatmentRecord


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
        # Set CHW from authenticated user if role is CHW
        user = self.context['request'].user
        if user.role == 'CHW':
            validated_data['chw'] = user
        return super().create(validated_data)


class TreatmentRecordSerializer(serializers.ModelSerializer):
    doctor_name = serializers.CharField(source='doctor.get_full_name', read_only=True)
    child_id = serializers.CharField(source='assessment.child_id', read_only=True)
    
    class Meta:
        model = TreatmentRecord
        fields = '__all__'
        read_only_fields = ['id', 'created_at', 'updated_at']
