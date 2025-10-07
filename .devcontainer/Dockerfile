# Sefaria Development Container
# Based on Python 3.9 with Node.js 20 and development tools
# 
# DERIVATION NOTES:
# - Base Python version: Upgraded to 3.9 from 3.7 (Dockerfile uses 3.7, but dev_docker/Dockerfile uses 3.9)
# - Node.js version: 20.x chosen to match modern requirements (docker-compose.yml uses node:latest)
# - Working directory: /app matches existing Dockerfile and docker-compose.yml volumes
# - Dependencies: Derived from requirements.txt and package.json

# [RECOMMENDATION] Use Python 3.9 instead of 3.7 for better compatibility
# Source: dev_docker/Dockerfile uses Python 3.9, main Dockerfile uses 3.7 (outdated)
# Reason: Python 3.9 has better library support and is recommended in installation docs
FROM python:3.9-slim

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
# [DERIVED] Core dependencies from main Dockerfile and dev_docker/Dockerfile
# gcc and libpq-dev: From main Dockerfile
# git, curl: From dev_docker/Dockerfile  
# gettext: Required for Django i18n (installation docs)
# postgresql-client, redis-tools: For database access
# vim, nano, zsh, wget, gnupg, ca-certificates, sudo: Development conveniences
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    g++ \
    make \
    libpq-dev \
    postgresql-client \
    git \
    curl \
    wget \
    vim \
    nano \
    zsh \
    gettext \
    gnupg \
    ca-certificates \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install MongoDB Shell and Database Tools
# [DERIVED] MongoDB 4.4 from docker-compose.yml: image: "mongo:4.4"
# [RECOMMENDATION] Install mongosh and database-tools for dump/restore operations
RUN curl -fsSL https://www.mongodb.org/static/pgp/server-4.4.asc | gpg --dearmor -o /usr/share/keyrings/mongodb-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/mongodb-archive-keyring.gpg] http://repo.mongodb.org/apt/debian buster/mongodb-org/4.4 main" | tee /etc/apt/sources.list.d/mongodb-org-4.4.list \
    && apt-get update \
    && apt-get install -y mongodb-mongosh mongodb-database-tools \
    && rm -rf /var/lib/apt/lists/*

# Install Redis CLI
# [DERIVED] Redis from docker-compose.yml: image: "redis:latest"
# [RECOMMENDATION] Add redis-tools for redis-cli access
RUN apt-get update && apt-get install -y redis-tools \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 20.x
# [DERIVED] docker-compose.yml uses image: "node:latest"
# [RECOMMENDATION] Pin to Node.js 20.x LTS for stability while staying modern
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Verify installations
# [RECOMMENDATION] Validate all critical tools are installed
RUN python --version && \
    node --version && \
    npm --version && \
    git --version

# Set working directory
# [DERIVED] Matches Dockerfile: "WORKDIR /app"
# [DERIVED] Matches docker-compose.yml volumes: ".:/app"
WORKDIR /app

# Copy requirements first for better layer caching
# [DERIVED] requirements.txt from project root
COPY requirements.txt /app/

# Install Python dependencies
# [DERIVED] Fallback for psycopg2 issues mentioned in installation docs
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt || \
    (echo "Note: Some packages may have failed. This is often OK for psycopg2." && \
     sed -i 's/^psycopg2==2.8.6/#psycopg2==2.8.6\npsycopg2-binary==2.8.6/' requirements.txt && \
     pip install --no-cache-dir -r requirements.txt)

# Copy package files for Node dependencies
# [DERIVED] package.json and package-lock.json from project root
COPY package*.json /app/
RUN npm install

# Create log directory with proper permissions
# [DERIVED] Installation docs: "Create a directory called log under the root project folder"
RUN mkdir -p /app/log && chmod 777 /app/log

# Install global npm packages useful for development
# [DERIVED] package.json devDependencies includes nodemon
# [RECOMMENDATION] Install globally for easier access
RUN npm install -g nodemon

# Set up a non-root user for development (optional, commented out for simplicity)
# [RECOMMENDATION] Security best practice, but disabled for easier initial setup
# ARG USER_UID=1000
# ARG USER_GID=1000
# RUN groupadd --gid $USER_GID developer && \
#     useradd --uid $USER_UID --gid $USER_GID -m developer && \
#     echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Configure git to trust the workspace directory
# [RECOMMENDATION] Prevents git "dubious ownership" warnings in container
RUN git config --global --add safe.directory /app

# Set environment variables
# [DERIVED] Standard for Django: PYTHONUNBUFFERED shows logs immediately
# [RECOMMENDATION] NODE_ENV=development for development mode
ENV PYTHONUNBUFFERED=1
ENV NODE_ENV=development

# Keep container running
# [RECOMMENDATION] Override CMD to keep container alive for devcontainer
# Original Dockerfile uses: CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
CMD ["sleep", "infinity"]
