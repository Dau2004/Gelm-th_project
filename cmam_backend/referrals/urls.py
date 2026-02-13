from django.urls import path
from .views import ReferralViewSet

urlpatterns = [
    path('', ReferralViewSet.as_view({'get': 'list', 'post': 'create'}), name='referral-list'),
    path('bulk_create/', ReferralViewSet.as_view({'post': 'bulk_create'}), name='referral-bulk'),
    path('<int:pk>/', ReferralViewSet.as_view({'get': 'retrieve', 'put': 'update', 'patch': 'partial_update', 'delete': 'destroy'}), name='referral-detail'),
    path('<int:pk>/update_status/', ReferralViewSet.as_view({'patch': 'update_status'}), name='referral-update-status'),
]
