# Sefaria Development Container

This directory contains a complete VS Code Development Container (devcontainer) configuration for the Sefaria-Project. The devcontainer provides a fully automated, consistent development environment across all platforms (Windows, macOS, and Linux).

## 🚀 Quick Start

### Prerequisites

1. **Install Docker Desktop**
   - Windows/Mac: [Docker Desktop](https://www.docker.com/products/docker-desktop)
   - Linux: [Docker Engine](https://docs.docker.com/engine/install/) + [Docker Compose](https://docs.docker.com/compose/install/)

2. **Install VS Code**
   - Download from [code.visualstudio.com](https://code.visualstudio.com/)

3. **Install Dev Containers Extension**
   - Open VS Code
   - Install the "Dev Containers" extension by Microsoft
   - Extension ID: `ms-vscode-remote.remote-containers`

### Opening the Project

1. Clone the Sefaria-Project repository (if you haven't already):
   ```bash
   git clone https://github.com/Sefaria/Sefaria-Project.git
   cd Sefaria-Project
   ```

2. Open in VS Code:
   ```bash
   code .
   ```

3. When prompted, click **"Reopen in Container"**
   - Alternatively, press `F1` and select **"Dev Containers: Reopen in Container"**

4. Wait for the container to build and initialize (first time may take 10-15 minutes)

5. The setup script will guide you through MongoDB database restoration

That's it! Your development environment is ready.

## 📦 What's Included

### Services

- **Django Web Server** (Python 3.9) - Main application server
- **MongoDB 4.4** - Primary database for texts and data
- **Redis** - Caching layer
- **PostgreSQL** - Django authentication database
- **Node.js 20** - Frontend build tools and SSR

### Development Tools

- Python 3.9 with all dependencies
- Node.js 20 with npm packages
- MongoDB Shell (`mongosh`)
- Redis CLI
- PostgreSQL client
- Git, curl, wget, vim, nano
- Zsh shell with oh-my-zsh

### VS Code Extensions

Automatically installed:
- Python (with Pylance and debugger)
- Django support
- ESLint & Prettier
- MongoDB for VS Code
- Docker tools
- GitLens
- Code Spell Checker

## 🗄️ MongoDB Database Setup

### Automatic Setup (Default)

No manual steps required. On first launch, the devcontainer:

1. Checks whether MongoDB already contains data
2. Uses any pre-loaded dump in `.devcontainer/sefaria-mongo-backup/`
   - Prioritizes `dump_small.tar.gz` if both small and full are present
3. If no dump is pre-loaded, downloads the small dump (`~3-4 GB`)
4. Restores the dump and ensures the `history` collection exists for the small dataset

If the automatic download fails (e.g., no internet connection), the setup stops with a clear error so you can resolve the issue or provide a dump manually.

### Pre-Loading Dumps (Optional)

For offline use or to control which dataset is restored:

1. Create the directory `.devcontainer/sefaria-mongo-backup/`
2. Place one of these archives inside:
   - `dump_small.tar.gz` (recommended for most development)
   - `dump.tar.gz` (full dump with revision history)
3. Rebuild or reopen the devcontainer. The setup will automatically detect and use your archive.

### Manual Restoration (Advanced)

You can still run the helper script if you want to re-import data or switch datasets:

```bash
./.devcontainer/scripts/restore_mongo_dump.sh        # Small dump
./.devcontainer/scripts/restore_mongo_dump.sh --full # Full dump
```

Use `--workdir`, `--keep-archive`, or `--force` for additional control (see `--help`).

## 🎮 Common Commands

### Starting the Development Servers

```bash
# Start Django development server
python manage.py runserver 0.0.0.0:8000

# Watch and rebuild frontend (in a separate terminal)
npm run watch-client

# Start Node.js SSR server (optional, in a separate terminal)
npm start
```

### Database Access

```bash
# MongoDB shell
mongosh --host db

# Redis CLI
redis-cli -h cache

# PostgreSQL shell
psql -h postgres -U admin -d sefaria
# Password: admin
```

### Useful Django Commands

```bash
# Run migrations
python manage.py migrate

# Create superuser
python manage.py createsuperuser

# Django shell
python manage.py shell

# Sefaria CLI (custom REPL)
./cli

# Run tests
python manage.py test
```

### Frontend Commands

```bash
# Install/update Node dependencies
npm install

# Build client bundles (one-time)
npm run build-client

# Watch for changes and rebuild
npm run watch-client

# Build all bundles
npm run build

# Watch all bundles
npm run watch
```

## 🌐 Accessing Services

Once the servers are running, you can access:

- **Django Web**: http://localhost:8000
- **Node.js SSR**: http://localhost:3000
- **MongoDB**: localhost:27017
- **Redis**: localhost:6379
- **PostgreSQL**: localhost:5433

VS Code automatically forwards these ports, so they work the same as if running locally.

## 📁 Project Structure

```
.devcontainer/
├── devcontainer.json              # Main devcontainer configuration
├── Dockerfile                     # Development container image
├── docker-compose.devcontainer.yml # Service orchestration overrides
├── local_settings_devcontainer.py # Pre-configured Django settings
├── scripts/
│   ├── postCreate.sh             # One-time setup script
│   └── postStart.sh              # Runs on each container start
└── README.md                      # This file
```

## 🔧 Customization

### Adding VS Code Extensions

Edit `.devcontainer/devcontainer.json` and add to the `extensions` array:

```json
"customizations": {
  "vscode": {
    "extensions": [
      "your-extension-id"
    ]
  }
}
```

Then rebuild the container: `F1` → "Dev Containers: Rebuild Container"

### Modifying Django Settings

Edit `.devcontainer/local_settings_devcontainer.py` and rebuild, or directly edit `sefaria/local_settings.py` inside the container (changes won't persist across rebuilds).

### Adding System Packages

Edit `.devcontainer/Dockerfile` and add packages to the `apt-get install` commands, then rebuild.

## 🐛 Troubleshooting

### Container Fails to Build

**Issue**: Build errors during container creation

**Solutions**:
- Check Docker Desktop is running
- Ensure you have enough disk space (10+ GB recommended)
- Try: `F1` → "Dev Containers: Rebuild Container Without Cache"
- Check Docker logs for specific errors

### MongoDB Connection Failed

**Issue**: Can't connect to MongoDB

**Solutions**:
```bash
# Check if MongoDB is running
docker ps | grep mongo

# Restart MongoDB service
docker-compose restart db

# Check MongoDB logs
docker-compose logs db
```

### Port Already in Use

**Issue**: Port 8000, 27017, etc. already in use

**Solutions**:
- Stop other instances: `docker-compose down`
- Check for local MongoDB/Redis: `sudo systemctl stop mongodb redis`
- Change ports in `docker-compose.yml` if needed

### Webpack Build Errors

**Issue**: Frontend build fails

**Solutions**:
```bash
# Clear node_modules and reinstall
rm -rf node_modules
npm install

# Clear webpack cache
rm -rf static/bundles
npm run build-client
```

### Python Import Errors

**Issue**: Module not found errors

**Solutions**:
```bash
# Reinstall Python dependencies
pip install -r requirements.txt

# Check Python path
python -c "import sys; print(sys.path)"
```

### Performance Issues

**Issue**: Container is slow

**Solutions**:
- Allocate more resources to Docker Desktop (Settings → Resources)
- Use Docker volume for node_modules (already configured)
- Close unnecessary applications
- On Windows, use WSL 2 backend

## 🆚 Comparison with Other Installation Methods

| Feature | Devcontainer | Local Install | Docker Compose |
|---------|-------------|---------------|----------------|
| Setup Time | 5-10 min | 1-2 hours | 30-45 min |
| Manual Steps | 1 click | 11+ steps | 7 steps |
| OS Dependencies | Docker only | Many | Docker only |
| Auto-Configuration | ✅ Full | ❌ Manual | ⚠️ Partial |
| IDE Integration | ✅ Complete | ⚠️ Manual | ❌ None |
| Debugging | ✅ Pre-configured | ⚠️ Manual | ⚠️ Manual |
| Consistency | ✅ Excellent | ⚠️ Varies | ✅ Good |
| Updates | ✅ Automatic | ❌ Manual | ⚠️ Manual |

## 📚 Additional Resources

- [VS Code Dev Containers Documentation](https://code.visualstudio.com/docs/devcontainers/containers)
- [Sefaria Developer Documentation](https://developers.sefaria.org)
- [Sefaria Project on GitHub](https://github.com/Sefaria/Sefaria-Project)
- [Docker Documentation](https://docs.docker.com)

## 🤝 Contributing

If you encounter issues with the devcontainer or have suggestions for improvements, please:

1. Check existing [GitHub Issues](https://github.com/Sefaria/Sefaria-Project/issues)
2. Create a new issue with the `devcontainer` label
3. Include your OS, Docker version, and error messages

## 📝 Notes

- The devcontainer uses the existing `docker-compose.yml` as a base
- Local settings are automatically configured for container service names
- MongoDB dumps are not included and must be downloaded separately
- The container runs as root for simplicity (can be changed if needed)
- Node modules are cached in a Docker volume for better performance
- Bash history is persisted across container rebuilds

## 🎉 Getting Help

If you need help:

1. Check this README
2. Review the [troubleshooting section](#-troubleshooting)
3. Check the postCreate script output for errors
4. Ask in the Sefaria developer community
5. Open a GitHub issue

---

**Happy Coding!** 🚀
