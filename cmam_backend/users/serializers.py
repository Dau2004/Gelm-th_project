from rest_framework import serializers
from django.contrib.auth import authenticate
from .models import CHWUser

class CHWUserSerializer(serializers.ModelSerializer):
    display_name_for_referral = serializers.ReadOnlyField()
    doctor_info_summary = serializers.ReadOnlyField()
    
    class Meta:
        model = CHWUser
        fields = ['id', 'username', 'email', 'first_name', 'last_name', 'phone', 
                  'state', 'facility', 'role', 'is_active_chw', 'created_at',
                  'doctor_title', 'doctor_specialization', 'doctor_description', 
                  'years_experience', 'display_name_for_referral', 'doctor_info_summary']
        read_only_fields = ['id', 'created_at']

class CHWUserCreateSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=6)
    
    class Meta:
        model = CHWUser
        fields = ['username', 'password', 'email', 'first_name', 'last_name', 
                  'phone', 'state', 'facility', 'role', 'doctor_title', 
                  'doctor_specialization', 'doctor_description', 'years_experience']
    
    def create(self, validated_data):
        user = CHWUser.objects.create_user(
            username=validated_data['username'],
            password=validated_data['password'],
            email=validated_data.get('email', ''),
            first_name=validated_data.get('first_name', ''),
            last_name=validated_data.get('last_name', ''),
            phone=validated_data.get('phone', ''),
            state=validated_data.get('state', ''),
            facility=validated_data.get('facility', ''),
            role=validated_data.get('role', 'CHW'),
            doctor_title=validated_data.get('doctor_title', ''),
            doctor_specialization=validated_data.get('doctor_specialization', ''),
            doctor_description=validated_data.get('doctor_description', ''),
            years_experience=validated_data.get('years_experience'),
        )
        return user

class LoginSerializer(serializers.Serializer):
    username = serializers.CharField()
    password = serializers.CharField(write_only=True)
    
    def validate(self, data):
        user = authenticate(username=data['username'], password=data['password'])
        if not user:
            raise serializers.ValidationError("Invalid credentials")
        if not user.is_active:
            raise serializers.ValidationError("User account is disabled")
        data['user'] = user
        return data
