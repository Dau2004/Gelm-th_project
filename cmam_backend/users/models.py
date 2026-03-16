from django.contrib.auth.models import AbstractUser
from django.db import models

class CHWUser(AbstractUser):
    """Community Health Worker User Model"""
    ROLE_CHOICES = [
        ('MOH_ADMIN', 'MoH Administrator'),
        ('CHW', 'Community Health Worker'),
        ('DOCTOR', 'Doctor'),
    ]
    
    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default='CHW')
    phone = models.CharField(max_length=20, blank=True)
    state = models.CharField(max_length=100, blank=True)
    facility = models.CharField(max_length=200, blank=True)
    is_active_chw = models.BooleanField(default=True)
    
    # Doctor-specific fields
    doctor_title = models.CharField(max_length=100, blank=True, help_text="e.g., Pediatrician, General Practitioner")
    doctor_specialization = models.CharField(max_length=200, blank=True, help_text="e.g., Child Nutrition Specialist, Emergency Medicine")
    doctor_description = models.TextField(blank=True, help_text="Brief description of expertise and experience")
    years_experience = models.PositiveIntegerField(null=True, blank=True, help_text="Years of medical experience")
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'chw_users'
        verbose_name = 'CHW User'
        verbose_name_plural = 'CHW Users'
    
    def __str__(self):
        if self.role == 'DOCTOR' and self.doctor_title:
            return f"Dr. {self.get_full_name()} - {self.doctor_title} ({self.facility})"
        return f"{self.username} - {self.get_full_name()} ({self.facility})"
    
    @property
    def display_name_for_referral(self):
        """Display name for CHW referral selection"""
        if self.role == 'DOCTOR':
            name = f"Dr. {self.get_full_name()}"
            if self.doctor_title:
                name += f" - {self.doctor_title}"
            if self.doctor_specialization:
                name += f" ({self.doctor_specialization})"
            return name
        return self.get_full_name()
    
    @property
    def doctor_info_summary(self):
        """Summary for doctor selection in referrals"""
        if self.role != 'DOCTOR':
            return None
        
        info = []
        if self.doctor_title:
            info.append(self.doctor_title)
        if self.doctor_specialization:
            info.append(self.doctor_specialization)
        if self.years_experience:
            info.append(f"{self.years_experience} years exp.")
        
        return " | ".join(info) if info else "General Practice"
