# 🪟 Crawl4AI MCP Server - Windows 11 Setup Guide

Complete setup guide for running the Crawl4AI MCP Server on Windows 11 with Docker.

## 🎯 Prerequisites

### 1. Windows 11 Requirements

- Windows 11 Pro, Enterprise, or Education (recommended)
- Windows 11 Home with WSL 2 enabled
- At least 8GB RAM (16GB recommended)
- 20GB free disk space

### 2. Docker Desktop for Windows

1. Download [Docker Desktop](https://www.docker.com/products/docker-desktop/)
2. Install with these settings:
   - ✅ Use WSL 2 instead of Hyper-V
   - ✅ Add path to Windows PATH
3. Restart Windows after installation
4. Open Docker Desktop and complete setup

### 3. Enable WSL 2 (if not already enabled)

```powershell
# Run as Administrator
wsl --install
# Restart Windows
wsl --set-default-version 2
```

### 4. Git for Windows

Download and install [Git for Windows](https://git-scm.com/download/win)

## 🚀 Quick Start

### 1. Clone the Repository

```powershell
git clone https://github.com/nate-hart-di/crawl4ai-rag-windows.git
cd crawl4ai-rag-windows
```

### 2. Configure Environment

```powershell
# Copy environment template
copy .env.example .env

# Edit .env file with your settings
notepad .env
```

### 3. Set Required Variables

Edit `.env` and set these **REQUIRED** values:

```bash
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key-here

# Choose one:
OPENAI_API_KEY=your-key-here # For OpenAI embeddings
# OR
USE_LOCAL_EMBEDDINGS=true # For free local embeddings
```

### 4. Start the Server

**Option A: PowerShell (Recommended)**

```powershell
.\restart_crawl4ai.ps1
```

**Option B: Command Prompt**

```cmd
restart_crawl4ai.bat
```

### 5. Verify Installation

The server should be running at: `http://localhost:8051`

Check container status:

```powershell
docker ps --filter "ancestor=mcp/crawl4ai-rag"
```

## 🔧 Configuration Options

### Embeddings Strategy

**Option 1: Free Local Embeddings (Recommended)**

```bash
USE_LOCAL_EMBEDDINGS=true
LOCAL_EMBEDDING_MODEL=all-mpnet-base-v2
```

- ✅ Completely free
- ✅ No rate limits
- ✅ Works offline
- ✅ High quality

**Option 2: OpenAI Embeddings**

```bash
OPENAI_API_KEY=your-key-here
USE_LOCAL_EMBEDDINGS=false
```

- ⚠️ Costs money
- ⚠️ Rate limited
- ✅ Slightly higher quality

### Advanced Features

**Knowledge Graph (Optional)**

```bash
USE_KNOWLEDGE_GRAPH=true
NEO4J_URI=bolt://localhost:7687
NEO4J_USER=neo4j
NEO4J_PASSWORD=your-password
```

**Performance Tuning**

```bash
USE_RERANKING=true             # Better search quality
USE_CONTEXTUAL_EMBEDDINGS=true # More accurate embeddings
MAX_CONCURRENT_CRAWLS=5        # Lower for limited resources
```

## 🛠 Windows-Specific Commands

### PowerShell Commands

```powershell
# Start server
.\restart_crawl4ai.ps1

# Check Docker status
docker ps

# View logs
docker logs (docker ps -q --filter "ancestor=mcp/crawl4ai-rag")

# Stop server
docker stop (docker ps -q --filter "ancestor=mcp/crawl4ai-rag")

# Force rebuild
docker build -t mcp/crawl4ai-rag --no-cache .
```

### Command Prompt Commands

```cmd
:: Start server
restart_crawl4ai.bat

:: View logs
for /f %i in ('docker ps -q --filter "ancestor=mcp/crawl4ai-rag"') do docker logs %i

:: Stop server
for /f %i in ('docker ps -q --filter "ancestor=mcp/crawl4ai-rag"') do docker stop %i
```

## 📊 Performance Optimization

### For Lower-End Systems (8GB RAM)

```bash
# In .env file
USE_LOCAL_EMBEDDINGS=true
LOCAL_EMBEDDING_MODEL=all-MiniLM-L6-v2 # Smaller model
USE_RERANKING=false
MAX_CONCURRENT_CRAWLS=3
DEFAULT_CHUNK_SIZE=3000
```

### For High-End Systems (16GB+ RAM)

```bash
# In .env file
USE_LOCAL_EMBEDDINGS=true
LOCAL_EMBEDDING_MODEL=all-mpnet-base-v2 # Best quality
USE_RERANKING=true
USE_CONTEXTUAL_EMBEDDINGS=true
MAX_CONCURRENT_CRAWLS=10
DEFAULT_CHUNK_SIZE=5000
```

## 🔍 Troubleshooting

### Docker Issues

**Docker Desktop not starting:**

1. Restart Windows
2. Ensure Hyper-V is disabled
3. Enable WSL 2 integration

**Port 8051 already in use:**

```powershell
# Find what's using the port
netstat -ano | findstr :8051
# Kill the process (replace PID)
taskkill /PID 1234 /F
```

### Container Issues

**Container won't start:**

```powershell
# Check Docker logs
docker logs (docker ps -aq --filter "ancestor=mcp/crawl4ai-rag" | Select-Object -First 1)

# Rebuild completely
docker system prune -f
.\restart_crawl4ai.ps1
```

**Out of memory errors:**

1. Close other applications
2. Increase Docker memory limit in Docker Desktop settings
3. Use smaller embedding model

### Environment Issues

**Environment variables not loading:**

1. Ensure `.env` file is in the same directory
2. Check file encoding (should be UTF-8)
3. No spaces around `=` in `.env` file

**Supabase connection errors:**

1. Verify URLs don't have trailing slashes
2. Check firewall settings
3. Ensure keys are correct

## 📁 File Structure

```
crawl4ai-rag-windows/
├── .env                    # Your configuration (create from .env.example)
├── .env.example           # Configuration template
├── Dockerfile             # Docker image definition
├── restart_crawl4ai.ps1   # PowerShell start script
├── restart_crawl4ai.bat   # Batch start script
├── src/
│   ├── crawl4ai_mcp.py   # Main MCP server
│   └── utils.py          # Utility functions
├── knowledge_graphs/      # AI hallucination detection
└── docs/                 # Additional documentation
```

## 🔗 Integration with MCP Clients

### Claude Desktop

Add to your Claude Desktop configuration:

```json
{
  "mcpServers": {
    "crawl4ai": {
      "args": [
        "/c",
        "docker",
        "run",
        "--env-file",
        ".env",
        "-p",
        "8051:8051",
        "mcp/crawl4ai-rag"
      ],
      "command": "cmd",
      "cwd": "C:\\path\\to\\crawl4ai-rag-windows"
    }
  }
}
```

### Cursor IDE

Configure in Cursor settings:

```json
{
  "mcp.servers": {
    "crawl4ai": {
      "url": "http://localhost:8051"
    }
  }
}
```

## 🆘 Getting Help

### Common Issues

1. **Docker won't start**: Restart Windows, check WSL 2
2. **Port conflicts**: Change port in Dockerfile and scripts
3. **Memory issues**: Use smaller embedding models
4. **Permission errors**: Run PowerShell as Administrator

### Support Channels

- GitHub Issues: Report bugs and feature requests
- Discussions: Ask questions and share tips
- Discord: Real-time community support

### Diagnostic Commands

```powershell
# System info
docker --version
wsl --version
systeminfo | findstr /B /C:"OS Name" /C:"OS Version"

# Docker info
docker info
docker system df

# Container logs
docker logs --tail 50 (docker ps -q --filter "ancestor=mcp/crawl4ai-rag")
```

## 🎉 Next Steps

Once your server is running:

1. **Test the API**: Visit `http://localhost:8051/health`
2. **Run test crawl**: Use the MCP tools to crawl a simple website
3. **Configure your client**: Set up Claude Desktop or Cursor
4. **Explore features**: Try different crawling modes and settings

## 🔄 Updates

To update to the latest version:

```powershell
git pull origin main
.\restart_crawl4ai.ps1
```

The container will automatically rebuild with the latest changes.
