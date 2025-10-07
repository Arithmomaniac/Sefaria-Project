FROM python:3.9-slim

# Prevent Python from writing pyc files and enable unbuffered output
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Build essentials
    build-essential \
    gcc \
    g++ \
    # PostgreSQL client library
    libpq-dev \
    # Development tools
    git \
    curl \
    wget \
    vim \
    zsh \
    # Gettext for Django i18n
    gettext \
    # Additional utilities
    procps \
    net-tools \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 20
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements and install Python dependencies
# This is done before copying the full app to leverage Docker layer caching
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Copy package files and install Node dependencies
COPY package.json package-lock.json /app/
RUN npm install

# Create log directory
RUN mkdir -p /app/log && chmod 777 /app/log

# Create non-root user (optional, but good practice)
ARG USER_UID=1000
ARG USER_GID=1000
RUN groupadd --gid $USER_GID vscode || true \
    && useradd --uid $USER_UID --gid $USER_GID -m vscode || true

# Install mongosh (MongoDB Shell) for database access
RUN wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | apt-key add - || true \
    && echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/debian bullseye/mongodb-org/6.0 main" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list || true \
    && apt-get update || true \
    && apt-get install -y mongodb-mongosh || true \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install redis-cli for Redis access
RUN apt-get update && apt-get install -y redis-tools \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set the default shell to bash
SHELL ["/bin/bash", "-c"]

# Default command (will be overridden by devcontainer)
CMD ["sleep", "infinity"]
