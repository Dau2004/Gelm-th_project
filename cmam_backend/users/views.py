from rest_framework import viewsets, status
from rest_framework.decorators import api_view, permission_classes, action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth import get_user_model
from .models import CHWUser
from .serializers import CHWUserSerializer, CHWUserCreateSerializer, LoginSerializer

User = get_user_model()

@api_view(['POST'])
@permission_classes([AllowAny])
def login(request):
    """Login endpoint - returns JWT tokens"""
    serializer = LoginSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)
    
    user = serializer.validated_data['user']
    refresh = RefreshToken.for_user(user)
    
    return Response({
        'access': str(refresh.access_token),
        'refresh': str(refresh),
        'user': {
            'id': user.id,
            'username': user.username,
            'full_name': user.get_full_name(),
            'phone': user.phone,
            'state': user.state,
            'facility': user.facility,
            'role': user.role,
        }
    })

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def me(request):
    """Get current user info"""
    serializer = CHWUserSerializer(request.user)
    return Response(serializer.data)

class CHWUserViewSet(viewsets.ModelViewSet):
    """CRUD operations for CHW users (MoH Admin only)"""
    queryset = CHWUser.objects.all()
    serializer_class = CHWUserSerializer
    permission_classes = [IsAuthenticated]
    
    def get_serializer_class(self):
        if self.action == 'create':
            return CHWUserCreateSerializer
        return CHWUserSerializer
    
    def get_queryset(self):
        # MoH admins see all users, CHWs only see themselves
        if self.request.user.role == 'MOH_ADMIN':
            return CHWUser.objects.all()
        return CHWUser.objects.filter(id=self.request.user.id)
    
    @action(detail=True, methods=['post'])
    def reset_password(self, request, pk=None):
        """Reset user password (MoH Admin only)"""
        if request.user.role != 'MOH_ADMIN':
            return Response({'error': 'Permission denied'}, status=status.HTTP_403_FORBIDDEN)
        
        user = self.get_object()
        new_password = request.data.get('password')
        
        if not new_password or len(new_password) < 6:
            return Response({'error': 'Password must be at least 6 characters'}, 
                          status=status.HTTP_400_BAD_REQUEST)
        
        user.set_password(new_password)
        user.save()
        
        return Response({'message': 'Password reset successfully'})
