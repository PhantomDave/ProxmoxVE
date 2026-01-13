# Questarr Installation Script Summary

## Files Created

✅ **ct/questarr.sh** (2.0 KB)
- Container creation script for Proxmox host
- Includes update functionality
- Configures container specs: 2 CPU, 2GB RAM, 8GB disk

✅ **install/questarr-install.sh** (3.6 KB)  
- Installation script that runs inside container
- Installs Node.js 20, PostgreSQL 16, and all dependencies
- Builds Questarr from source
- Configures environment and systemd service

✅ **QUESTARR_README.md**
- Comprehensive documentation
- Installation instructions
- Troubleshooting guide
- Configuration details

## Key Features Implemented

### Following ProxmoxVE Best Practices ✅

1. **Proper Script Structure**
   - CT script sources build.func from community-scripts
   - Install script uses FUNCTIONS_FILE_PATH pattern
   - Includes proper copyright headers and source attribution

2. **Standard Functions Used**
   - `setup_nodejs` for Node.js 20 installation
   - `setup_postgresql` for PostgreSQL 16
   - `setup_postgresql_db` for database creation
   - `get_latest_github_release` for version checking
   - `check_for_gh_release` for update detection

3. **Container Configuration**
   - Unprivileged container (secure)
   - Appropriate resource allocation
   - Tagged as "media;arr" for categorization
   - Debian 13 base OS

4. **Update Script**
   - Proper version checking via GitHub releases
   - Graceful service stop/start
   - Environment backup during updates
   - Database migration support

5. **Security**
   - Auto-generated JWT_SECRET using OpenSSL
   - Auto-generated PostgreSQL password
   - Restricted file permissions on .env (600)
   - Service security settings (NoNewPrivileges, PrivateTmp, etc.)

## What is Questarr?

Questarr is a video game collection manager inspired by the *arr family of apps (Sonarr, Radarr, etc.). It provides:

- **Game Discovery**: Browse and discover games via IGDB API
- **Library Management**: Track games (Wanted, Owned, Playing, Completed)
- **Download Integration**: Works with torrent clients (qBittorrent, Transmission, rTorrent) and Usenet (SABnzbd, NZBGet)
- **Indexer Support**: Integrates with Prowlarr and Torznab/Newznab indexers
- **Auto-Search**: Automatically searches for wanted games

## Technical Stack

- **Frontend**: React 18 + TypeScript + Vite + Tailwind CSS + shadcn/ui
- **Backend**: Node.js 20 + Express + TypeScript
- **Database**: PostgreSQL 16 with Drizzle ORM
- **APIs**: IGDB for game metadata, Torznab for indexer search

## Installation

```bash
bash -c "$(wget -qLO - https://github.com/community-scripts/ProxmoxVE/raw/main/ct/questarr.sh)"
```

## Post-Installation Requirements

1. **Access web interface**: http://CONTAINER_IP:5000
2. **Create admin account** (first visit)
3. **Configure IGDB API credentials** (required for game discovery):
   - Get credentials from: https://dev.twitch.tv/console
   - Edit: `/opt/questarr/.env`
   - Add: `IGDB_CLIENT_ID` and `IGDB_CLIENT_SECRET`
   - Restart: `systemctl restart questarr`

## Update Command

```bash
update
```

Or from Proxmox host:
```bash
bash -c "$(wget -qLO - https://github.com/community-scripts/ProxmoxVE/raw/main/ct/questarr.sh)" -s -- -u
```

## Architecture Decisions

### Why Git Clone Instead of GitHub Release Tarball?

- Questarr doesn't publish pre-built release assets
- Source needs to be built with `npm run build`
- Git allows easy updates via `git pull` and tag checkout
- Follows the pattern of similar apps like Docmost in the repo

### Why Node.js 20?

- Questarr's package.json specifies Node.js 20+
- Matches project requirements exactly
- Stable LTS version with good support

### Why PostgreSQL 16?

- Questarr requires PostgreSQL (not optional)
- PostgreSQL 16 is the latest stable version
- Required for Drizzle ORM migrations

### Build vs Pre-built

- Application must be built from source (`npm run build`)
- Includes both client (React/Vite) and server (Express) builds
- Production build optimizes frontend assets

## Script Comparison with Similar Apps

| Feature | Questarr | Sonarr/Radarr | Docmost |
|---------|----------|---------------|---------|
| Language | Node.js/TypeScript | .NET | Node.js/TypeScript |
| Database | PostgreSQL | SQLite | PostgreSQL |
| Build Required | Yes | No (pre-built) | Yes |
| Install Method | Git clone | GitHub release | GitHub tarball |
| Update Method | Git pull + build | GitHub release | GitHub tarball |

## Files Location in Container

```
/opt/questarr/                    # Application directory
├── .env                          # Configuration (JWT, DB, IGDB)
├── client/                       # React frontend source
├── server/                       # Express backend source
├── shared/                       # Shared TypeScript types
├── dist/                         # Built production files
├── migrations/                   # Database migrations
├── package.json                  # Dependencies
└── node_modules/                 # Installed packages

/etc/systemd/system/questarr.service  # Service configuration
/etc/update-motd.d/99-questarr        # Login message
```

## Testing Checklist

Before submitting to ProxmoxVE repository:

- [ ] Test installation on fresh Proxmox system
- [ ] Verify service starts and is accessible
- [ ] Test update script functionality
- [ ] Confirm database migrations work
- [ ] Check log output for errors
- [ ] Verify MOTD displays correctly
- [ ] Test with IGDB credentials configured
- [ ] Ensure proper cleanup on container removal

## Next Steps

1. **Test the scripts** on a Proxmox host
2. **Update URLs** in both scripts from test fork to main repo
3. **Create JSON file** for ProxmoxVE website (if submitting PR)
4. **Submit PR** following contribution guidelines

## Resources

- **Questarr**: https://github.com/Doezer/Questarr
- **ProxmoxVE Scripts**: https://github.com/community-scripts/ProxmoxVE
- **IGDB API**: https://dev.twitch.tv/console
- **Contribution Guide**: https://github.com/community-scripts/ProxmoxVE/blob/main/docs/contribution/CONTRIBUTING.md

---

**Created by**: PhantomDave
**Date**: January 13, 2026
**License**: MIT
