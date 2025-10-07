# Sefaria Development Container Local Settings
# This file is automatically copied to sefaria/local_settings.py during devcontainer setup

# ====================
# Core Settings
# ====================

DEBUG = True
ALLOWED_HOSTS = ['*']

# ====================
# Database Configuration
# ====================

# PostgreSQL - Used by Django for authentication and sessions
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'sefaria',
        'USER': 'admin',
        'PASSWORD': 'admin',
        'HOST': 'postgres',  # Docker Compose service name
        'PORT': '',
    }
}

# MongoDB - Main database for Sefaria texts and data
MONGO_HOST = "db"  # Docker Compose service name
SEFARIA_DB = "sefaria"
SEFARIA_DB_USER = ""
SEFARIA_DB_PASSWORD = ""

# ====================
# Cache Configuration
# ====================

# Redis configuration for caching
MULTISERVER_REDIS_SERVER = "cache"  # Docker Compose service name
REDIS_HOST = "cache"
REDIS_PORT = 6379

CACHES = {
    "default": {
        "BACKEND": "django_redis.cache.RedisCache",
        "LOCATION": "redis://cache:6379/0",
        "OPTIONS": {
            "CLIENT_CLASS": "django_redis.client.DefaultClient",
            "PARSER_CLASS": "redis.connection.HiredisParser",
        },
        "KEY_PREFIX": "sefaria",
        "TIMEOUT": 60 * 60 * 24 * 30,
    },
    "shared": {
        "BACKEND": "django_redis.cache.RedisCache", 
        "LOCATION": "redis://cache:6379/1",
        "OPTIONS": {
            "CLIENT_CLASS": "django_redis.client.DefaultClient",
            "PARSER_CLASS": "redis.connection.HiredisParser",
        },
        "KEY_PREFIX": "sefaria-shared",
        "TIMEOUT": 60 * 60 * 24 * 30,
    }
}

# Session configuration
SESSION_CACHE_ALIAS = "default"
USER_AGENTS_CACHE = 'default'
SHARED_DATA_CACHE_ALIAS = 'shared'

# ====================
# Node.js Server-Side Rendering
# ====================

USE_NODE = True
NODE_HOST = "http://node:3000"  # Docker Compose service name
NODE_TIMEOUT = 10

# ====================
# reCAPTCHA Configuration
# ====================

# Use test keys for development to suppress warnings
SILENCED_SYSTEM_CHECKS = ['captcha.recaptcha_test_key_error']

# ====================
# Logging Configuration
# ====================

LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'standard': {
            'format': '%(asctime)s [%(levelname)s] %(name)s: %(message)s'
        },
    },
    'handlers': {
        'console': {
            'level': 'INFO',
            'class': 'logging.StreamHandler',
            'formatter': 'standard'
        },
        'file': {
            'level': 'DEBUG',
            'class': 'logging.FileHandler',
            'filename': '/app/log/sefaria.log',
            'formatter': 'standard'
        },
    },
    'loggers': {
        'django': {
            'handlers': ['console', 'file'],
            'level': 'INFO',
            'propagate': False,
        },
        'sefaria': {
            'handlers': ['console', 'file'],
            'level': 'DEBUG',
            'propagate': False,
        },
    },
    'root': {
        'handlers': ['console'],
        'level': 'INFO',
    }
}

# ====================
# Email Configuration (Development)
# ====================

# Use console backend for development
EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'

# ====================
# Static Files
# ====================

STATIC_URL = '/static/'
STATIC_ROOT = '/app/static/'

# ====================
# Security Settings (Development)
# ====================

# Less strict security for development
SECRET_KEY = 'dev-secret-key-change-in-production'
CSRF_COOKIE_SECURE = False
SESSION_COOKIE_SECURE = False

# ====================
# Celery Configuration
# ====================

# Use Redis as broker for Celery
CELERY_BROKER_URL = 'redis://cache:6379/2'
CELERY_RESULT_BACKEND = 'redis://cache:6379/2'

# ====================
# Search Configuration
# ====================

# Elasticsearch is not included in the basic devcontainer setup
# Uncomment and configure if you need Elasticsearch for development
# SEARCH_HOST = "elasticsearch"
# SEARCH_ADMIN = "http://elasticsearch:9200"

# ====================
# Custom Settings
# ====================

# Add any custom settings below this line
