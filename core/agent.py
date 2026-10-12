"""«ШІ-агент» Learnova — пародія на AI-асистента (розділ 1.3).

Тут немає жодної нейромережі та жодного зовнішнього API. Алгоритм простий:
  1) нормалізуємо запитання та визначаємо «намір» (інтент) за ключовими словами;
  2) відповідь збирається з реальних таблиць бази даних (ORM-запити);
  3) якщо наміру немає — шукаємо у базі знань ``AgentKnowledge`` за ключовими словами;
  4) якщо й там порожньо — відповідаємо «не знаю» та підказуємо приклади.

Кожен діалог зберігається в ``ChatSession`` / ``ChatMessage``, тобто історія живе в БД.
"""
import re
from dataclasses import dataclass, field

from django.db.models import Count, F, Sum

from . import i18n, recommender, services
from .models import (AgentKnowledge, ChatMessage, ChatSession, Course, Enrollment, Interest,
                     Skill)

tr = i18n.tr
_PUNCT = re.compile(r'[^\w\sіїєґ\'-]+', re.UNICODE)


@dataclass
class Answer:
    text: str
    source: str = 'db'            # db | kb | fallback
    tables: tuple = ()            # які таблиці «дивився» агент (для підписи під відповіддю)
    chips: list = field(default_factory=list)


def _norm(text):
    return _PUNCT.sub(' ', (text or '').lower().replace('ё', 'е')).strip()


def _has(words, tokens):
    """Збіг за словом або його початком (легкий стеммінг для української)."""
    for w in words:
        if w in tokens:
            return True
        if len(w) >= 4 and any(w in t for t in tokens):
            return True
    return False


def _list(items, limit=4):
    items = list(items)
    text = ', '.join(f'«{i}»' for i in items[:limit])
    if len(items) > limit:
        text += f' (+{len(items) - limit})'
    return text


def _example_questions(limit=3):
    rows = list(AgentKnowledge.objects.filter(is_active=True)[:limit].values_list('question_uk', 'question_en'))
    idx = 0 if i18n.get_lang() == 'uk' else 1
    picked = [r[idx] for r in rows]
    return _list(picked, limit) if picked else tr('ask')


# ---------- наміри (усе рахується з таблиць бази даних) ----------

def _intent_help(user, q, tokens):
    if _has(('допом', 'help', 'what can', 'можеш', 'уміє', 'команд', 'command'), tokens):
        return Answer(tr('agHelp'), 'db', ('agentknowledge',))
    return None


def _intent_greet(user, q, tokens):
    if len(tokens) >= 7:
        return None
    if _has(('привіт', 'віта', 'hello', 'добр', 'good'), tokens):
        return Answer(tr('agGreet'), 'db', ('course',))
    if _has(('дяк', 'thank'), tokens):
        return Answer(tr('agThanks'), 'db', ())
    return None


def _intent_catalog_stats(user, q, tokens):
    if not _has(('скільки', 'кільк', 'how many', 'count'), tokens):
        return None
    if not _has (('курс', 'course', 'каталог', 'catalog', 'навчан'), tokens):
        return None
    qs = Course.objects.filter(is_published=True)
    total = qs.count()
    if not total:
        return Answer(tr('agNoCatalog'), 'db', ('course',))
    cats = Interest.objects.filter(courses__is_published=True).distinct().count()
    skills = Skill.objects.filter(courses__is_published=True).distinct().count()
    hours = qs.aggregate(s=Sum('duration_hours'))['s'] or 0
    longest = max(qs, key=lambda c: c.duration_hours)
    shortest = min(qs, key=lambda c: c.duration_hours)
    return Answer(tr('agCourses', total, cats, skills, hours, longest.title, shortest.title),
                  'db', ('course', 'interest'))


def _find_course(q, tokens):
    """Знайти курс, назва якого згадується у запитанні."""
    best = None
    for c in Course.objects.filter(is_published=True).select_related('category'):
        title = _norm(c.title)
        if title and title in q:
            return c
        hits = sum(1 for w in title.split() if len(w) > 3 and w in tokens)
        if hits and (best is None or hits > best[0]):
            best = (hits, c)
    return best[1] if best else None


def _intent_course(user, q, tokens):
    course = _find_course(q, tokens)
    if course is None:
        return None
    enrollment = None
    if getattr(user, 'is_authenticated', False):
        enrollment = Enrollment.objects.filter(user=user, course=course).first()
    done = bool(enrollment) and course.modules.count() > 0 and \
        enrollment.progress.count() == course.modules.count()
    state = tr('agCourseDone') if done else (tr('agCourseStarted') if enrollment else tr('agCourseNew'))
    prereqs = [f'{p.skill.name} ≥ {p.min_level}' for p in course.prerequisites.select_related('skill')]
    text = tr('agCourse', course.title, tr(f'l{course.level}'), course.duration_hours,
              tr(course.format), ', '.join(s.name for s in course.skill_list) or '—',
              course.modules.count(), state)
    if prereqs:
        text += ' ' + tr('agCoursePrereq', ', '.join(prereqs))
    return Answer(text, 'db', ('course', 'module', 'prerequisite'))


def _intent_recommend(user, q, tokens):
    if not _has(('рекоменд', 'порад', 'recommend', 'suggest', 'what should', 'навчатис', 'radit'), tokens):
        return None
    if not getattr(user, 'is_authenticated', False):
        return Answer(tr('agAnon', _example_questions()), 'db', ('course',))
    done = services.completed_ids(services.progress_map(user))
    recs = recommender.recommend(user, done)
    if not recs:
        return Answer(tr('emptyP'), 'db', ('course',))
    top = ', '.join(f'«{r.course.title}» — {r.score}%' for r in recs[:3])
    return Answer(tr('agRecs', len(recs), top, recommender.why_text(recs[0])),
                  'db', ('course', 'userskill', 'profile'))


def _intent_gaps(user, q, tokens):
    if not _has (('навичк', 'прогалин', 'skill', 'gap', 'бракує', 'компетент'), tokens):
        return None
    if not getattr(user, 'is_authenticated', False):
        return Answer(tr('agAnon', _example_questions()), 'db', ('userskill',))
    done = services.completed_ids(services.progress_map(user))
    gaps = sorted((us for us in user.skill_levels.select_related('skill') if us.gap > 0),
                  key=lambda us: -us.gap)
    if not gaps:
        return Answer(tr('noGap'), 'db', ('userskill',))
    names = ', '.join(f'{us.skill.name} ({us.current_level}→{us.desired_level})' for us in gaps[:5])
    best = recommender.best_for_skill(user, gaps[0].skill, done)
    tail = tr('agGapBest', best.title) if best else ''
    return Answer((tr('agGaps', names) + ' ' + tail).strip(), 'db', ('userskill', 'course'))


def _intent_progress(user, q, tokens):
    if not _has(('прогрес', 'progress', 'досягнен', 'статист', 'streak', 'сері', 'виконан'), tokens):
        return None
    if not getattr(user, 'is_authenticated', False):
        return Answer(tr('agAnon', _example_questions()), 'db', ('moduleprogress',))
    pmap = services.progress_map(user)
    if not pmap:
        return Answer(tr('agNoProgress'), 'db', ('enrollment',))
    done = services.completed_ids(pmap)
    hours = services.hours_done(user)
    hours = int(hours) if hours == int(hours) else round(hours, 1)
    overall = round(sum(pmap.values()) / len(pmap) * 100)
    return Answer(tr('agProgress', len(done), len(pmap), hours, services.streak(user), overall,
                     services.week_hours(user)),
                  'db', ('enrollment', 'moduleprogress'))


def _intent_plan(user, q, tokens):
    if not _has(('план', 'розклад', 'schedule', 'plan', 'тижд', 'week'), tokens):
        return None
    if not getattr(user, 'is_authenticated', False):
        return Answer(tr('agAnon', _example_questions()), 'db', ('enrollment',))
    done = services.completed_ids(services.progress_map(user))
    active = [e.course for e in user.enrollments.select_related('course') if e.course_id not in done]
    if not active:
        return Answer(tr('a3none'), 'db', ('enrollment',))
    hours = user.profile.weekly_hours
    per = max(1, round(hours / len(active)))
    parts = [f'«{c.title}» — {per} {tr("hrs")} (~{services.est_weeks(c, hours)} {tr("wks")})' for c in active]
    return Answer(tr('agPlan', hours, '; '.join(parts)), 'db', ('enrollment', 'profile'))


def _intent_compare(user, q, tokens):
    if not _has(('порівня', 'compare', 'різниц'), tokens):
        return None
    if not getattr(user, 'is_authenticated', False):
        return Answer(tr('agAnon', _example_questions()), 'db', ('course',))
    done = services.completed_ids(services.progress_map(user))
    recs = recommender.recommend(user, done)
    if len(recs) < 2:
        return Answer(tr('emptyP'), 'db', ('course',))
    a, b = recs[0].course, recs[1].course
    return Answer(tr('a4', a.title, a.duration_hours, tr(f'l{a.level}'),
                     b.title, b.duration_hours, tr(f'l{b.level}')),
                  'db', ('course', 'userskill'))


def _intent_saved(user, q, tokens):
    if not _has(('збереж', 'saved', 'обран', 'вибран', 'bookmark', 'ваклин'), tokens):
        return None
    if not getattr(user, 'is_authenticated', False):
        return Answer(tr('agAnon', _example_questions()), 'db', ('savedcourse',))
    titles = [s.course.title for s in user.saved_courses.select_related('course__category')]
    if not titles:
        return Answer(tr('agNoSaved'), 'db', ('savedcourse',))
    return Answer(tr('agSaved', len(titles), _list(titles)), 'db', ('savedcourse',))


def _intent_categories(user, q, tokens):
    if not _has(('категор', 'напрям', 'categor', 'сфер', 'розділ'), tokens):
        return None
    rows = Interest.objects.filter(courses__is_published=True).annotate(n=Count('courses')).order_by('-n')
    if not rows:
        return Answer(tr('agNoCatalog'), 'db', ('interest',))
    return Answer(tr('agCats', '; '.join(f'{r.name} — {r.n}' for r in rows)),
                  'db', ('interest',))


def _intent_profile(user, q, tokens):
    if not _has(('профіль', 'profile', 'мета', 'goal', 'інтерес', 'interest'), tokens):
        return None
    if not getattr(user, 'is_authenticated', False):
        return Answer(tr('agAnon', _example_questions()), 'db', ('profile',))
    p = user.profile
    interests = ', '.join(i.name for i in p.interests.all()) or '—'
    levels = ', '.join(f'{us.skill.name} {us.current_level}/{us.desired_level}'
                       for us in user.skill_levels.select_related('skill'))
    return Answer(tr('agProfile', p.shown_name, tr(p.goal), p.weekly_hours, tr(p.preferred_format),
                     interests, levels or '—'),
                  'db', ('profile', 'userskill'))


def _intent_prereq(user, q, tokens):
    if not _has(('передумов', 'prerequisite', 'requirement', 'знати перед'), tokens):
        return None
    course = _find_course(q, tokens)
    if course is None:
        recs = recommender.recommend(user, set()) if getattr(user, 'is_authenticated', False) else []
        course = recs[0].course if recs else Course.objects.filter(is_published=True).first()
    if course is None:
        return Answer(tr('agNoCatalog'), 'db', ('course',))
    rows = [f'{p.skill.name} — {tr("needL", p.min_level)}' for p in course.prerequisites.select_related('skill')]
    return Answer(tr('agPrereq', course.title, '; '.join(rows) if rows else tr('noPre')),
                  'db', ('prerequisite', 'skill'))


INTENTS = (
    _intent_help, _intent_greet, _intent_course, _intent_catalog_stats, _intent_recommend,
    _intent_gaps, _intent_progress, _intent_plan, _intent_compare, _intent_saved,
    _intent_categories, _intent_profile, _intent_prereq,
)


# ---------- база знань (таблиця AgentKnowledge) ----------

def _match_kb(q, tokens):
    best, best_score = None, 0
    for row in AgentKnowledge.objects.filter(is_active=True):
        score = sum(1 for w in row.word_list if w in tokens or (len(w) >= 4 and any(w in t for t in tokens)))
        if _norm(row.question) in q and q:
            score += 3
        score += row.priority / 100
        if score > best_score:
            best, best_score = row, score
    return best if best_score >= 1 else None


# ---------- публічний API ----------

def ask(user, text):
    """Повертає Answer: текст із бази даних + походження відповіді."""
    raw = str(text or '').strip()
    if not raw:
        return Answer(tr('ask'), 'fallback', ())
    q, tokens = _norm(raw), set(_norm(raw).split())
    for fn in INTENTS:
        out = fn(user, q, tokens)
        if out is not None:
            return out
    row = _match_kb(q, tokens)
    if row is not None:
        AgentKnowledge.objects.filter(pk=row.pk).update(hits=F('hits') + 1)
        return Answer(row.answer, 'kb', ('agentknowledge',))
    return Answer(tr('agNone', _example_questions()), 'fallback', ('agentknowledge',))


def quick_questions(limit=5):
    """Швидкі чипи: приклади запитань із бази знань (за пріоритетом)."""
    return list(AgentKnowledge.objects.filter(is_active=True)[:limit].values_list('question_uk', 'question_en'))


def question_for_lang(pair):
    return pair[0 if i18n.get_lang() == 'uk' else 1]


def get_session(user, session_key):
    if getattr(user, 'is_authenticated', False):
        session, _ = ChatSession.objects.get_or_create(user=user, session_key='')
        return session
    session, _ = ChatSession.objects.get_or_create(user=None, session_key=session_key or 'anon')
    return session


def history(user, session_key, limit=40):
    return list(get_session(user, session_key).messages.order_by('-id')[:limit][::-1])


def save_dialogue(user, session_key, question, answer):
    """Зберігає пару «запитання → відповідь» у таблиці ChatMessage."""
    session = get_session(user, session_key)
    user_msg = ChatMessage.objects.create(session=session, role='user', content=question)
    agent_msg = ChatMessage.objects.create(session=session, role='agent', content=answer.text,
                                            source=answer.source)
    session.save(update_fields=['updated_at'])
    return user_msg, agent_msg


def clear_history(user, session_key):
    get_session(user, session_key).messages.all().delete()
