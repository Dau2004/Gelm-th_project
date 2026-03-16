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
    
    print("📋 Current doctors in system:")
    for doctor in doctors:
        print(f"   Username: {doctor.username}, Name: {doctor.get_full_name()}, Current Title: {doctor.doctor_title}, Current Specialization: {doctor.doctor_specialization}")
    
    # Update all doctors found in the system
    doctor_updates = {
        'kuir': {
            'doctor_title': 'Dr.',
            'doctor_specialization': 'Pediatrician',
            'years_experience': 5,
            'doctor_description': 'Specialist in child nutrition and malnutrition treatment'
        },
        'doctor_user': {
            'doctor_title': 'Dr.',
            'doctor_specialization': 'General Practitioner',
            'years_experience': 8,
            'doctor_description': 'General practice with focus on community health'
        },
        'ajang': {
            'doctor_title': 'Dr.',
            'doctor_specialization': 'Nutritionist',
            'years_experience': 7,
            'doctor_description': 'Clinical nutritionist specializing in acute malnutrition'
        },
        'peter_deng': {
            'doctor_title': 'Dr.',
            'doctor_specialization': 'Family Medicine',
            'years_experience': 6,
            'doctor_description': 'Family medicine physician with pediatric experience'
        },
        'mary_akol': {
            'doctor_title': 'Dr.',
            'doctor_specialization': 'Internal Medicine',
            'years_experience': 10,
            'doctor_description': 'Internal medicine specialist with nutrition expertise'
        },
        'john_garang': {
            'doctor_title': 'Prof.',
            'doctor_specialization': 'Pediatric Nutrition',
            'years_experience': 15,
            'doctor_description': 'Professor of pediatric nutrition and malnutrition research'
        },
        'majok': {
            'doctor_title': 'Dr.',
            'doctor_specialization': 'Pediatrician',
            'years_experience': 5,
            'doctor_description': 'Specialist in child nutrition and malnutrition treatment'
        },
        'doctor1': {
            'doctor_title': 'Dr.',
            'doctor_specialization': 'General Practitioner',
            'years_experience': 8,
            'doctor_description': 'General practice with focus on community health'
        }
    }
    
    # Also update any doctor found in the system with a default if not in the list above
    for doctor in doctors:
        if doctor.username not in doctor_updates:
            doctor_updates[doctor.username] = {
                'doctor_title': 'Dr.',
                'doctor_specialization': 'General Medicine',
                'years_experience': 3,
                'doctor_description': 'Medical practitioner specializing in community health'
            }
    
    updated_count = 0
    for username, update_data in doctor_updates.items():
        try:
            doctor = CHWUser.objects.get(username=username, role='DOCTOR')
            doctor.doctor_title = update_data['doctor_title']
            doctor.doctor_specialization = update_data['doctor_specialization']
            doctor.years_experience = update_data['years_experience']
            doctor.doctor_description = update_data['doctor_description']
            doctor.save()
            
            print(f"✅ Updated {doctor.username}: {doctor.display_name_for_referral}")
            updated_count += 1
            
        except CHWUser.DoesNotExist:
            print(f"❌ Doctor with username '{username}' not found")
        except Exception as e:
            print(f"❌ Error updating {username}: {e}")
    
    print(f"\n🎉 Updated {updated_count} doctors successfully!")
    
    # Display all doctors after update
    print("\n📋 All doctors after update:")
    for doctor in CHWUser.objects.filter(role='DOCTOR'):
        print(f"   {doctor.username}: {doctor.display_name_for_referral}")

if __name__ == '__main__':
    update_doctors()