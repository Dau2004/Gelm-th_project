#!/usr/bin/env python3
"""
Security Audit Script - Check Encryption & Security Configuration
Run this before production deployment
"""
import os
import sys
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'gelmath_api.settings')
django.setup()

from django.conf import settings
from django.contrib.auth import get_user_model
from django.contrib.auth.hashers import check_password

User = get_user_model()

def check_password_encryption():
    """Verify password hashing works"""
    print("\n=== PASSWORD ENCRYPTION ===")
    user = User.objects.create_user(username='_audit_test', password='TestPass123!', role='CHW')
    
    issues = []
    
    # Check 1: Not plaintext
    if user.password == 'TestPass123!':
        issues.append("CRITICAL: Passwords stored in plaintext!")
    else:
        print("Passwords are hashed (not plaintext)")
    
    # Check 2: Algorithm
    algo = user.password.split('$')[0]
    if algo != 'pbkdf2_sha256':
        issues.append(f"  Weak algorithm: {algo} (should be pbkdf2_sha256)")
    else:
        print(f" Strong algorithm: {algo}")
    
    # Check 3: Iterations
    iterations = int(user.password.split('$')[1])
    if iterations < 100000:
        issues.append(f"WARNING  Low iterations: {iterations} (should be 100K+)")
    else:
        print(f" Strong iterations: {iterations:,}")
    
    # Check 4: Verification
    if not check_password('TestPass123!', user.password):
        issues.append(" CRITICAL: Password verification failed!")
    else:
        print(" Password verification works")
    
    user.delete()
    return issues

def check_jwt_security():
    """Verify JWT token security"""
    print("\n=== JWT TOKEN SECURITY ===")
    issues = []
    
    # Check SECRET_KEY
    if len(settings.SECRET_KEY) < 32:
        issues.append(f" CRITICAL: SECRET_KEY too short ({len(settings.SECRET_KEY)} chars)")
    else:
        print(f" SECRET_KEY length: {len(settings.SECRET_KEY)} chars")
    
    if 'django-insecure' in settings.SECRET_KEY.lower():
        issues.append(" CRITICAL: Using default Django SECRET_KEY!")
    else:
        print(" SECRET_KEY is not default")
    
    return issues

def check_https_settings():
    """Verify HTTPS/TLS configuration"""
    print("\n=== HTTPS/TLS SETTINGS ===")
    issues = []
    
    if settings.DEBUG:
        print("  DEBUG=True (development mode)")
        print("   Production requires: DEBUG=False")
    else:
        print(" DEBUG=False (production mode)")
    
    ssl_redirect = getattr(settings, 'SECURE_SSL_REDIRECT', False)
    if not ssl_redirect and not settings.DEBUG:
        issues.append(" SECURE_SSL_REDIRECT not enabled")
    elif ssl_redirect:
        print(" SECURE_SSL_REDIRECT enabled")
    
    session_secure = getattr(settings, 'SESSION_COOKIE_SECURE', False)
    if not session_secure and not settings.DEBUG:
        issues.append(" SESSION_COOKIE_SECURE not enabled")
    elif session_secure:
        print(" SESSION_COOKIE_SECURE enabled")
    
    csrf_secure = getattr(settings, 'CSRF_COOKIE_SECURE', False)
    if not csrf_secure and not settings.DEBUG:
        issues.append(" CSRF_COOKIE_SECURE not enabled")
    elif csrf_secure:
        print(" CSRF_COOKIE_SECURE enabled")
    
    hsts = getattr(settings, 'SECURE_HSTS_SECONDS', 0)
    if hsts == 0 and not settings.DEBUG:
        issues.append(" HSTS not configured")
    elif hsts > 0:
        print(f" HSTS enabled: {hsts:,} seconds")
    
    return issues

def check_allowed_hosts():
    """Verify ALLOWED_HOSTS configuration"""
    print("\n=== ALLOWED HOSTS ===")
    issues = []
    
    if '*' in settings.ALLOWED_HOSTS and not settings.DEBUG:
        issues.append(" CRITICAL: ALLOWED_HOSTS=['*'] in production!")
    elif '*' in settings.ALLOWED_HOSTS:
        print("  ALLOWED_HOSTS=['*'] (development only)")
    else:
        print(f" ALLOWED_HOSTS: {settings.ALLOWED_HOSTS}")
    
    return issues

def main():
    print("=" * 60)
    print("GELMATH SECURITY AUDIT - Encryption & Configuration Check")
    print("=" * 60)
    
    all_issues = []
    
    all_issues.extend(check_password_encryption())
    all_issues.extend(check_jwt_security())
    all_issues.extend(check_https_settings())
    all_issues.extend(check_allowed_hosts())
    
    print("\n" + "=" * 60)
    print("AUDIT SUMMARY")
    print("=" * 60)
    
    if all_issues:
        print(f"\n  Found {len(all_issues)} security issues:\n")
        for issue in all_issues:
            print(f"  {issue}")
        
        print("\n SECURITY AUDIT FAILED")
        print("\nFix these issues before production deployment!")
        print("See: settings_production.py and .env.production.template")
        sys.exit(1)
    else:
        print("\n ALL SECURITY CHECKS PASSED")
        print("\nEncryption is properly configured!")
        if settings.DEBUG:
            print("\nWARNING  Note: Running in DEBUG mode (development)")
            print("   Use settings_production.py for production")
        sys.exit(0)

if __name__ == '__main__':
    main()
