#!/bin/bash

# Script to completely restart the crawl4ai MCP server
# This stops, removes, rebuilds, and runs the Docker container

set -e # Exit on any error

echo "🔄 Starting crawl4ai MCP server restart..."

# Step 1: Stop all running crawl4ai containers
echo "⏹️  Stopping running crawl4ai containers..."
RUNNING_CONTAINERS=$(docker ps -q --filter "ancestor=mcp/crawl4ai-rag" 2> /dev/null || true)
if [ -n "$RUNNING_CONTAINERS" ]; then
  docker stop $RUNNING_CONTAINERS
  echo "✅ Stopped containers: $RUNNING_CONTAINERS"
else
  echo "ℹ️  No running crawl4ai containers found"
fi

# Step 2: Remove all crawl4ai containers (running and stopped)
echo "🗑️  Removing crawl4ai containers..."
ALL_CONTAINERS=$(docker ps -aq --filter "ancestor=mcp/crawl4ai-rag" 2> /dev/null || true)
if [ -n "$ALL_CONTAINERS" ]; then
  docker rm $ALL_CONTAINERS
  echo "✅ Removed containers: $ALL_CONTAINERS"
else
  echo "ℹ️  No crawl4ai containers to remove"
fi

# Step 3: Build the Docker image
echo "🔨 Building Docker image..."
docker build -t mcp/crawl4ai-rag --build-arg PORT=8051 .
echo "✅ Docker image built successfully"

# Step 4: Run the container with environment variables
echo "🚀 Starting container with environment variables..."
if [ -f ".env" ]; then
  docker run --env-file .env -p 8051:8051 mcp/crawl4ai-rag &
  echo "✅ Container started with .env file"
else
  echo "⚠️  No .env file found, starting without environment file"
  docker run -p 8051:8051 mcp/crawl4ai-rag &
fi

# Step 5: Wait for container to be ready
echo "⏳ Waiting for container to be ready..."
sleep 10

# Step 6: Check if container is running
CONTAINER_ID=$(docker ps -q --filter "ancestor=mcp/crawl4ai-rag" | head -1)
if [ -n "$CONTAINER_ID" ]; then
  echo "✅ Container is running: $CONTAINER_ID"
  echo "🔗 MCP server available at: http://localhost:8051"
  echo "📋 To view logs: docker logs $CONTAINER_ID"
  echo "🛑 To stop: docker stop $CONTAINER_ID"
else
  echo "❌ Container failed to start"
  exit 1
fi

echo "🎉 Crawl4ai MCP server restart complete!"
