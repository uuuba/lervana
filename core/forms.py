"""Форми Learnova (використовуються generic views: FormView / UpdateView)."""
from django import forms
from django.contrib.auth.forms import UserCreationForm
from django.contrib.auth.models import User

from . import i18n
from .models import Profile


class RegisterForm(UserCreationForm):
    """Реєстрація: мінімум полів, профіль створюється сигналом."""

    class Meta:
        model = User
        fields = ('username',)


class ProfileForm(forms.ModelForm):
    """Профіль: мета, формат, години на тиждень та інтереси (M2M)."""

    class Meta:
        model = Profile
        fields = ('display_name', 'goal', 'preferred_format', 'weekly_hours', 'interests')

    def clean_interests(self):
        interests = self.cleaned_data.get('interests')
        if not interests:
            raise forms.ValidationError(i18n.tr('errInt'))
        return interests

    def clean_weekly_hours(self):
        value = self.cleaned_data.get('weekly_hours') or 1
        return max(1, min(30, int(value)))
