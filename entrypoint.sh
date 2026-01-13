#!/bin/bash
set -e

# Hytale Server Docker Entrypoint Script

echo "======================================"
echo "  Hytale Server Docker Container"
echo "======================================"
echo ""

# Change to server directory
cd /hytale/Server

# Build the Java command
JAVA_CMD="java ${JAVA_OPTS} -jar HytaleServer.jar --assets ${HYTALE_ASSETS} --bind ${HYTALE_BIND}:${HYTALE_PORT}"

# Add any additional arguments passed to the container
if [ $# -gt 0 ]; then
    JAVA_CMD="${JAVA_CMD} $@"
fi

echo "Starting Hytale Server..."
echo "Java Options: ${JAVA_OPTS}"
echo "Assets: ${HYTALE_ASSETS}"
echo "Bind Address: ${HYTALE_BIND}:${HYTALE_PORT}"
echo ""
echo "IMPORTANT: On first run, you need to authenticate:"
echo "  1. Use '/auth login device' in the console"
echo "  2. Visit the URL and enter the code shown"
echo "  3. Authentication will persist across restarts"
echo ""
echo "======================================"
echo ""

# Execute the server
exec ${JAVA_CMD}
