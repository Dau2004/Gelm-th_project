from django.db import models
from django.utils import timezone
from users.models import CHWUser

class Assessment(models.Model):
    # Child information
    child_id = models.CharField(max_length=50)
    sex = models.CharField(max_length=1, choices=[('M', 'Male'), ('F', 'Female')])
    age_months = models.IntegerField()
    muac_mm = models.IntegerField()
    edema = models.IntegerField(default=0)
    appetite = models.CharField(max_length=20)
    danger_signs = models.IntegerField(default=0)
    
    # Assessment results
    muac_z_score = models.FloatField(null=True, blank=True)
    clinical_status = models.CharField(max_length=20, null=True, blank=True)
    recommended_pathway = models.CharField(max_length=20, null=True, blank=True)
    confidence = models.FloatField(null=True, blank=True)
    
    # CHW information
    chw_user = models.ForeignKey(CHWUser, on_delete=models.SET_NULL, null=True, blank=True, related_name='assessments')
    chw_username = models.CharField(max_length=150, default='')
    chw_name = models.CharField(max_length=255, default='')
    chw_phone = models.CharField(max_length=20, blank=True, default='')
    chw_facility = models.CharField(max_length=255, blank=True, default='')
    chw_state = models.CharField(max_length=100, blank=True, default='')
    chw_notes = models.TextField(blank=True, default='')
    chw_signature = models.CharField(max_length=255, blank=True, default='')
    
    # Timestamps
    assessment_date = models.DateTimeField(default=timezone.now)
    created_at = models.DateTimeField(default=timezone.now)
    synced = models.BooleanField(default=True)

    class Meta:
        ordering = ['-assessment_date']
        indexes = [
            models.Index(fields=['chw_username', '-assessment_date']),
            models.Index(fields=['child_id']),
        ]

    def __str__(self):
        return f"{self.child_id} - {self.recommended_pathway} by {self.chw_username}"
