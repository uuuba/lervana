# ERD (розділ 1.2)

Діаграму можна відкрити у будь-якому Mermaid-рендері (GitHub, VS Code, mermaid.live) і додати до звіту як зображення.

> У цій же теці лежить **`docs/ERD.mwb`** — готова модель тієї ж бази для **MySQL Workbench**
> (усі 28 таблиць, звʼязки FK та ER-діаграма). Відкриється подвійним кліком або через
> Workbench → *File → Open Model*.
> У VS Code модель не відкривається (це бінарний формат Workbench) — там користуйтесь
> Mermaid-блоком нижче: розгорніть попередній перегляд Markdown
> (розширення *Markdown Preview Mermaid Support*; підказки є у `.vscode/extensions.json`).

```mermaid
erDiagram
    USER ||--|| PROFILE : "має"
    PROFILE }o--o{ INTEREST : "обрані інтереси"
    USER ||--o{ USERSKILL : "оцінює"
    SKILL ||--o{ USERSKILL : ""
    INTEREST ||--o{ COURSE : "категорія"
    COURSE }o--o{ INTEREST : "теги"
    COURSE ||--o{ COURSESKILL : "дає навичку"
    SKILL ||--o{ COURSESKILL : ""
    COURSE ||--o{ PREREQUISITE : "вимагає"
    SKILL ||--o{ PREREQUISITE : ""
    COURSE ||--o{ MODULE : "складається з"
    USER ||--o{ ENROLLMENT : "проходить"
    COURSE ||--o{ ENROLLMENT : ""
    ENROLLMENT ||--o{ MODULEPROGRESS : "виконані модулі"
    MODULE ||--o{ MODULEPROGRESS : ""
    USER ||--o{ SAVEDCOURSE : "зберігає"
    COURSE ||--o{ SAVEDCOURSE : ""
    USER ||--o{ RECENTVIEW : "переглядав"
    COURSE ||--o{ RECENTVIEW : ""
    USER ||--o{ NOTIFICATION : "отримує"
    USER ||--o{ CHATSESSION : "діалоги з агентом"
    CHATSESSION ||--o{ CHATMESSAGE : "повідомлення"

    PROFILE {
        string display_name
        string goal
        int weekly_hours
        string preferred_format
        bool reminders
    }
    USERSKILL {
        int current_level "0-5"
        int desired_level "0-5"
    }
    COURSE {
        string title_uk
        string title_en
        int level "1-3"
        int duration_hours
        string format "vid/prac/txt"
        string cover_key "ключ ілюстрації обкладинки"
        bool is_published
    }
    PREREQUISITE {
        int min_level "1-5"
    }
    MODULEPROGRESS {
        datetime completed_at
    }
    AGENTKNOWLEDGE {
        string key "унікальний"
        string keywords "ключові слова для пошуку"
        string question_uk
        string question_en
        text answer_uk
        text answer_en
        int priority "пріоритет збігу"
        int hits "лічильник використань"
        bool is_active
    }
    CHATSESSION {
        int user_id "null для гостей"
        string session_key
        datetime updated_at
    }
    CHATMESSAGE {
        string role "user/agent"
        text content
        string source "db/kb/fallback"
        datetime created_at
    }
```

## Обмеження цілісності (міграція 0002)

| Таблиця | Обмеження / індекс |
|---|---|
| `course` | `UNIQUE` немає; `CHECK level IN (1,2,3)`, `CHECK duration_hours > 0`; індекси `(is_published, level)`, `(category, format)` |
| `courseskill` | `UNIQUE (course, skill)`; індекс `(skill, order)` |
| `prerequisite` | `UNIQUE (course, skill)`, `CHECK min_level >= 1` |
| `module` | `UNIQUE (course, order)` |
| `profile` | `UNIQUE (user)`, `CHECK weekly_hours BETWEEN 1 AND 30` |
| `userskill` | `UNIQUE (user, skill)`, `CHECK current_level <= 5`, `CHECK desired_level <= 5`; індекс `(user, skill)` |
| `enrollment` | `UNIQUE (user, course)`; індекс `(user, started_at)` |
| `moduleprogress` | `UNIQUE (enrollment, module)`; індекс на `completed_at` |
| `savedcourse` / `recentview` | `UNIQUE (user, course)`; `recentview` — індекс `(user, -viewed_at)` |
| `notification` | індекс `(user, is_read)` |
| `agentknowledge` | `UNIQUE (key)`; індекс `(is_active, -priority)` |
| `chatsession` | індекс `(user, -updated_at)`, `session_key` індексовано |
| `chatmessage` | індекс `(session, created_at)`; `created_at` індексовано |

Точний SQL, який Django генерує для цих таблиць, лежить у `docs/schema.sql`
(отримано командами `python manage.py sqlmigrate core 0001` та `python manage.py sqlmigrate core 0002`).
