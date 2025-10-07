#!/bin/bash
# Sefaria Development Container - Post-Creation Setup Script
# This script runs once after the container is created
#
# DERIVATION NOTES:
# - Service names (db, cache, postgres) from docker-compose.yml
# - MongoDB dump URLs from installation documentation
# - Django migrations: Standard Django practice
# - npm build commands: From package.json scripts
# - Wait logic: Standard best practice for multi-service containers

set -e

echo "======================================"
echo "Sefaria Development Container Setup"
echo "======================================"
echo ""

# Colors for output
# [RECOMMENDATION] Use colors for better readability
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored output
# [RECOMMENDATION] Helper functions for consistent output formatting
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "ℹ $1"
}

# ====================
# Step 1: Wait for Services
# ====================
echo "Step 1: Waiting for services to be ready..."

# Wait for MongoDB
# [DERIVED] Service name 'db' from docker-compose.yml
# [RECOMMENDATION] Use mongosh (modern MongoDB shell) instead of deprecated mongo
print_info "Waiting for MongoDB..."
max_attempts=30
attempt=0
until mongosh --host db --eval "db.adminCommand('ping')" >/dev/null 2>&1; do
    attempt=$((attempt + 1))
    if [ $attempt -ge $max_attempts ]; then
        print_error "MongoDB did not become ready in time"
        exit 1
    fi
    sleep 2
done
print_success "MongoDB is ready"

# Wait for Redis
# [DERIVED] Service name 'cache' from docker-compose.yml
print_info "Waiting for Redis..."
attempt=0
until redis-cli -h cache ping >/dev/null 2>&1; do
    attempt=$((attempt + 1))
    if [ $attempt -ge $max_attempts ]; then
        print_error "Redis did not become ready in time"
        exit 1
    fi
    sleep 2
done
print_success "Redis is ready"

# Wait for PostgreSQL
# [DERIVED] Service name 'postgres' and user 'admin' from docker-compose.yml
print_info "Waiting for PostgreSQL..."
attempt=0
until pg_isready -h postgres -U admin >/dev/null 2>&1; do
    attempt=$((attempt + 1))
    if [ $attempt -ge $max_attempts ]; then
        print_error "PostgreSQL did not become ready in time"
        exit 1
    fi
    sleep 2
done
print_success "PostgreSQL is ready"

echo ""

# ====================
# Step 2: Configure Local Settings
# ====================
echo "Step 2: Configuring local settings..."

# [DERIVED] Copy devcontainer-specific settings to sefaria/local_settings.py
# Source file: .devcontainer/local_settings_devcontainer.py
# Destination: Standard Django local_settings.py location
if [ ! -f "/app/sefaria/local_settings.py" ]; then
    cp /app/.devcontainer/local_settings_devcontainer.py /app/sefaria/local_settings.py
    print_success "Created local_settings.py"
else
    print_warning "local_settings.py already exists, skipping"
fi

echo ""

# ====================
# Step 3: Ensure Log Directory
# ====================
echo "Step 3: Setting up log directory..."

# [DERIVED] Log directory location from installation docs
# "Create a directory called log under the root project folder"
if [ ! -d "/app/log" ]; then
    mkdir -p /app/log
fi
chmod 777 /app/log
print_success "Log directory ready"

echo ""

# ====================
# Step 4: MongoDB Database Setup
# ====================
echo "Step 4: Checking MongoDB database..."

# Check if MongoDB has data
# [RECOMMENDATION] Check for existing data before prompting for dump restoration
collection_count=$(mongosh --host db --quiet --eval "db.getMongo().getDBNames().length")

if [ "$collection_count" -le 1 ]; then
    print_warning "MongoDB is empty - you need to restore a database dump"
    echo ""
    echo "======================================"
    echo "MongoDB Database Setup Required"
    echo "======================================"
    echo ""
    echo "Choose one of the following database dumps:"
    echo ""
    # [DERIVED] Dump URLs and descriptions from installation documentation
    # https://developers.sefaria.org/docs/local-installation-instructions
    echo "📦 Option 1: Small Dump (Recommended for most development)"
    echo "   • Size: ~3-4 GB"
    echo "   • Contains: All texts, no revision history"
    echo "   • Download command:"
    echo "     curl -O https://storage.googleapis.com/sefaria-mongo-backup/dump_small.tar.gz"
    echo ""
    echo "📦 Option 2: Full Dump (Only if you need revision history)"
    echo "   • Size: Larger"
    echo "   • Contains: All texts + complete revision history"
    echo "   • Download command:"
    echo "     curl -O https://storage.googleapis.com/sefaria-mongo-backup/dump.tar.gz"
    echo ""
    # [DERIVED] mongorestore commands from installation documentation
    echo "After downloading, extract the dump:"
    echo "   tar -xzf dump_small.tar.gz  # or dump.tar.gz for full dump"
    echo ""
    echo "Then restore it to MongoDB:"
    echo "   mongorestore --host db --port 27017"
    echo ""
    # [DERIVED] History collection requirement from installation docs
    echo "If using the small dump, also create the history collection:"
    echo "   mongosh --host db --eval 'use sefaria; db.createCollection(\"history\")'"
    echo ""
    echo "After restoring the database, you can continue with development!"
    echo "======================================"
    echo ""
else
    print_success "MongoDB already contains data"
    
    # Check if we need to create history collection (for small dump users)
    # [DERIVED] History collection requirement from installation docs
    has_history=$(mongosh --host db sefaria --quiet --eval "db.getCollectionNames().includes('history')")
    if [ "$has_history" = "false" ]; then
        print_info "Creating empty history collection..."
        mongosh --host db sefaria --eval "db.createCollection('history')" >/dev/null 2>&1
        print_success "History collection created"
    fi
fi

echo ""

# ====================
# Step 5: Django Setup
# ====================
echo "Step 5: Running Django migrations..."

# [DERIVED] Django migrations: Standard Django setup step
# Mentioned in installation docs: "Run Django migrations"
cd /app
python manage.py migrate --noinput
print_success "Django migrations completed"

echo ""

# ====================
# Step 6: Frontend Setup
# ====================
echo "Step 6: Building frontend assets..."

# Check if node_modules exists, if not install
# [RECOMMENDATION] Avoid rebuilding if already present (from Dockerfile)
if [ ! -d "/app/node_modules" ]; then
    print_info "Installing Node.js dependencies..."
    npm install
    print_success "Node.js dependencies installed"
fi

# Build client-side bundles
# [DERIVED] npm run build-client from package.json scripts
# From package.json: "build-client": "webpack --config ./node/webpack.client.js"
print_info "Building webpack bundles (this may take a few minutes)..."
npm run build-client
print_success "Frontend assets built"

echo ""

# ====================
# Step 7: Final Setup
# ====================
echo "======================================"
echo "🎉 Setup Complete!"
echo "======================================"
echo ""
echo "Your Sefaria development environment is ready!"
echo ""
# [DERIVED] Port numbers from docker-compose.yml service definitions
echo "📍 Important URLs:"
echo "   • Django Web Server: http://localhost:8000"
echo "   • Node.js SSR Server: http://localhost:3000"
echo "   • MongoDB: localhost:27017"
echo "   • Redis: localhost:6379"
echo "   • PostgreSQL: localhost:5433"
echo ""
# [DERIVED] Commands from package.json scripts and Django commands
echo "🚀 Common Commands:"
echo "   • Start Django: python manage.py runserver 0.0.0.0:8000"
echo "   • Watch frontend: npm run watch-client"
echo "   • Start Node.js SSR: npm start"
echo "   • Sefaria CLI: ./cli"
echo "   • MongoDB shell: mongosh --host db"
echo "   • Redis CLI: redis-cli -h cache"
echo ""
echo "📚 Documentation:"
echo "   • See .devcontainer/README.md for more information"
echo "   • Visit https://developers.sefaria.org for full docs"
echo ""
echo "======================================"
echo ""
