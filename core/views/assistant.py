"""Сторінка асистента та API «ШІ-агент» (відповіді збираються з БД)."""
import json

from django.http import JsonResponse
from django.views import View

from .. import agent, i18n
from .base import PageView

tr = i18n.tr
MAX_Q = 400


def _session_key(request):
    """Ключ сесії для історії діалогу (у гостей створюємо одразу)."""
    if not request.session.session_key:
        request.session.create()
    return request.session.session_key


def _payload(request):
    try:
        data = json.loads(request.body or '{}')
    except ValueError:
        data = {}
    if not isinstance(data, dict):
        data = {}
    return str(data.get('q') or data.get('text') or '').strip()[:MAX_Q]


class AssistantView(PageView):
    """Повноцінна сторінка діалогу: історія з ChatMessage + швидкі чипи."""
    template_name = 'core/assistant.html'

    def get_context_data(self, **kwargs):
        ctx = super().get_context_data(**kwargs)
        key = _session_key(self.request)
        ctx.update({
            'history': agent.history(self.request.user, key, limit=50),
            'chips': [agent.question_for_lang(p) for p in agent.quick_questions(4)],
            'agent_note': tr('agentNote'),
            'ag_tables': tr('agTables'),
        })
        return ctx


class AssistantAskView(View):
    """POST /assistant/api/ask/ — ядро пародії на ШІ-агента."""

    def post(self, request):
        question = _payload(request)
        if not question:
            return JsonResponse({'answer': tr('ask'), 'source': 'fallback', 'tables': []})
        answer = agent.ask(request.user, question)
        agent.save_dialogue(request.user, _session_key(request), question, answer)
        return JsonResponse({
            'answer': answer.text,
            'source': answer.source,
            'tables': list(answer.tables),
            'label': {'db': tr('srcDb'), 'kb': tr('srcKb')}.get(answer.source, tr('srcFallback')),
        })


class AssistantHistoryView(View):
    """GET: останні повідомлення діалогу (використовує віджет на кожній сторінці)."""

    def get(self, request):
        rows = agent.history(request.user, _session_key(request), limit=20)
        return JsonResponse({'messages': [
            {'role': m.role, 'content': m.content, 'source': m.source} for m in rows]})


class AssistantClearView(View):
    """POST: очистити історію діалогу."""

    def post(self, request):
        agent.clear_history(request.user, _session_key(request))
        return JsonResponse({'ok': True})


class NotificationsReadView(View):
    """POST: позначити всі сповіщення прочитаними."""

    def post(self, request):
        if request.user.is_authenticated:
            request.user.notifications.filter(is_read=False).update(is_read=True)
        return JsonResponse({'ok': True})
