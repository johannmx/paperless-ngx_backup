# 💾 Paperless-ngx Backup (Modernized)

A robust Dockerized backup solution for [Paperless-ngx](https://github.com/paperless-ngx/paperless-ngx). 

This script creates compressed archives of your documents, database, and media, with integrated support for multi-platform notifications and automatic retention management.

## ✨ Features

- **Efficient Compression**: Support for `zstd` (default), `xz`, and `gzip`.
- **Global Notifications**: Powered by [Apprise](https://github.com/caronc/apprise) (Discord, Telegram, Slack, Gotify, Email, etc.).
- **Automatic Cleanup**: Delete old backups based on a retention period.
- **Security**: Runs as a non-privileged user inside the container.
- **Flexible Scheduling**: Simple cron-based scheduling.
- **Multi-Arch**: Compatible with `x86_64`, `ARM64`, and more.

## 🚀 Quick Start

### Docker Compose

```yaml
services:
  backup:
    image: ghcr.io/johannmx/paperless-ngx_backup:latest
    container_name: paperless-ngx_backup
    restart: unless-stopped
    volumes:
      - /path/to/paperless/data:/data:ro # Read-only access to Paperless data
      - /path/to/backups:/backups        # Where to store backups
      - /etc/localtime:/etc/localtime:ro # Sync timezone
    environment:
      - CRON_TIME=0 3 * * *              # Runs daily at 3:00 AM
      - DELETE_AFTER=30                  # Keep backups for 30 days
      - COMPRESSION=zstd                 # (zstd, xz, gz)
      - UID=1000
      - GID=1000
      - TZ=America/Argentina/Buenos_Aires
      - APPRISE_URLS=discord://id/token,gotifys://server/token
```

### Manual Backup

Run a one-time backup without waiting for the schedule:

```bash
docker-compose run --rm backup manual
```

## ⚙️ Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `CRON_TIME` | Cron schedule for backups. | `0 3 * * *` |
| `DELETE_AFTER` | Delete backups older than X days. (0 to disable) | `0` |
| `COMPRESSION` | Compression algorithm: `zstd`, `xz`, or `gz`. | `zstd` |
| `APPRISE_URLS` | Comma-separated list of [Apprise URLs](https://github.com/caronc/apprise). | (empty) |
| `UID` / `GID` | User/Group ID to own the backup files. | `1000/1000` |
| `TZ` | Timezone inside the container. | `UTC` |

## 📦 What's Backed Up?

The script expects the `/data` volume to contain the standard Paperless-ngx structure:
- `/data/pgdata` (PostgreSQL data, if mounted here)
- `/data/data` (Application data)
- `/data/media` (Original documents and thumbnails)

## 🛠️ Development

### Build locally

```bash
docker build -t paperless-ngx_backup .
```

---
*Based on the original script by JohannMX.*
