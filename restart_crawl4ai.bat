@echo off
REM Batch script to completely restart the crawl4ai MCP server
REM This stops, removes, rebuilds, and runs the Docker container on Windows

setlocal enabledelayedexpansion

echo 🔄 Starting crawl4ai MCP server restart...

REM Check if Docker is running
docker version >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker is not running. Please start Docker Desktop first.
    exit /b 1
)

REM Step 1: Stop all running crawl4ai containers
echo ⏹️  Stopping running crawl4ai containers...

for /f "delims=" %%i in ('docker ps -q --filter "ancestor=mcp/crawl4ai-rag" 2^>nul') do (
    set "running_containers=%%i"
)

if defined running_containers (
    docker stop !running_containers!
    echo ✅ Stopped containers: !running_containers!
) else (
    echo ℹ️  No running crawl4ai containers found
)

REM Step 2: Remove all crawl4ai containers (running and stopped)
echo 🗑️  Removing crawl4ai containers...

for /f "delims=" %%i in ('docker ps -aq --filter "ancestor=mcp/crawl4ai-rag" 2^>nul') do (
    set "all_containers=%%i"
)

if defined all_containers (
    docker rm !all_containers!
    echo ✅ Removed containers: !all_containers!
) else (
    echo ℹ️  No crawl4ai containers to remove
)

REM Step 3: Build the Docker image
echo 🔨 Building Docker image...
docker build -t mcp/crawl4ai-rag --build-arg PORT=8051 .
if errorlevel 1 (
    echo ❌ Docker build failed
    exit /b 1
)
echo ✅ Docker image built successfully

REM Step 4: Run the container with environment variables
echo 🚀 Starting container with environment variables...

if exist ".env" (
    start /b docker run --env-file .env -p 8051:8051 mcp/crawl4ai-rag
    echo ✅ Container started with .env file
) else (
    echo ⚠️  No .env file found, starting without environment file
    start /b docker run -p 8051:8051 mcp/crawl4ai-rag
    echo ✅ Container started without .env file
)

REM Step 5: Wait for container to be ready
echo ⏳ Waiting for container to be ready...
timeout /t 10 /nobreak >nul

REM Step 6: Check if container is running
for /f "delims=" %%i in ('docker ps -q --filter "ancestor=mcp/crawl4ai-rag" 2^>nul') do (
    set "container_id=%%i"
    goto :found_container
)

echo ❌ Container failed to start
echo 📋 Check Docker logs for details
exit /b 1

:found_container
echo ✅ Container is running: !container_id!
echo 🔗 MCP server available at: http://localhost:8051
echo 📋 To view logs: docker logs !container_id!
echo 🛑 To stop: docker stop !container_id!

echo 🎉 Crawl4ai MCP server restart complete!

endlocal 
