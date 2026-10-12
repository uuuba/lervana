"""Представлення (розділ 1.3): сторінки застосунку та AJAX-ендпоінти."""
import json
import math

from django.contrib import messages
from django.contrib.auth import login
from django.contrib.auth.decorators import login_required
from django.contrib.auth.forms import UserCreationForm
from django.http import JsonResponse
from django.shortcuts import get_object_or_404, redirect, render
from django.utils.http import url_has_allowed_host_and_scheme
from django.views.decorators.http import require_POST

from . import i18n, recommender, services
from .models import (Course, Enrollment, Interest, Module, ModuleProgress, Notification, Profile,
                     RecentView, SavedCourse, Skill)

tr = i18n.tr


def _ajax(request):
    return request.headers.get('x-requested-with') == 'XMLHttpRequest'


def _int(value, lo, hi, default):
    try:
        return max(lo, min(hi, int(value)))
    except (TypeError, ValueError):
        return default


def _saved_ids(user):
    return set(user.saved_courses.values_list('course_id', flat=True))


# ---------- автентифікація та мова ----------
class RegisterForm(UserCreationForm):
    pass


def register(request):
    form = RegisterForm(request.POST or None)
    if request.method == 'POST' and form.is_valid():
        user = form.save()
        login(request, user)
        messages.success(request, tr('n3'))
        return redirect('profile')
    return render(request, 'core/auth.html', {'form': form, 'mode': 'register'})


def set_lang(request, code):
    if code in i18n.LANGS:
        request.session['lang'] = code
    target = request.META.get('HTTP_REFERER', '')
    if not url_has_allowed_host_and_scheme(target, {request.get_host()}):
        target = '/'
    return redirect(target)


# ---------- сторінки ----------
@login_required
def dashboard(request):
    u, prof = request.user, request.user.profile
    services.ensure_user_skills(u)
    pmap = services.progress_map(u)
    done = services.completed_ids(pmap)
    recs = recommender.recommend(u, done) if prof.interests.exists() else []
    hours = services.week_hours(u)
    hours = int(hours) if hours == int(hours) else round(hours, 1)
    return render(request, 'core/dashboard.html', {
        'profile': prof, 'recs': recs[:3], 'rec_count': len(recs), 'saved_ids': _saved_ids(u),
        'in_progress': [{'course': e.course, 'pct': round(pmap.get(e.course_id, 0) * 100)}
                        for e in u.enrollments.select_related('course') if e.course_id not in done],
        'hours': round(services.hours_done(u)), 'done_count': len(done), 'streak': services.streak(u),
        'skill_levels': u.skill_levels.select_related('skill'),
        'week_hours': hours, 'week_pct': min(100, round(services.week_hours(u) / prof.weekly_hours * 100)),
        'recent': [rv.course for rv in u.recent_views.select_related('course')[:4]],
        'gap': recommender.top_gap(u, done),
    })


def _catalog(request, mode, title_key):
    u, g = request.user, request.GET
    done = services.completed_ids(services.progress_map(u))
    saved_ids = _saved_ids(u)
    qs = Course.objects.filter(is_published=True)
    if mode == 'saved':
        qs = qs.filter(pk__in=saved_ids)
    if g.get('cat'):
        qs = qs.filter(category__key=g['cat'])
    if g.get('lvl', '').isdigit():
        qs = qs.filter(level=int(g['lvl']))
    if g.get('dur', '').isdigit():
        qs = qs.filter(duration_hours__lte=int(g['dur']))
    if g.get('fmt'):
        qs = qs.filter(format=g['fmt'])
    if g.get('skill'):
        qs = qs.filter(skills__key=g['skill'])
    recs = recommender.score_courses(u, qs.distinct())
    if mode == 'recs':
        recs = [r for r in recs if r.course.id not in done]
    if g.get('mine'):
        recs = [r for r in recs if r.matched]
    q = g.get('q', '').strip().lower()
    if q:
        recs = [r for r in recs if q in r.course.search_text]
    recs.sort(key=(lambda r: -r.score) if mode == 'recs' else (lambda r: r.course.id))
    return render(request, 'core/catalog.html', {
        'mode': mode, 'title_key': title_key, 'recs': recs, 'saved_ids': saved_ids,
        'needs_profile': mode == 'recs' and not u.profile.interests.exists(),
        'flt': {k: g.get(k, '') for k in ('cat', 'lvl', 'dur', 'fmt', 'skill', 'mine', 'q')},
        'interests': Interest.objects.all(), 'skills': Skill.objects.all(),
        'levels': [(str(v), tr(f'l{v}')) for v in (1, 2, 3)],
        'durations': [('10', tr('d10')), ('25', tr('d25'))],
        'formats': [(k, tr(k)) for k, _ in Course.FORMATS],
    })


@login_required
def explore(request):
    return _catalog(request, 'explore', 'explore')


@login_required
def recommendations(request):
    return _catalog(request, 'recs', 'recs')


@login_required
def saved(request):
    return _catalog(request, 'saved', 'saved')


@login_required
def course_detail(request, pk):
    u = request.user
    course = get_object_or_404(Course.objects.select_related('category'), pk=pk, is_published=True)
    view, _ = RecentView.objects.get_or_create(user=u, course=course)
    view.save()  # оновлює viewed_at
    rec = recommender.score_courses(u, Course.objects.filter(pk=pk))[0]
    levels = {us.skill_id: us.current_level for us in u.skill_levels.all()}
    enrollment = Enrollment.objects.filter(user=u, course=course).first()
    done_ids = set(enrollment.progress.values_list('module_id', flat=True)) if enrollment else set()
    modules = list(course.modules.all())
    return render(request, 'core/course_detail.html', {
        'course': course, 'rec': rec, 'saved_ids': _saved_ids(u), 'modules': modules,
        'prereqs': [(p, levels.get(p.skill_id, 0) >= p.min_level) for p in course.prerequisites.select_related('skill')],
        'enrolled': enrollment is not None,
        'pct': round(len(done_ids) / len(modules) * 100) if modules else 0,
        'completed': bool(modules) and len(done_ids) == len(modules),
    })


@login_required
def plan(request):
    u = request.user
    items = []
    for e in u.enrollments.select_related('course').prefetch_related('course__modules', 'progress'):
        done_ids = {p.module_id for p in e.progress.all()}
        mods = [(m, m.id in done_ids) for m in e.course.modules.all()]
        items.append({'course': e.course, 'modules': mods, 'pct': round(len(done_ids) / len(mods) * 100) if mods else 0,
                      'weeks': services.est_weeks(e.course, u.profile.weekly_hours)})
    return render(request, 'core/plan.html', {'items': items})


@login_required
def skills(request):
    u = request.user
    services.ensure_user_skills(u)
    done = services.completed_ids(services.progress_map(u))
    recs = recommender.recommend(u, done)
    rows = []
    for us in u.skill_levels.select_related('skill'):
        best = next((r.course for r in recs if us.skill in r.course.skill_list), None) if us.gap else None
        rows.append({'us': us, 'best': best})
    return render(request, 'core/skills.html', {'rows': rows})


@login_required
def progress(request):
    u = request.user
    pmap = services.progress_map(u)
    courses = Course.objects.in_bulk(pmap.keys())
    overall = round(sum(pmap.values()) / len(pmap) * 100) if pmap else 0
    return render(request, 'core/progress.html', {
        'overall': overall, 'week': services.weekly_activity(u),
        'items': [{'course': courses[cid], 'pct': round(p * 100)} for cid, p in pmap.items()],
    })


@login_required
def profile_view(request):
    u, prof = request.user, request.user.profile
    services.ensure_user_skills(u)
    if request.method == 'POST':
        p = request.POST
        ids = [int(x) for x in p.getlist('interests') if x.isdigit()]
        if not ids:
            messages.error(request, tr('errInt'))
            return redirect('profile')
        prof.display_name = p.get('display_name', '').strip()[:60]
        prof.goal = p.get('goal') if p.get('goal') in dict(Profile.GOALS) else prof.goal
        prof.preferred_format = p.get('preferred_format') if p.get('preferred_format') in dict(Course.FORMATS) else prof.preferred_format
        prof.weekly_hours = _int(p.get('weekly_hours'), 1, 30, prof.weekly_hours)
        prof.save()
        prof.interests.set(Interest.objects.filter(id__in=ids))
        for us in u.skill_levels.all():
            us.current_level = _int(p.get(f'cur_{us.skill_id}'), 0, 5, us.current_level)
            us.desired_level = _int(p.get(f'want_{us.skill_id}'), 0, 5, us.desired_level)
            us.save()
        Notification.objects.create(user=u, code='n1')
        messages.success(request, tr('okP'))
        return redirect('profile')
    return render(request, 'core/profile.html', {
        'profile': prof, 'interests': Interest.objects.all(),
        'selected': set(prof.interests.values_list('id', flat=True)),
        'skill_levels': u.skill_levels.select_related('skill'),
        'goals': [(k, tr(k)) for k, _ in Profile.GOALS],
        'formats': [(k, tr(k)) for k, _ in Course.FORMATS],
    })


@login_required
def settings_view(request):
    prof = request.user.profile
    if request.method == 'POST':
        action = request.POST.get('action')
        if action == 'reminders':
            prof.reminders = 'reminders' in request.POST
            prof.save(update_fields=['reminders'])
            messages.success(request, tr('noteSaved'))
        elif action == 'reset':
            services.reset_user_data(request.user)
            messages.success(request, tr('resetOk'))
        return redirect('settings')
    return render(request, 'core/settings.html', {'profile': prof})


@login_required
def assistant(request):
    return render(request, 'core/assistant.html', {'questions': [(str(i), tr(f'q{i}')) for i in (1, 2, 3, 4)]})


# ---------- дії (POST) ----------
@login_required
@require_POST
def course_start(request, pk):
    course = get_object_or_404(Course, pk=pk, is_published=True)
    _, created = Enrollment.objects.get_or_create(user=request.user, course=course)
    if created:
        messages.success(request, tr('started'))
    return redirect('plan')


@login_required
@require_POST
def save_toggle(request, pk):
    course = get_object_or_404(Course, pk=pk)
    obj, created = SavedCourse.objects.get_or_create(user=request.user, course=course)
    if not created:
        obj.delete()
    if _ajax(request):
        return JsonResponse({'saved': created, 'label': tr('unsave' if created else 'save'),
                             'msg': tr('saved2' if created else 'unsaved2')})
    return redirect(request.META.get('HTTP_REFERER') or 'saved')


@login_required
@require_POST
def task_toggle(request, module_id):
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
        return JsonResponse({'done': done, 'pct': pct, 'course': module.course_id, 'msg': tr('progUp')})
    return redirect('plan')


@login_required
@require_POST
def notifications_read(request):
    request.user.notifications.filter(is_read=False).update(is_read=True)
    return JsonResponse({'ok': True})


@login_required
@require_POST
def assistant_ask(request):
    try:
        data = json.loads(request.body or '{}')
    except ValueError:
        data = {}
    q = str(data.get('q', ''))
    return JsonResponse({'answer': services.assistant_answer(request.user, q if q in ('1', '2', '3', '4') else '')})
