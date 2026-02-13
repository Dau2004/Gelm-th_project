from rest_framework import serializers
from django.contrib.auth import authenticate
from .models import CHWUser

class CHWUserSerializer(serializers.ModelSerializer):
    class Meta:
        model = CHWUser
        fields = ['id', 'username', 'email', 'first_name', 'last_name', 'phone', 
                  'state', 'facility', 'role', 'is_active_chw', 'created_at']
        read_only_fields = ['id', 'created_at']

class CHWUserCreateSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=6)
    
    class Meta:
        model = CHWUser
        fields = ['username', 'password', 'email', 'first_name', 'last_name', 
                  'phone', 'state', 'facility', 'role']
    
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
