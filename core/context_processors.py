# (url name, ключ перекладу, іконка)
NAV = [
    ('dashboard', 'dash', 'home'), ('explore', 'explore', 'compass'), ('recommendations', 'recs', 'spark'),
    ('plan', 'plan', 'list'), ('skills', 'skills', 'target'), ('progress', 'prog', 'trend'),
    ('saved', 'saved', 'bookmark'), ('assistant', 'assistant', 'chat'), ('profile', 'profile', 'user'),
    ('settings', 'settings', 'sliders'),
]
ALIAS = {'course': 'explore'}


def ui(request):
    match = getattr(request, 'resolver_match', None)
    name = match.url_name if match else ''
    ctx = {'LANG': getattr(request, 'lang', 'uk'), 'NAV': NAV, 'nav_active': ALIAS.get(name, name)}
    if request.user.is_authenticated:
        ctx['notifications'] = list(request.user.notifications.all()[:6])
        ctx['unread'] = request.user.notifications.filter(is_read=False).count()
    return ctx
