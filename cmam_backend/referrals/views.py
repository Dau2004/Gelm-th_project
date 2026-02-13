from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import Referral
from .serializers import ReferralSerializer, ReferralCreateSerializer, ReferralUpdateSerializer

class ReferralViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        user = self.request.user
        if user.role == 'DOCTOR':
            return Referral.objects.filter(chw_state=user.state)
        elif user.role == 'CHW':
            return Referral.objects.filter(chw_user=user)
        return Referral.objects.all()
    
    def get_serializer_class(self):
        if self.action == 'create' or self.action == 'bulk_create':
            return ReferralCreateSerializer
        elif self.action in ['update', 'partial_update']:
            return ReferralUpdateSerializer
        return ReferralSerializer
    
    def perform_create(self, serializer):
        serializer.save(chw_user=self.request.user)
    
    @action(detail=False, methods=['post'])
    def bulk_create(self, request):
        referrals_data = request.data if isinstance(request.data, list) else [request.data]
        serializer = ReferralCreateSerializer(data=referrals_data, many=True)
        
        if serializer.is_valid():
            referrals = []
            for data in serializer.validated_data:
                data['chw_user'] = request.user
                if not data.get('chw_username'):
                    data['chw_username'] = request.user.username
                if not data.get('chw_name'):
                    data['chw_name'] = request.user.get_full_name()
                if not data.get('chw_facility'):
                    data['chw_facility'] = request.user.facility
                if not data.get('chw_state'):
                    data['chw_state'] = request.user.state
                referrals.append(Referral(**data))
            
            Referral.objects.bulk_create(referrals)
            return Response(
                ReferralSerializer(referrals, many=True).data,
                status=status.HTTP_201_CREATED
            )
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    @action(detail=True, methods=['patch'])
    def update_status(self, request, pk=None):
        referral = self.get_object()
        serializer = ReferralUpdateSerializer(referral, data=request.data, partial=True)
        
        if serializer.is_valid():
            if request.user.role == 'DOCTOR':
                serializer.save(doctor_user=request.user)
            else:
                serializer.save()
            return Response(ReferralSerializer(referral).data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
