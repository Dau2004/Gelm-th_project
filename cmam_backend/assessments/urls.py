from django.urls import path
from .views import AssessmentViewSet, health_check, statistics, check_quality, chw_assessment_counts

urlpatterns = [
    path('assessments/', AssessmentViewSet.as_view({'get': 'list', 'post': 'create'}), name='assessment-list'),
    path('assessments/bulk_create/', AssessmentViewSet.as_view({'post': 'bulk_create'}), name='assessment-bulk'),
    path('assessments/<int:pk>/', AssessmentViewSet.as_view({'get': 'retrieve', 'put': 'update', 'delete': 'destroy'}), name='assessment-detail'),
    path('assessments/chw-counts/', chw_assessment_counts, name='chw-assessment-counts'),
    path('health/', health_check, name='health'),
    path('statistics/', statistics, name='statistics'),
    path('check-quality/', check_quality, name='check_quality'),
]
