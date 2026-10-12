"""Маршрутизація Learnova (namespace ``core``).

Групування: сторінки → курси → API агента → акаунт/мова.
Імена маршрутів викликаються як ``{% url 'core:dashboard' %}`` / ``reverse('core:course')``.
"""
from django.contrib.auth.views import LogoutView
from django.urls import path

from . import views

app_name = 'core'

urlpatterns = [
    # ---- сторінки (generic views) ----
    path('', views.DashboardView.as_view(), name='dashboard'),
    path('explore/', views.ExploreView.as_view(), name='explore'),
    path('recommendations/', views.RecommendationsView.as_view(), name='recommendations'),
    path('saved/', views.SavedView.as_view(), name='saved'),
    path('plan/', views.PlanView.as_view(), name='plan'),
    path('skills/', views.SkillsView.as_view(), name='skills'),
    path('progress/', views.ProgressView.as_view(), name='progress'),
    path('assistant/', views.AssistantView.as_view(), name='assistant'),
    path('profile/', views.ProfileView.as_view(), name='profile'),
    path('settings/', views.SettingsView.as_view(), name='settings'),

    # ---- курси ----
    path('course/<int:pk>/', views.CourseDetailView.as_view(), name='course'),
    path('course/<int:pk>/start/', views.CourseStartView.as_view(), name='course_start'),
    path('course/<int:pk>/save/', views.SaveToggleView.as_view(), name='save_toggle'),
    path('module/<int:module_id>/toggle/', views.ModuleToggleView.as_view(), name='task_toggle'),

    # ---- API «ШІ-агента» та сповіщення ----
    path('assistant/api/ask/', views.AssistantAskView.as_view(), name='assistant_ask'),
    path('assistant/api/history/', views.AssistantHistoryView.as_view(), name='assistant_history'),
    path('assistant/api/clear/', views.AssistantClearView.as_view(), name='assistant_clear'),
    path('notifications/read/', views.NotificationsReadView.as_view(), name='notifications_read'),

    # ---- акаунт та мова ----
    path('login/', views.LoginView.as_view(), name='login'),
    path('logout/', LogoutView.as_view(), name='logout'),
    path('register/', views.RegisterView.as_view(), name='register'),
    path('lang/<str:code>/', views.SetLangView.as_view(), name='set_lang'),
]
