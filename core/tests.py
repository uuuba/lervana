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
        self.assertRedirects(self.client.get(reverse('dashboard')), '/login/?next=/')

    def test_all_pages_render_in_both_languages(self):
        names = ['dashboard', 'explore', 'recommendations', 'plan', 'skills', 'progress', 'saved',
                 'assistant', 'profile', 'settings']
        for lang in ('uk', 'en'):
            self.client.get(reverse('set_lang', args=[lang]))
            for n in names:
                self.assertEqual(self.client.get(reverse(n)).status_code, 200, (lang, n))
            self.assertEqual(self.client.get(reverse('course', args=[2])).status_code, 200)

    def test_language_switch_changes_text(self):
        self.client.get(reverse('set_lang', args=['en']))
        self.assertContains(self.client.get(reverse('dashboard')), 'Recommendations')

    def test_filters_and_search(self):
        r = self.client.get(reverse('explore'), {'cat': 'db'})
        self.assertEqual(len(r.context['recs']), 1)  # фільтр за категорією: лише «SQL і проєктування БД»
        r = self.client.get(reverse('explore'), {'q': 'pandas'})
        self.assertEqual(len(r.context['recs']), 1)

    def test_task_toggle_updates_progress(self):
        module = Module.objects.filter(course__title_en='SQL & Database Design').first()
        r = self.client.post(reverse('task_toggle', args=[module.id]), HTTP_X_REQUESTED_WITH='XMLHttpRequest')
        self.assertEqual(r.json()['done'], True)
        self.assertEqual(ModuleProgress.objects.filter(module=module).count(), 1)
        r = self.client.post(reverse('task_toggle', args=[module.id]), HTTP_X_REQUESTED_WITH='XMLHttpRequest')
        self.assertEqual(r.json()['done'], False)

    def test_save_toggle(self):
        r = self.client.post(reverse('save_toggle', args=[1]), HTTP_X_REQUESTED_WITH='XMLHttpRequest')
        self.assertTrue(r.json()['saved'])

    def test_profile_requires_interest(self):
        r = self.client.post(reverse('profile'), {'display_name': 'X'}, follow=True)
        self.assertContains(r, 'js-msg')
        self.assertEqual(Profile.objects.get(user=self.user).interests.count(), 3)

    def test_register_creates_profile_and_empty_state(self):
        self.client.logout()
        r = self.client.post(reverse('register'), {'username': 'newbie', 'password1': 'Str0ngPass!', 'password2': 'Str0ngPass!'})
        self.assertRedirects(r, reverse('profile'))
        user = User.objects.get(username='newbie')
        self.assertTrue(hasattr(user, 'profile'))
        self.assertContains(self.client.get(reverse('recommendations')), 'c em')

    def test_assistant_and_stats(self):
        r = self.client.post(reverse('assistant_ask'), '{"q": "2"}', content_type='application/json')
        self.assertIn('answer', r.json())
        self.assertGreaterEqual(services.streak(self.user), 0)
