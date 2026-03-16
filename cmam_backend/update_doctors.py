#!/usr/bin/env python3
"""
Script to update existing doctors with sample titles and specializations
"""
import os
import sys
import django

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'cmam_project.settings')
django.setup()

from users.models import CHWUser

def update_doctors():
    """Update existing doctors with sample data"""
    doctors = CHWUser.objects.filter(role='DOCTOR')
    
    # Sample data for doctors
    doctor_updates = [
        {
            'username': 'kuir',
            'doctor_title': 'Dr.',
            'doctor_specialization': 'Pediatrician',
            'years_experience': 5,
            'doctor_description': 'Specialist in child nutrition and malnutrition treatment'
        },
        {
            'username': 'doctor_user',
            'doctor_title': 'Dr.',
            'doctor_specialization': 'General Practitioner',
            'years_experience': 3,
            'doctor_description': 'General practice with focus on community health'
        },
        {
            'username': 'ajang',
            'doctor_title': 'Dr.',
            'doctor_specialization': 'Nutritionist',
            'years_experience': 8,
            'doctor_description': 'Clinical nutritionist specializing in acute malnutrition'
        },
        {
            'username': 'dr_peter',
            'doctor_title': 'Dr.',
            'doctor_specialization': 'Family Medicine',
            'years_experience': 6,
            'doctor_description': 'Family medicine physician with pediatric experience'
        },
        {
            'username': 'dr_mary',
            'doctor_title': 'Dr.',
            'doctor_specialization': 'Internal Medicine',
            'years_experience': 10,
            'doctor_description': 'Internal medicine specialist with nutrition expertise'
        },
        {
            'username': 'john_garang',
            'doctor_title': 'Prof.',
            'doctor_specialization': 'Pediatric Nutrition',
            'years_experience': 15,
            'doctor_description': 'Professor of pediatric nutrition and malnutrition research'
        }
    ]
    
    updated_count = 0
    for update_data in doctor_updates:
        try:
            doctor = CHWUser.objects.get(username=update_data['username'], role='DOCTOR')
            doctor.doctor_title = update_data['doctor_title']
            doctor.doctor_specialization = update_data['doctor_specialization']
            doctor.years_experience = update_data['years_experience']
            doctor.doctor_description = update_data['doctor_description']
            doctor.save()
            
            print(f"✅ Updated {doctor.username}: {doctor.doctor_title} {doctor.get_full_name()} - {doctor.doctor_specialization}")
            updated_count += 1
            
        except CHWUser.DoesNotExist:
            print(f"❌ Doctor with username '{update_data['username']}' not found")
        except Exception as e:
            print(f"❌ Error updating {update_data['username']}: {e}")
    
    print(f"\n🎉 Updated {updated_count} doctors successfully!")
    
    # Display all doctors
    print("\n📋 All doctors in system:")
    for doctor in CHWUser.objects.filter(role='DOCTOR'):
        print(f"   {doctor.username}: {doctor.display_name_for_referral}")

if __name__ == '__main__':
    update_doctors()