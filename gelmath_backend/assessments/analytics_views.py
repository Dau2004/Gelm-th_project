from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.db.models import Count, Q
from .models import Assessment


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def national_summary(request):
    """Get national-level summary statistics"""
    assessments = Assessment.objects.all()
    
    total = assessments.count()
    sam = assessments.filter(clinical_status='SAM').count()
    mam = assessments.filter(clinical_status='MAM').count()
    healthy = assessments.filter(clinical_status='Healthy').count()
    
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
    """Get state-level breakdown"""
    from django.db.models import Count, Q
    
    states = Assessment.objects.values('state').annotate(
        sam_count=Count('id', filter=Q(clinical_status='SAM')),
        mam_count=Count('id', filter=Q(clinical_status='MAM')),
        healthy_count=Count('id', filter=Q(clinical_status='Healthy'))
    ).order_by('-sam_count')
    
    return Response(list(states))


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def time_series(request):
    """Get time series data"""
    from django.db.models.functions import TruncDate
    
    series = Assessment.objects.annotate(
        date=TruncDate('timestamp')
    ).values('date').annotate(
        sam_count=Count('id', filter=Q(clinical_status='SAM')),
        mam_count=Count('id', filter=Q(clinical_status='MAM')),
        healthy_count=Count('id', filter=Q(clinical_status='Healthy'))
    ).order_by('date')
    
    return Response(list(series))


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def chw_performance(request):
    """Get CHW performance metrics"""
    from accounts.models import User
    
    chws = User.objects.filter(role='CHW').values('id', 'username', 'first_name', 'last_name')
    
    performance = []
    for chw in chws:
        assessments = Assessment.objects.filter(chw_id=chw['id'])
        total = assessments.count()
        sam = assessments.filter(clinical_status='SAM').count()
        mam = assessments.filter(clinical_status='MAM').count()
        
        performance.append({
            'chw_id': chw['id'],
            'chw_name': f"{chw['first_name']} {chw['last_name']}" if chw['first_name'] else chw['username'],
            'total_assessments': total,
            'sam_cases': sam,
            'mam_cases': mam,
            'healthy_cases': total - sam - mam
        })
    
    return Response(performance)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def doctor_performance(request):
    """Get doctor performance metrics"""
    from accounts.models import User
    from assessments.models import Referral
    
    doctors = User.objects.filter(role='DOCTOR').values('id', 'username', 'first_name', 'last_name')
    
    performance = []
    for doc in doctors:
        referrals = Referral.objects.filter(referred_to_id=doc['id'])
        total = referrals.count()
        completed = referrals.filter(status='COMPLETED').count()
        
        performance.append({
            'doctor_id': doc['id'],
            'doctor_name': f"{doc['first_name']} {doc['last_name']}" if doc['first_name'] else doc['username'],
            'total_referrals': total,
            'completed_referrals': completed,
            'completion_rate': round((completed / total * 100) if total > 0 else 0, 1)
        })
    
    return Response(performance)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def facility_stats(request, facility_id):
    """Get facility statistics"""
    from accounts.models import Facility, User
    from django.db.models import Avg
    
    try:
        facility = Facility.objects.get(id=facility_id)
    except Facility.DoesNotExist:
        return Response({'error': 'Facility not found'}, status=404)
    
    assessments = Assessment.objects.filter(facility_id=facility_id)
    total = assessments.count()
    sam = assessments.filter(clinical_status='SAM').count()
    mam = assessments.filter(clinical_status='MAM').count()
    healthy = assessments.filter(clinical_status='Healthy').count()
    avg_muac = assessments.aggregate(Avg('muac_mm'))['muac_mm__avg']
    
    chw_count = User.objects.filter(facility_id=facility_id, role='CHW', is_active=True).count()
    
    return Response({
        'facility': facility.name,
        'state': facility.state,
        'chw_count': chw_count,
        'total': total,
        'sam_count': sam,
        'mam_count': mam,
        'healthy_count': healthy,
        'avg_muac': avg_muac
    })
