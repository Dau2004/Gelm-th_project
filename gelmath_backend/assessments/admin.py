from django.contrib import admin
from .models import Assessment, TreatmentRecord


@admin.register(Assessment)
class AssessmentAdmin(admin.ModelAdmin):
    list_display = ['child_id', 'clinical_status', 'recommended_pathway', 'state', 'facility', 'timestamp']
    list_filter = ['clinical_status', 'recommended_pathway', 'state', 'timestamp']
    search_fields = ['child_id', 'chw_name']
    date_hierarchy = 'timestamp'


@admin.register(TreatmentRecord)
class TreatmentRecordAdmin(admin.ModelAdmin):
    list_display = ['assessment', 'doctor', 'status', 'admission_date', 'discharge_date']
    list_filter = ['status', 'admission_date']
    search_fields = ['assessment__child_id', 'doctor__username']
