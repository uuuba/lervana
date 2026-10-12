"""python manage.py seed_demo — довідники, 8 демо-курсів і демо-користувач (demo / demo12345)."""
from django.contrib.auth import get_user_model
from django.core.management.base import BaseCommand

from core import i18n
from core.models import (Course, CourseSkill, Enrollment, Interest, Module, ModuleProgress, Notification,
                         Prerequisite, RecentView, SavedCourse, Skill, UserSkill)

INTERESTS = {'python': ('Python', 'Python'), 'web': ('Веб-розробка', 'Web development'),
             'data': ('Data Science', 'Data Science'), 'ai': ('AI/ML', 'AI/ML'), 'db': ('Бази даних', 'Databases'),
             'ux': ('UI/UX', 'UI/UX'), 'eng': ('Англійська для IT', 'English for IT')}
SKILLS = {'python': ('Python', 'Python'), 'web': ('Веб', 'Web'), 'db': ('Бази даних', 'Databases'),
          'data': ('Аналіз даних', 'Data analysis'), 'eng': ('Англійська', 'English')}
# title, description, tags (перший — категорія), level, hours, format, skills, prerequisites
COURSES = [
    (('Python з нуля', 'Python from Scratch'), ('Синтаксис, типи даних, функції та файли.', 'Syntax, data types, functions and files.'), ['python'], 1, 18, 'vid', ['python'], {}),
    (('Django: веб-застосунки', 'Django Web Apps'), ('Моделі, шаблони та адмін-панель у Django.', 'Models, templates and the admin panel in Django.'), ['python', 'web', 'db'], 2, 30, 'prac', ['web', 'python'], {'python': 2}),
    (('SQL і проєктування БД', 'SQL & Database Design'), ('SQL-запити, нормалізація та ERD.', 'SQL queries, normalization and ERDs.'), ['db'], 2, 22, 'prac', ['db'], {}),
    (('Основи Data Science', 'Data Science Basics'), ('Pandas, візуалізація та базова статистика.', 'Pandas, visualization and basic statistics.'), ['data', 'python'], 2, 35, 'vid', ['data', 'python'], {'python': 2}),
    (('Машинне навчання: вступ', 'Intro to Machine Learning'), ('Класифікація, регресія та оцінка моделей.', 'Classification, regression and model evaluation.'), ['ai', 'data'], 3, 45, 'vid', ['data'], {'python': 3}),
    (('Адаптивна верстка', 'Responsive Web Design'), ('HTML, CSS, Flexbox та Grid.', 'HTML, CSS, Flexbox and Grid.'), ['web', 'ux'], 1, 16, 'prac', ['web'], {}),
    (('Основи UI/UX', 'UI/UX Fundamentals'), ('Дослідження користувачів і прототипування.', 'User research and prototyping.'), ['ux', 'web'], 1, 14, 'txt', ['web'], {}),
    (('Технічна англійська для IT', 'Technical English for IT'), ('Лексика, документація та листування.', 'Vocabulary, documentation and email.'), ['eng'], 1, 12, 'txt', ['eng'], {}),
]


class Command(BaseCommand):
    help = 'Заповнює базу демонстраційними даними (можна запускати повторно).'

    def handle(self, *args, **opts):
        interests = {k: Interest.objects.update_or_create(key=k, defaults={'name_uk': u, 'name_en': e})[0] for k, (u, e) in INTERESTS.items()}
        skills = {k: Skill.objects.update_or_create(key=k, defaults={'name_uk': u, 'name_en': e})[0] for k, (u, e) in SKILLS.items()}
        m1, m2, m3 = i18n.STRINGS['m1'], i18n.STRINGS['m2'], i18n.STRINGS['m3']
        courses = []
        for (title, desc, tags, level, hours, fmt, sk, req) in COURSES:
            course, created = Course.objects.update_or_create(title_en=title[1], defaults={
                'title_uk': title[0], 'description_uk': desc[0], 'description_en': desc[1],
                'category': interests[tags[0]], 'level': level, 'duration_hours': hours, 'format': fmt})
            courses.append(course)
            course.interests.set([interests[t] for t in tags])
            course.courseskill_set.all().delete()
            CourseSkill.objects.bulk_create([CourseSkill(course=course, skill=skills[s], order=i) for i, s in enumerate(sk)])
            course.prerequisites.all().delete()
            Prerequisite.objects.bulk_create([Prerequisite(course=course, skill=skills[s], min_level=v) for s, v in req.items()])
            if created or not course.modules.exists():
                first, last = skills[sk[0]], skills[sk[-1]]
                Module.objects.bulk_create([
                    Module(course=course, order=1, title_uk=m1[0].format(first.name_uk), title_en=m1[1].format(first.name_en)),
                    Module(course=course, order=2, title_uk=m2[0].format(last.name_uk), title_en=m2[1].format(last.name_en)),
                    Module(course=course, order=3, title_uk=m3[0], title_en=m3[1])])
        self._demo_user(interests, skills, courses)
        self.stdout.write(self.style.SUCCESS('Готово. Демо-користувач: demo / demo12345'))

    def _demo_user(self, interests, skills, courses):
        User = get_user_model()
        user, created = User.objects.get_or_create(username='demo')
        user.set_password('demo12345')
        user.save()
        for s in skills.values():
            UserSkill.objects.get_or_create(user=user, skill=s)
        prof = user.profile
        prof.display_name, prof.goal, prof.weekly_hours, prof.preferred_format = 'Demo', 'g1', 6, 'prac'
        prof.save()
        prof.interests.set([interests[k] for k in ('python', 'web', 'db')])
        for k, (cur, want) in {'python': (3, 4), 'web': (2, 3), 'db': (2, 3), 'data': (1, 3), 'eng': (3, 4)}.items():
            UserSkill.objects.filter(user=user, skill=skills[k]).update(current_level=cur, desired_level=want)
        if not user.enrollments.exists():
            first = Enrollment.objects.create(user=user, course=courses[0])
            for m in courses[0].modules.all():
                ModuleProgress.objects.create(enrollment=first, module=m)
            second = Enrollment.objects.create(user=user, course=courses[1])
            ModuleProgress.objects.create(enrollment=second, module=courses[1].modules.first())
        SavedCourse.objects.get_or_create(user=user, course=courses[3])
        for c in (courses[2], courses[5]):
            RecentView.objects.get_or_create(user=user, course=c)
        if not user.notifications.filter(code='n2').exists():
            Notification.objects.create(user=user, code='n2')
