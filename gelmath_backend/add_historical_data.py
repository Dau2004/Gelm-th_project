"""
Add historical assessment data for forecasting demonstration.
Run: python manage.py shell < add_historical_data.py
"""

from assessments.models import Assessment
from accounts.models import User
from datetime import datetime, timedelta
import random

# Get a CHW user
chw = User.objects.filter(role='CHW').first()
if not chw:
    print("No CHW found. Please create a CHW user first.")
    exit()

# Generate assessments for last 6 months with realistic trends
base_date = datetime.now()
months_data = []

# Simulate increasing trend in SAM cases
for month_offset in range(6, 0, -1):
    month_date = base_date - timedelta(days=30 * month_offset)
    
    # Increasing SAM trend: more cases in recent months
    sam_count = 3 + (6 - month_offset) * 2  # 3, 5, 7, 9, 11, 13
    mam_count = 8 + random.randint(-2, 2)   # Around 8 ±2
    healthy_count = 15 + random.randint(-3, 3)  # Around 15 ±3
    
    months_data.append({
        'date': month_date,
        'sam': sam_count,
        'mam': mam_count,
        'healthy': healthy_count
    })

# Create assessments
created_count = 0
for month_data in months_data:
    # SAM cases
    for i in range(month_data['sam']):
        Assessment.objects.create(
            child_id=f"DEMO_SAM_{month_data['date'].month}_{i}",
            chw=chw,
            sex=random.choice(['M', 'F']),
            age_months=random.randint(6, 59),
            muac_mm=random.randint(95, 114),  # SAM range
            edema=random.choice([0, 1, 2]),
            appetite=random.choice(['good', 'poor']),
            danger_signs=random.choice([0, 1]),
            clinical_status='SAM',
            recommended_pathway=random.choice(['SC_ITP', 'OTP']),
            state=chw.state,
            facility=chw.facility,
            timestamp=month_data['date']
        )
        created_count += 1
    
    # MAM cases
    for i in range(month_data['mam']):
        Assessment.objects.create(
            child_id=f"DEMO_MAM_{month_data['date'].month}_{i}",
            chw=chw,
            sex=random.choice(['M', 'F']),
            age_months=random.randint(6, 59),
            muac_mm=random.randint(115, 124),  # MAM range
            edema=0,
            appetite='good',
            danger_signs=0,
            clinical_status='MAM',
            recommended_pathway='TSFP',
            state=chw.state,
            facility=chw.facility,
            timestamp=month_data['date']
        )
        created_count += 1
    
    # Healthy cases
    for i in range(month_data['healthy']):
        Assessment.objects.create(
            child_id=f"DEMO_HEALTHY_{month_data['date'].month}_{i}",
            chw=chw,
            sex=random.choice(['M', 'F']),
            age_months=random.randint(6, 59),
            muac_mm=random.randint(125, 145),  # Healthy range
            edema=0,
            appetite='good',
            danger_signs=0,
            clinical_status='Healthy',
            recommended_pathway='None',
            state=chw.state,
            facility=chw.facility,
            timestamp=month_data['date']
        )
        created_count += 1

print(f"✓ Created {created_count} historical assessments across 6 months")
print(f"✓ SAM trend: Increasing from 3 to 13 cases per month")
print(f"✓ MAM trend: Stable around 8 cases per month")
print(f"✓ Refresh the Predictive Analytics dashboard to see the forecast!")
