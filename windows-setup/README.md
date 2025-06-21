# 🪟 Crawl4AI MCP Server - Windows 11 Setup Package

This folder contains everything you need to run the Crawl4AI MCP Server on Windows 11 with Docker.

## 📁 What's Included

```
windows-setup/
├── README.md                    # This file - start here!
├── install.ps1                 # Automated installation script
├── WINDOWS_SETUP.md            # Detailed setup guide
├── .env.example                # Environment configuration template
├── restart_crawl4ai.ps1        # PowerShell startup script (recommended)
├── restart_crawl4ai.bat        # Batch file startup script
├── Dockerfile                  # Docker container definition
├── .dockerignore              # Docker build exclusions
├── pyproject.toml             # Python dependencies
├── crawled_pages.sql          # Database schema
├── src/                       # Source code
│   ├── crawl4ai_mcp.py       # Main MCP server
│   └── utils.py              # Utility functions
└── knowledge_graphs/          # AI hallucination detection (optional)
```

## 🚀 Quick Start (5 Minutes)

### 1. Prerequisites

- **Windows 11** (Pro/Enterprise recommended, Home with WSL2 works)
- **Docker Desktop** installed and running
- **Git for Windows** installed
- **8GB+ RAM** (16GB recommended)

### 2. Setup Steps

**Step 1: Download this folder**

```powershell
# If you have git
git clone https://github.com/your-repo/crawl4ai-rag.git
cd crawl4ai-rag/windows-setup

# Or download and extract the windows-setup folder
```

**Step 2: Configure environment**

```powershell
# Copy the template
copy .env.example .env

# Edit with your settings
notepad .env
```

**Step 3: Add required settings to .env**

```bash
# Required: Get these from your Supabase project
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key-here

# Choose one embedding option:
# Option A: Free local embeddings (recommended)
USE_LOCAL_EMBEDDINGS=true

# Option B: OpenAI embeddings (paid)
# OPENAI_API_KEY=your-key-here
```

**Step 4: Start the server**

```powershell
# PowerShell (recommended)
.\restart_crawl4ai.ps1

# OR Command Prompt
restart_crawl4ai.bat
```

**Step 5: Verify it's working**

- Server runs at: `http://localhost:8051`
- Check status: `docker ps --filter "ancestor=mcp/crawl4ai-rag"`

## 🔧 Configuration Options

### Free vs Paid Embeddings

**🆓 Free Local Embeddings (Recommended)**

```bash
USE_LOCAL_EMBEDDINGS=true
LOCAL_EMBEDDING_MODEL=all-mpnet-base-v2
```

- ✅ Completely free
- ✅ No rate limits
- ✅ Works offline
- ✅ High quality results

**💰 OpenAI Embeddings**

```bash
OPENAI_API_KEY=your-key-here
USE_LOCAL_EMBEDDINGS=false
```

- ⚠️ Costs money (~$20-50/month)
- ⚠️ Rate limited
- ✅ Slightly higher quality

### Performance Tuning

**For 8GB RAM Systems:**

```bash
USE_LOCAL_EMBEDDINGS=true
LOCAL_EMBEDDING_MODEL=all-MiniLM-L6-v2 # Smaller model
USE_RERANKING=false
MAX_CONCURRENT_CRAWLS=3
```

**For 16GB+ RAM Systems:**

```bash
USE_LOCAL_EMBEDDINGS=true
LOCAL_EMBEDDING_MODEL=all-mpnet-base-v2 # Best quality
USE_RERANKING=true
USE_CONTEXTUAL_EMBEDDINGS=true
MAX_CONCURRENT_CRAWLS=10
```

## 🛠 Using the Scripts

### PowerShell Script (restart_crawl4ai.ps1)

**Recommended for most users**

```powershell
# Start server
.\restart_crawl4ai.ps1

# Features:
# ✅ Colored output
# ✅ Error handling
# ✅ Docker validation
# ✅ Background process management
```

### Batch Script (restart_crawl4ai.bat)

**For Command Prompt users**

```cmd
restart_crawl4ai.bat

# Features:
# ✅ Command prompt compatibility
# ✅ Windows batch syntax
# ✅ Background execution
```

### What the Scripts Do

1. **Stop** any running crawl4ai containers
2. **Remove** old containers
3. **Build** fresh Docker image
4. **Start** new container with your .env settings
5. **Verify** everything is running

## 🔍 Troubleshooting

### Common Issues

**"Docker is not running"**

```powershell
# Solution: Start Docker Desktop
# Check: docker --version
```

**"Port 8051 already in use"**

```powershell
# Find what's using it
netstat -ano | findstr :8051

# Kill the process (replace 1234 with actual PID)
taskkill /PID 1234 /F
```

**"Container failed to start"**

```powershell
# Check logs
docker logs (docker ps -aq --filter "ancestor=mcp/crawl4ai-rag" | Select-Object -First 1)

# Force rebuild
docker system prune -f
.\restart_crawl4ai.ps1
```

**"Out of memory errors"**

1. Close other applications
2. Use smaller embedding model: `LOCAL_EMBEDDING_MODEL=all-MiniLM-L6-v2`
3. Reduce concurrent crawls: `MAX_CONCURRENT_CRAWLS=3`

### Getting Help

**Check Status:**

```powershell
docker ps                          # Running containers
docker logs [container-id]         # View logs
docker system df                   # Disk usage
```

**Diagnostic Info:**

```powershell
docker --version                   # Docker version
wsl --version                      # WSL version
systeminfo | findstr "OS"         # Windows version
```

## 🔗 Integration with AI Tools

### Claude Desktop

Add to your Claude Desktop config:

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
      "cwd": "C:\\path\\to\\your\\windows-setup"
    }
  }
}
```

### Cursor IDE

Add to Cursor settings:

```json
{
  "mcp.servers": {
    "crawl4ai": {
      "url": "http://localhost:8051"
    }
  }
}
```

## 📊 Features Available

### Core Features

- ✅ **Web Crawling**: Single pages, sitemaps, recursive crawling
- ✅ **RAG Search**: Semantic search through crawled content
- ✅ **Code Examples**: Extract and search code snippets
- ✅ **Free Embeddings**: No API costs with local models
- ✅ **Docker Containerized**: Easy deployment and management

### Advanced Features (Optional)

- 🔬 **AI Hallucination Detection**: Validate AI-generated code
- 📊 **Knowledge Graphs**: Repository analysis with Neo4j
- 🎯 **Contextual Embeddings**: More accurate search results
- 🔄 **Reranking**: Improved search quality

## 🔄 Updates

To update to the latest version:

```powershell
# Pull latest changes
git pull origin main

# Restart with new version
.\restart_crawl4ai.ps1
```

## 💡 Tips for Success

1. **Start Simple**: Use free local embeddings first
2. **Check Resources**: Monitor RAM usage during crawling
3. **Use PowerShell**: Better error handling than batch files
4. **Read Logs**: Docker logs help diagnose issues
5. **Test Small**: Try crawling a simple website first

## 📚 Additional Documentation

- **`WINDOWS_SETUP.md`** - Detailed setup guide with troubleshooting
- **`src/crawl4ai_mcp.py`** - Main server code with all MCP tools
- **`.env.example`** - All available configuration options

## 🆘 Support

If you encounter issues:

1. Check the troubleshooting section above
2. Review Docker logs for error messages
3. Ensure all prerequisites are installed
4. Try the diagnostic commands to gather system info

## 🎉 You're Ready!

Once your server is running at `http://localhost:8051`, you can:

- Crawl websites and build your knowledge base
- Perform semantic searches on content
- Extract and analyze code examples
- Integrate with Claude Desktop or Cursor IDE

Happy crawling! 🕸️
