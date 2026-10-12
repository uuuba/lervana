"""Каталог, рекомендації та збережене — один ListView із фільтрами GET."""
from django.contrib.auth.mixins import LoginRequiredMixin
from django.views.generic import ListView

from .. import i18n, recommender, services
from ..models import Course, Interest, Skill
from .base import SavedIdsMixin

tr = i18n.tr


class CatalogView(SavedIdsMixin, LoginRequiredMixin, ListView):
    """Спільна сторінка-каталог: фільтри з query-string + оцінка збігу."""
    model = Course
    template_name = 'core/catalog.html'
    context_object_name = 'courses'
    login_url = 'core:login'

    mode = 'explore'        # explore | recs | saved
    title_key = 'explore'

    # ---------- фільтрація ----------
    def get_queryset(self):
        g = self.request.GET
        qs = Course.objects.filter(is_published=True)
        if self.mode == 'saved':
            qs = qs.filter(pk__in=self.get_saved_ids())
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
        return qs.select_related('category').distinct()

    # ---------- контекст ----------
    def get_context_data(self, **kwargs):
        ctx = super().get_context_data(**kwargs)
        g = self.request.GET
        user = self.request.user
        done = services.completed_ids(services.progress_map(user))
        recs = recommender.score_courses(user, self.get_queryset())
        if self.mode == 'recs':
            recs = [r for r in recs if r.course.id not in done]
        if g.get('mine'):
            recs = [r for r in recs if r.matched]
        q = g.get('q', '').strip().lower()
        if q:
            recs = [r for r in recs if q in r.course.search_text]
        recs.sort(key=(lambda r: -r.score) if self.mode == 'recs' else (lambda r: r.course.id))
        ctx.update({
            'mode': self.mode,
            'title_key': self.title_key,
            'recs': recs,
            'needs_profile': self.mode == 'recs' and not user.profile.interests.exists(),
            'flt': {k: g.get(k, '') for k in ('cat', 'lvl', 'dur', 'fmt', 'skill', 'mine', 'q')},
            'interests': Interest.objects.all(),
            'skills': Skill.objects.all(),
            'levels': [(str(v), tr(f'l{v}')) for v in (1, 2, 3)],
            'durations': [('10', tr('d10')), ('25', tr('d25'))],
            'formats': [(k, tr(k)) for k, _ in Course.FORMATS],
        })
        return ctx


class ExploreView(CatalogView):
    """Каталог усіх курсів."""
    mode = 'explore'
    title_key = 'explore'


class RecommendationsView(CatalogView):
    """Персональні рекомендації (тільки незавершені, за спаданням збігу)."""
    mode = 'recs'
    title_key = 'recs'


class SavedView(CatalogView):
    """Збережені курси користувача."""
    mode = 'saved'
    title_key = 'saved'
