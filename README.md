# Learnova — Django-проєкт

Інтелектуальна система персоналізованих освітніх рекомендацій на основі інтересів, компетенцій та навчальних потреб користувача.
Це перенесення HTML-прототипу на Django: дизайн, теми, двомовність та анімації збережені, а дані й логіка тепер працюють через базу даних.

## Запуск (Windows, PowerShell)

```powershell
cd learnova
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
python manage.py migrate
python manage.py seed_demo          # довідники, 8 курсів, база знань агента, демо-користувач
python manage.py runserver
```

Відкрити http://127.0.0.1:8000/ та увійти: **demo / demo12345**
(або зареєструвати нового користувача — тоді побачите порожні стани й онбординг).
Адмінка: `python manage.py createsuperuser`, далі http://127.0.0.1:8000/admin/ — там можна додавати курси, модулі, передумови **та записи бази знань агента**.

Тести: `python manage.py test core` (26 тестів: рекомендатор, фільтри, прогрес, реєстрація, мови, generic views, «ШІ-агент», віджет на сторінках і його закриття, редірект для анонімів).

## Структура

```
config/                     налаштування проєкту (settings, urls)
core/
  models.py                 модель даних (розділ 1.2) + таблиці агента
  migrations/               0001 — схема, 0002 — обмеження, індекси, таблиці агента
  views/                    generic views (пакет замість одного views.py)
    base.py                 LoginRequiredMixin, PageView, SavedIdsMixin
    pages.py                DashboardView, PlanView, SkillsView, ProgressView,
                            ProfileView (UpdateView + ProfileForm), SettingsView
    catalog.py              CatalogView (ListView) + Explore/Recommendations/Saved
    courses.py              CourseDetailView (DetailView) + POST-дії над курсом
    auth.py                 LoginView, RegisterView (FormView), SetLangView
    assistant.py            AssistantView + API агента (ask/history/clear)
  urls.py                   маршрути з namespace `core` (app_name='core')
  forms.py                  ProfileForm, RegisterForm
  agent.py                  «ШІ-агент»: інтенти → запити до БД → база знань
  recommender.py            рекомендаційна формула, прогалини навичок (1.3)
  services.py               прогрес, серія днів, тижнева активність
  i18n.py                   єдиний словник UA/EN (ключ -> (uk, en))
  icons.py                  SVG-іконки (60+) та обкладинки курсів (фото + градієнт)
  middleware.py             мова з сесії
  context_processors.py     меню, сповіщення, чипи агента
  templatetags/ui.py        теги {% t %}, {% icon %}, {% cover %}, {% why %}, fmt_icon
  templates/core/           base, dashboard, catalog, course_detail, plan, skills,
                            progress, profile, settings, assistant, auth,
                            _agent_widget.html (віджет на кожній сторінці)
  static/core/              css/styles.css, js/app.js, img/covers, img/avatars
  management/commands/seed_demo.py
docs/ERD.md, docs/schema.sql   ERD (Mermaid) і SQL-скрипти створення таблиць
```

## Маршрутизація та generic views

Усі сторінки — класи на базі дженерік-вів Django:

| Сторінка | Клас | URL |
|---|---|---|
| Панель | `DashboardView` (`TemplateView`) | `/` |
| Каталог / Рекомендації / Збережене | `CatalogView` (`ListView`) + підкласи | `/explore/`, `/recommendations/`, `/saved/` |
| Курс | `CourseDetailView` (`DetailView`) | `/course/<pk>/` |
| Профіль | `ProfileView` (`UpdateView` + `ProfileForm`) | `/profile/` |
| Реєстрація | `RegisterView` (`FormView`) | `/register/` |
| Вхід | `LoginView` (вбудований Django) | `/login/` |
| План / Навички / Прогрес / Налаштування | `TemplateView` | `/plan/`, `/skills/`, `/progress/`, `/settings/` |
| Дії (POST) | `View` | `/course/<pk>/start/`, `.../save/`, `/module/<id>/toggle/` |

Усі маршрути в `core/urls.py` мають неймспейс: `reverse('core:dashboard')`, `{% url 'core:course' pk %}`.
`app_name = 'core'`, `LOGIN_URL = 'core:login'`.

## «ШІ-агент» (пародія) і віджет на кожній сторінці

`core/agent.py` — агент **без нейромережі**: він відповідає виключно з бази даних.

1. нормалізує запитання та визначає намір («скільки курсів», «що рекомендують», «мій прогрес», «план на тиждень», «порівняй», «збережене», «категорії», «профіль», «передумови»);
2. збирає відповідь із таблиць (`course`, `profile`, `userskill`, `enrollment`, `moduleprogress`, `savedcourse`, `interest`) через ORM;
3. якщо наміру немає — шукає у базі знань `AgentKnowledge` за ключовими словами;
4. інакше — відповідає «не знаю» з прикладами запитань.

Кожне повідомлення зберігається в `ChatSession` / `ChatMessage` (джерело відповіді: `db`, `kb` або `fallback`).

API:

- `POST /assistant/api/ask/` — `{text}` → `{answer, source, label, tables}`
- `GET  /assistant/api/history/` — останні повідомлення діалогу
- `POST /assistant/api/clear/` — очистити історію

На **кожній сторінці** (включно зі сторінками входу/реєстрації) вставляється плаваючий віджет
`core/_agent_widget.html`: кнопка-«бульбашка» → панель чату з історією з БД, швидкими чипами
(з `AgentKnowledge`) та полем запитання. Повноцінний діалог — на сторінці `/assistant/`.

## Як працюють рекомендації

Оцінка збігу (0–100) — проста пояснювана формула, а не «чорна скринька»:

| Складник | Макс. | Що враховується |
|---|---|---|
| Інтереси | 40 | частка тегів курсу, що збігаються з інтересами користувача |
| Прогалини | 30 | частка навичок курсу, де бажаний рівень вищий за поточний |
| Рівень | 20 | наскільки рівень курсу підходить до поточного рівня основної навички |
| Формат | 10 | збіг із бажаним форматом навчання |

Завершені курси зі списку рекомендацій прибираються. Пояснення «Чому рекомендовано» формується з тих самих складників.

## Відповідність розділам звіту

- **1.2 Проєктування БД:** `docs/ERD.md` (діаграма), `docs/schema.sql` (SQL), `core/models.py` (обмеження та індекси — міграція `0002`).
- **1.3 Програмна реалізація:** `core/recommender.py`, `core/services.py`, `core/agent.py`, `core/views/` (generic views), `core/templatetags/ui.py`, `core/signals.py`.
- **1.4 Контрольний приклад:** вхід → профіль (інтереси, рівні) → рекомендації → сторінка курсу → «Почати» → план (відмітки модулів) → прогрес і навички → запитання «ШІ-агенту» у віджеті. Скріншоти робіть після `seed_demo` (демо-користувач) та зі свіжозареєстрованим акаунтом (порожні стани).

## Відмінності від HTML-прототипу

- Перемикання мови (UA/EN) відбувається з перезавантаженням сторінки: мова зберігається в сесії.
- Тема (світла/темна) зберігається в `localStorage` браузера.
- Усі числа реальні: години навчання, серія днів і діаграма тижня рахуються з виконаних модулів.
- «Асистент» тепер справжній ендпоінт: відповіді збираються з таблиць, історія діалогу зберігається в БД.
- Шрифт Manrope підтягується з Google Fonts, тому потрібен інтернет (без нього працює запасний шрифт).
