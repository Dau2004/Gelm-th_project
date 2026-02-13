from rest_framework import viewsets, permissions, filters
from django_filters.rest_framework import DjangoFilterBackend
from .models import Assessment, TreatmentRecord
from .serializers import (AssessmentSerializer, AssessmentCreateSerializer, 
                          TreatmentRecordSerializer)


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
