from accounts.models import User, Facility
from assessments.models import Assessment
from datetime import datetime, timedelta
import random

print('🌱 Seeding database with sample data...')

# Create facilities
facilities = []
states = ['Central Equatoria', 'Eastern Equatoria', 'Western Equatoria', 'Jonglei', 'Unity']
for state in states:
    f, created = Facility.objects.get_or_create(
        name=f'{state} Health Center',
        defaults={
            'facility_type': 'OTP',
            'state': state
        }
    )
    facilities.append(f)
    if created:
        print(f'✅ Created facility: {f.name}')

# Create CHW users
for i in range(5):
    username = f'chw{i+1}'
    if not User.objects.filter(username=username).exists():
        User.objects.create_user(
            username=username,
            password='chw123',
            email=f'{username}@gelmath.org',
            role='CHW',
            facility=random.choice(facilities),
            state=random.choice(states)
        )
        print(f'✅ Created CHW: {username}')

# Create Doctor users
for i in range(3):
    username = f'doctor{i+1}'
    if not User.objects.filter(username=username).exists():
        User.objects.create_user(
            username=username,
            password='doctor123',
            email=f'{username}@gelmath.org',
            role='DOCTOR',
            facility=random.choice(facilities),
            state=random.choice(states)
        )
        print(f'✅ Created doctor: {username}')

# Create sample assessments
existing_count = Assessment.objects.count()
if existing_count < 50:
    for i in range(50 - existing_count):
        Assessment.objects.create(
            child_id=f'CH{1000+existing_count+i}',
            sex=random.choice(['M', 'F']),
            age_months=random.randint(6, 59),
            muac_mm=random.randint(95, 135),
            edema=random.choice([0, 1]),
            appetite=random.choice(['good', 'poor']),
            danger_signs=random.choice([0, 1]),
            recommended_pathway=random.choice(['OTP', 'TSFP', 'SC_ITP', 'None']),
            confidence=random.uniform(0.7, 0.99),
            state=random.choice(states),
            facility=random.choice(facilities),
            clinical_status=random.choice(['SAM', 'MAM', 'Healthy'])
        )
    print(f'✅ Created {50 - existing_count} assessments')

print('\n🎉 Sample data seeding complete!')
print(f'📊 Total facilities: {Facility.objects.count()}')
print(f'👥 Total users: {User.objects.count()}')
print(f'📋 Total assessments: {Assessment.objects.count()}')
