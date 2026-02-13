from django.db import models
from users.models import CHWUser
from assessments.models import Assessment

class Referral(models.Model):
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('accepted', 'Accepted'),
        ('in_progress', 'In Progress'),
        ('completed', 'Completed'),
        ('rejected', 'Rejected'),
    ]
    
    assessment = models.ForeignKey(Assessment, on_delete=models.CASCADE, related_name='referrals')
    child_id = models.CharField(max_length=50)
    pathway = models.CharField(max_length=50)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    notes = models.TextField(blank=True, null=True)
    
    # CHW info
    chw_user = models.ForeignKey(CHWUser, on_delete=models.SET_NULL, null=True, related_name='referrals_created')
    chw_username = models.CharField(max_length=150, blank=True)
    chw_name = models.CharField(max_length=255, blank=True)
    chw_facility = models.CharField(max_length=255, blank=True)
    chw_state = models.CharField(max_length=100, blank=True)
    
    # Doctor info
    doctor_user = models.ForeignKey(CHWUser, on_delete=models.SET_NULL, null=True, blank=True, related_name='referrals_handled')
    doctor_notes = models.TextField(blank=True, null=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ['-created_at']
    
    def __str__(self):
        return f"Referral {self.id} - {self.child_id} ({self.status})"
