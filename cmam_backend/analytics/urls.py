from django.urls import path
from . import views

urlpatterns = [
    path('national-summary/', views.national_summary, name='national-summary'),
    path('state-trends/', views.state_trends, name='state-trends'),
    path('time-series/', views.time_series, name='time-series'),
]
