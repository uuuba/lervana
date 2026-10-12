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
    list_display = ('title_en', 'category', 'level', 'duration_hours', 'format', 'is_published')
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


admin.site.register([models.UserSkill, models.Enrollment, models.ModuleProgress, models.SavedCourse,
                     models.RecentView, models.Notification])
