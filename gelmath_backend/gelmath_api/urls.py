from django.contrib import admin
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from accounts.views import UserViewSet, FacilityViewSet
from assessments.views import AssessmentViewSet, TreatmentRecordViewSet
from analytics.views import (NationalSummaryView, StateTrendsView, 
                             TimeSeriesView, FacilityStatsView)

router = DefaultRouter()
router.register(r'users', UserViewSet)
router.register(r'facilities', FacilityViewSet)
router.register(r'assessments', AssessmentViewSet)
router.register(r'treatments', TreatmentRecordViewSet)

urlpatterns = [
    path('admin/', admin.site.urls),
    
    # Authentication
    path('api/auth/login/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/auth/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    
    # API Routes
    path('api/', include(router.urls)),
    
    # Analytics
    path('api/analytics/national-summary/', NationalSummaryView.as_view()),
    path('api/analytics/state-trends/', StateTrendsView.as_view()),
    path('api/analytics/time-series/', TimeSeriesView.as_view()),
    path('api/analytics/facility/<int:facility_id>/', FacilityStatsView.as_view()),
]
