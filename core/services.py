"""Допоміжна бізнес-логіка: прогрес, статистика, план, скидання даних.

Відповіді «ШІ-агента» винесено в окремий модуль ``core.agent`` (там само
працює база знань AgentKnowledge та збереження діалогу в ChatMessage).
"""
import math
from datetime import timedelta

from django.db.models import Count
from django.utils import timezone

from . import i18n
from .models import Enrollment, Module, ModuleProgress, Skill, UserSkill


def ensure_user_skills(user):
    have = set(user.skill_levels.values_list('skill_id', flat=True))
    UserSkill.objects.bulk_create([UserSkill(user=user, skill=s) for s in Skill.objects.exclude(id__in=have)])


def progress_map(user):
    """{course_id: частка виконаних модулів 0..1} для курсів, що проходить користувач."""
    rows = (Enrollment.objects.filter(user=user)
            .annotate(total=Count('course__modules', distinct=True), done=Count('progress', distinct=True))
            .values_list('course_id', 'total', 'done'))
    return {cid: (done / total if total else 0) for cid, total, done in rows}


def completed_ids(pmap):
    return {cid for cid, p in pmap.items() if p >= 1}


def _module_counts():
    return dict(Module.objects.values('course').annotate(n=Count('id')).values_list('course', 'n'))


def _hours(progress_qs):
    counts = _module_counts()
    return sum(p.module.course.duration_hours / counts[p.module.course_id]
               for p in progress_qs.select_related('module__course'))


def hours_done(user):
    return _hours(ModuleProgress.objects.filter(enrollment__user=user))


def week_start():
    today = timezone.localdate()
    return today - timedelta(days=today.weekday())


def week_hours(user):
    since = timezone.make_aware(timezone.datetime.combine(week_start(), timezone.datetime.min.time()))
    return _hours(ModuleProgress.objects.filter(enrollment__user=user, completed_at__gte=since))


def active_dates(user):
    return {timezone.localtime(dt).date() for dt in
            ModuleProgress.objects.filter(enrollment__user=user).values_list('completed_at', flat=True)}


def streak(user):
    days, day, n = active_dates(user), timezone.localdate(), 0
    if day not in days:
        day -= timedelta(days=1)
    while day in days:
        n, day = n + 1, day - timedelta(days=1)
    return n


def weekly_activity(user):
    """Кількість виконаних модулів по днях поточного тижня (Пн..Нд) для діаграми."""
    start, counts = week_start(), [0] * 7
    for dt in ModuleProgress.objects.filter(enrollment__user=user).values_list('completed_at', flat=True):
        idx = (timezone.localtime(dt).date() - start).days
        if 0 <= idx < 7:
            counts[idx] += 1
    labels = i18n.tr('days').split(',')
    return [{'label': labels[i], 'n': n, 'h': n * 28 + 4} for i, n in enumerate(counts)]


def est_weeks(course, weekly_hours):
    return math.ceil(course.duration_hours / max(1, weekly_hours))


def reset_user_data(user):
    """Скинути навчальні дані користувача (для демонстрації порожніх станів)."""
    user.profile.interests.clear()
    user.enrollments.all().delete()
    user.saved_courses.all().delete()
    user.recent_views.all().delete()
    user.notifications.all().delete()
    user.skill_levels.update(current_level=0, desired_level=0)
