"""Модель даних Learnova (розділ 1.2: проєктування БД).

Правила нормалізації:
  * довідники (Interest, Skill) винесено в окремі таблиці, зв'язки — через FK/M2M;
  * зв'язок «багато-до-багатьох» із проміжними таблицями (CourseSkill, Prerequisite);
  * цілісність забезпечують UNIQUE/Check-обмеження та індекси на полях фільтрації;
  * «м'які» поля (uk/en) зберігаються парами, вибір мови — у сервісному шарі (i18n).
"""
from django.conf import settings
from django.core.validators import MaxValueValidator, MinValueValidator
from django.db import models

from . import i18n


class NamedModel(models.Model):
    """Довідник із назвою українською та англійською."""
    key = models.SlugField(unique=True, verbose_name='ключ')
    name_uk = models.CharField(max_length=80, verbose_name='назва (uk)')
    name_en = models.CharField(max_length=80, verbose_name='назва (en)')

    class Meta:
        abstract = True
        ordering = ['id']

    @property
    def name(self):
        return i18n.pick(self.name_uk, self.name_en)

    def __str__(self):
        return self.name_en


class Interest(NamedModel):
    """Освітній інтерес / категорія курсу."""

    class Meta(NamedModel.Meta):
        verbose_name = 'інтерес'
        verbose_name_plural = 'інтереси'


class Skill(NamedModel):
    """Компетенція, яку можна оцінювати (0–5) і здобувати на курсах."""

    class Meta(NamedModel.Meta):
        verbose_name = 'навичка'
        verbose_name_plural = 'навички'


class Course(models.Model):
    FORMATS = [('vid', 'Video'), ('prac', 'Practice'), ('txt', 'Text')]
    LEVELS = [(1, 'Beginner'), (2, 'Intermediate'), (3, 'Advanced')]

    title_uk = models.CharField(max_length=160, verbose_name='назва (uk)')
    title_en = models.CharField(max_length=160, verbose_name='назва (en)')
    description_uk = models.TextField(verbose_name='опис (uk)')
    description_en = models.TextField(verbose_name='опис (en)')
    category = models.ForeignKey(Interest, on_delete=models.PROTECT, related_name='courses', verbose_name='категорія')
    interests = models.ManyToManyField(Interest, related_name='tagged_courses', blank=True, verbose_name='теги')
    skills = models.ManyToManyField(Skill, through='CourseSkill', related_name='courses', verbose_name='навички')
    level = models.PositiveSmallIntegerField(choices=LEVELS, default=1, verbose_name='рівень')
    duration_hours = models.PositiveSmallIntegerField(verbose_name='годин')
    format = models.CharField(max_length=4, choices=FORMATS, default='vid', verbose_name='формат')
    cover_key = models.SlugField(max_length=32, blank=True, default='',
                                 help_text='Ключ ілюстрації обкладинки (напр. python, web, ai)')
    is_published = models.BooleanField(default=True, verbose_name='опубліковано')

    class Meta:
        ordering = ['id']
        verbose_name = 'курс'
        verbose_name_plural = 'курси'
        indexes = [
            models.Index(fields=['is_published', 'level'], name='course_pub_lvl_idx'),
            models.Index(fields=['category', 'format'], name='course_cat_fmt_idx'),
        ]
        constraints = [
            models.CheckConstraint(condition=models.Q(level__in=(1, 2, 3)), name='course_level_1_3'),
            models.CheckConstraint(condition=models.Q(duration_hours__gt=0), name='course_hours_positive'),
        ]

    @property
    def title(self):
        return i18n.pick(self.title_uk, self.title_en)

    @property
    def description(self):
        return i18n.pick(self.description_uk, self.description_en)

    @property
    def search_text(self):
        return f'{self.title_uk} {self.title_en} {self.description_uk} {self.description_en}'.lower()

    @property
    def art_key(self):
        """Ключ обкладинки: власний або ключ категорії."""
        return self.cover_key or self.category.key

    @property
    def skill_list(self):
        links = getattr(self, 'skill_links', None)
        if links is None:
            links = self.courseskill_set.select_related('skill').order_by('order')
        return [link.skill for link in links]

    def __str__(self):
        return self.title_en


class CourseSkill(models.Model):
    """Навичка, яку дає курс (order=0 — основна)."""
    course = models.ForeignKey(Course, on_delete=models.CASCADE, related_name='courseskill_set')
    skill = models.ForeignKey(Skill, on_delete=models.CASCADE, related_name='course_links')
    order = models.PositiveSmallIntegerField(default=0, verbose_name='порядок')

    class Meta:
        ordering = ['order']
        verbose_name = 'навичка курсу'
        verbose_name_plural = 'навички курсу'
        constraints = [
            models.UniqueConstraint(fields=['course', 'skill'], name='uniq_course_skill'),
        ]
        indexes = [models.Index(fields=['skill', 'order'], name='courseskill_skill_idx')]

    def __str__(self):
        return f'{self.course} → {self.skill}'


class Prerequisite(models.Model):
    """Передумова: мінімальний рівень навички для курсу."""
    course = models.ForeignKey(Course, on_delete=models.CASCADE, related_name='prerequisites')
    skill = models.ForeignKey(Skill, on_delete=models.CASCADE, related_name='prerequisites')
    min_level = models.PositiveSmallIntegerField(validators=[MinValueValidator(1), MaxValueValidator(5)],
                                                 verbose_name='мін. рівень')

    class Meta:
        verbose_name = 'передумова'
        verbose_name_plural = 'передумови'
        constraints = [
            models.UniqueConstraint(fields=['course', 'skill'], name='uniq_course_prereq'),
            models.CheckConstraint(condition=models.Q(min_level__gte=1), name='prereq_min_level_1'),
        ]

    def __str__(self):
        return f'{self.course} / {self.skill} ≥ {self.min_level}'


class Module(models.Model):
    course = models.ForeignKey(Course, on_delete=models.CASCADE, related_name='modules')
    order = models.PositiveSmallIntegerField(default=1, verbose_name='порядок')
    title_uk = models.CharField(max_length=160, verbose_name='назва (uk)')
    title_en = models.CharField(max_length=160, verbose_name='назва (en)')

    class Meta:
        ordering = ['course_id', 'order']
        verbose_name = 'модуль'
        verbose_name_plural = 'модулі'
        constraints = [models.UniqueConstraint(fields=['course', 'order'], name='uniq_course_module_order')]

    @property
    def title(self):
        return i18n.pick(self.title_uk, self.title_en)

    def __str__(self):
        return f'{self.course} / {self.order}'


class Profile(models.Model):
    GOALS = [('g1', 'First IT job'), ('g2', 'Upskill'), ('g3', 'Switch fields')]

    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='profile')
    display_name = models.CharField(max_length=60, blank=True, verbose_name="ім'я")
    goal = models.CharField(max_length=2, choices=GOALS, default='g1', verbose_name='мета')
    weekly_hours = models.PositiveSmallIntegerField(default=6, validators=[MinValueValidator(1), MaxValueValidator(30)],
                                                    verbose_name='годин на тиждень')
    preferred_format = models.CharField(max_length=4, choices=Course.FORMATS, default='prac', verbose_name='формат')
    reminders = models.BooleanField(default=True, verbose_name='нагадування')
    interests = models.ManyToManyField(Interest, related_name='profiles', blank=True, verbose_name='інтереси')

    class Meta:
        verbose_name = 'профіль'
        verbose_name_plural = 'профілі'
        constraints = [
            models.CheckConstraint(condition=models.Q(weekly_hours__gte=1, weekly_hours__lte=30),
                                   name='profile_weekly_hours_1_30'),
        ]

    @property
    def shown_name(self):
        return self.display_name or i18n.tr('stud')

    @property
    def initial(self):
        return (self.display_name or self.user.get_username() or '?')[:1].upper()

    def __str__(self):
        return f'Profile({self.user})'


class UserSkill(models.Model):
    """Самооцінка користувача: поточний і бажаний рівень навички (0–5)."""
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='skill_levels')
    skill = models.ForeignKey(Skill, on_delete=models.CASCADE, related_name='user_levels')
    current_level = models.PositiveSmallIntegerField(default=0, validators=[MaxValueValidator(5)],
                                                     verbose_name='поточний')
    desired_level = models.PositiveSmallIntegerField(default=0, validators=[MaxValueValidator(5)],
                                                     verbose_name='бажаний')

    class Meta:
        verbose_name = 'рівень навички'
        verbose_name_plural = 'рівні навичок'
        ordering = ['skill_id']
        constraints = [
            models.UniqueConstraint(fields=['user', 'skill'], name='uniq_user_skill'),
            models.CheckConstraint(condition=models.Q(current_level__lte=5), name='userskill_cur_lte_5'),
            models.CheckConstraint(condition=models.Q(desired_level__lte=5), name='userskill_want_lte_5'),
        ]
        indexes = [models.Index(fields=['user', 'skill'], name='userskill_user_idx')]

    @property
    def gap(self):
        return max(0, self.desired_level - self.current_level)

    @property
    def cur_pct(self):
        return self.current_level * 20

    @property
    def want_pct(self):
        return self.desired_level * 20

    def __str__(self):
        return f'{self.user} · {self.skill} {self.current_level}→{self.desired_level}'


class Enrollment(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='enrollments')
    course = models.ForeignKey(Course, on_delete=models.CASCADE, related_name='enrollments')
    started_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['started_at']
        verbose_name = 'запис на курс'
        verbose_name_plural = 'записи на курси'
        constraints = [models.UniqueConstraint(fields=['user', 'course'], name='uniq_enrollment')]
        indexes = [models.Index(fields=['user', 'started_at'], name='enroll_user_idx')]

    @property
    def pct(self):
        total = self.course.modules.count()
        return round(self.progress.count() / total * 100) if total else 0

    def __str__(self):
        return f'{self.user} → {self.course}'


class ModuleProgress(models.Model):
    """Наявність запису = модуль виконано."""
    enrollment = models.ForeignKey(Enrollment, on_delete=models.CASCADE, related_name='progress')
    module = models.ForeignKey(Module, on_delete=models.CASCADE, related_name='progress_marks')
    completed_at = models.DateTimeField(auto_now_add=True, db_index=True)

    class Meta:
        verbose_name = 'виконаний модуль'
        verbose_name_plural = 'виконані модулі'
        constraints = [models.UniqueConstraint(fields=['enrollment', 'module'], name='uniq_module_progress')]

    def __str__(self):
        return f'{self.enrollment} / {self.module}'


class SavedCourse(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='saved_courses')
    course = models.ForeignKey(Course, on_delete=models.CASCADE, related_name='saved_by')
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = 'збережений курс'
        verbose_name_plural = 'збережені курси'
        constraints = [models.UniqueConstraint(fields=['user', 'course'], name='uniq_saved_course')]

    def __str__(self):
        return f'{self.user} ★ {self.course}'


class RecentView(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='recent_views')
    course = models.ForeignKey(Course, on_delete=models.CASCADE, related_name='views')
    viewed_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = 'перегляд'
        verbose_name_plural = 'перегляди'
        ordering = ['-viewed_at']
        constraints = [models.UniqueConstraint(fields=['user', 'course'], name='uniq_recent_view')]
        indexes = [models.Index(fields=['user', '-viewed_at'], name='recent_user_idx')]

    def __str__(self):
        return f'{self.user} · {self.course}'


class Notification(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='notifications')
    code = models.CharField(max_length=20, db_index=True)  # ключ у словнику i18n (n1, n2, n3)
    is_read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at', '-id']
        verbose_name = 'сповіщення'
        verbose_name_plural = 'сповіщення'
        indexes = [models.Index(fields=['user', 'is_read'], name='notif_user_read_idx')]

    @property
    def message(self):
        return i18n.tr(self.code)

    def __str__(self):
        return f'{self.user}: {self.code}'


# ---------- «ШІ-агент» (поки що відповідає виключно з бази даних) ----------

class AgentKnowledge(models.Model):
    """База знань агента: ключові слова запитання -> відповідь із БД.

    Жодної AI-моделі: агент шукає найкращий запис за ключовими словами,
    підставляє актуальні цифри з таблиць і повертає відповідь.
    """
    key = models.SlugField(unique=True, verbose_name='ключ')
    keywords = models.CharField(max_length=200, help_text='ключові слова через пробіл', verbose_name='ключові слова')
    question_uk = models.CharField(max_length=200, verbose_name='приклад запитання (uk)')
    question_en = models.CharField(max_length=200, verbose_name='приклад запитання (en)')
    answer_uk = models.TextField(verbose_name='відповідь (uk)')
    answer_en = models.TextField(verbose_name='відповідь (en)')
    priority = models.PositiveSmallIntegerField(default=10, verbose_name='пріоритет')
    hits = models.PositiveIntegerField(default=0, verbose_name='використань')
    is_active = models.BooleanField(default=True, verbose_name='активно')

    class Meta:
        ordering = ['-priority', 'id']
        verbose_name = 'знання агента'
        verbose_name_plural = 'знання агента'
        constraints = [models.UniqueConstraint(fields=['key'], name='uniq_agent_knowledge_key')]
        indexes = [models.Index(fields=['is_active', '-priority'], name='agent_kb_idx')]

    @property
    def question(self):
        return i18n.pick(self.question_uk, self.question_en)

    @property
    def answer(self):
        return i18n.pick(self.answer_uk, self.answer_en)

    @property
    def word_list(self):
        return [w for w in self.keywords.lower().split() if w]

    def __str__(self):
        return f'AgentKnowledge({self.key})'


class ChatSession(models.Model):
    """Історія діалогу з агентом (для авторизованих — user, для гостей — session_key)."""
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, null=True, blank=True,
                             related_name='chat_sessions')
    session_key = models.CharField(max_length=40, blank=True, default='', db_index=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-updated_at']
        verbose_name = 'діалог з агентом'
        verbose_name_plural = 'діалоги з агентом'
        indexes = [models.Index(fields=['user', '-updated_at'], name='chatsession_user_idx')]

    @property
    def title(self):
        first = self.messages.filter(role='user').first()
        return (first.content[:60] if first else '—')

    def __str__(self):
        return f'ChatSession({self.user or self.session_key})'


class ChatMessage(models.Model):
    """Повідомлення діалогу: запитання користувача та відповідь агента."""
    ROLES = [('user', 'user'), ('agent', 'agent')]
    SOURCES = [('db', 'db'), ('kb', 'kb'), ('fallback', 'fallback')]

    session = models.ForeignKey(ChatSession, on_delete=models.CASCADE, related_name='messages')
    role = models.CharField(max_length=5, choices=ROLES)
    content = models.TextField()
    source = models.CharField(max_length=16, choices=SOURCES, default='db',
                              help_text='звідки відповідь: запити до БД, база знань або загальна')
    created_at = models.DateTimeField(auto_now_add=True, db_index=True)

    class Meta:
        ordering = ['created_at']
        verbose_name = 'повідомлення агента'
        verbose_name_plural = 'повідомлення агента'
        indexes = [models.Index(fields=['session', 'created_at'], name='chatmsg_session_idx')]

    @property
    def is_user(self):
        return self.role == 'user'

    def __str__(self):
        return f'{self.role}: {self.content[:40]}'
