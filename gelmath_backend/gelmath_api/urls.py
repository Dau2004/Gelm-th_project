from django.contrib import admin
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenRefreshView
from accounts.views import UserViewSet, FacilityViewSet
from accounts.auth_views import CustomTokenObtainPairView
from assessments.views import AssessmentViewSet, TreatmentRecordViewSet, ReferralViewSet, explain_prediction
from assessments.analytics_views import national_summary, state_trends, time_series, chw_performance, doctor_performance, facility_stats
from assessments.forecast_views import forecast_trends

router = DefaultRouter()
router.register(r'users', UserViewSet)
router.register(r'facilities', FacilityViewSet)
router.register(r'assessments', AssessmentViewSet)
router.register(r'treatments', TreatmentRecordViewSet)
router.register(r'referrals', ReferralViewSet)

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/auth/login/', CustomTokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/auth/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('api/analytics/national-summary/', national_summary),
    path('api/analytics/state-trends/', state_trends),
    path('api/analytics/time-series/', time_series),
    path('api/analytics/chw-performance/', chw_performance),
    path('api/analytics/doctor-performance/', doctor_performance),
    path('api/analytics/facility/<int:facility_id>/', facility_stats),
    path('api/analytics/forecast/', forecast_trends),
    path('api/assessments/explain/', explain_prediction, name='explain_prediction'),
    path('api/', include(router.urls)),
]
