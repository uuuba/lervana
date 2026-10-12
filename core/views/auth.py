"""Автентифікація та мова: FormView / View (плюс LoginView з Django)."""
from django.contrib import messages
from django.contrib.auth import login
from django.contrib.auth.views import LoginView as DjangoLoginView
from django.shortcuts import redirect
from django.urls import reverse_lazy
from django.utils.http import url_has_allowed_host_and_scheme
from django.views.generic import FormView, View

from .. import i18n
from ..forms import RegisterForm

tr = i18n.tr


class LoginView(DjangoLoginView):
    """Вхід (вбудований generic view Django)."""
    template_name = 'core/auth.html'
    extra_context = {'mode': 'login'}

    def get_success_url(self):
        return self.get_redirect_url() or reverse_lazy('core:dashboard')


class RegisterView(FormView):
    """Реєстрація: профіль і рівні навичок створюються сигналом post_save."""
    template_name = 'core/auth.html'
    form_class = RegisterForm
    success_url = reverse_lazy('core:profile')

    def get_context_data(self, **kwargs):
        ctx = super().get_context_data(**kwargs)
        ctx['mode'] = 'register'
        return ctx

    def form_valid(self, form):
        user = form.save()
        login(self.request, user)
        messages.success(self.request, tr('n3'))
        return super().form_valid(form)


class SetLangView(View):
    """Перемикання мови інтерфейсу (зберігається в сесії)."""
    login_url = 'core:login'

    def get(self, request, code):
        if code in i18n.LANGS:
            request.session['lang'] = code
        target = request.META.get('HTTP_REFERER', '')
        if not url_has_allowed_host_and_scheme(target, {request.get_host()}):
            target = '/'
        return redirect(target)
