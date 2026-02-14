from django.contrib import admin
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenRefreshView
from accounts.views import UserViewSet, FacilityViewSet
from accounts.auth_views import CustomTokenObtainPairView
from assessments.views import AssessmentViewSet, TreatmentRecordViewSet, ReferralViewSet
from assessments.analytics_views import national_summary, state_trends, time_series, chw_performance, doctor_performance

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
    path('api/', include(router.urls)),
    path('api/analytics/national-summary/', national_summary),
    path('api/analytics/state-trends/', state_trends),
    path('api/analytics/time-series/', time_series),
    path('api/analytics/chw-performance/', chw_performance),
    path('api/analytics/doctor-performance/', doctor_performance),
]
