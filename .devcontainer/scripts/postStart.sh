#!/bin/bash
# Sefaria Development Container - Post-Start Script
# This script runs every time the container starts

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo ""
echo "======================================"
echo "Sefaria Development Container"
echo "======================================"
echo ""

# Check service connectivity
echo "📡 Service Status:"

# MongoDB
if mongosh --host db --eval "db.adminCommand('ping')" >/dev/null 2>&1; then
    echo -e "   ${GREEN}✓${NC} MongoDB (db:27017)"
else
    echo -e "   ${YELLOW}⚠${NC} MongoDB (connecting...)"
fi

# Redis
if redis-cli -h cache ping >/dev/null 2>&1; then
    echo -e "   ${GREEN}✓${NC} Redis (cache:6379)"
else
    echo -e "   ${YELLOW}⚠${NC} Redis (connecting...)"
fi

# PostgreSQL
if pg_isready -h postgres -U admin >/dev/null 2>&1; then
    echo -e "   ${GREEN}✓${NC} PostgreSQL (postgres:5433)"
else
    echo -e "   ${YELLOW}⚠${NC} PostgreSQL (connecting...)"
fi

echo ""
echo "🚀 Quick Start Commands:"
echo "   python manage.py runserver 0.0.0.0:8000  # Start Django server"
echo "   npm run watch-client                      # Watch & rebuild frontend"
echo "   npm start                                 # Start Node.js SSR server"
echo "   ./cli                                     # Open Sefaria CLI"
echo ""
echo "🔍 Database Access:"
echo "   mongosh --host db                         # MongoDB shell"
echo "   redis-cli -h cache                        # Redis CLI"
echo "   psql -h postgres -U admin -d sefaria      # PostgreSQL shell"
echo ""
echo "📚 For more help, see .devcontainer/README.md"
echo "======================================"
echo ""
