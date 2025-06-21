# PowerShell script to completely restart the crawl4ai MCP server
# This stops, removes, rebuilds, and runs the Docker container on Windows

# Enable strict mode for better error handling
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Function to write colored output
function Write-ColoredOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

# Function to check if Docker is running
function Test-DockerRunning {
    try {
        docker version | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

Write-ColoredOutput "🔄 Starting crawl4ai MCP server restart..." "Cyan"

# Check if Docker is running
if (-not (Test-DockerRunning)) {
    Write-ColoredOutput "❌ Docker is not running. Please start Docker Desktop first." "Red"
    exit 1
}

try {
    # Step 1: Stop all running crawl4ai containers
    Write-ColoredOutput "⏹️  Stopping running crawl4ai containers..." "Yellow"
    
    $runningContainers = docker ps -q --filter "ancestor=mcp/crawl4ai-rag" 2>$null
    if ($runningContainers) {
        docker stop $runningContainers
        Write-ColoredOutput "✅ Stopped containers: $($runningContainers -join ', ')" "Green"
    }
    else {
        Write-ColoredOutput "ℹ️  No running crawl4ai containers found" "Blue"
    }

    # Step 2: Remove all crawl4ai containers (running and stopped)
    Write-ColoredOutput "🗑️  Removing crawl4ai containers..." "Yellow"
    
    $allContainers = docker ps -aq --filter "ancestor=mcp/crawl4ai-rag" 2>$null
    if ($allContainers) {
        docker rm $allContainers
        Write-ColoredOutput "✅ Removed containers: $($allContainers -join ', ')" "Green"
    }
    else {
        Write-ColoredOutput "ℹ️  No crawl4ai containers to remove" "Blue"
    }

    # Step 3: Build the Docker image
    Write-ColoredOutput "🔨 Building Docker image..." "Yellow"
    docker build -t mcp/crawl4ai-rag --build-arg PORT=8051 .
    if ($LASTEXITCODE -eq 0) {
        Write-ColoredOutput "✅ Docker image built successfully" "Green"
    }
    else {
        throw "Docker build failed"
    }

    # Step 4: Run the container with environment variables
    Write-ColoredOutput "🚀 Starting container with environment variables..." "Yellow"
    
    if (Test-Path ".env") {
        # Start container in background job
        $job = Start-Job -ScriptBlock {
            param($envFile)
            docker run --env-file $envFile -p 8051:8051 mcp/crawl4ai-rag
        } -ArgumentList (Resolve-Path ".env").Path
        
        Write-ColoredOutput "✅ Container started with .env file (Job ID: $($job.Id))" "Green"
    }
    else {
        Write-ColoredOutput "⚠️  No .env file found, starting without environment file" "Magenta"
        
        # Start container in background job
        $job = Start-Job -ScriptBlock {
            docker run -p 8051:8051 mcp/crawl4ai-rag
        }
        
        Write-ColoredOutput "✅ Container started without .env file (Job ID: $($job.Id))" "Green"
    }

    # Step 5: Wait for container to be ready
    Write-ColoredOutput "⏳ Waiting for container to be ready..." "Yellow"
    Start-Sleep -Seconds 10

    # Step 6: Check if container is running
    $containerId = (docker ps -q --filter "ancestor=mcp/crawl4ai-rag" | Select-Object -First 1)
    if ($containerId) {
        Write-ColoredOutput "✅ Container is running: $containerId" "Green"
        Write-ColoredOutput "🔗 MCP server available at: http://localhost:8051" "Cyan"
        Write-ColoredOutput "📋 To view logs: docker logs $containerId" "Blue"
        Write-ColoredOutput "🛑 To stop: docker stop $containerId" "Blue"
    }
    else {
        Write-ColoredOutput "❌ Container failed to start" "Red"
        Write-ColoredOutput "📋 Check Docker logs for details" "Yellow"
        exit 1
    }

    Write-ColoredOutput "🎉 Crawl4ai MCP server restart complete!" "Green"
}
catch {
    Write-ColoredOutput "❌ Error occurred: $($_.Exception.Message)" "Red"
    Write-ColoredOutput "💡 Tips:" "Yellow"
    Write-ColoredOutput "   - Ensure Docker Desktop is running" "White"
    Write-ColoredOutput "   - Check your .env file format" "White"
    Write-ColoredOutput "   - Verify port 8051 is not in use" "White"
    exit 1
} 
