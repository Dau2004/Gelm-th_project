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
    
    # Doctor-specific fields
    doctor_title = models.CharField(max_length=20, blank=True, help_text="e.g., Dr., Prof., Mr., Ms.")
    doctor_specialization = models.CharField(max_length=100, blank=True, help_text="e.g., Pediatrician, General Practitioner")
    doctor_description = models.TextField(blank=True, help_text="Brief description of doctor's expertise")
    years_experience = models.PositiveIntegerField(null=True, blank=True, help_text="Years of medical experience")
    
    class Meta:
        db_table = 'users'
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.username} ({self.get_role_display()})"
    
    @property
    def display_name_with_title(self):
        """Return formatted name with title for referrals"""
        if self.role == 'DOCTOR' and self.doctor_title:
            full_name = self.get_full_name() or self.username
            return f"{self.doctor_title} {full_name}"
        return self.get_full_name() or self.username
    
    @property
    def doctor_info_display(self):
        """Return formatted doctor info for display"""
        if self.role == 'DOCTOR':
            parts = []
            if self.doctor_title:
                parts.append(self.doctor_title)
            if self.doctor_specialization:
                parts.append(self.doctor_specialization)
            if self.years_experience:
                parts.append(f"{self.years_experience} years exp.")
            return " | ".join(parts) if parts else "Doctor"
        return ""


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
