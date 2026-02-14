from rest_framework import viewsets, permissions, filters
from rest_framework.decorators import action
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from .models import Assessment, TreatmentRecord, Referral
from .serializers import (AssessmentSerializer, AssessmentCreateSerializer, 
                          TreatmentRecordSerializer, ReferralSerializer, DoctorProfileSerializer)
from accounts.models import User


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
