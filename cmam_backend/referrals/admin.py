from django.contrib import admin
from .models import Referral

@admin.register(Referral)
class ReferralAdmin(admin.ModelAdmin):
    list_display = ['id', 'child_id', 'pathway', 'status', 'chw_name', 'chw_state', 'created_at']
    list_filter = ['status', 'pathway', 'chw_state']
    search_fields = ['child_id', 'chw_name', 'chw_username']
