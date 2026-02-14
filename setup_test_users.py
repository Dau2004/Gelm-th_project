#!/usr/bin/env python3
import os
import sys
import django

# Setup Django
sys.path.insert(0, '/Users/ram/Downloads/MUAC_DEVELOPMENT/gelmath_backend')
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'gelmath_api.settings')
django.setup()

from accounts.models import User

print("Setting up test users...")
print("=" * 50)

# Set password for CHW
chw = User.objects.filter(username='chw_james').first()
if chw:
    chw.set_password('chw123')
    chw.save()
    print(f"✓ Password set for CHW: {chw.username}")
else:
    print("✗ CHW chw_james not found")

# Check doctors
print("\nActive Doctors in System:")
print("-" * 50)
doctors = User.objects.filter(role='DOCTOR', is_active=True)
for doc in doctors:
    facility_name = doc.facility.name if doc.facility else "No facility"
    print(f"ID: {doc.id} | {doc.username} | {doc.first_name} {doc.last_name} | {facility_name}")

print(f"\nTotal active doctors: {doctors.count()}")
