from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import CHWUser

@admin.register(CHWUser)
class CHWUserAdmin(UserAdmin):
    list_display = ['username', 'first_name', 'last_name', 'role', 'facility', 'state', 'is_active_chw']
    list_filter = ['role', 'state', 'is_active_chw', 'is_staff']
    search_fields = ['username', 'first_name', 'last_name', 'facility', 'phone']
    
    fieldsets = UserAdmin.fieldsets + (
        ('CHW Information', {
            'fields': ('role', 'phone', 'state', 'facility', 'is_active_chw')
        }),
    )
    
    add_fieldsets = UserAdmin.add_fieldsets + (
        ('CHW Information', {
            'fields': ('role', 'phone', 'state', 'facility', 'is_active_chw')
        }),
    )
