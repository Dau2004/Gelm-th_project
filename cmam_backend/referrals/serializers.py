from rest_framework import serializers
from .models import Referral

class ReferralSerializer(serializers.ModelSerializer):
    assessment_data = serializers.SerializerMethodField()
    
    class Meta:
        model = Referral
        fields = '__all__'
        read_only_fields = ['created_at', 'updated_at']
    
    def get_assessment_data(self, obj):
        if obj.assessment:
            return {
                'child_id': obj.assessment.child_id,
                'sex': obj.assessment.sex,
                'age_months': obj.assessment.age_months,
                'muac_mm': obj.assessment.muac_mm,
                'pathway': obj.assessment.recommended_pathway,
                'assessment_date': obj.assessment.assessment_date,
            }
        return None

class ReferralCreateSerializer(serializers.ModelSerializer):
    assessment_id = serializers.IntegerField(required=False, allow_null=True)
    
    class Meta:
        model = Referral
        fields = ['assessment_id', 'child_id', 'pathway', 'status', 'notes', 
                  'chw_username', 'chw_name', 'chw_facility', 'chw_state']
    
    def create(self, validated_data):
        assessment_id = validated_data.pop('assessment_id', None)
        if assessment_id:
            from assessments.models import Assessment
            try:
                validated_data['assessment'] = Assessment.objects.get(id=assessment_id)
            except Assessment.DoesNotExist:
                pass
        return super().create(validated_data)

class ReferralUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Referral
        fields = ['status', 'doctor_notes', 'doctor_user']
