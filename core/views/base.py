"""Спільні базові класи представлень (generic views + mixins)."""
from django.contrib.auth.mixins import LoginRequiredMixin as _LoginRequiredMixin
from django.views.generic import TemplateView

from ..models import Course


class LoginRequiredMixin(_LoginRequiredMixin):
    """Логін обов'язковий для всіх сторінок застосунку."""
    login_url = 'core:login'


class SavedIdsMixin:
    """Підказує шаблону, які курси вже збережені (для кнопок «Зберегти»)."""
    saved_ids = frozenset()

    def get_saved_ids(self):
        user = self.request.user
        if not user.is_authenticated:
            return frozenset()
        return frozenset(user.saved_courses.values_list('course_id', flat=True))

    def get_context_data(self, **kwargs):
        ctx = super().get_context_data(**kwargs)
        ctx['saved_ids'] = self.get_saved_ids()
        return ctx


class PageView(LoginRequiredMixin, TemplateView):
    """Базова сторінка інтерфейсу: шаблон і контекст меню/сповіщень.

    Контекст меню, мови та сповіщень додає ``core.context_processors.ui``,
    тут лише те, що належить конкретній сторінці.
    """
    template_name = None
    heading_key = None          # ключ перекладу заголовка (якщо не задано — блок heading у шаблоні)

    def get_context_data(self, **kwargs):
        ctx = super().get_context_data(**kwargs)
        if self.heading_key:
            ctx['title_key'] = self.heading_key
        return ctx


def published_courses():
    return Course.objects.filter(is_published=True)
