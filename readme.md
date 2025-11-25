# ActiveMQ Classic on Windows Server Core Container

## Overview

This project provides a Docker container running **Apache ActiveMQ Classic 5.19.1** on **Windows Server Core LTSC 2022**. It's designed for environments requiring ActiveMQ on Windows containers, providing a production-ready message broker with full protocol support.

## Features

- **Base Image**: Microsoft Windows Server Core LTSC 2022
- **Java Runtime**: Oracle JDK 25 (extracted from zip archive)
- **Message Broker**: Apache ActiveMQ Classic 5.19.1
- **Supported Protocols**: 
  - OpenWire (61616)
  - AMQP (5672)
  - STOMP (61613)
  - MQTT (1883)
  - WebSocket (61614)
  - Web Console (8161)

## Prerequisites

Before building the container, you need to download the following files and place them in the `setup/` directory:

1. **Oracle JDK 25** (Windows x64 zip format)
   - Download from: https://download.oracle.com/java/25/latest/jdk-25_windows-x64_bin.zip
   - Place as: `setup/jdk-25_windows-x64_bin.zip`

2. **Apache ActiveMQ Classic 5.19.1**
   - Download from: https://dlcdn.apache.org/activemq/5.19.1/apache-activemq-5.19.1-bin.zip
   - Place as: `setup/apache-activemq-5.19.1-bin.zip`

## Directory Structure

```
.
├── dockerfile              # Main Dockerfile
├── docker-compose.yaml     # Docker Compose configuration
├── readme.md              # This file
├── setup/                 # Required installation files
│   ├── jdk-25_windows-x64_bin.zip
│   └── apache-activemq-5.19.1-bin.zip
└── activemq_data/         # Persistent data volume (auto-created)
```

## How It Works

### Dockerfile Build Process

1. **Base Image**: Starts from Windows Server Core LTSC 2022
2. **Java Installation**: 
   - Copies JDK zip file into the container
   - Extracts to `C:\Java\jre`
   - Sets `JAVA_HOME` and updates `PATH` environment variables
3. **ActiveMQ Installation**:
   - Copies and extracts ActiveMQ distribution to `C:\ActiveMQ`
   - Configures Jetty to listen on `0.0.0.0` (all interfaces) instead of `127.0.0.1`
4. **Port Exposure**: Exposes all ActiveMQ ports
5. **Startup**: Launches ActiveMQ in foreground mode using `activemq.bat start`

### Docker Compose Configuration

The `docker-compose.yaml` file provides:
- **Container name**: `activemq_win`
- **Port mappings**: Web console (8161) and OpenWire (61616)
- **Data persistence**: Mounts local `./activemq_data` to `C:/ActiveMQ/data` for persistent message storage

## Usage

### Building the Image

```powershell
# Build using Docker Compose
docker compose build

# Or build directly with Docker
docker build -t activemq-windows .
```

### Running the Container

```powershell
# Start with Docker Compose (recommended)
docker compose up -d

# View logs
docker compose logs -f

# Stop the container
docker compose down
```

### Running with Docker CLI

```powershell
# Run the container
docker run -d `
  --name activemq_win `
  -p 8161:8161 `
  -p 61616:61616 `
  -v ${PWD}/activemq_data:C:/ActiveMQ/data `
  activemq-windows

# View logs
docker logs -f activemq_win

# Stop and remove
docker stop activemq_win
docker rm activemq_win
```

## Accessing ActiveMQ

### Web Console

- **URL**: http://localhost:8161
- **Default credentials**: 
  - Username: `admin`
  - Password: `admin`

### Message Broker Endpoints

- **OpenWire**: `tcp://localhost:61616`
- **AMQP**: `amqp://localhost:5672`
- **STOMP**: `stomp://localhost:61613`
- **MQTT**: `mqtt://localhost:1883`
- **WebSocket**: `ws://localhost:61614`

## Configuration

### Custom Configuration Files

To use custom ActiveMQ configurations, you can mount the configuration directory:

```yaml
volumes:
  - ./activemq_data:C:/ActiveMQ/data
  - ./conf:C:/ActiveMQ/apache-activemq-5.19.1/conf
```

### Environment Variables

Key environment variables set in the container:
- `JAVA_HOME=C:\Java\jre`
- `PATH` includes Java binaries

## Troubleshooting

### Container starts but web console is unreachable

The Dockerfile configures Jetty to listen on `0.0.0.0` by modifying `jetty.xml`. Verify this change was applied during build.

### Java not found

Ensure the JDK zip file was correctly extracted. Check logs during build for extraction errors.

### Persistent data not saved

Verify the volume mount in docker-compose.yaml points to the correct path and that the host directory has proper permissions.

### Port conflicts

If ports 8161 or 61616 are already in use, modify the port mappings in `docker-compose.yaml`:

```yaml
ports:
  - "8162:8161"  # Use different host port
  - "61617:61616"
```

## Notes

- **Windows Containers**: This container requires Docker with Windows container support
- **Base Image Size**: Windows Server Core images are significantly larger than Linux alternatives (~2-4 GB)
- **Java Version**: Uses JDK 25, but can be adapted for JDK 8, 11, or 17 by changing the zip file
- **Production Use**: Consider implementing additional security measures:
  - Change default admin credentials
  - Configure SSL/TLS
  - Implement proper authentication
  - Set up firewall rules

## License

This project configuration is provided as-is. Please refer to the respective licenses for:
- Microsoft Windows Server Core
- Oracle JDK
- Apache ActiveMQ

## Support

For issues related to:
- **ActiveMQ**: https://activemq.apache.org/
- **Docker Windows Containers**: https://docs.microsoft.com/virtualization/windowscontainers/
- **This configuration**: Open an issue in the repository
