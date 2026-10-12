from django.contrib.auth import views as auth_views
from django.urls import path

from . import views

urlpatterns = [
    path('', views.dashboard, name='dashboard'),
    path('explore/', views.explore, name='explore'),
    path('recommendations/', views.recommendations, name='recommendations'),
    path('plan/', views.plan, name='plan'),
    path('skills/', views.skills, name='skills'),
    path('progress/', views.progress, name='progress'),
    path('saved/', views.saved, name='saved'),
    path('assistant/', views.assistant, name='assistant'),
    path('assistant/ask/', views.assistant_ask, name='assistant_ask'),
    path('profile/', views.profile_view, name='profile'),
    path('settings/', views.settings_view, name='settings'),
    path('course/<int:pk>/', views.course_detail, name='course'),
    path('course/<int:pk>/start/', views.course_start, name='course_start'),
    path('course/<int:pk>/save/', views.save_toggle, name='save_toggle'),
    path('module/<int:module_id>/toggle/', views.task_toggle, name='task_toggle'),
    path('notifications/read/', views.notifications_read, name='notifications_read'),
    path('lang/<str:code>/', views.set_lang, name='set_lang'),
    path('login/', auth_views.LoginView.as_view(template_name='core/auth.html', extra_context={'mode': 'login'}), name='login'),
    path('logout/', auth_views.LogoutView.as_view(), name='logout'),
    path('register/', views.register, name='register'),
]
