# Sefaria Development Container
# Based on Python 3.9 with Node.js 20 and development tools

FROM python:3.9-slim

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    # Build essentials
    build-essential \
    gcc \
    g++ \
    make \
    # PostgreSQL client libraries
    libpq-dev \
    postgresql-client \
    # Git and version control
    git \
    # Network utilities
    curl \
    wget \
    # Text editors
    vim \
    nano \
    # Shell
    zsh \
    # Localization
    gettext \
    # MongoDB tools will be installed separately
    gnupg \
    # Other utilities
    ca-certificates \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install MongoDB Shell and Database Tools
RUN curl -fsSL https://www.mongodb.org/static/pgp/server-4.4.asc | gpg --dearmor -o /usr/share/keyrings/mongodb-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/mongodb-archive-keyring.gpg] http://repo.mongodb.org/apt/debian buster/mongodb-org/4.4 main" | tee /etc/apt/sources.list.d/mongodb-org-4.4.list \
    && apt-get update \
    && apt-get install -y mongodb-mongosh mongodb-database-tools \
    && rm -rf /var/lib/apt/lists/*

# Install Redis CLI
RUN apt-get update && apt-get install -y redis-tools \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 20.x
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Verify installations
RUN python --version && \
    node --version && \
    npm --version && \
    git --version

# Set working directory
WORKDIR /app

# Copy requirements first for better layer caching
COPY requirements.txt /app/
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt || \
    (echo "Note: Some packages may have failed. This is often OK for psycopg2." && \
     sed -i 's/^psycopg2==2.8.6/#psycopg2==2.8.6\npsycopg2-binary==2.8.6/' requirements.txt && \
     pip install --no-cache-dir -r requirements.txt)

# Copy package files for Node dependencies
COPY package*.json /app/
RUN npm install

# Create log directory with proper permissions
RUN mkdir -p /app/log && chmod 777 /app/log

# Install global npm packages useful for development
RUN npm install -g nodemon

# Set up a non-root user for development (optional, commented out for simplicity)
# ARG USER_UID=1000
# ARG USER_GID=1000
# RUN groupadd --gid $USER_GID developer && \
#     useradd --uid $USER_UID --gid $USER_GID -m developer && \
#     echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Configure git to trust the workspace directory
RUN git config --global --add safe.directory /app

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV NODE_ENV=development

# Keep container running
CMD ["sleep", "infinity"]
