"""Сторінка курсу (DetailView) та дії над курсом (View + POST)."""
from django.contrib import messages
from django.contrib.auth.mixins import LoginRequiredMixin
from django.http import JsonResponse
from django.shortcuts import get_object_or_404, redirect
from django.views import View
from django.views.generic import DetailView

from .. import i18n, recommender
from ..models import Course, Enrollment, Module, ModuleProgress, RecentView, SavedCourse
from .base import SavedIdsMixin

tr = i18n.tr


def _ajax(request):
    return request.headers.get('x-requested-with') == 'XMLHttpRequest'


class CourseDetailView(SavedIdsMixin, LoginRequiredMixin, DetailView):
    """Деталі курсу: програма, передумови, пояснення рекомендації, прогрес."""
    model = Course
    template_name = 'core/course_detail.html'
    context_object_name = 'course'
    login_url = 'core:login'
    queryset = Course.objects.select_related('category').filter(is_published=True)

    def get_object(self, queryset=None):
        obj = super().get_object(queryset)
        view, _ = RecentView.objects.get_or_create(user=self.request.user, course=obj)
        view.save()  # оновлюємо viewed_at (auto_now)
        return obj

    def get_context_data(self, **kwargs):
        ctx = super().get_context_data(**kwargs)
        u, course = self.request.user, self.object
        rec = recommender.score_courses(u, Course.objects.filter(pk=course.pk))[0]
        levels = {us.skill_id: us.current_level for us in u.skill_levels.all()}
        enrollment = Enrollment.objects.filter(user=u, course=course).first()
        done_ids = set(enrollment.progress.values_list('module_id', flat=True)) if enrollment else set()
        modules = list(course.modules.all())
        ctx.update({
            'rec': rec,
            'modules': modules,
            'prereqs': [(p, levels.get(p.skill_id, 0) >= p.min_level)
                        for p in course.prerequisites.select_related('skill')],
            'enrolled': enrollment is not None,
            'pct': round(len(done_ids) / len(modules) * 100) if modules else 0,
            'completed': bool(modules) and len(done_ids) == len(modules),
        })
        return ctx


class CourseStartView(LoginRequiredMixin, View):
    """POST: додати курс до плану навчання."""
    login_url = 'core:login'

    def post(self, request, pk):
        course = get_object_or_404(Course, pk=pk, is_published=True)
        _, created = Enrollment.objects.get_or_create(user=request.user, course=course)
        if created:
            messages.success(request, tr('started'))
        return redirect('core:plan')


class SaveToggleView(LoginRequiredMixin, View):
    """POST: зберегти / прибрати курс зі збережених (AJAX або redirect)."""
    login_url = 'core:login'

    def post(self, request, pk):
        course = get_object_or_404(Course, pk=pk)
        obj, created = SavedCourse.objects.get_or_create(user=request.user, course=course)
        if not created:
            obj.delete()
        if _ajax(request):
            return JsonResponse({'saved': created, 'label': tr('unsave' if created else 'save'),
                                 'msg': tr('saved2' if created else 'unsaved2')})
        return redirect(request.META.get('HTTP_REFERER') or 'core:saved')


class ModuleToggleView(LoginRequiredMixin, View):
    """POST: позначити модуль виконаним / скасувати (AJAX або redirect)."""
    login_url = 'core:login'

    def post(self, request, module_id):
        module = get_object_or_404(Module, pk=module_id)
        enrollment, _ = Enrollment.objects.get_or_create(user=request.user, course=module.course)
        existing = ModuleProgress.objects.filter(enrollment=enrollment, module=module)
        done = not existing.exists()
        if done:
            ModuleProgress.objects.create(enrollment=enrollment, module=module)
        else:
            existing.delete()
        total = module.course.modules.count()
        pct = round(enrollment.progress.count() / total * 100) if total else 0
        if _ajax(request):
            return JsonResponse({'done': done, 'pct': pct, 'course': module.course_id,
                                 'msg': tr('progUp')})
        return redirect('core:plan')
