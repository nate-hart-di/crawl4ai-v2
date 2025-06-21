# Crawl4AI MCP Server - Windows Installation Script
# This script automates the complete setup process

param(
    [switch]$SkipDocker,
    [switch]$UseOpenAI,
    [string]$SupabaseUrl,
    [string]$SupabaseAnonKey,
    [string]$SupabaseServiceKey,
    [string]$OpenAIKey
)

# Enable strict mode
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Colors for output
function Write-Step { param($Message) Write-Host "🔄 $Message" -ForegroundColor Cyan }
function Write-Success { param($Message) Write-Host "✅ $Message" -ForegroundColor Green }
function Write-Warning { param($Message) Write-Host "⚠️  $Message" -ForegroundColor Yellow }
function Write-Error { param($Message) Write-Host "❌ $Message" -ForegroundColor Red }
function Write-Info { param($Message) Write-Host "ℹ️  $Message" -ForegroundColor Blue }

Write-Host @"
🪟 Crawl4AI MCP Server - Windows 11 Installation
================================================
This script will set up everything you need to run the Crawl4AI MCP server.

"@ -ForegroundColor Magenta

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin) {
    Write-Warning "For best results, run as Administrator (optional but recommended)"
}

# Step 1: Check Prerequisites
Write-Step "Checking prerequisites..."

# Check Windows version
$osVersion = [System.Environment]::OSVersion.Version
if ($osVersion.Major -lt 10) {
    Write-Error "Windows 10 or higher required. Current version: $($osVersion)"
    exit 1
}
Write-Success "Windows version: $($osVersion) ✓"

# Check Docker
if (-not $SkipDocker) {
    try {
        $dockerVersion = docker --version 2>$null
        if ($dockerVersion) {
            Write-Success "Docker found: $dockerVersion"
        } else {
            throw "Docker not found"
        }
    }
    catch {
        Write-Error "Docker Desktop not found or not running"
        Write-Info "Please install Docker Desktop from: https://www.docker.com/products/docker-desktop/"
        Write-Info "Then restart this script with: .\install.ps1"
        exit 1
    }
}

# Check available memory
$memory = Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -ExpandProperty TotalPhysicalMemory
$memoryGB = [math]::Round($memory / 1GB, 1)
Write-Info "Available RAM: $memoryGB GB"

if ($memoryGB -lt 8) {
    Write-Warning "Less than 8GB RAM detected. Consider using lighter settings."
}

# Step 2: Create .env file
Write-Step "Setting up environment configuration..."

if (Test-Path ".env") {
    Write-Warning ".env file already exists. Creating backup..."
    Copy-Item ".env" ".env.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
}

# Interactive configuration if parameters not provided
if (-not $SupabaseUrl) {
    Write-Host "`nSupabase Configuration Required:" -ForegroundColor Yellow
    $SupabaseUrl = Read-Host "Enter your Supabase URL (https://your-project.supabase.co)"
}

if (-not $SupabaseAnonKey) {
    $SupabaseAnonKey = Read-Host "Enter your Supabase Anon Key"
}

if (-not $SupabaseServiceKey) {
    $SupabaseServiceKey = Read-Host "Enter your Supabase Service Role Key"
}

# Embedding choice
if (-not $UseOpenAI -and -not $OpenAIKey) {
    Write-Host "`nEmbedding Configuration:" -ForegroundColor Yellow
    Write-Host "1. Free Local Embeddings (recommended, no API costs)"
    Write-Host "2. OpenAI Embeddings (paid, slightly higher quality)"
    $choice = Read-Host "Choose option (1 or 2)"
    
    if ($choice -eq "2") {
        $UseOpenAI = $true
        $OpenAIKey = Read-Host "Enter your OpenAI API Key"
    }
}

# Create .env file
$envContent = @"
# Crawl4AI MCP Server Configuration - Generated $(Get-Date)

# Supabase Configuration (Required)
SUPABASE_URL=$SupabaseUrl
SUPABASE_ANON_KEY=$SupabaseAnonKey
SUPABASE_SERVICE_ROLE_KEY=$SupabaseServiceKey

"@

if ($UseOpenAI -and $OpenAIKey) {
    $envContent += @"

# OpenAI Embeddings
OPENAI_API_KEY=$OpenAIKey
USE_LOCAL_EMBEDDINGS=false
"@
} else {
    $envContent += @"

# Free Local Embeddings
USE_LOCAL_EMBEDDINGS=true
LOCAL_EMBEDDING_MODEL=all-mpnet-base-v2
"@
}

# Performance settings based on available RAM
if ($memoryGB -lt 12) {
    $envContent += @"

# Performance Settings (Optimized for $memoryGB GB RAM)
USE_RERANKING=false
USE_CONTEXTUAL_EMBEDDINGS=false
MAX_CONCURRENT_CRAWLS=3
DEFAULT_CHUNK_SIZE=3000
"@
} else {
    $envContent += @"

# Performance Settings (Optimized for $memoryGB GB RAM)
USE_RERANKING=true
USE_CONTEXTUAL_EMBEDDINGS=true
MAX_CONCURRENT_CRAWLS=10
DEFAULT_CHUNK_SIZE=5000
"@
}

$envContent += @"

# Advanced Features (Optional)
USE_KNOWLEDGE_GRAPH=false

# Windows Optimizations
WINDOWS_OPTIMIZED=true
"@

$envContent | Out-File -FilePath ".env" -Encoding UTF8
Write-Success "Environment configuration created: .env"

# Step 3: Build and start the server
Write-Step "Building and starting the Crawl4AI MCP server..."

try {
    if (Test-Path "restart_crawl4ai.ps1") {
        & ".\restart_crawl4ai.ps1"
    } else {
        Write-Error "restart_crawl4ai.ps1 not found in current directory"
        exit 1
    }
}
catch {
    Write-Error "Failed to start server: $($_.Exception.Message)"
    Write-Info "Try running manually: .\restart_crawl4ai.ps1"
    exit 1
}

# Step 4: Verify installation
Write-Step "Verifying installation..."

Start-Sleep -Seconds 15  # Give container time to start

$containerId = docker ps -q --filter "ancestor=mcp/crawl4ai-rag" | Select-Object -First 1
if ($containerId) {
    Write-Success "Server is running! Container ID: $containerId"
    Write-Success "🔗 MCP server available at: http://localhost:8051"
    
    # Test connectivity
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8051" -TimeoutSec 10 -UseBasicParsing
        Write-Success "✅ Server is responding to HTTP requests"
    }
    catch {
        Write-Warning "Server is running but not responding to HTTP yet (may still be starting up)"
    }
} else {
    Write-Error "Server failed to start. Check Docker logs:"
    Write-Info "docker logs `$(docker ps -aq --filter `"ancestor=mcp/crawl4ai-rag`" | Select-Object -First 1)"
    exit 1
}

# Step 5: Show next steps
Write-Host @"

🎉 Installation Complete!

Next Steps:
1. Test the server: http://localhost:8051
2. View logs: docker logs $containerId
3. Stop server: docker stop $containerId

Integration:
- Add to Claude Desktop (see README.md for config)
- Use with Cursor IDE (see README.md for setup)

Configuration:
- Edit .env file to modify settings
- Restart with: .\restart_crawl4ai.ps1

Documentation:
- README.md - Quick start guide
- WINDOWS_SETUP.md - Detailed setup and troubleshooting

Happy crawling! 🕸️

"@ -ForegroundColor Green 
