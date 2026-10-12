"""Сторінки застосунку на базі generic views (TemplateView / UpdateView)."""
from django.contrib import messages
from django.shortcuts import redirect
from django.urls import reverse_lazy
from django.views.generic import TemplateView, UpdateView

from .. import i18n, recommender, services
from ..forms import ProfileForm
from ..models import Course, Notification, Profile
from .base import LoginRequiredMixin, PageView, SavedIdsMixin

tr = i18n.tr


class DashboardView(SavedIdsMixin, PageView):
    """Панель: вітання, статистика, рекомендації, активні курси, інсайт."""
    template_name = 'core/dashboard.html'

    def get_context_data(self, **kwargs):
        ctx = super().get_context_data(**kwargs)
        u, prof = self.request.user, self.request.user.profile
        services.ensure_user_skills(u)
        pmap = services.progress_map(u)
        done = services.completed_ids(pmap)
        recs = recommender.recommend(u, done) if prof.interests.exists() else []
        hours = services.week_hours(u)
        ctx.update({
            'profile': prof,
            'recs': recs[:3],
            'rec_count': len(recs),
            'in_progress': [{'course': e.course, 'pct': round(pmap.get(e.course_id, 0) * 100)}
                            for e in u.enrollments.select_related('course') if e.course_id not in done],
            'hours': int(hours) if hours == int(hours) else round(hours, 1),
            'done_count': len(done),
            'streak': services.streak(u),
            'skill_levels': u.skill_levels.select_related('skill'),
            'week_hours': hours,
            'week_pct': min(100, round(hours / prof.weekly_hours * 100)),
            'recent': [rv.course for rv in u.recent_views.select_related('course')[:4]],
            'gap': recommender.top_gap(u, done),
        })
        return ctx


class PlanView(SavedIdsMixin, PageView):
    """План навчання: курси, модулі та відмітки виконаного."""
    template_name = 'core/plan.html'

    def get_context_data(self, **kwargs):
        ctx = super().get_context_data(**kwargs)
        u = self.request.user
        items = []
        for e in u.enrollments.select_related('course').prefetch_related('course__modules', 'progress'):
            done_ids = {p.module_id for p in e.progress.all()}
            mods = [(m, m.id in done_ids) for m in e.course.modules.all()]
            items.append({
                'course': e.course, 'modules': mods,
                'pct': round(len(done_ids) / len(mods) * 100) if mods else 0,
                'weeks': services.est_weeks(e.course, u.profile.weekly_hours),
            })
        ctx['items'] = items
        return ctx


class SkillsView(PageView):
    """Самооцінка навичок + найкращий курс для кожної прогалини."""
    template_name = 'core/skills.html'

    def get_context_data(self, **kwargs):
        ctx = super().get_context_data(**kwargs)
        u = self.request.user
        services.ensure_user_skills(u)
        recs = recommender.recommend(u, services.completed_ids(services.progress_map(u)))
        ctx['rows'] = [
            {'us': us,
             'best': next((r.course for r in recs if us.skill in r.course.skill_list), None) if us.gap else None}
            for us in u.skill_levels.select_related('skill')
        ]
        return ctx


class ProgressView(PageView):
    """Загальний прогрес і активність за тиждень."""
    template_name = 'core/progress.html'

    def get_context_data(self, **kwargs):
        ctx = super().get_context_data(**kwargs)
        u = self.request.user
        pmap = services.progress_map(u)
        by_id = Course.objects.in_bulk(pmap.keys())
        ctx.update({
            'overall': round(sum(pmap.values()) / len(pmap) * 100) if pmap else 0,
            'week': services.weekly_activity(u),
            'items': [{'course': by_id[cid], 'pct': round(p * 100)} for cid, p in pmap.items()],
        })
        return ctx


class ProfileView(LoginRequiredMixin, UpdateView):
    """Профіль: класичний UpdateView із ModelForm (інтереси, мета, рівні)."""
    model = Profile
    form_class = ProfileForm
    template_name = 'core/profile.html'
    success_url = reverse_lazy('core:profile')

    def get_object(self, queryset=None):
        return self.request.user.profile

    def get_context_data(self, **kwargs):
        ctx = super().get_context_data(**kwargs)
        u = self.request.user
        services.ensure_user_skills(u)
        ctx.update({
            'profile': self.object,
            'interests': ctx['form'].fields['interests'].queryset,
            'selected': set(self.object.interests.values_list('id', flat=True)),
            'skill_levels': u.skill_levels.select_related('skill'),
            'goals': [(k, tr(k)) for k, _ in Profile.GOALS],
            'formats': [(k, tr(k)) for k, _ in Course.FORMATS],
        })
        return ctx

    def form_valid(self, form):
        u = self.request.user
        for us in u.skill_levels.all():
            cur = form.data.get(f'cur_{us.skill_id}')
            want = form.data.get(f'want_{us.skill_id}')
            us.current_level = _bounded(cur, 0, 5, us.current_level)
            us.desired_level = _bounded(want, 0, 5, us.desired_level)
            us.save()
        response = super().form_valid(form)
        Notification.objects.create(user=u, code='n1')
        messages.success(self.request, tr('okP'))
        return response

    def form_invalid(self, form):
        if self.request.method == 'POST':
            messages.error(self.request, tr('errInt'))
            return redirect('core:profile')
        return super().form_invalid(form)


def _bounded(value, lo, hi, default):
    try:
        return max(lo, min(hi, int(value)))
    except (TypeError, ValueError):
        return default


class SettingsView(PageView):
    """Налаштування: мова, тема, нагадування, скидання демо-даних."""
    template_name = 'core/settings.html'

    def get_context_data(self, **kwargs):
        ctx = super().get_context_data(**kwargs)
        ctx['profile'] = self.request.user.profile
        return ctx

    def post(self, request, *args, **kwargs):
        prof = request.user.profile
        action = request.POST.get('action')
        if action == 'reminders':
            prof.reminders = 'reminders' in request.POST
            prof.save(update_fields=['reminders'])
            messages.success(request, tr('noteSaved'))
        elif action == 'reset':
            services.reset_user_data(request.user)
            messages.success(request, tr('resetOk'))
        return redirect('core:settings')
