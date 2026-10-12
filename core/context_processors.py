"""Контекст-процесори: меню навігації, мова, сповіщення, чипи «ШІ-агента»."""
from . import agent

# (URL із namespace, ключ перекладу, іконка, ключ активного пункту)
NAV = [
    ('core:dashboard', 'dash', 'home', 'dashboard'),
    ('core:explore', 'explore', 'compass', 'explore'),
    ('core:recommendations', 'recs', 'spark', 'recommendations'),
    ('core:plan', 'plan', 'list', 'plan'),
    ('core:skills', 'skills', 'target', 'skills'),
    ('core:progress', 'prog', 'trend', 'progress'),
    ('core:saved', 'saved', 'bookmark', 'saved'),
    ('core:assistant', 'assistant', 'chat', 'assistant'),
    ('core:profile', 'profile', 'user', 'profile'),
    ('core:settings', 'settings', 'sliders', 'settings'),
]
ALIAS = {'course': 'explore', 'course_start': 'explore', 'save_toggle': 'explore',
         'task_toggle': 'plan', 'assistant_ask': 'assistant', 'assistant_clear': 'assistant',
         'assistant_history': 'assistant'}


def ui(request):
    match = getattr(request, 'resolver_match', None)
    name = match.url_name if match else ''
    active = ALIAS.get(name, name)
    ctx = {'LANG': getattr(request, 'lang', 'uk'), 'NAV': NAV, 'nav_active': active}
    if request.user.is_authenticated:
        ctx['notifications'] = list(request.user.notifications.all()[:6])
        ctx['unread'] = request.user.notifications.filter(is_read=False).count()
    # чипи для віджета «порадитись з агентом» (з таблиці AgentKnowledge)
    try:
        ctx['agent_chips'] = [agent.question_for_lang(p) for p in agent.quick_questions(3)]
    except Exception:  # БД ще не мігрована (наприклад, під час manage.py migrate)
        ctx['agent_chips'] = []
    return ctx
