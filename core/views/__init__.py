"""Представлення Learnova (розділ 1.3).

Класи на базі Django generic views (TemplateView / ListView / DetailView / UpdateView /
FormView) + невеликі View для POST/AJAX. Маршрути — у ``core/urls.py`` (namespace ``core``).
"""
from .assistant import (AssistantAskView, AssistantClearView, AssistantHistoryView,
                        AssistantView, NotificationsReadView)
from .auth import LoginView, RegisterView, SetLangView
from .catalog import CatalogView, ExploreView, RecommendationsView, SavedView
from .courses import CourseDetailView, CourseStartView, ModuleToggleView, SaveToggleView
from .pages import (DashboardView, PlanView, ProfileView, ProgressView, SettingsView,
                    SkillsView)

__all__ = [
    'AssistantAskView', 'AssistantClearView', 'AssistantHistoryView', 'AssistantView',
    'CatalogView', 'CourseDetailView', 'CourseStartView', 'DashboardView', 'ExploreView',
    'LoginView', 'ModuleToggleView', 'NotificationsReadView', 'PlanView', 'ProfileView',
    'ProgressView', 'RecommendationsView', 'RegisterView', 'SaveToggleView', 'SavedView',
    'SetLangView', 'SettingsView', 'SkillsView',
]
