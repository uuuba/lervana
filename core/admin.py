from django.contrib import admin

from . import models


class ModuleInline(admin.TabularInline):
    model = models.Module
    extra = 0


class PrerequisiteInline(admin.TabularInline):
    model = models.Prerequisite
    extra = 0


class CourseSkillInline(admin.TabularInline):
    model = models.CourseSkill
    extra = 0


@admin.register(models.Course)
class CourseAdmin(admin.ModelAdmin):
    list_display = ('title_en', 'category', 'level', 'duration_hours', 'format', 'cover_key', 'is_published')
    list_filter = ('category', 'level', 'format', 'is_published')
    search_fields = ('title_uk', 'title_en')
    filter_horizontal = ('interests',)
    inlines = [CourseSkillInline, PrerequisiteInline, ModuleInline]


@admin.register(models.Interest, models.Skill)
class NamedAdmin(admin.ModelAdmin):
    list_display = ('key', 'name_uk', 'name_en')


@admin.register(models.Profile)
class ProfileAdmin(admin.ModelAdmin):
    list_display = ('user', 'display_name', 'goal', 'weekly_hours', 'preferred_format')
    filter_horizontal = ('interests',)


@admin.register(models.AgentKnowledge)
class AgentKnowledgeAdmin(admin.ModelAdmin):
    """База знань «ШІ-агента»: ключові слова → відповідь."""
    list_display = ('key', 'question_uk', 'priority', 'hits', 'is_active')
    list_filter = ('is_active', 'priority')
    search_fields = ('key', 'keywords', 'question_uk', 'question_en', 'answer_uk', 'answer_en')
    list_editable = ('priority', 'is_active')
    ordering = ('-priority', 'id')


class ChatMessageInline(admin.TabularInline):
    model = models.ChatMessage
    extra = 0
    readonly_fields = ('role', 'content', 'source', 'created_at')
    can_delete = True


@admin.register(models.ChatSession)
class ChatSessionAdmin(admin.ModelAdmin):
    list_display = ('id', 'user', 'session_key', 'messages_count', 'created_at', 'updated_at')
    list_filter = ('created_at',)
    search_fields = ('user__username', 'session_key')
    inlines = [ChatMessageInline]

    @admin.display(description='повідомлень')
    def messages_count(self, obj):
        return obj.messages.count()


admin.site.register([models.UserSkill, models.Enrollment, models.ModuleProgress, models.SavedCourse,
                     models.RecentView, models.Notification, models.ChatMessage])
