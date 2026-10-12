from django.contrib.auth import get_user_model
from django.core.management import call_command
from django.test import TestCase
from django.urls import reverse

from core import recommender, services
from core.models import Course, Module, ModuleProgress, Profile

User = get_user_model()


class BaseTest(TestCase):
    def setUp(self):
        call_command('seed_demo', verbosity=0)
        self.user = User.objects.get(username='demo')
        self.client.login(username='demo', password='demo12345')


class RecommenderTests(BaseTest):
    def test_scores_are_in_range_and_sorted(self):
        done = services.completed_ids(services.progress_map(self.user))
        recs = recommender.recommend(self.user, done)
        self.assertEqual(len(recs), 8 - 1)  # Python-курс уже завершено в демо-даних
        scores = [r.score for r in recs]
        self.assertEqual(scores, sorted(scores, reverse=True))
        self.assertTrue(all(0 <= s <= 100 for s in scores))

    def test_interest_match_raises_score(self):
        django_course = Course.objects.get(title_en='Django Web Apps')
        rec = recommender.score_courses(self.user, Course.objects.filter(pk=django_course.pk))[0]
        self.assertTrue(rec.matched and rec.gaps)

    def test_top_gap_points_to_course(self):
        gap = recommender.top_gap(self.user)
        self.assertEqual(gap['skill'].key, 'data')


class ViewTests(BaseTest):
    def test_login_required(self):
        self.client.logout()
        self.assertRedirects(self.client.get(reverse('core:dashboard')), '/login/?next=/')

    def test_all_pages_render_in_both_languages(self):
        names = ['dashboard', 'explore', 'recommendations', 'plan', 'skills', 'progress', 'saved',
                 'assistant', 'profile', 'settings']
        for lang in ('uk', 'en'):
            self.client.get(reverse('core:set_lang', args=[lang]))
            for n in names:
                self.assertEqual(self.client.get(reverse('core:' + n)).status_code, 200, (lang, n))
            self.assertEqual(self.client.get(reverse('core:course', args=[2])).status_code, 200)

    def test_language_switch_changes_text(self):
        self.client.get(reverse('core:set_lang', args=['en']))
        self.assertContains(self.client.get(reverse('core:dashboard')), 'Recommendations')

    def test_filters_and_search(self):
        r = self.client.get(reverse('core:explore'), {'cat': 'db'})
        self.assertEqual(len(r.context['recs']), 1)  # фільтр за категорією: лише «SQL і проєктування БД»
        r = self.client.get(reverse('core:explore'), {'q': 'pandas'})
        self.assertEqual(len(r.context['recs']), 1)

    def test_task_toggle_updates_progress(self):
        module = Module.objects.filter(course__title_en='SQL & Database Design').first()
        r = self.client.post(reverse('core:task_toggle', args=[module.id]), HTTP_X_REQUESTED_WITH='XMLHttpRequest')
        self.assertEqual(r.json()['done'], True)
        self.assertEqual(ModuleProgress.objects.filter(module=module).count(), 1)
        r = self.client.post(reverse('core:task_toggle', args=[module.id]), HTTP_X_REQUESTED_WITH='XMLHttpRequest')
        self.assertEqual(r.json()['done'], False)

    def test_save_toggle(self):
        r = self.client.post(reverse('core:save_toggle', args=[1]), HTTP_X_REQUESTED_WITH='XMLHttpRequest')
        self.assertTrue(r.json()['saved'])

    def test_profile_requires_interest(self):
        r = self.client.post(reverse('core:profile'), {'display_name': 'X'}, follow=True)
        self.assertContains(r, 'js-msg')
        self.assertEqual(Profile.objects.get(user=self.user).interests.count(), 3)

    def test_register_creates_profile_and_empty_state(self):
        self.client.logout()
        r = self.client.post(reverse('core:register'), {'username': 'newbie', 'password1': 'Str0ngPass!', 'password2': 'Str0ngPass!'})
        self.assertRedirects(r, reverse('core:profile'))
        user = User.objects.get(username='newbie')
        self.assertTrue(hasattr(user, 'profile'))
        self.assertContains(self.client.get(reverse('core:recommendations')), 'c em')

    def test_assistant_and_stats(self):
        r = self.client.post(reverse('core:assistant_ask'), '{"q": "2"}', content_type='application/json')
        self.assertIn('answer', r.json())
        self.assertGreaterEqual(services.streak(self.user), 0)


class AgentTests(BaseTest):
    """«ШІ-агент»: пародія, що відповідає виключно з бази даних."""

    def test_counts_come_from_database(self):
        from core import agent
        ans = agent.ask(self.user, 'Скільки курсів у каталозі?')
        self.assertEqual(ans.source, 'db')
        self.assertIn(str(Course.objects.filter(is_published=True).count()), ans.text)
        self.assertTrue({'course'} <= set(ans.tables))

    def test_recommendation_uses_recommender(self):
        from core import agent
        ans = agent.ask(self.user, 'Що мені рекомендують?')
        self.assertEqual(ans.source, 'db')
        self.assertIn('%', ans.text)

    def test_knowledge_base_fallback(self):
        from core import agent
        ans = agent.ask(self.user, 'Хто ти такий взагалі?')
        self.assertEqual(ans.source, 'kb')
        self.assertIn('пародія', ans.text.lower())

    def test_unknown_question_falls_back(self):
        from core import agent
        ans = agent.ask(self.user, 'qqqqzzzz незрозуміле запитання')
        self.assertEqual(ans.source, 'fallback')

    def test_dialogue_saved_to_database(self):
        from core import agent
        from core.models import ChatMessage, ChatSession
        agent.ask(self.user, 'Скільки курсів у каталозі?')
        agent.save_dialogue(self.user, 'test-key', 'Скільки курсів?', agent.ask(self.user, 'Скільки курсів у каталозі?'))
        self.assertTrue(ChatSession.objects.filter(user=self.user).exists())
        self.assertGreaterEqual(ChatMessage.objects.filter(session__user=self.user).count(), 2)

    def test_ask_endpoint_and_history(self):
        r = self.client.post(reverse('core:assistant_ask'), '{"text": "Скільки курсів у каталозі"}',
                              content_type='application/json', HTTP_X_REQUESTED_WITH='XMLHttpRequest')
        data = r.json()
        self.assertIn('answer', data)
        self.assertEqual(data['source'], 'db')
        h = self.client.get(reverse('core:assistant_history')).json()
        self.assertGreaterEqual(len(h['messages']), 2)
        self.client.post(reverse('core:assistant_clear'))
        self.assertEqual(len(self.client.get(reverse('core:assistant_history')).json()['messages']), 0)

    def test_anonymous_agent_answers_from_public_tables(self):
        self.client.logout()
        r = self.client.post(reverse('core:assistant_ask'), '{"text": "Скільки курсів у каталозі"}',
                              content_type='application/json')
        self.assertEqual(r.status_code, 200)
        self.assertIn('answer', r.json())


class WidgetTests(BaseTest):
    """Плаваючий віджет «порадитись з агентом» присутній на кожній сторінці."""

    def test_widget_on_all_pages(self):
        names = ['dashboard', 'explore', 'recommendations', 'plan', 'skills', 'progress', 'saved',
                 'assistant', 'profile', 'settings']
        for n in names:
            r = self.client.get(reverse('core:' + n))
            self.assertContains(r, 'id="agentw"', msg_prefix=n)
        self.assertContains(self.client.get(reverse('core:course', args=[2])), 'id="agentw"')

    def test_widget_on_auth_pages(self):
        self.client.logout()
        self.assertContains(self.client.get(reverse('core:login')), 'id="agentw"')
        self.assertContains(self.client.get(reverse('core:register')), 'id="agentw"')

    def test_chips_are_loaded_from_knowledge_base(self):
        from core.models import AgentKnowledge
        self.assertTrue(AgentKnowledge.objects.filter(is_active=True).exists())
        r = self.client.get(reverse('core:assistant'))
        self.assertContains(r, 'js-q')


class RoutingTests(BaseTest):
    """Маршрутизація: namespace core, generic views, жодного зайвого редіректу."""

    def test_namespaced_urls(self):
        from django.urls import NoReverseMatch, reverse
        for name in ('dashboard', 'explore', 'assistant', 'profile', 'settings'):
            self.assertTrue(reverse('core:' + name).startswith('/'))
        with self.assertRaises(NoReverseMatch):
            reverse('dashboard')

    def test_views_are_classes(self):
        from core import views
        from django.views.generic import View
        for name in ('DashboardView', 'ExploreView', 'CourseDetailView', 'ProfileView',
                     'AssistantAskView', 'RegisterView'):
            self.assertTrue(issubclass(getattr(views, name), View), name)
