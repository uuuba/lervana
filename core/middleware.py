from django.utils import translation

from . import i18n


class LanguageMiddleware:
    """Активує мову інтерфейсу із сесії (за замовчуванням — українська)."""

    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        i18n.set_lang(request.session.get('lang', i18n.DEFAULT))
        request.lang = i18n.get_lang()
        translation.activate(request.lang)  # вбудовані повідомлення Django (форми, адмінка)
        return self.get_response(request)
