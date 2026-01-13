# Hytale Server Docker Image

A production-ready Docker image for running a Hytale dedicated server. Built with Java 25 (Adoptium) and optimized for deployment on Linux VPS environments.

## Features

- Based on Eclipse Temurin Java 25 (official Adoptium distribution)
- Automatic server file download using Hytale Downloader CLI
- Persistent data storage (worlds, configs, mods, logs)
- Proper UDP port mapping for QUIC protocol
- Easy configuration via environment variables
- Ready for Docker Hub deployment
- Memory and resource limits configured

## Requirements

### Local Development
- Docker Engine 20.10 or later
- Docker Compose 2.0 or later
- 4GB RAM minimum (6GB+ recommended)

### Production VPS
- Linux VPS with Docker installed
- 4GB RAM minimum (8GB+ recommended for multiple players)
- UDP port 5520 open in firewall
- Hytale game license for server authentication

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/hytaleserver-docker.git
cd hytaleserver-docker
```

### 2. Build the Image

**IMPORTANT**: The first build will download the Hytale server files using the official downloader CLI. This requires authentication.

```bash
docker-compose build
```

### 3. Start the Server

```bash
docker-compose up -d
```

### 4. Authenticate the Server (REQUIRED - First Run Only)

On first launch, you must authenticate the server with your Hytale account:

```bash
# Attach to the server console
docker attach hytale-server

# In the console, run:
/auth login device

# Follow the instructions:
# 1. Visit the URL shown (https://accounts.hytale.com/device)
# 2. Enter the code displayed
# 3. Complete authentication in your browser
# 4. Authentication persists across restarts!

# Detach from console without stopping: Ctrl+P, Ctrl+Q
```

### 5. View Logs

```bash
docker-compose logs -f hytale-server
```

### 6. Stop the Server

```bash
docker-compose down
```

## Configuration

### Environment Variables

Edit `docker-compose.yml` to customize these settings:

| Variable | Default | Description |
|----------|---------|-------------|
| `JAVA_OPTS` | `-Xms2G -Xmx4G` | JVM memory and options |
| `HYTALE_PORT` | `5520` | Server port (must match port mapping) |
| `HYTALE_BIND` | `0.0.0.0` | Bind address |

### Memory Settings

Adjust based on your VPS specs and player count:

```yaml
environment:
  # For 8GB VPS:
  - JAVA_OPTS=-Xms4G -Xmx6G -XX:AOTCache=Server/HytaleServer.aot
```

### Custom Server Arguments

Pass additional arguments to HytaleServer.jar:

```bash
docker-compose run hytale-server --allow-op --backup --backup-frequency 60
```

### Port Mapping

To use a different port, update BOTH places in docker-compose.yml:

```yaml
ports:
  - "25565:25565/udp"  # Change external port here
environment:
  - HYTALE_PORT=25565   # Change internal port here
```

## Persistent Data

All server data is stored in `./data/` and persists across container restarts:

```
data/
├── universe/          # World saves and player data
├── mods/              # Installed server mods
├── logs/              # Server logs
├── .cache/            # AOT and optimization cache
├── config.json        # Server configuration
├── permissions.json   # Permission settings
├── whitelist.json     # Whitelisted players
└── bans.json          # Banned players
```

## Docker Hub Deployment

### 1. Tag the Image

```bash
# Replace 'yourusername' with your Docker Hub username
docker tag hytale-server:latest yourusername/hytale-server:latest
docker tag hytale-server:latest yourusername/hytale-server:1.0.0
```

### 2. Login to Docker Hub

```bash
docker login
```

### 3. Push to Docker Hub

```bash
docker push yourusername/hytale-server:latest
docker push yourusername/hytale-server:1.0.0
```

### 4. Pull on VPS

```bash
# On your VPS:
docker pull yourusername/hytale-server:latest
```

### 5. Use in Production

Update `docker-compose.yml` to use your published image:

```yaml
services:
  hytale-server:
    image: yourusername/hytale-server:latest
    # Remove the 'build: .' line
```

## VPS Deployment

### Initial Setup on VPS

```bash
# Install Docker (Ubuntu/Debian)
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo apt-get update
sudo apt-get install docker-compose-plugin

# Configure firewall for UDP
sudo ufw allow 5520/udp
sudo ufw enable

# Clone your repo
git clone https://github.com/yourusername/hytaleserver-docker.git
cd hytaleserver-docker

# Start the server
docker-compose up -d

# Authenticate (first run only)
docker attach hytale-server
# Run: /auth login device
# Detach: Ctrl+P, Ctrl+Q
```

### Updates

```bash
# Pull latest image
docker-compose pull

# Recreate container
docker-compose up -d
```

## Installing Mods

1. Download mod files (.zip or .jar) from sources like CurseForge
2. Place them in `./data/mods/` on your host
3. Restart the container:

```bash
docker-compose restart
```

## Troubleshooting

### Players Can't Connect

1. **Check firewall**: Ensure UDP port 5520 is open
   ```bash
   sudo ufw status
   sudo ufw allow 5520/udp
   ```

2. **Verify port mapping**: Check docker-compose.yml uses `/udp` not `/tcp`

3. **Check server authentication**: Ensure you completed `/auth login device`

4. **Check logs**:
   ```bash
   docker-compose logs -f
   ```

### High Memory Usage

Hytale's default view distance (384 blocks) is high. Reduce in config:

```bash
# Edit config after first run
nano ./data/config.json
```

Consider using the `Nitrado:PerformanceSaver` plugin to dynamically adjust view distance.

### Server Won't Start

1. **Check Java version in container**:
   ```bash
   docker-compose run hytale-server java --version
   ```
   Should show Java 25.

2. **Check available memory**:
   ```bash
   free -h
   ```

3. **Reduce memory allocation** if VPS has less than 6GB:
   ```yaml
   - JAVA_OPTS=-Xms1G -Xmx2G
   ```

### Authentication Issues

- **Limit**: 100 servers per Hytale license
- **Solution**: Purchase additional licenses or apply for Server Provider account
- **Documentation**: See [Server Provider Authentication Guide](https://support.hytale.com/hc/en-us/articles/45326769420827)

## Important Notes

### QUIC Protocol
Hytale uses **QUIC over UDP**, not TCP. Ensure:
- Port forwarding is for **UDP**, not TCP
- Firewall rules allow **UDP** traffic
- Docker port mapping uses `/udp` suffix

### Server Authentication
- Required for all servers to prevent abuse
- Persists after first authentication
- Stored in container volumes (survives restarts)
- 100 server limit per license

### Protocol Version
- Client and server must match protocol version exactly
- Update your Docker image when Hytale releases updates
- Future: ±2 version tolerance planned

## Advanced Configuration

### Disable Sentry Crash Reporting (Development)

```bash
docker-compose run hytale-server --disable-sentry
```

### Enable Backups

```bash
docker-compose run hytale-server --backup --backup-frequency 30
```

### View Distance Limit

Add to docker-compose command or config.json to reduce RAM usage:

Recommended: 12 chunks (384 blocks) max

### Custom JVM Arguments

```yaml
environment:
  - JAVA_OPTS=-Xms4G -Xmx6G -XX:+UseG1GC -XX:MaxGCPauseMillis=50
```

## Useful Commands

```bash
# Start server
docker-compose up -d

# Stop server
docker-compose down

# Restart server
docker-compose restart

# View logs (live)
docker-compose logs -f

# Access console
docker attach hytale-server

# Detach from console (without stopping)
# Press: Ctrl+P, then Ctrl+Q

# Check resource usage
docker stats hytale-server

# Update server
docker-compose pull && docker-compose up -d

# Backup world data
tar -czf backup-$(date +%Y%m%d).tar.gz ./data/universe/
```

## Resources

- [Official Hytale Server Manual](https://support.hytale.com/hc/en-us/articles/45326769420827)
- [Server Provider Authentication Guide](https://support.hytale.com/hc/en-us/articles/45326769420827)
- [Hytale Official Website](https://hytale.com)
- [Docker Documentation](https://docs.docker.com)

## License

This Docker image is provided as-is for running Hytale servers. Hytale and all related assets are property of Hypixel Studios.

## Support

- **GitHub Issues**: Report problems or request features
- **Hytale Support**: https://support.hytale.com
- **Community**: Join Hytale Discord and forums

## Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## Changelog

### 1.0.0 (2026-01-13)
- Initial release
- Java 25 support
- Automatic server file download
- Docker Compose configuration
- Persistent data volumes
- UDP/QUIC support
- Authentication flow
