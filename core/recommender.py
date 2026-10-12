"""Прозорий рекомендаційний модуль (розділ 1.3).

Оцінка збігу (0–100) — проста пояснювана формула, а не «чорна скринька»:
  інтереси 40 + закриття прогалин 30 + відповідність рівня 20 + формат 10.
"""
from dataclasses import dataclass

from django.db.models import Prefetch

from . import i18n
from .models import Course, CourseSkill


@dataclass
class Rec:
    course: Course
    score: int
    matched: list   # інтереси користувача, що збігаються з тегами курсу
    gaps: list      # навички курсу, де бажаний рівень вищий за поточний
    fit: float      # 0..1 — наскільки рівень курсу відповідає рівню користувача


def _prepare(qs):
    links = CourseSkill.objects.select_related('skill').order_by('order')
    return qs.select_related('category').prefetch_related('interests', Prefetch('courseskill_set', queryset=links, to_attr='skill_links'))


def user_context(user):
    profile = user.profile
    return {
        'interests': set(profile.interests.values_list('id', flat=True)),
        'levels': {us.skill_id: (us.current_level, us.desired_level) for us in user.skill_levels.all()},
        'format': profile.preferred_format,
    }


def score(course, ctx):
    tags = list(course.interests.all())
    skills = [link.skill for link in course.skill_links]
    level = lambda s: ctx['levels'].get(s.id, (0, 0))  # noqa: E731
    matched = [i for i in tags if i.id in ctx['interests']]
    gaps = [s for s in skills if level(s)[1] > level(s)[0]]
    current = level(skills[0])[0] if skills else 0
    fit = max(0.0, 1 - abs(current - course.level * 1.5) / 3)
    points = (len(matched) / len(tags) * 40 if tags else 0) + (len(gaps) / len(skills) * 30 if skills else 0)
    points += fit * 20 + (10 if course.format == ctx['format'] else 0)
    return Rec(course, round(min(100, points)), matched, gaps, fit)


def score_courses(user, queryset):
    ctx = user_context(user)
    return [score(c, ctx) for c in _prepare(queryset)]


def recommend(user, exclude=()):
    """Відсортований за збігом список Rec (без вже завершених курсів)."""
    recs = score_courses(user, Course.objects.filter(is_published=True))
    return sorted((r for r in recs if r.course.id not in exclude), key=lambda r: -r.score)


def best_for_skill(user, skill, exclude=()):
    recs = [r for r in recommend(user, exclude) if skill in r.course.skill_list]
    return recs[0].course if recs else None


def top_gap(user, exclude=()):
    """Найбільша прогалина користувача + найкращий курс, що її закриває."""
    best = None
    for us in user.skill_levels.select_related('skill'):
        if us.gap > 0 and (best is None or us.gap > best.gap):
            best = us
    if not best:
        return None
    course = best_for_skill(user, best.skill, exclude)
    return {'skill': best.skill, 'cur': best.current_level, 'want': best.desired_level, 'course': course} if course else None


def why_text(rec):
    return i18n.tr(
        'whyTxt',
        ', '.join(i.name for i in rec.matched) or '—',
        ', '.join(s.name for s in rec.gaps) or '—',
        i18n.tr('fitOk' if rec.fit > .5 else 'fitUp'),
    )
