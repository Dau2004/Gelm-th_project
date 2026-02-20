from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.db.models import Count, Q
from django.db.models.functions import TruncMonth
from datetime import datetime, timedelta
import numpy as np
from .models import Assessment


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def forecast_trends(request):
    """Generate 3-month forecast for malnutrition trends using simple time-series analysis."""
    try:
        from django.utils import timezone
        
        # Get historical data (last 12 months)
        end_date = timezone.now()
        start_date = end_date - timedelta(days=365)
        
        # Aggregate monthly data
        monthly_data = Assessment.objects.filter(
            timestamp__gte=start_date,
            timestamp__lte=end_date
        ).annotate(
            month=TruncMonth('timestamp')
        ).values('month').annotate(
            total=Count('id'),
            sam=Count('id', filter=Q(clinical_status='SAM')),
            mam=Count('id', filter=Q(clinical_status='MAM'))
        ).order_by('month')
        
        # Convert to lists for analysis
        months = []
        sam_counts = []
        mam_counts = []
        total_counts = []
        
        for entry in monthly_data:
            months.append(entry['month'].strftime('%Y-%m'))
            sam_counts.append(entry['sam'])
            mam_counts.append(entry['mam'])
            total_counts.append(entry['total'])
        
        # Simple linear regression forecast
        if len(sam_counts) >= 3:
            sam_forecast = simple_forecast(sam_counts, periods=3)
            mam_forecast = simple_forecast(mam_counts, periods=3)
            total_forecast = simple_forecast(total_counts, periods=3)
            print(f"Forecast generated from {len(sam_counts)} months of data")
            print(f"Historical SAM: {sam_counts}")
            print(f"Forecasted SAM: {sam_forecast}")
        else:
            # Not enough data, use averages
            sam_forecast = [np.mean(sam_counts)] * 3 if sam_counts else [0, 0, 0]
            mam_forecast = [np.mean(mam_counts)] * 3 if mam_counts else [0, 0, 0]
            total_forecast = [np.mean(total_counts)] * 3 if total_counts else [0, 0, 0]
            print(f"Not enough data ({len(sam_counts)} months), using averages")
        
        # Generate future months
        future_months = []
        for i in range(1, 4):
            future_date = end_date + timedelta(days=30 * i)
            future_months.append(future_date.strftime('%Y-%m'))
        
        print(f"Total assessments in DB: {Assessment.objects.count()}")
        print(f"Assessments in date range: {Assessment.objects.filter(timestamp__gte=start_date, timestamp__lte=end_date).count()}")
        print(f"Unique months found: {len(months)}")
        print(f"Months: {months}")
        
        # Calculate trends and alerts
        sam_trend = calculate_trend(sam_counts)
        mam_trend = calculate_trend(mam_counts)
        
        # Generate alerts
        alerts = []
        if sam_trend > 10:
            alerts.append({
                'severity': 'high',
                'type': 'SAM_INCREASE',
                'message': f'SAM cases projected to increase by {sam_trend:.1f}% in next 3 months',
                'recommendation': 'Increase RUTF stock and SC-ITP capacity'
            })
        if mam_trend > 15:
            alerts.append({
                'severity': 'medium',
                'type': 'MAM_INCREASE',
                'message': f'MAM cases projected to increase by {mam_trend:.1f}% in next 3 months',
                'recommendation': 'Prepare additional TSFP resources'
            })
        
        # Resource requirements
        resources = calculate_resource_needs(sam_forecast, mam_forecast)
        
        return Response({
            'historical': {
                'months': months,
                'sam_counts': sam_counts,
                'mam_counts': mam_counts,
                'total_counts': total_counts
            },
            'forecast': {
                'months': future_months,
                'sam_forecast': [int(x) for x in sam_forecast],
                'mam_forecast': [int(x) for x in mam_forecast],
                'total_forecast': [int(x) for x in total_forecast]
            },
            'trends': {
                'sam_trend': round(sam_trend, 1),
                'mam_trend': round(mam_trend, 1),
                'sam_direction': 'increasing' if sam_trend > 0 else 'decreasing',
                'mam_direction': 'increasing' if mam_trend > 0 else 'decreasing'
            },
            'alerts': alerts,
            'resources': resources,
            'confidence': 'medium' if len(sam_counts) >= 6 else 'low'
        })
        
    except Exception as e:
        return Response({'error': str(e)}, status=500)


def simple_forecast(data, periods=3):
    """Simple linear trend forecast."""
    if len(data) < 2:
        return [data[0] if data else 0] * periods
    
    # Linear regression
    x = np.arange(len(data))
    y = np.array(data)
    
    # Calculate slope and intercept
    slope = np.sum((x - np.mean(x)) * (y - np.mean(y))) / np.sum((x - np.mean(x)) ** 2)
    intercept = np.mean(y) - slope * np.mean(x)
    
    # Forecast
    forecast = []
    for i in range(periods):
        future_x = len(data) + i
        forecast_value = slope * future_x + intercept
        forecast.append(max(0, forecast_value))  # No negative cases
    
    return forecast


def calculate_trend(data):
    """Calculate percentage trend."""
    if len(data) < 2:
        return 0
    
    recent_avg = np.mean(data[-3:]) if len(data) >= 3 else data[-1]
    older_avg = np.mean(data[:3]) if len(data) >= 6 else data[0]
    
    if older_avg == 0:
        return 0
    
    return ((recent_avg - older_avg) / older_avg) * 100


def calculate_resource_needs(sam_forecast, mam_forecast):
    """Calculate resource requirements based on forecast."""
    total_sam = sum(sam_forecast)
    total_mam = sum(mam_forecast)
    
    # RUTF sachets (92 sachets per SAM child for 8 weeks)
    rutf_sachets = int(total_sam * 92)
    
    # Supplementary food (CSB+ for MAM, 30 days supply)
    csb_kg = int(total_mam * 15)  # 15kg per child per month
    
    # CHW workload (1 CHW can handle 50 cases)
    chw_needed = int((total_sam + total_mam) / 50) + 1
    
    return {
        'rutf_sachets': rutf_sachets,
        'csb_kg': csb_kg,
        'chw_needed': chw_needed,
        'sc_itp_beds': int(total_sam * 0.3),  # 30% of SAM need SC-ITP
        'otp_capacity': int(total_sam * 0.7)   # 70% of SAM for OTP
    }
