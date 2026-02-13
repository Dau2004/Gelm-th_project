from django.db import models
from accounts.models import User, Facility

class Assessment(models.Model):
    SEX_CHOICES = (
        ('M', 'Male'),
        ('F', 'Female'),
    )
    
    APPETITE_CHOICES = (
        ('good', 'Good'),
        ('poor', 'Poor'),
        ('failed', 'Failed'),
    )
    
    PATHWAY_CHOICES = (
        ('SC_ITP', 'Stabilization Centre / Inpatient'),
        ('OTP', 'Outpatient Therapeutic Programme'),
        ('TSFP', 'Targeted Supplementary Feeding Programme'),
        ('None', 'No Treatment Required'),
    )
    
    STATUS_CHOICES = (
        ('SAM', 'Severe Acute Malnutrition'),
        ('MAM', 'Moderate Acute Malnutrition'),
        ('Healthy', 'Healthy'),
    )
    
    # Child Information
    child_id = models.CharField(max_length=50)
    sex = models.CharField(max_length=1, choices=SEX_CHOICES)
    age_months = models.IntegerField()
    
    # Measurements
    muac_mm = models.IntegerField()
    muac_z_score = models.FloatField(null=True, blank=True)
    edema = models.IntegerField(default=0)
    
    # Clinical Assessment
    appetite = models.CharField(max_length=10, choices=APPETITE_CHOICES)
    danger_signs = models.IntegerField(default=0)
    clinical_status = models.CharField(max_length=20, choices=STATUS_CHOICES, blank=True)
    
    # AI Recommendation
    recommended_pathway = models.CharField(max_length=20, choices=PATHWAY_CHOICES, blank=True)
    confidence = models.FloatField(null=True, blank=True)
    
    # Location & CHW
    facility = models.ForeignKey(Facility, on_delete=models.SET_NULL, null=True, blank=True, related_name='assessments')
    state = models.CharField(max_length=100, blank=True)
    county = models.CharField(max_length=100, blank=True)
    chw = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, related_name='assessments')
    chw_name = models.CharField(max_length=200, blank=True)
    chw_phone = models.CharField(max_length=20, blank=True)
    chw_notes = models.TextField(blank=True)
    chw_signature = models.CharField(max_length=200, blank=True)
    
    # Doctor Assignment
    assigned_doctor = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, related_name='assigned_assessments')
    
    # Metadata
    timestamp = models.DateTimeField(auto_now_add=True)
    synced = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'assessments'
        ordering = ['-timestamp']
        indexes = [
            models.Index(fields=['timestamp']),
            models.Index(fields=['state']),
            models.Index(fields=['facility']),
            models.Index(fields=['clinical_status']),
            models.Index(fields=['child_id']),
        ]
    
    def __str__(self):
        return f"{self.child_id} - {self.clinical_status} ({self.timestamp.date()})"


class TreatmentRecord(models.Model):
    STATUS_CHOICES = (
        ('ADMITTED', 'Admitted'),
        ('IN_TREATMENT', 'In Treatment'),
        ('RECOVERED', 'Recovered'),
        ('DEFAULTED', 'Defaulted'),
        ('DIED', 'Died'),
        ('TRANSFERRED', 'Transferred'),
    )
    
    assessment = models.ForeignKey(Assessment, on_delete=models.CASCADE, related_name='treatment_records')
    doctor = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, related_name='treatments')
    status = models.CharField(max_length=20, choices=STATUS_CHOICES)
    notes = models.TextField(blank=True)
    admission_date = models.DateField(null=True, blank=True)
    discharge_date = models.DateField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'treatment_records'
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.assessment.child_id} - {self.status}"
