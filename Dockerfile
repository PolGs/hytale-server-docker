# Hytale Server Docker Image
# Based on Eclipse Temurin Java 25 (Adoptium)

FROM eclipse-temurin:25-jdk-noble

# Install required dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wget \
    unzip \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Create server directory
WORKDIR /hytale

# Download Hytale Downloader CLI
RUN wget -O hytale-downloader.zip https://launcher.hytale.com/hytale-downloader/hytale-downloader.zip && \
    unzip hytale-downloader.zip -d downloader && \
    chmod +x downloader/hytale-downloader && \
    rm hytale-downloader.zip

# Download Hytale server files
# This will prompt for authentication during build
RUN cd downloader && \
    ./hytale-downloader -download-path /hytale/game.zip && \
    cd /hytale && \
    unzip game.zip && \
    rm game.zip && \
    rm -rf downloader

# Create volume mount points for persistent data
RUN mkdir -p /hytale/universe /hytale/mods /hytale/logs /hytale/.cache

# Expose Hytale server port (UDP)
EXPOSE 5520/udp

# Set environment variables with defaults
ENV JAVA_OPTS="-Xms2G -Xmx4G -XX:AOTCache=Server/HytaleServer.aot" \
    HYTALE_ASSETS="/hytale/Assets.zip" \
    HYTALE_PORT="5520" \
    HYTALE_BIND="0.0.0.0"

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Use entrypoint script
ENTRYPOINT ["/entrypoint.sh"]
