"""
Pre-configured local settings for VS Code devcontainer environment.
This file is automatically used when running in the devcontainer.
"""
from datetime import timedelta
import sys
import structlog
import sefaria.system.logging as sefaria_logging
import os

# Database configuration for PostgreSQL in Docker
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'sefaria',
        'USER': 'admin',
        'PASSWORD': 'admin',
        'HOST': 'postgres',  # Service name from docker-compose
        'PORT': '',
    }
}

# Map domain to an interface language
DOMAIN_LANGUAGES = {
    "http://localhost:8000": "english",
}

# MongoDB configuration
MONGO_REPLICASET_NAME = None
MONGO_HOST = "db"  # Service name from docker-compose
MONGO_PORT = 27017
SEFARIA_DB = 'sefaria'
SEFARIA_DB_USER = ''
SEFARIA_DB_PASSWORD = ''
APSCHEDULER_NAME = "apscheduler"

# Redis cache configuration for development with Node SSR
CACHES = {
    "shared": {
        "BACKEND": "django_redis.cache.RedisCache",
        "LOCATION": "redis://cache:6379/1",
        "OPTIONS": {
            "CLIENT_CLASS": "django_redis.client.DefaultClient",
            "SERIALIZER": "sefaria.system.serializers.JSONSerializer",
        },
        "TIMEOUT": None,
    },
    "default": {
        "BACKEND": "django_redis.cache.RedisCache",
        "LOCATION": "redis://cache:6379/0",
        "OPTIONS": {
            "CLIENT_CLASS": "django_redis.client.DefaultClient",
        },
        "TIMEOUT": 60 * 60 * 24 * 30,
    },
}

SESSION_CACHE_ALIAS = "default"
USER_AGENTS_CACHE = 'default'
SHARED_DATA_CACHE_ALIAS = 'shared'

SITE_PACKAGE = "sites.sefaria"

# Development settings
DEBUG = True
ALLOWED_HOSTS = ['*']
OFFLINE = False
DOWN_FOR_MAINTENANCE = False
MAINTENANCE_MESSAGE = ""

# Strapi CMS (not used in development by default)
STRAPI_LOCATION = None
STRAPI_PORT = None

ADMINS = (
    ('Developer', 'dev@example.com'),
)

MANAGERS = ADMINS

SECRET_KEY = 'devcontainer-secret-key-change-in-production'

# Email backend for development (console output)
EMAIL_HOST = 'localhost'
EMAIL_PORT = 1025
EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'

# ElasticSearch - not configured by default for devcontainer
# Set this to https://sefaria.org:443/api/search to use production search
SEARCH_URL = "http://localhost:9200"
SEARCH_INDEX_ON_SAVE = False
SEARCH_INDEX_NAME_TEXT = 'text'
SEARCH_INDEX_NAME_SHEET = 'sheet'

# Node.js SSR configuration
USE_NODE = True
NODE_HOST = "http://node:3000"  # Service name from docker-compose
NODE_TIMEOUT = 10

# Data paths (inside container)
SEFARIA_DATA_PATH = '/app/data'
SEFARIA_EXPORT_PATH = '/app/data/export'

# Analytics (disabled for development)
GOOGLE_GTAG = ''
GOOGLE_TAG_MANAGER_CODE = ''
HOTJAR_ID = None

# CRM (disabled for development)
CRM_TYPE = "NONE"

# Varnish (disabled for development)
USE_VARNISH = False
FRONT_END_URL = "http://localhost:8000"

# Multiserver Redis
MULTISERVER_REDIS_SERVER = "cache"
REDIS_HOST = "cache"
REDIS_PORT = 6379

# Silence reCAPTCHA test key warnings
SILENCED_SYSTEM_CHECKS = ['captcha.recaptcha_test_key_error']

# Logging configuration
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'format': '{levelname} {asctime} {module} {message}',
            'style': '{',
        },
    },
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
            'formatter': 'verbose',
        },
        'file': {
            'level': 'DEBUG',
            'class': 'logging.FileHandler',
            'filename': '/app/log/sefaria.log',
            'formatter': 'verbose',
        },
    },
    'loggers': {
        'django': {
            'handlers': ['console', 'file'],
            'level': 'INFO',
            'propagate': True,
        },
        'sefaria': {
            'handlers': ['console', 'file'],
            'level': 'DEBUG',
            'propagate': False,
        },
    },
}

# Admin path
ADMIN_PATH = 'admin'

# IP Country for parashat hashavua
PINNED_IPCOUNTRY = "IL"
