from pathlib import Path
import os

BASE_DIR = Path(__file__).resolve().parent.parent

# Секрети з'єднання з БД лежать у config/local_settings.py (у .gitignore)
# або підставляються зі змінних середовища: DB_USER / DB_PASSWORD / DB_NAME / ...
try:
    from .local_settings import DB_NAME as _DB_NAME, DB_PASSWORD as _DB_PASSWORD, DB_USER as _DB_USER
except ImportError:  # локального файлу немає — беремо значення за замовчуванням/env
    _DB_NAME, _DB_PASSWORD, _DB_USER = 'learnova', '', 'learnova'

SECRET_KEY = 'dev-only-change-me-in-production'
DEBUG = True
ALLOWED_HOSTS = []

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'core',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'core.middleware.LanguageMiddleware',  # мова інтерфейсу з сесії
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'config.urls'

TEMPLATES = [{
    'BACKEND': 'django.template.backends.django.DjangoTemplates',
    'DIRS': [],
    'APP_DIRS': True,
    'OPTIONS': {'context_processors': [
        'django.template.context_processors.request',
        'django.contrib.auth.context_processors.auth',
        'django.contrib.messages.context_processors.messages',
        'core.context_processors.ui',
    ]},
}]

WSGI_APPLICATION = 'config.wsgi.application'

DATABASES = {
    # Learnova повністю на MySQL 8 (InnoDB, utf8mb4). Драйвер — PyMySQL (див. config/__init__.py).
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': os.environ.get('DB_NAME', _DB_NAME),
        'USER': os.environ.get('DB_USER', _DB_USER),
        'PASSWORD': os.environ.get('DB_PASSWORD', _DB_PASSWORD),
        'HOST': os.environ.get('DB_HOST', '127.0.0.1'),
        'PORT': os.environ.get('DB_PORT', '3306'),
        'CONN_MAX_AGE': 60,                       # тримає пул з'єднань між запитами
        'OPTIONS': {
            'charset': 'utf8mb4',
            'init_command': "SET sql_mode='STRICT_TRANS_TABLES'",
            'connect_timeout': 10,
        },
        'ATOMIC_REQUESTS': True,                  # кожен HTTP-запит = одна транзакція
        'TEST': {'NAME': 'test_learnova', 'CHARSET': 'utf8mb4', 'COLLATION': 'utf8mb4_unicode_ci'},
    },
}

AUTH_PASSWORD_VALIDATORS = [
    {'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator', 'OPTIONS': {'min_length': 6}},
]

LANGUAGE_CODE = 'uk'
LANGUAGES = [('uk', 'Українська'), ('en', 'English')]
TIME_ZONE = 'Europe/Kyiv'
USE_I18N = True
USE_TZ = True

STATIC_URL = 'static/'
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

LOGIN_URL = 'core:login'
LOGIN_REDIRECT_URL = 'core:dashboard'
LOGOUT_REDIRECT_URL = 'core:login'
