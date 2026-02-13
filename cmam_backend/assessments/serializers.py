from rest_framework import serializers
from .models import Assessment

class AssessmentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Assessment
        fields = '__all__'
        read_only_fields = ['created_at', 'synced', 'chw_user']

class AssessmentCreateSerializer(serializers.ModelSerializer):
    # Make optional fields explicitly optional and allow null
    muac_z_score = serializers.FloatField(required=False, allow_null=True)
    clinical_status = serializers.CharField(required=False, allow_null=True, allow_blank=True)
    recommended_pathway = serializers.CharField(required=False, allow_null=True, allow_blank=True)
    confidence = serializers.FloatField(required=False, allow_null=True)
    chw_username = serializers.CharField(required=False, allow_null=True, allow_blank=True, default='')
    chw_name = serializers.CharField(required=False, allow_blank=True, default='')
    chw_phone = serializers.CharField(required=False, allow_blank=True, default='')
    chw_facility = serializers.CharField(required=False, allow_blank=True, default='')
    chw_state = serializers.CharField(required=False, allow_blank=True, default='')
    chw_notes = serializers.CharField(required=False, allow_blank=True, default='')
    chw_signature = serializers.CharField(required=False, allow_blank=True, default='')
    assessment_date = serializers.DateTimeField(required=False)
    
    class Meta:
        model = Assessment
        exclude = ['chw_user', 'created_at', 'synced']
    
    def validate_chw_username(self, value):
        # Convert null to empty string
        return value if value else ''
    
    def create(self, validated_data):
        # Link to CHW user if username matches
        from users.models import CHWUser
        chw_username = validated_data.get('chw_username', '')
        if chw_username:
            try:
                chw_user = CHWUser.objects.get(username=chw_username)
                validated_data['chw_user'] = chw_user
            except CHWUser.DoesNotExist:
                pass
        
        return super().create(validated_data)
