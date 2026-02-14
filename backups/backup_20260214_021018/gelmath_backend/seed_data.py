#!/usr/bin/env python
"""
Seed script to populate database with initial data
Run: python manage.py shell < seed_data.py
"""

from accounts.models import User, Facility
from assessments.models import Assessment
from django.utils import timezone
from datetime import timedelta
import random

# Create Facilities
facilities_data = [
    {'name': 'Juba Teaching Hospital', 'facility_type': 'SC_ITP', 'state': 'Central Equatoria', 'county': 'Juba'},
    {'name': 'Wau State Hospital', 'facility_type': 'OTP', 'state': 'Western Bahr el Ghazal', 'county': 'Wau'},
    {'name': 'Malakal Health Center', 'facility_type': 'TSFP', 'state': 'Upper Nile', 'county': 'Malakal'},
    {'name': 'Yambio County Hospital', 'facility_type': 'OTP', 'state': 'Western Equatoria', 'county': 'Yambio'},
    {'name': 'Bor Civil Hospital', 'facility_type': 'SC_ITP', 'state': 'Jonglei', 'county': 'Bor'},
]

print("Creating facilities...")
facilities = []
for data in facilities_data:
    facility, created = Facility.objects.get_or_create(**data)
    facilities.append(facility)
    print(f"  {'Created' if created else 'Exists'}: {facility.name}")

# Create MoH Admin
print("\nCreating MoH Admin...")
moh_admin, created = User.objects.get_or_create(
    username='moh_admin',
    defaults={
        'email': 'admin@moh.gov.ss',
        'first_name': 'Ministry',
        'last_name': 'Admin',
        'role': 'MOH_ADMIN',
        'phone': '+211123456789',
        'state': 'Central Equatoria',
        'is_staff': True,
        'is_superuser': True,
    }
)
if created:
    moh_admin.set_password('admin123')
    moh_admin.save()
    print(f"  Created: {moh_admin.username} (password: admin123)")
else:
    print(f"  Exists: {moh_admin.username}")

# Create Doctors
print("\nCreating doctors...")
doctors_data = [
    {'username': 'dr_john', 'first_name': 'John', 'last_name': 'Garang', 'facility': facilities[0]},
    {'username': 'dr_mary', 'first_name': 'Mary', 'last_name': 'Akol', 'facility': facilities[1]},
    {'username': 'dr_peter', 'first_name': 'Peter', 'last_name': 'Deng', 'facility': facilities[2]},
]

doctors = []
for data in doctors_data:
    doctor, created = User.objects.get_or_create(
        username=data['username'],
        defaults={
            'email': f"{data['username']}@gelmath.ss",
            'first_name': data['first_name'],
            'last_name': data['last_name'],
            'role': 'DOCTOR',
            'facility': data['facility'],
            'state': data['facility'].state,
            'phone': f'+21192{random.randint(1000000, 9999999)}',
            'created_by': moh_admin,
        }
    )
    if created:
        doctor.set_password('doctor123')
        doctor.save()
        print(f"  Created: {doctor.username} (password: doctor123)")
    else:
        print(f"  Exists: {doctor.username}")
    doctors.append(doctor)

# Create CHWs
print("\nCreating CHWs...")
chws_data = [
    {'username': 'chw_james', 'first_name': 'James', 'last_name': 'Maker', 'facility': facilities[0]},
    {'username': 'chw_sarah', 'first_name': 'Sarah', 'last_name': 'Nyandeng', 'facility': facilities[1]},
    {'username': 'chw_david', 'first_name': 'David', 'last_name': 'Yau', 'facility': facilities[2]},
    {'username': 'chw_grace', 'first_name': 'Grace', 'last_name': 'Bol', 'facility': facilities[3]},
]

chws = []
for data in chws_data:
    chw, created = User.objects.get_or_create(
        username=data['username'],
        defaults={
            'email': f"{data['username']}@gelmath.ss",
            'first_name': data['first_name'],
            'last_name': data['last_name'],
            'role': 'CHW',
            'facility': data['facility'],
            'state': data['facility'].state,
            'phone': f'+21193{random.randint(1000000, 9999999)}',
            'created_by': moh_admin,
        }
    )
    if created:
        chw.set_password('chw123')
        chw.save()
        print(f"  Created: {chw.username} (password: chw123)")
    else:
        print(f"  Exists: {chw.username}")
    chws.append(chw)

# Create Sample Assessments
print("\nCreating sample assessments...")
statuses = ['SAM', 'MAM', 'Healthy']
pathways = ['SC_ITP', 'OTP', 'TSFP', 'None']
sexes = ['M', 'F']
appetites = ['good', 'poor', 'failed']

for i in range(50):
    status = random.choice(statuses)
    if status == 'SAM':
        pathway = random.choice(['SC_ITP', 'OTP'])
        muac = random.randint(90, 114)
    elif status == 'MAM':
        pathway = 'TSFP'
        muac = random.randint(115, 124)
    else:
        pathway = 'None'
        muac = random.randint(125, 150)
    
    chw = random.choice(chws)
    assessment = Assessment.objects.create(
        child_id=f'CH{str(i+1).zfill(6)}',
        sex=random.choice(sexes),
        age_months=random.randint(6, 59),
        muac_mm=muac,
        muac_z_score=round(random.uniform(-4.0, 1.0), 2),
        edema=1 if status == 'SAM' and random.random() > 0.7 else 0,
        appetite=random.choice(appetites),
        danger_signs=1 if pathway == 'SC_ITP' else 0,
        clinical_status=status,
        recommended_pathway=pathway,
        confidence=round(random.uniform(0.7, 0.99), 2),
        facility=chw.facility,
        state=chw.state,
        chw=chw,
        chw_name=chw.get_full_name(),
        chw_phone=chw.phone,
        timestamp=timezone.now() - timedelta(days=random.randint(0, 90)),
        synced=True,
    )

print(f"  Created {Assessment.objects.count()} assessments")

print("\n✅ Database seeded successfully!")
print("\nLogin credentials:")
print("  MoH Admin: moh_admin / admin123")
print("  Doctor: dr_john / doctor123")
print("  CHW: chw_james / chw123")
