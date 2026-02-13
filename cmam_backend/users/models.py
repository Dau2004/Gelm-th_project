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
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'chw_users'
        verbose_name = 'CHW User'
        verbose_name_plural = 'CHW Users'
    
    def __str__(self):
        return f"{self.username} - {self.get_full_name()} ({self.facility})"
