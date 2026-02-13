from django.contrib.auth.models import AbstractUser
from django.db import models

class User(AbstractUser):
    ROLE_CHOICES = (
        ('MOH_ADMIN', 'MoH Administrator'),
        ('DOCTOR', 'Doctor'),
        ('CHW', 'Community Health Worker'),
    )
    
    role = models.CharField(max_length=20, choices=ROLE_CHOICES)
    phone = models.CharField(max_length=20, blank=True)
    facility = models.ForeignKey('Facility', on_delete=models.SET_NULL, null=True, blank=True, related_name='users')
    state = models.CharField(max_length=100, blank=True)
    is_active = models.BooleanField(default=True)
    created_by = models.ForeignKey('self', on_delete=models.SET_NULL, null=True, blank=True, related_name='created_users')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'users'
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.username} ({self.get_role_display()})"


class Facility(models.Model):
    FACILITY_TYPES = (
        ('SC_ITP', 'Stabilization Centre / Inpatient'),
        ('OTP', 'Outpatient Therapeutic Programme'),
        ('TSFP', 'Targeted Supplementary Feeding Programme'),
    )
    
    name = models.CharField(max_length=200)
    facility_type = models.CharField(max_length=20, choices=FACILITY_TYPES)
    state = models.CharField(max_length=100)
    county = models.CharField(max_length=100, blank=True)
    latitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    longitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    contact_person = models.CharField(max_length=200, blank=True)
    phone = models.CharField(max_length=20, blank=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'facilities'
        ordering = ['state', 'name']
        verbose_name_plural = 'Facilities'
    
    def __str__(self):
        return f"{self.name} ({self.state})"
