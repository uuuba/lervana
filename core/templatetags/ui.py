from django import template
from django.utils.safestring import mark_safe

from core import i18n, icons
from core.recommender import why_text

register = template.Library()


@register.simple_tag
def t(key, *args):
    """{% t 'hello' name %} — переклад із центрального словника."""
    return i18n.tr(key, *args)


@register.simple_tag
def icon(name):
    return mark_safe(icons.svg(name))


@register.simple_tag
def cover(course):
    return mark_safe(icons.cover(course.id, course.category.key))


@register.simple_tag
def why(rec):
    return why_text(rec)


@register.filter
def level_name(value):
    return i18n.tr(f'l{value}')
