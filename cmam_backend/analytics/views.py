from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.db.models import Count, Q
from assessments.models import Assessment

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def national_summary(request):
    """Get national-level summary statistics."""
    queryset = Assessment.objects.all()
    
    total = queryset.count()
    sam = queryset.filter(clinical_status='SAM').count()
    mam = queryset.filter(clinical_status='MAM').count()
    healthy = queryset.filter(clinical_status='Healthy').count()
    
    return Response({
        'total_assessments': total,
        'sam_count': sam,
        'mam_count': mam,
        'healthy_count': healthy,
        'sam_prevalence': round((sam / total * 100) if total > 0 else 0, 1),
        'mam_prevalence': round((mam / total * 100) if total > 0 else 0, 1),
    })

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def state_trends(request):
    """Get assessment counts by state."""
    from django.db.models import Count, Q
    
    states = Assessment.objects.values('chw_state').annotate(
        total=Count('id'),
        sam_count=Count('id', filter=Q(clinical_status='SAM')),
        mam_count=Count('id', filter=Q(clinical_status='MAM')),
        healthy_count=Count('id', filter=Q(clinical_status='Healthy'))
    ).filter(chw_state__isnull=False).exclude(chw_state='').order_by('-total')
    
    return Response([{
        'state': s['chw_state'],
        'sam_count': s['sam_count'],
        'mam_count': s['mam_count'],
        'healthy_count': s['healthy_count']
    } for s in states])

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def time_series(request):
    """Get time series data for trend analysis."""
    from django.db.models.functions import TruncDate
    
    data = Assessment.objects.annotate(
        date=TruncDate('assessment_date')
    ).values('date').annotate(
        sam_count=Count('id', filter=Q(clinical_status='SAM')),
        mam_count=Count('id', filter=Q(clinical_status='MAM')),
        healthy_count=Count('id', filter=Q(clinical_status='Healthy'))
    ).order_by('date')
    
    return Response([{
        'date': d['date'].strftime('%Y-%m-%d'),
        'sam_count': d['sam_count'],
        'mam_count': d['mam_count'],
        'healthy_count': d['healthy_count']
    } for d in data])
