# Questarr Installation Scripts

## Overview

These scripts install **Questarr**, a video game collection manager inspired by the *arr apps (Sonarr, Radarr, etc.), in a Proxmox LXC container.

## What is Questarr?

Questarr is a modern web application for managing your video game collection with features like:
- **Game Discovery**: Browse games via IGDB integration
- **Library Management**: Track your collection (Wanted, Owned, Playing, Completed)
- **Download Management**: Integration with torrent/usenet clients (qBittorrent, Transmission, SABnzbd, etc.)
- **Indexer Support**: Prowlarr/Torznab/Newznab integration
- **Auto-Search**: Automatically search for wanted games

## Tech Stack

- **Frontend**: React 18 + TypeScript + Vite + Tailwind CSS
- **Backend**: Node.js 20 + Express + TypeScript
- **Database**: PostgreSQL 16
- **ORM**: Drizzle ORM

## Files

### 1. `ct/questarr.sh`
Main container creation script that runs on the **Proxmox host**. This script:
- Defines container specifications (CPU, RAM, disk)
- Contains the `update_script()` function for updating Questarr
- Calls the installation script

### 2. `install/questarr-install.sh`
Installation script that runs **inside the container**. This script:
- Installs Node.js 20 and PostgreSQL 16
- Clones and builds Questarr from GitHub
- Configures environment variables
- Sets up the systemd service
- Runs database migrations

## Usage

### Installation

From the Proxmox host, run:

```bash
bash -c "$(wget -qLO - https://github.com/community-scripts/ProxmoxVE/raw/main/ct/questarr.sh)"
```

Or if using a fork:

```bash
bash -c "$(wget -qLO - https://github.com/YOUR_USERNAME/ProxmoxVE/raw/main/ct/questarr.sh)"
```

### First-Time Setup

After installation:

1. **Access the web interface**: `http://YOUR_CONTAINER_IP:5000`

2. **Create admin account** on first visit

3. **Configure IGDB API credentials** (Required):
   ```bash
   nano /opt/questarr/.env
   ```
   
   Add your credentials:
   ```env
   IGDB_CLIENT_ID=your_client_id_here
   IGDB_CLIENT_SECRET=your_client_secret_here
   ```
   
   Get credentials from: https://dev.twitch.tv/console

4. **Restart the service**:
   ```bash
   systemctl restart questarr
   ```

5. **Configure indexers** (optional): Add Prowlarr or Torznab indexers in the web interface

6. **Add downloaders** (optional): Configure qBittorrent, Transmission, SABnzbd, etc.

### Update

SSH into the container and run:

```bash
update
```

Or from the Proxmox host:

```bash
bash -c "$(wget -qLO - https://github.com/community-scripts/ProxmoxVE/raw/main/ct/questarr.sh)" -s -- -u
```

## Container Specifications

- **OS**: Debian 13 (unprivileged container)
- **CPU**: 2 cores
- **RAM**: 2048 MB
- **Disk**: 8 GB
- **Tags**: media, arr

These can be adjusted during installation or modified in the script before running.

## Post-Installation

### Service Management

```bash
# Check status
systemctl status questarr

# View logs
journalctl -u questarr -f

# Restart service
systemctl restart questarr

# Stop service
systemctl stop questarr

# Start service
systemctl start questarr
```

### Configuration Files

- **Environment**: `/opt/questarr/.env`
- **Application**: `/opt/questarr/`
- **Service**: `/etc/systemd/system/questarr.service`
- **Database**: PostgreSQL database `questarr`

### Database Access

```bash
# Access PostgreSQL as questarr_user
sudo -u postgres psql questarr

# Backup database
sudo -u postgres pg_dump questarr > questarr_backup.sql

# Restore database
sudo -u postgres psql questarr < questarr_backup.sql
```

## Key Features

### Environment Variables

The installation creates a `.env` file with:

- `DATABASE_URL`: PostgreSQL connection string
- `JWT_SECRET`: Automatically generated secure token
- `PORT`: Application port (default: 5000)
- `HOST`: Bind address (0.0.0.0 for container access)
- `NODE_ENV`: production
- `IGDB_CLIENT_ID`: *Needs manual configuration*
- `IGDB_CLIENT_SECRET`: *Needs manual configuration*

### Security

- JWT secret automatically generated using OpenSSL
- PostgreSQL password automatically generated
- Service runs with appropriate permissions
- Read-only filesystem protection where possible

### Integration Options

Questarr can integrate with:

**Indexers:**
- Prowlarr (recommended)
- Any Torznab-compatible indexer
- Newznab indexers

**Download Clients:**
- qBittorrent
- Transmission
- rTorrent
- SABnzbd (Usenet)
- NZBGet (Usenet)

## Troubleshooting

### Service won't start

Check logs:
```bash
journalctl -u questarr -n 50
```

Common issues:
- Missing IGDB credentials (optional but recommended)
- Database connection issues
- Port 5000 already in use

### Can't access web interface

1. Check if service is running:
   ```bash
   systemctl status questarr
   ```

2. Check if port is listening:
   ```bash
   ss -tlnp | grep 5000
   ```

3. Check firewall rules in Proxmox

### Database migration errors

Re-run migrations:
```bash
cd /opt/questarr
npm run db:migrate
systemctl restart questarr
```

### Update issues

If update fails:
```bash
cd /opt/questarr
git status
git stash  # Save any local changes
git pull origin main
npm ci
npm run build
npm run db:migrate
systemctl restart questarr
```

## Additional Resources

- **Questarr GitHub**: https://github.com/Doezer/Questarr
- **Questarr Wiki**: https://github.com/Doezer/Questarr/wiki
- **IGDB API Docs**: https://api-docs.igdb.com/
- **Community Scripts**: https://github.com/community-scripts/ProxmoxVE

## Contributing

To contribute improvements to these scripts:

1. Fork the ProxmoxVE repository
2. Modify the scripts
3. Test thoroughly
4. Submit a pull request

Follow the contribution guidelines at:
https://github.com/community-scripts/ProxmoxVE/blob/main/docs/contribution/CONTRIBUTING.md

## License

MIT License - see the LICENSE file in the ProxmoxVE repository

## Credits

- **Questarr**: Created by @Doezer
- **Installation Scripts**: Created by PhantomDave
- **ProxmoxVE Scripts Framework**: community-scripts ORG
