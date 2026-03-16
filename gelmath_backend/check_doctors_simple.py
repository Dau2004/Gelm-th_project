#!/usr/bin/env python3
"""
Simple script to check doctors without new fields
"""
import os
import sys
import django

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'gelmath_api.settings')
django.setup()

from accounts.models import User

def check_doctors_simple():
    """Check existing doctors in the system without new fields"""
    doctors = User.objects.filter(role='DOCTOR')
    
    print("📋 Current doctors in gelmath_backend:")
    print(f"Total doctors found: {doctors.count()}")
    
    for doctor in doctors:
        print(f"   Username: {doctor.username}")
        print(f"   Name: {doctor.get_full_name()}")
        print(f"   Role: {doctor.role}")
        print(f"   Active: {doctor.is_active}")
        print("   ---")

if __name__ == '__main__':
    check_doctors_simple()