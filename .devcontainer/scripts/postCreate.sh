#!/bin/bash
set -e

echo "🚀 Starting Sefaria devcontainer initialization..."
echo ""

# Wait for services to be ready
echo "⏳ Waiting for services to start..."

# Wait for MongoDB
echo "Checking MongoDB..."
max_attempts=30
attempt=0
until mongosh --host db --eval "print('MongoDB is ready')" > /dev/null 2>&1; do
    attempt=$((attempt + 1))
    if [ $attempt -gt $max_attempts ]; then
        echo "❌ MongoDB failed to start after $max_attempts attempts"
        exit 1
    fi
    echo "  Waiting for MongoDB... (attempt $attempt/$max_attempts)"
    sleep 2
done
echo "✅ MongoDB is ready"

# Wait for Redis
echo "Checking Redis..."
attempt=0
until redis-cli -h cache ping > /dev/null 2>&1; do
    attempt=$((attempt + 1))
    if [ $attempt -gt $max_attempts ]; then
        echo "❌ Redis failed to start after $max_attempts attempts"
        exit 1
    fi
    echo "  Waiting for Redis... (attempt $attempt/$max_attempts)"
    sleep 2
done
echo "✅ Redis is ready"

# Wait for PostgreSQL
echo "Checking PostgreSQL..."
attempt=0
until PGPASSWORD=admin psql -h postgres -U admin -d sefaria -c "SELECT 1" > /dev/null 2>&1; do
    attempt=$((attempt + 1))
    if [ $attempt -gt $max_attempts ]; then
        echo "❌ PostgreSQL failed to start after $max_attempts attempts"
        exit 1
    fi
    echo "  Waiting for PostgreSQL... (attempt $attempt/$max_attempts)"
    sleep 2
done
echo "✅ PostgreSQL is ready"

echo ""
echo "📝 Configuring local settings..."
# Copy devcontainer local settings if local_settings.py doesn't exist
if [ ! -f /app/sefaria/local_settings.py ]; then
    cp /app/.devcontainer/local_settings_devcontainer.py /app/sefaria/local_settings.py
    echo "✅ Created sefaria/local_settings.py from devcontainer template"
else
    echo "ℹ️  sefaria/local_settings.py already exists, skipping"
fi

echo ""
echo "🗄️  Checking MongoDB data..."
# Check if MongoDB has data
collection_count=$(mongosh --host db --quiet --eval "db.adminCommand('listDatabases').databases.find(d => d.name === 'sefaria')?.sizeOnDisk || 0")

if [ "$collection_count" = "0" ] || [ -z "$collection_count" ]; then
    echo "⚠️  MongoDB is empty. You need to restore a database dump."
    echo ""
    echo "📥 Choose one of the following dumps:"
    echo ""
    echo "Option 1: Small Dump (Recommended for most development)"
    echo "  Size: ~3-4 GB"
    echo "  Contains: All texts, no revision history"
    echo "  Download: curl -L -o dump_small.tar.gz https://storage.googleapis.com/sefaria-mongo-backup/dump_small.tar.gz"
    echo ""
    echo "Option 2: Full Dump (Only if you need revision history)"
    echo "  Size: Larger"
    echo "  Contains: All texts + complete revision history"
    echo "  Download: curl -L -o dump.tar.gz https://storage.googleapis.com/sefaria-mongo-backup/dump.tar.gz"
    echo ""
    echo "After downloading to your local machine:"
    echo "  1. Extract: tar -xzf dump_small.tar.gz (or dump.tar.gz)"
    echo "  2. Place the extracted 'dump' folder in the project root"
    echo "  3. Rebuild the devcontainer (Cmd/Ctrl+Shift+P -> 'Dev Containers: Rebuild Container')"
    echo ""
    echo "The setup will automatically restore the dump on next rebuild."
    echo ""
    
    # Check if dump directory exists
    if [ -d /app/dump ]; then
        echo "📦 Found dump directory, restoring..."
        mongorestore --host db --port 27017 --drop -d sefaria /app/dump/sefaria
        echo "✅ MongoDB data restored"
        
        # If using small dump, create empty history collection
        echo "Creating history collection (if needed)..."
        mongosh --host db --eval "use sefaria; db.createCollection('history')" || true
    fi
else
    echo "✅ MongoDB already contains data"
fi

echo ""
echo "🔧 Setting up Django..."
# Create log directory with proper permissions
mkdir -p /app/log
chmod 777 /app/log
echo "✅ Log directory created"

# Run Django migrations
echo "Running Django migrations..."
python /app/manage.py migrate
echo "✅ Django migrations complete"

echo ""
echo "📦 Setting up frontend..."
# Build frontend (if not already built)
if [ ! -d /app/static/bundles ]; then
    echo "Building webpack bundles (this may take a few minutes)..."
    cd /app && npm run build-client
    echo "✅ Frontend build complete"
else
    echo "✅ Frontend bundles already exist"
fi

echo ""
echo "✨ Devcontainer initialization complete!"
echo ""
echo "🎯 Next steps:"
echo "  1. If MongoDB was empty, download and restore a dump (see instructions above)"
echo "  2. Start Django: python manage.py runserver 0.0.0.0:8000"
echo "  3. Start webpack watch: npm run watch-client"
echo "  4. Start Node.js SSR: npm start"
echo ""
echo "📚 Useful commands:"
echo "  python manage.py runserver 0.0.0.0:8000  - Start Django dev server"
echo "  npm run watch-client                      - Watch and rebuild frontend"
echo "  npm start                                 - Start Node.js SSR server"
echo "  ./cli                                     - Open Sefaria CLI interface"
echo "  mongosh --host db                         - Connect to MongoDB"
echo "  redis-cli -h cache                        - Connect to Redis"
echo ""
