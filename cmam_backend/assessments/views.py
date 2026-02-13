from rest_framework import viewsets, status
from rest_framework.decorators import api_view, permission_classes, action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import Assessment
from .serializers import AssessmentSerializer, AssessmentCreateSerializer
from .quality_service import get_quality_service

class AssessmentViewSet(viewsets.ModelViewSet):
    queryset = Assessment.objects.all()
    serializer_class = AssessmentSerializer
    permission_classes = [IsAuthenticated]
    
    def get_serializer_class(self):
        if self.action == 'create':
            return AssessmentCreateSerializer
        return AssessmentSerializer
    
    def get_queryset(self):
        # CHWs see only their assessments, MoH admins see all
        if self.request.user.role == 'MOH_ADMIN':
            return Assessment.objects.all()
        return Assessment.objects.filter(chw_username=self.request.user.username)
    
    @action(detail=False, methods=['post'])
    def bulk_create(self, request):
        """Bulk upload assessments from mobile app."""
        import json
        print("=== BULK CREATE DEBUG ===")
        print(f"Request data type: {type(request.data)}")
        print(f"Request data: {json.dumps(request.data, indent=2, default=str)}")
        
        assessments_data = request.data if isinstance(request.data, list) else [request.data]
        
        serializer = AssessmentCreateSerializer(data=assessments_data, many=True)
        if serializer.is_valid():
            serializer.save()
            return Response({
                'message': f'{len(assessments_data)} assessments synced successfully',
                'count': len(assessments_data)
            }, status=status.HTTP_201_CREATED)
        
        # Return detailed error information
        print(f"Validation errors: {serializer.errors}")
        return Response({
            'error': 'Validation failed',
            'details': serializer.errors
        }, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET'])
def health_check(request):
    return Response({'status': 'healthy', 'service': 'CMAM API'})

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def statistics(request):
    # Filter by user role
    if request.user.role == 'MOH_ADMIN':
        queryset = Assessment.objects.all()
    else:
        queryset = Assessment.objects.filter(chw_username=request.user.username)
    
    total = queryset.count()
    by_pathway = {}
    for pathway in ['SC_ITP', 'OTP', 'TSFP', 'None']:
        count = queryset.filter(recommended_pathway=pathway).count()
        by_pathway[pathway] = count
    
    return Response({
        'total_assessments': total,
        'by_pathway': by_pathway,
    })

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def chw_assessment_counts(request):
    """Get assessment counts per CHW."""
    from django.db.models import Count
    
    counts = Assessment.objects.values('chw_username').annotate(
        count=Count('id')
    ).order_by('-count')
    
    return Response({chw['chw_username']: chw['count'] for chw in counts})

@api_view(['POST'])
def check_quality(request):
    """Model 2: Check measurement quality before pathway prediction."""
    data = request.data
    
    # Extract parameters
    muac_mm = data.get('muac_mm')
    age_months = data.get('age_months')
    sex = data.get('sex')
    edema = data.get('edema', 0)
    appetite = data.get('appetite', 'good')
    danger_signs = data.get('danger_signs', 0)
    
    # Validate required fields
    if not all([muac_mm, age_months, sex]):
        return Response(
            {'error': 'Missing required fields: muac_mm, age_months, sex'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    # Run quality check
    quality_service = get_quality_service()
    result = quality_service.check_quality(
        muac_mm=int(muac_mm),
        age_months=int(age_months),
        sex=sex,
        edema=int(edema),
        appetite=appetite,
        danger_signs=int(danger_signs)
    )
    
    return Response(result)
