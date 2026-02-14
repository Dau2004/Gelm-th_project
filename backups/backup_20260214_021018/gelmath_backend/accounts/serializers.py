from rest_framework import serializers
from django.contrib.auth.password_validation import validate_password
from .models import User, Facility


class FacilitySerializer(serializers.ModelSerializer):
    class Meta:
        model = Facility
        fields = '__all__'


class UserSerializer(serializers.ModelSerializer):
    facility_name = serializers.CharField(source='facility.name', read_only=True)
    facility_input = serializers.CharField(write_only=True, required=False, allow_blank=True, allow_null=True)
    
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'first_name', 'last_name', 'role', 
                  'phone', 'facility', 'facility_name', 'facility_input', 'state', 'is_active', 
                  'created_at', 'last_login']
        read_only_fields = ['id', 'created_at', 'last_login', 'facility']
    
    def update(self, instance, validated_data):
        facility_input = validated_data.pop('facility_input', None)
        
        # Handle facility - find or create by name
        if facility_input:
            facility, _ = Facility.objects.get_or_create(
                name=facility_input,
                defaults={'state': validated_data.get('state', ''), 'facility_type': 'OTP'}
            )
            instance.facility = facility
        elif facility_input == '':
            instance.facility = None
        
        # Update other fields
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        
        instance.save()
        return instance


class UserCreateSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, required=True, validators=[validate_password])
    password2 = serializers.CharField(write_only=True, required=True)
    facility_input = serializers.CharField(write_only=True, required=False, allow_blank=True)
    
    class Meta:
        model = User
        fields = ['username', 'email', 'password', 'password2', 'first_name', 
                  'last_name', 'role', 'phone', 'facility_input', 'state']
    
    def validate(self, attrs):
        if attrs['password'] != attrs['password2']:
            raise serializers.ValidationError({"password": "Passwords don't match"})
        return attrs
    
    def create(self, validated_data):
        validated_data.pop('password2')
        facility_input = validated_data.pop('facility_input', None)
        
        user = User.objects.create_user(**validated_data)
        user.created_by = self.context['request'].user
        
        # Handle facility - find or create by name
        if facility_input:
            facility, _ = Facility.objects.get_or_create(
                name=facility_input,
                defaults={'state': validated_data.get('state', ''), 'facility_type': 'OTP'}
            )
            user.facility = facility
        
        user.save()
        return user


class ChangePasswordSerializer(serializers.Serializer):
    old_password = serializers.CharField(required=True)
    new_password = serializers.CharField(required=True, validators=[validate_password])
