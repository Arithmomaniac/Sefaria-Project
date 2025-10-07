# Sefaria Development Container

This directory contains the VS Code devcontainer configuration for Sefaria-Project. The devcontainer provides a fully automated, one-click development environment that works identically across Windows, macOS, and Linux.

## Quick Start

### Prerequisites

1. [Docker Desktop](https://www.docker.com/products/docker-desktop) (Windows/macOS) or Docker Engine (Linux)
2. [Visual Studio Code](https://code.visualstudio.com/)
3. [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

### Opening the Project

1. Clone the repository:
   ```bash
   git clone https://github.com/Sefaria/Sefaria-Project.git
   cd Sefaria-Project
   ```

2. Open in VS Code:
   ```bash
   code .
   ```

3. When prompted "Reopen in Container", click **Reopen in Container**
   - Alternatively, press `Cmd/Ctrl+Shift+P` and select "Dev Containers: Reopen in Container"

4. Wait for the container to build and initialize (first time takes 10-15 minutes)

### MongoDB Data Setup

The devcontainer requires a MongoDB database dump to function. On first startup, if MongoDB is empty, you'll see instructions to download a dump.

#### Option 1: Small Dump (Recommended)
Best for most development work. Contains all texts but no revision history.

```bash
# Download (on your local machine, not in container)
curl -L -o dump_small.tar.gz https://storage.googleapis.com/sefaria-mongo-backup/dump_small.tar.gz

# Extract
tar -xzf dump_small.tar.gz

# Place the extracted 'dump' folder in the project root
# Then rebuild the container: Cmd/Ctrl+Shift+P -> "Dev Containers: Rebuild Container"
```

#### Option 2: Full Dump
Only if you need complete revision history.

```bash
# Download (on your local machine)
curl -L -o dump.tar.gz https://storage.googleapis.com/sefaria-mongo-backup/dump.tar.gz

# Extract and rebuild as above
tar -xzf dump.tar.gz
```

The dump will be automatically restored when you rebuild the container.

## What's Included

### Services

- **Web (Django)**: Python 3.9 with all dependencies
- **MongoDB**: Version 4.4 (port 27017)
- **Redis**: Latest version (port 6379)
- **PostgreSQL**: Latest version (port 5433 → 5432 internal)
- **Node.js**: Version 20 for SSR server (port 3000)

### VS Code Extensions

The following extensions are automatically installed:

- Python language support (Pylance)
- Django template support
- ESLint for JavaScript
- Prettier code formatter
- Docker file support
- GitLens for enhanced Git features
- MongoDB explorer

### Tools

- `python` 3.9 with all requirements
- `node` 20 with npm
- `mongosh` - MongoDB shell
- `redis-cli` - Redis command line
- `psql` - PostgreSQL client
- `git`, `vim`, `zsh` - Development tools

## Common Commands

### Starting Services

```bash
# Start Django development server
python manage.py runserver 0.0.0.0:8000

# Watch and rebuild frontend (in a new terminal)
npm run watch-client

# Start Node.js SSR server (in another terminal)
npm start
```

### Database Access

```bash
# MongoDB shell
mongosh --host db

# Redis CLI
redis-cli -h cache

# PostgreSQL
PGPASSWORD=admin psql -h postgres -U admin -d sefaria
```

### Django Management

```bash
# Run migrations
python manage.py migrate

# Create superuser
python manage.py createsuperuser

# Open Django shell
python manage.py shell

# Use Sefaria CLI
./cli
```

### Frontend Development

```bash
# Build all bundles
npm run build

# Build only client bundles
npm run build-client

# Watch client files for changes
npm run watch-client

# Watch all files
npm run watch
```

## Port Mappings

| Service | Container Port | Host Port | Purpose |
|---------|---------------|-----------|---------|
| Django | 8000 | 8000 | Web application |
| Node.js | 3000 | 3000 | SSR server |
| MongoDB | 27017 | 27017 | Database |
| Redis | 6379 | 6379 | Cache |
| PostgreSQL | 5432 | 5433 | Relational DB |

## Configuration Files

- **devcontainer.json**: Main devcontainer configuration
- **Dockerfile**: Container image definition
- **docker-compose.devcontainer.yml**: Service overrides for development
- **local_settings_devcontainer.py**: Pre-configured Django settings
- **scripts/postCreate.sh**: One-time initialization script
- **scripts/postStart.sh**: Startup health checks

## Troubleshooting

### Container won't start

1. Make sure Docker is running
2. Check Docker has enough resources (recommended: 4GB RAM, 2 CPUs)
3. Try rebuilding: `Cmd/Ctrl+Shift+P` → "Dev Containers: Rebuild Container"

### MongoDB connection errors

1. Ensure MongoDB service is running: `mongosh --host db --eval "db.version()"`
2. Check if data was restored: See MongoDB Data Setup above
3. Restart services: Rebuild the container

### Webpack build errors

1. Clear node_modules: `rm -rf node_modules && npm install`
2. Clear webpack cache: `rm -rf static/bundles`
3. Rebuild: `npm run build-client`

### Port conflicts

If you see port binding errors:
1. Stop any local services using ports 8000, 3000, 27017, 6379, or 5433
2. Or modify the ports in `docker-compose.yml`

### Permission issues

The container runs as root by default for simplicity. If you encounter permission issues with files:

```bash
# Fix permissions for log directory
chmod 777 log

# Fix permissions for a specific file
chmod 666 path/to/file
```

## Advantages vs Other Methods

| Feature | Local Install | Docker-Compose | Devcontainer |
|---------|--------------|----------------|--------------|
| Setup Time | 1-2 hours | 30-45 min | 5-10 min (+ dump download) |
| Manual Steps | 11+ steps | 7 steps | 1 click |
| OS Dependencies | Yes | Docker only | Docker only |
| Auto-Configuration | No | Partial | Full |
| IDE Integration | Manual | None | Complete |
| Debugging | Manual setup | Manual | Pre-configured |
| Consistency | Varies by OS | Good | Excellent |
| Updates | Manual | Manual rebuild | Automatic |

## Updating the Devcontainer

When dependencies change (requirements.txt, package.json):

1. `Cmd/Ctrl+Shift+P` → "Dev Containers: Rebuild Container"
2. Or rebuild without cache: "Dev Containers: Rebuild Container Without Cache"

## Additional Resources

- [VS Code Dev Containers documentation](https://code.visualstudio.com/docs/devcontainers/containers)
- [Sefaria local installation guide](../README.mkd)
- [Docker documentation](https://docs.docker.com/)

## Support

If you encounter issues:

1. Check the troubleshooting section above
2. Review logs in the VS Code terminal
3. Open an issue on GitHub with:
   - Your OS (Windows/macOS/Linux)
   - Docker version: `docker --version`
   - Error messages from the terminal
   - Steps to reproduce
