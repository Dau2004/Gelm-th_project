from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/auth/', include('users.urls')),
    path('api/', include('assessments.urls')),
    path('api/analytics/', include('analytics.urls')),
    path('api/referrals/', include('referrals.urls')),
]
