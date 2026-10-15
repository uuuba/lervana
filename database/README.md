# database/ — дамп бази даних Learnova (MySQL)

Тут зберігається повний знімок робочої бази у форматі MySQL.

| Файл | Що це |
|---|---|
| `learnova.sql` | Повний дамп: схема всіх 28 таблиць + демонстраційні дані (`mysqldump`, MySQL 8.0.46) |

У MySQL дані зберігаються на самому сервері (не в файлі, як у SQLite), тому «папка бази»
у проєкті — це SQL-дамп, з якого базу повністю відновлюються на будь-якій машині.

## Склад дампу

- 28 таблиць: 18 власних (`core_*`) + системні Django (`auth_*`, `django_*`)
- дані: 8 курсів, 24 модулі, 7 інтересів, 5 навичок, 8 записів бази знань агента,
  демо-користувач `demo` (пароль `demo12345`), 2 профілі, 2 записи на курси
- кодування `utf8mb4`, колація `utf8mb4_unicode_ci`

## Відновлення бази з дампу

Створіть базу та користувача (один раз, від `root`):

```sql
CREATE DATABASE IF NOT EXISTS learnova CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'learnova'@'localhost' IDENTIFIED BY 'learnova_app_2026';
CREATE USER IF NOT EXISTS 'learnova'@'127.0.0.1' IDENTIFIED BY 'learnova_app_2026';
GRANT ALL PRIVILEGES ON `learnova`.* TO 'learnova'@'localhost';
GRANT ALL PRIVILEGES ON `learnova`.* TO 'learnova'@'127.0.0.1';
GRANT ALL PRIVILEGES ON `test\_learnova`.* TO 'learnova'@'localhost';
GRANT ALL PRIVILEGES ON `test\_learnova`.* TO 'learnova'@'127.0.0.1';
FLUSH PRIVILEGES;
```

Імпорт (PowerShell, у теці проєкту):

```powershell
cmd /c "`"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe`" -u learnova -plearnova_app_2026 --protocol=TCP -h 127.0.0.1 -P 3306 --default-character-set=utf8mb4 learnova < database\learnova.sql"
```

У файлі є `DROP TABLE IF EXISTS`, тому імпорт можна повторювати — таблиці перестворюються.

## Оновлення дампу

Після змін у даних (наприклад, після `seed_demo`):

```powershell
& 'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysqldump.exe' `
  -u learnova -plearnova_app_2026 --protocol=TCP -h 127.0.0.1 -P 3306 `
  --default-character-set=utf8mb4 --single-transaction --add-drop-table --no-tablespace `
  --result-file=database\learnova.sql learnova
```

## Альтернатива: чиста схема без даних

Для звіту/налаштування з нуля використовуйте `docs/schema.sql` (DDL з міграцій Django)
або просто:

```powershell
python manage.py migrate     # створить таблиці
python manage.py seed_demo   # наповнить демо-даними
```
