from django.conf import settings
from django.db.models.signals import post_save
from django.dispatch import receiver

from .models import Notification, Profile, Skill, UserSkill


@receiver(post_save, sender=settings.AUTH_USER_MODEL)
def init_user(sender, instance, created, **kwargs):
    """Після створення користувача: профіль, порожні рівні навичок, вітальне сповіщення."""
    if created:
        Profile.objects.create(user=instance)
        UserSkill.objects.bulk_create([UserSkill(user=instance, skill=s) for s in Skill.objects.all()])
        Notification.objects.create(user=instance, code='n3')
