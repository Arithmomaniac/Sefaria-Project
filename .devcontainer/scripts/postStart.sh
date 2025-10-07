#!/bin/bash
set -e

echo "🔄 Sefaria devcontainer startup..."
echo ""

# Quick health checks
echo "✓ Checking services..."

# Check MongoDB
if mongosh --host db --eval "print('ok')" > /dev/null 2>&1; then
    echo "  ✓ MongoDB: Connected"
else
    echo "  ✗ MongoDB: Not available"
fi

# Check Redis
if redis-cli -h cache ping > /dev/null 2>&1; then
    echo "  ✓ Redis: Connected"
else
    echo "  ✗ Redis: Not available"
fi

# Check PostgreSQL
if PGPASSWORD=admin psql -h postgres -U admin -d sefaria -c "SELECT 1" > /dev/null 2>&1; then
    echo "  ✓ PostgreSQL: Connected"
else
    echo "  ✗ PostgreSQL: Not available"
fi

echo ""
echo "🎯 Ready to start developing!"
echo ""
echo "📚 Common commands:"
echo "  python manage.py runserver 0.0.0.0:8000  - Start Django dev server"
echo "  npm run watch-client                      - Watch and rebuild frontend"
echo "  npm start                                 - Start Node.js SSR server"
echo "  ./cli                                     - Open Sefaria CLI interface"
echo ""
