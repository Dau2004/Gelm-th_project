from django.contrib import admin
from .models import Assessment

@admin.register(Assessment)
class AssessmentAdmin(admin.ModelAdmin):
    list_display = ['child_id', 'sex', 'age_months', 'muac_mm', 'clinical_status', 
                    'recommended_pathway', 'chw_username', 'assessment_date']
    list_filter = ['recommended_pathway', 'clinical_status', 'sex', 'synced', 'chw_state']
    search_fields = ['child_id', 'chw_username', 'chw_name']
    readonly_fields = ['created_at']
    fieldsets = (
        ('Child Information', {
            'fields': ('child_id', 'sex', 'age_months', 'muac_mm', 'edema', 'appetite', 'danger_signs')
        }),
        ('Assessment Results', {
            'fields': ('muac_z_score', 'clinical_status', 'recommended_pathway', 'confidence')
        }),
        ('CHW Information', {
            'fields': ('chw_username', 'chw_name', 'chw_phone', 'chw_facility', 'chw_state', 'chw_notes', 'chw_signature')
        }),
        ('Metadata', {
            'fields': ('assessment_date', 'created_at', 'synced')
        }),
    )
