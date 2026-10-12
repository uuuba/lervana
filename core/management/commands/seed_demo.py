"""python manage.py seed_demo — довідники, 8 демо-курсів і демо-користувач (demo / demo12345)."""
from django.contrib.auth import get_user_model
from django.core.management.base import BaseCommand

from core import i18n
from core.models import (AgentKnowledge, Course, CourseSkill, Enrollment, Interest, Module, ModuleProgress,
                         Notification, Prerequisite, RecentView, SavedCourse, Skill, UserSkill)

INTERESTS = {'python': ('Python', 'Python'), 'web': ('Веб-розробка', 'Web development'),
             'data': ('Data Science', 'Data Science'), 'ai': ('AI/ML', 'AI/ML'), 'db': ('Бази даних', 'Databases'),
             'ux': ('UI/UX', 'UI/UX'), 'eng': ('Англійська для IT', 'English for IT')}
SKILLS = {'python': ('Python', 'Python'), 'web': ('Веб', 'Web'), 'db': ('Бази даних', 'Databases'),
          'data': ('Аналіз даних', 'Data analysis'), 'eng': ('Англійська', 'English')}
# title, description, tags (перший — категорія), level, hours, format, skills, prerequisites, cover
COURSES = [
    (('Python з нуля', 'Python from Scratch'), ('Синтаксис, типи даних, функції та файли.', 'Syntax, data types, functions and files.'), ['python'], 1, 18, 'vid', ['python'], {}, 'python'),
    (('Django: веб-застосунки', 'Django Web Apps'), ('Моделі, шаблони та адмін-панель у Django.', 'Models, templates and the admin panel in Django.'), ['python', 'web', 'db'], 2, 30, 'prac', ['web', 'python'], {'python': 2}, 'web'),
    (('SQL і проєктування БД', 'SQL & Database Design'), ('SQL-запити, нормалізація та ERD.', 'SQL queries, normalization and ERDs.'), ['db'], 2, 22, 'prac', ['db'], {}, 'db'),
    (('Основи Data Science', 'Data Science Basics'), ('Pandas, візуалізація та базова статистика.', 'Pandas, visualization and basic statistics.'), ['data', 'python'], 2, 35, 'vid', ['data', 'python'], {'python': 2}, 'data'),
    (('Машинне навчання: вступ', 'Intro to Machine Learning'), ('Класифікація, регресія та оцінка моделей.', 'Classification, regression and model evaluation.'), ['ai', 'data'], 3, 45, 'vid', ['data'], {'python': 3}, 'ai'),
    (('Адаптивна верстка', 'Responsive Web Design'), ('HTML, CSS, Flexbox та Grid.', 'HTML, CSS, Flexbox and Grid.'), ['web', 'ux'], 1, 16, 'prac', ['web'], {}, 'web'),
    (('Основи UI/UX', 'UI/UX Fundamentals'), ('Дослідження користувачів і прототипування.', 'User research and prototyping.'), ['ux', 'web'], 1, 14, 'txt', ['web'], {}, 'ux'),
    (('Технічна англійська для IT', 'Technical English for IT'), ('Лексика, документація та листування.', 'Vocabulary, documentation and email.'), ['eng'], 1, 12, 'txt', ['eng'], {}, 'eng'),
]

# База знань «ШІ-агента»: ключові слова -> відповідь (таблиця AgentKnowledge)
AGENT_KB = [
    ('who', 'хто ти хто ви що ти бот агент who you assistant',
     'Хто ти такий?', 'Who are you?',
     'Я — «ШІ-агент» Learnova: пародія на AI-асистента. Нейромережі немає — є база знань (таблиця agentknowledge) і запити до твоїх таблиць.',
     'I am the Learnova "AI agent": an AI-assistant parody. No neural network — just a knowledge base (the agentknowledge table) and queries to your tables.', 30),
    ('ai', 'ші ai нейромережа штучний інтелект chatgpt гпт справжній штучний',
     'Ти справжній ШІ?', 'Are you a real AI?',
     'Ні 😄 Я шукаю ключові слова у запитанні, а потім роблю SQL-запити до таблиць Learnova. Цифри реальні, бо з бази даних.',
     'No 😄 I match keywords in your question and then run SQL queries against Learnova tables. The numbers are real — they come from the database.', 30),
    ('how', 'як це працює рекомендації формула алгоритм збіг чому рекомендують how it works',
     'Як працюють рекомендації?', 'How do recommendations work?',
     'Оцінка збігу (0–100) = інтереси 40 + прогалини в навичках 30 + рівень 20 + формат 10. Прозора формула, а не «чорна скринька»; завершені курси прибираються.',
     'Match score (0–100) = interests 40 + skill gaps 30 + level 20 + format 10. A transparent formula, not a black box; completed courses are removed.', 20),
    ('plan', 'як навчатися план розклад скільки годин на тиждень як почати where to start',
     'З чого почати навчання?', 'Where should I start?',
     'Заповни профіль (інтереси та рівні) → відкрий «Рекомендації» → натисни «Почати» на курсі → відмічай модулі в «Плані». Прогрес рахують таблиці enrollment і moduleprogress.',
     'Fill in your profile (interests and levels) → open “Recommendations” → press “Start” on a course → tick modules in “Plan”. Progress is counted by the enrollment and moduleprogress tables.', 15),
    ('progress', 'як подивитись прогрес статистика досягнення серія де мій прогрес',
     'Де подивитись прогрес?', 'Where is my progress?',
     'Сторінка «Прогрес»: загальний відсоток, активність за тиждень і по кожному курсу. Дані — з таблиць moduleprogress та enrollment.',
     'The “Progress” page: overall percentage, weekly activity and per-course data. Everything comes from the moduleprogress and enrollment tables.', 15),
    ('cert', 'сертифікат сертифікати диплом підтвердження certificate',
     'Чи є сертифікат?', 'Is there a certificate?',
     'У демо-сертифікатів немає. Натомість є реальна статистика: години навчання, серія днів і рівні навичок — усе з твоїх таблиць.',
     'There are no certificates in the demo. Instead you get real statistics: learning hours, day streak and skill levels — all from your tables.', 10),
    ('price', 'ціна скільки коштує вартість безкоштовно підписка price free',
     'Скільки коштує навчання?', 'How much does it cost?',
     'Нічого: Learnova — навчальний прототип, у таблиці course навіть немає поля «ціна».',
     'Nothing: Learnova is a study prototype — the course table does not even have a price column.', 10),
    ('support', 'підтримка контакти звʼязатись написати скарга support contact',
     'Як звʼязатись з підтримкою?', 'How do I contact support?',
     'Це демо-проєкт: налаштування акаунта — на сторінці «Налаштування», а дані можна скинути там само (кнопка «Скинути демо-дані»).',
     'This is a demo: account settings live on the “Settings” page, where you can also reset the demo data.', 10),
]


class Command(BaseCommand):
    help = 'Заповнює базу демонстраційними даними (можна запускати повторно).'

    def handle(self, *args, **opts):
        interests = {k: Interest.objects.update_or_create(key=k, defaults={'name_uk': u, 'name_en': e})[0] for k, (u, e) in INTERESTS.items()}
        skills = {k: Skill.objects.update_or_create(key=k, defaults={'name_uk': u, 'name_en': e})[0] for k, (u, e) in SKILLS.items()}
        m1, m2, m3 = i18n.STRINGS['m1'], i18n.STRINGS['m2'], i18n.STRINGS['m3']
        courses = []
        for (title, desc, tags, level, hours, fmt, sk, req, cover) in COURSES:
            course, created = Course.objects.update_or_create(title_en=title[1], defaults={
                'title_uk': title[0], 'description_uk': desc[0], 'description_en': desc[1],
                'category': interests[tags[0]], 'level': level, 'duration_hours': hours,
                'format': fmt, 'cover_key': cover})
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
        self._seed_agent_kb()
        self._demo_user(interests, skills, courses)
        self.stdout.write(self.style.SUCCESS('Готово. Демо-користувач: demo / demo12345'))

    def _seed_agent_kb(self):
        """База знань «ШІ-агента» (таблиця AgentKnowledge) — ідемпотентно."""
        for key, keywords, q_uk, q_en, a_uk, a_en, priority in AGENT_KB:
            AgentKnowledge.objects.update_or_create(key=key, defaults={
                'keywords': keywords, 'question_uk': q_uk, 'question_en': q_en,
                'answer_uk': a_uk, 'answer_en': a_en, 'priority': priority, 'is_active': True,
            })

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
