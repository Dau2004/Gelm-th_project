from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import permissions
from django.db.models import Count, Q, Avg
from django.utils import timezone
from datetime import timedelta
from assessments.models import Assessment
from accounts.models import User, Facility


class NationalSummaryView(APIView):
    permission_classes = [permissions.IsAuthenticated]
    
    def get(self, request):
        total_assessments = Assessment.objects.count()
        
        # Status breakdown
        sam_count = Assessment.objects.filter(clinical_status='SAM').count()
        mam_count = Assessment.objects.filter(clinical_status='MAM').count()
        healthy_count = Assessment.objects.filter(clinical_status='Healthy').count()
        
        # Pathway breakdown
        pathways = Assessment.objects.values('recommended_pathway').annotate(
            count=Count('id')
        )
        
        # Active CHWs (assessed in last 30 days)
        thirty_days_ago = timezone.now() - timedelta(days=30)
        active_chws = Assessment.objects.filter(
            timestamp__gte=thirty_days_ago
        ).values('chw').distinct().count()
        
        # Recent trends (last 7 days)
        seven_days_ago = timezone.now() - timedelta(days=7)
        recent_assessments = Assessment.objects.filter(
            timestamp__gte=seven_days_ago
        ).count()
        
        return Response({
            'total_assessments': total_assessments,
            'sam_count': sam_count,
            'mam_count': mam_count,
            'healthy_count': healthy_count,
            'sam_prevalence': round((sam_count / total_assessments * 100), 2) if total_assessments > 0 else 0,
            'mam_prevalence': round((mam_count / total_assessments * 100), 2) if total_assessments > 0 else 0,
            'pathways': list(pathways),
            'active_chws': active_chws,
            'recent_assessments': recent_assessments,
            'total_facilities': Facility.objects.filter(is_active=True).count(),
        })


class StateTrendsView(APIView):
    permission_classes = [permissions.IsAuthenticated]
    
    def get(self, request):
        state_stats = Assessment.objects.values('state').annotate(
            total=Count('id'),
            sam_count=Count('id', filter=Q(clinical_status='SAM')),
            mam_count=Count('id', filter=Q(clinical_status='MAM')),
            healthy_count=Count('id', filter=Q(clinical_status='Healthy'))
        ).order_by('-total')
        
        return Response(list(state_stats))


class TimeSeriesView(APIView):
    permission_classes = [permissions.IsAuthenticated]
    
    def get(self, request):
        period = request.query_params.get('period', 'daily')
        days = {'daily': 30, 'weekly': 90, 'monthly': 365}.get(period, 30)
        
        start_date = timezone.now() - timedelta(days=days)
        
        if period == 'daily':
            assessments = Assessment.objects.filter(
                timestamp__gte=start_date
            ).extra(select={'date': 'date(timestamp)'}).values('date').annotate(
                total=Count('id'),
                sam_count=Count('id', filter=Q(clinical_status='SAM')),
                mam_count=Count('id', filter=Q(clinical_status='MAM')),
                healthy_count=Count('id', filter=Q(clinical_status='Healthy'))
            ).order_by('date')
        else:
            # Simplified for now
            assessments = []
        
        return Response(list(assessments))


class FacilityStatsView(APIView):
    permission_classes = [permissions.IsAuthenticated]
    
    def get(self, request, facility_id):
        facility = Facility.objects.get(id=facility_id)
        
        stats = Assessment.objects.filter(facility=facility).aggregate(
            total=Count('id'),
            sam_count=Count('id', filter=Q(clinical_status='SAM')),
            mam_count=Count('id', filter=Q(clinical_status='MAM')),
            healthy_count=Count('id', filter=Q(clinical_status='Healthy')),
            avg_muac=Avg('muac_mm')
        )
        
        return Response({
            'facility': facility.name,
            'state': facility.state,
            **stats
        })
