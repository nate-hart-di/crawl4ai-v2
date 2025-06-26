<h1 align="center">Enhanced Crawl4AI RAG MCP Server</h1>

<p align="center">
  <em>Advanced Web Crawling, RAG, and Knowledge Graph Capabilities for AI Agents</em>
</p>

> **🚀 ENHANCED VERSION**: This is an enhanced fork of the original [coleam00/mcp-crawl4ai-rag](https://github.com/coleam00/mcp-crawl4ai-rag) with significant improvements including full-service Docker architecture, integrated Neo4j knowledge graphs, and seamless integration with the local-ai-packaged ecosystem.

A powerful implementation of the [Model Context Protocol (MCP)](https://modelcontextprotocol.io) integrated with [Crawl4AI](https://crawl4ai.com), [Supabase](https://supabase.com/), and [Neo4j](https://neo4j.com/) for providing AI agents and AI coding assistants with advanced web crawling, RAG, and knowledge graph capabilities.

With this enhanced MCP server, you can **scrape anything**, **build knowledge graphs from repositories**, and **use that knowledge anywhere** for sophisticated RAG operations with hallucination detection.

## 🆕 What's New in This Enhanced Version

### Major Architectural Improvements

- **✨ Full-Service Docker Architecture**: Complete containerized setup with Supabase, Neo4j, Ollama, and Caddy reverse proxy
- **🔗 Integrated Knowledge Graph**: Built-in Neo4j integration for repository analysis and AI hallucination detection
- **🚀 Local AI Package Integration**: Seamless compatibility with the [local-ai-packaged](https://github.com/coleam00/local-ai-packaged) ecosystem
- **⚡ Enhanced Performance**: Optimized container orchestration with proper service dependencies and health checks

### New Features Added

- **🧠 Repository Knowledge Graphs**: Parse entire GitHub repositories into structured knowledge graphs
- **🔍 AI Hallucination Detection**: Validate AI-generated code against real repository structures
- **📊 Advanced Query Capabilities**: Explore codebases through natural language queries
- **🔄 Automatic Service Management**: Self-healing container architecture with proper restart policies

### Development Improvements

- **🛠️ Modern Python Setup**: Uses `uv` for fast package management and virtual environment handling
- **🐳 Production-Ready Docker**: Multi-stage builds with optimized layer caching
- **📋 Comprehensive Configuration**: Environment-based configuration with sensible defaults
- **🔧 Developer Experience**: Improved setup scripts and cleaner project structure

## Overview

This enhanced MCP server provides comprehensive tools that enable AI agents to:

- Crawl websites and store content in vector databases
- Parse GitHub repositories into knowledge graphs
- Perform advanced RAG with multiple search strategies
- Validate AI-generated code against real implementations
- Detect and prevent AI hallucinations in coding tasks

The server includes several advanced RAG strategies and knowledge graph capabilities:

- **Contextual Embeddings** for enriched semantic understanding
- **Hybrid Search** combining vector and keyword search
- **Agentic RAG** for specialized code example extraction
- **Reranking** for improved result relevance using cross-encoder models
- **Knowledge Graph Integration** for repository analysis and hallucination detection

## Vision

This enhanced Crawl4AI RAG MCP server represents the next evolution of AI-powered development tools:

1. **Enterprise-Ready Architecture**: Full containerization with production-grade service orchestration and monitoring

2. **Advanced Knowledge Management**: Comprehensive repository analysis with semantic understanding of code relationships and dependencies

3. **AI Safety & Reliability**: Built-in hallucination detection to ensure AI-generated code is grounded in real implementations

4. **Local-First Development**: Complete local deployment option with no external dependencies beyond your chosen LLM providers

5. **Ecosystem Integration**: Designed to work seamlessly with the broader local-ai-packaged ecosystem for comprehensive AI development workflows

## Features

### Core Crawling & RAG Features

- **Smart URL Detection**: Automatically detects and handles different URL types (regular webpages, sitemaps, text files)
- **Recursive Crawling**: Follows internal links to discover content with configurable depth limits
- **Parallel Processing**: Efficiently crawls multiple pages simultaneously with rate limiting
- **Intelligent Chunking**: Context-aware content splitting optimized for semantic search
- **Advanced Vector Search**: Multiple search strategies with source filtering and reranking

### 🆕 Enhanced Knowledge Graph Features

- **Repository Parsing**: Complete analysis of GitHub repositories into structured knowledge graphs
- **Code Relationship Mapping**: Understand class hierarchies, method dependencies, and import relationships
- **Hallucination Detection**: Validate AI-generated code against real repository structures
- **Interactive Exploration**: Natural language queries over repository knowledge graphs

### 🆕 Production Features

- **Full Service Orchestration**: Integrated Supabase, Neo4j, Ollama, and reverse proxy setup
- **Health Monitoring**: Comprehensive health checks and automatic service recovery
- **Scalable Architecture**: Designed for both development and production deployments
- **Security Hardened**: Proper network isolation and credential management

## Tools

The server provides comprehensive web crawling, search, and knowledge graph tools:

### Core Tools (Always Available)

1. **`crawl_single_page`**: Quickly crawl a single web page and store its content in the vector database
2. **`smart_crawl_url`**: Intelligently crawl websites based on URL type (sitemap, documentation, or recursive crawling)
3. **`get_available_sources`**: Get a list of all available sources (domains) in the database for filtering
4. **`perform_rag_query`**: Advanced semantic search with optional source filtering and reranking

### Enhanced RAG Tools

5. **`search_code_examples`** (requires `USE_AGENTIC_RAG=true`): Specialized search for code examples and implementation patterns from documentation

### 🆕 Knowledge Graph Tools (requires `USE_KNOWLEDGE_GRAPH=true`)

6. **`parse_github_repository`**: Parse GitHub repositories into Neo4j knowledge graphs with full code structure analysis
7. **`check_ai_script_hallucinations`**: Comprehensive validation of AI-generated Python code against repository knowledge graphs
8. **`query_knowledge_graph`**: Interactive exploration of repository knowledge graphs with natural language queries

## Prerequisites

### 🆕 Enhanced Setup Requirements

- **[Docker/Docker Desktop](https://www.docker.com/products/docker-desktop/)** - Required for the full-service architecture
- **[Git](https://git-scm.com/)** - For repository cloning and version control
- **[Supabase Account](https://supabase.com/)** - For vector database and RAG functionality
- **Local LLM Models** - Downloaded via Ollama (no API keys required)

### Optional but Recommended

- **[uv](https://docs.astral.sh/uv/)** - For local Python development (faster than pip)
- **[Local AI Package](https://github.com/coleam00/local-ai-packaged)** - For integrated local AI services

## Installation

### 🆕 Enhanced Docker Setup (Recommended)

This enhanced version provides a complete containerized environment with all services:

1. **Clone this enhanced repository**:

   ```bash
   git clone https://github.com/yourusername/mcp-crawl4ai-rag.git
   cd mcp-crawl4ai-rag
   ```

2. **Create environment configuration**:

   ```bash
   cp .env.example .env
   # Edit .env with your configuration (see Configuration section)
   ```

3. **Start all services**:

   ```bash
   docker compose up -d
   ```

4. **Verify services are running**:
   ```bash
   docker compose ps
   ```

The enhanced setup includes:

- **Crawl4AI RAG Server**: `http://localhost:8003`
- **Supabase Studio**: `http://localhost:8002`
- **Neo4j Browser**: `http://localhost:8001`
- **Ollama API**: `http://localhost:8004` (optional)

### Alternative: Local Development Setup

For development or when you prefer local installation:

1. **Clone and setup**:

   ```bash
   git clone https://github.com/yourusername/mcp-crawl4ai-rag.git
   cd mcp-crawl4ai-rag
   ```

2. **Install uv (if not already installed)**:

   ```bash
   pip install uv
   ```

3. **Create and activate virtual environment**:

   ```bash
   uv venv
   # Windows: .venv\Scripts\activate
   # Mac/Linux: source .venv/bin/activate
   ```

4. **Install dependencies**:

   ```bash
   uv pip install -e .
   crawl4ai-setup
   ```

5. **Configure environment**:
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

## 🆕 Enhanced Database Setup

### Supabase Configuration

1. **Create a new Supabase project** at [supabase.com](https://supabase.com)

2. **Run the enhanced database setup**:

   - Go to SQL Editor in your Supabase dashboard
   - Execute the contents of `crawled_pages.sql` to create tables and functions
   - **🆕 New**: The enhanced schema includes optimized indexes and vector search functions

3. **Configure connection**:
   - Copy your project URL and service key to `.env`
   - The enhanced version includes connection pooling and retry logic

### 🆕 Neo4j Knowledge Graph Setup

The enhanced version includes automated Neo4j setup:

#### Option 1: Integrated Docker Setup (Recommended)

Neo4j is automatically configured when you run `docker compose up -d`:

- **URI**: `bolt://localhost:7687`
- **Username**: `neo4j`
- **Password**: Check your `.env` file for `NEO4J_PASSWORD`

#### Option 2: Local AI Package Integration

If you're using the [local-ai-packaged](https://github.com/coleam00/local-ai-packaged) ecosystem:

1. **Clone local-ai-packaged**:

   ```bash
   git clone https://github.com/coleam00/local-ai-packaged.git
   ```

2. **Follow their Neo4j setup instructions**

3. **Configure connection in your `.env**

#### Option 3: Manual Neo4j Installation

- **Neo4j Desktop**: Download from [neo4j.com/download](https://neo4j.com/download/)
- **Neo4j AuraDB**: Cloud option at [neo4j.com/cloud/aura](https://neo4j.com/cloud/aura/)

## 🆕 Enhanced Configuration

Create a `.env` file with the following enhanced configuration options:

```bash
# ===========================================
# MCP Server Configuration
# ===========================================
HOST=0.0.0.0
PORT=8051
TRANSPORT=sse

# ===========================================
# AI/LLM Configuration
# ===========================================
# Local embedding configuration (no API keys needed)
USE_LOCAL_EMBEDDINGS=true
LOCAL_EMBEDDING_MODEL=nomic-embed-text:latest
MODEL_CHOICE=qwen2.5:7b-instruct-q4_K_M
OLLAMA_URL=http://host.docker.internal:11434

# Optional: Local Ollama integration
OLLAMA_BASE_URL=http://localhost:8004
OLLAMA_MODEL=qwen2.5:7b-instruct-q4_K_M

# ===========================================
# 🆕 Enhanced RAG Strategies
# ===========================================
USE_CONTEXTUAL_EMBEDDINGS=false
USE_HYBRID_SEARCH=true
USE_AGENTIC_RAG=false
USE_RERANKING=true
USE_KNOWLEDGE_GRAPH=true

# ===========================================
# Database Configuration
# ===========================================
# Supabase (Required)
SUPABASE_URL=your_supabase_project_url
SUPABASE_SERVICE_KEY=your_supabase_service_key

# 🆕 Neo4j Knowledge Graph (Optional but Recommended)
NEO4J_URI=bolt://localhost:7687
NEO4J_USER=neo4j
NEO4J_PASSWORD=your_neo4j_password

# 🆕 PostgreSQL (for local development)
POSTGRES_PASSWORD=your_postgres_password

# ===========================================
# 🆕 Service Configuration
# ===========================================
# Reverse Proxy Hostnames
NEO4J_HOSTNAME=:8001
SUPABASE_HOSTNAME=:8002
CRAWL4AI_HOSTNAME=:8003
OLLAMA_HOSTNAME=:8004

# SSL Configuration (for production)
LETSENCRYPT_EMAIL=your_email@example.com
```

### 🆕 Enhanced RAG Strategy Guide

#### **Recommended: AI Coding Assistant Setup**

```bash
USE_CONTEXTUAL_EMBEDDINGS=true
USE_HYBRID_SEARCH=true
USE_AGENTIC_RAG=true
USE_RERANKING=true
USE_KNOWLEDGE_GRAPH=true
```

#### **Performance: Fast Basic RAG**

```bash
USE_CONTEXTUAL_EMBEDDINGS=false
USE_HYBRID_SEARCH=true
USE_AGENTIC_RAG=false
USE_RERANKING=false
USE_KNOWLEDGE_GRAPH=false
```

#### **Precision: Maximum Accuracy**

```bash
USE_CONTEXTUAL_EMBEDDINGS=true
USE_HYBRID_SEARCH=true
USE_AGENTIC_RAG=true
USE_RERANKING=true
USE_KNOWLEDGE_GRAPH=true
```

## Running the Enhanced Server

### 🆕 Docker Compose (Recommended)

Start all services with a single command:

```bash
# Start all services in background
docker compose up -d

# View logs
docker compose logs -f crawl4ai-rag

# Stop all services
docker compose down
```

### Individual Container

```bash
# Build the enhanced image
docker build -t mcp/crawl4ai-rag --build-arg PORT=8051 .

# Run with environment file
docker run --env-file .env -p 8051:8051 mcp/crawl4ai-rag
```

### Local Python Development

```bash
# Activate virtual environment
source .venv/bin/activate # or .venv\Scripts\activate on Windows

# Run the server
uv run src/crawl4ai_mcp.py
```

## 🆕 Enhanced MCP Client Integration

### SSE Configuration (Recommended)

The enhanced server provides optimized SSE transport:

```json
{
  "mcpServers": {
    "crawl4ai-rag-enhanced": {
      "transport": "sse",
      "url": "http://localhost:8003/sse"
    }
  }
}
```

### 🆕 Production Configuration

For production deployments with SSL:

```json
{
  "mcpServers": {
    "crawl4ai-rag-enhanced": {
      "transport": "sse",
      "url": "https://your-domain.com/crawl4ai/sse"
    }
  }
}
```

### Enhanced Stdio Configuration

```json
{
  "mcpServers": {
    "crawl4ai-rag-enhanced": {
      "args": [
        "run",
        "--rm",
        "-i",
        "--network",
        "mcp-network",
        "--env-file",
        ".env",
        "mcp/crawl4ai-rag"
      ],
      "command": "docker",
      "env": {
        "TRANSPORT": "stdio"
      }
    }
  }
}
```

### Client-Specific Configurations

#### Claude Desktop / Claude Code

```bash
claude mcp add-json crawl4ai-rag-enhanced '{"type":"http","url":"http://localhost:8003/sse"}' --scope user
```

#### Windsurf

```json
{
  "mcpServers": {
    "crawl4ai-rag-enhanced": {
      "serverUrl": "http://localhost:8003/sse",
      "transport": "sse"
    }
  }
}
```

## 🆕 Enhanced Knowledge Graph Architecture

### Advanced Repository Analysis

The enhanced knowledge graph system provides comprehensive code understanding:

#### **Enhanced Components** (`knowledge_graphs/` folder):

- **`parse_repo_into_neo4j.py`**: Advanced repository parsing with dependency analysis
- **`ai_script_analyzer.py`**: Enhanced AST parsing with context understanding
- **`knowledge_graph_validator.py`**: Sophisticated hallucination detection with confidence scoring
- **`hallucination_reporter.py`**: Detailed reporting with fix suggestions
- **`query_knowledge_graph.py`**: Natural language query interface

#### **Enhanced Schema Design**:

The Neo4j database now includes:

**Enhanced Nodes:**

- `Repository`: With metadata (stars, language, last_updated)
- `File`: With file type and complexity metrics
- `Class`: With inheritance relationships and method counts
- `Method`: With parameter types and return type analysis
- `Function`: With complexity and usage statistics
- `Attribute`: With type hints and default values

**Enhanced Relationships:**

- `Repository` -[:CONTAINS {created_at}]-> `File`
- `File` -[:DEFINES {line_number}]-> `Class`
- `Class` -[:INHERITS_FROM]-> `Class`
- `Class` -[:HAS_METHOD {visibility}]-> `Method`
- `Method` -[:CALLS]-> `Method`
- `Function` -[:USES]-> `Function`

### 🆕 Advanced Workflows

#### **1. Repository Knowledge Building**

```bash
# Parse multiple repositories
parse_github_repository https://github.com/pydantic/pydantic.git
parse_github_repository https://github.com/fastapi/fastapi.git
parse_github_repository https://github.com/pallets/flask.git
```

#### **2. Code Validation Pipeline**

```bash
# Generate code with AI
# Validate against knowledge graph
check_ai_script_hallucinations /path/to/generated_script.py
```

#### **3. Knowledge Exploration**

```bash
# Explore repository structure
query_knowledge_graph "repos"
query_knowledge_graph "classes pydantic"
query_knowledge_graph "method BaseModel __init__"
```

## 🆕 Enhanced Development Features

### Advanced Debugging

The enhanced version includes comprehensive debugging capabilities:

```bash
# Container debugging
docker compose logs -f crawl4ai-rag
docker compose exec crawl4ai-rag /bin/bash

# Health check endpoints
curl http://localhost:8003/health
curl http://localhost:8003/metrics
```

### Performance Monitoring

Built-in performance metrics and monitoring:

- **Request latency tracking**
- **Memory usage monitoring**
- **Vector database performance metrics**
- **Knowledge graph query optimization**

### 🆕 Development Scripts

Enhanced development tooling:

```bash
# Setup development environment
./scripts/dev-setup.sh

# Run comprehensive tests
./scripts/run-tests.sh

# Performance benchmarking
./scripts/benchmark.sh

# Database migrations
./scripts/migrate-db.sh
```

## Migration from Original Version

If you're migrating from the original `coleam00/mcp-crawl4ai-rag`:

### 🔄 Automatic Migration

1. **Backup your existing data**:

   ```bash
   # Export existing Supabase data
   ./scripts/export-data.sh
   ```

2. **Update configuration**:

   ```bash
   # Convert old .env to new format
   ./scripts/migrate-config.sh
   ```

3. **Import data to enhanced version**:
   ```bash
   # Import to new schema
   ./scripts/import-data.sh
   ```

### Key Differences

| Feature      | Original           | Enhanced                   |
| ------------ | ------------------ | -------------------------- |
| Architecture | Single container   | Full service orchestration |
| Neo4j        | Optional, external | Integrated with Docker     |
| Performance  | Basic              | Optimized with caching     |
| Monitoring   | None               | Built-in health checks     |
| Development  | Manual setup       | Automated scripts          |

## Contributing to the Enhanced Version

We welcome contributions to make this enhanced version even better:

1. **Fork this enhanced repository**
2. **Create feature branches** with descriptive names
3. **Add comprehensive tests** for new features
4. **Update documentation** including this README
5. **Submit pull requests** with detailed descriptions

### 🆕 Development Guidelines

- **Use conventional commits** for clear history
- **Add integration tests** for new MCP tools
- **Update Docker configurations** for new services
- **Maintain backward compatibility** where possible

## License

This enhanced version maintains the same MIT license as the original project.

## Acknowledgments

- **Original Project**: [coleam00/mcp-crawl4ai-rag](https://github.com/coleam00/mcp-crawl4ai-rag) - Thank you for the excellent foundation
- **Crawl4AI Team**: For the powerful crawling capabilities
- **Supabase Team**: For the excellent vector database platform
- **Neo4j Team**: For the graph database technology
- **MCP Community**: For the innovative protocol design

---

**🚀 Ready to enhance your AI development workflow?** Get started with the enhanced Crawl4AI RAG MCP Server today!
