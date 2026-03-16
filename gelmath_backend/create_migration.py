#!/usr/bin/env python3
"""
Script to create migration for doctor fields
"""
import os
import sys
import django

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'gelmath_api.settings')
django.setup()

from django.core.management import execute_from_command_line

if __name__ == '__main__':
    execute_from_command_line(['manage.py', 'makemigrations', 'accounts'])