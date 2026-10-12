# ERD (розділ 1.2)

Діаграму можна відкрити у будь-якому Mermaid-рендері (GitHub, VS Code, mermaid.live) і додати до звіту як зображення.

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
        bool is_published
    }
    PREREQUISITE {
        int min_level "1-5"
    }
    MODULEPROGRESS {
        datetime completed_at
    }
```

Точний SQL, який Django генерує для цих таблиць, лежить у `docs/schema.sql`
(отримано командою `python manage.py sqlmigrate core 0001`).
