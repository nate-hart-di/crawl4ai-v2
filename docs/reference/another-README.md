<h1 align="center">Enhanced Crawl4AI RAG MCP Server</h1>

<p align="center">
  <em>Advanced Web Crawling, RAG, and Knowledge Graph Capabilities for AI Agents</em>
</p>

> **🚀 MAJOR UPGRADE:**  
> This version is **significantly different** from the original [coleam00/mcp-crawl4ai-rag](https://github.com/coleam00/mcp-crawl4ai-rag).
>
> - **All LLM and embedding operations are now handled by local models via [Ollama](https://ollama.com/)**
> - **No OpenAI API calls** are made unless you explicitly re-enable them
> - `.env` and Docker Compose have been simplified and hardened
> - Knowledge graph/Neo4j and RAG features remain and are improved

---

## 🆕 What's New & What's Different

### 🚨 **Major Architectural Changes: Local-First Everything**

- **Local LLMs & Embeddings:**  
  Powered by Ollama, with models selected via `.env` (`MODEL_CHOICE`, `LOCAL_EMBEDDING_MODEL`, `OLLAMA_URL`).  
  _No OpenAI or Qdrant cloud required by default._
- **Simplified Environment and Setup:**  
  Only variables in `.env` that are actually consumed by your stack are needed.
- **Full-Service Docker Compose:**  
  Runs all services (Crawl4AI, Neo4j, Supabase, Ollama, Caddy) as containers, optimized for local development and production.
- **Knowledge Graph Upgrades:**  
  Enhanced Neo4j integration for repository analysis, code validation, and hallucination detection with metadata powered by local LLMs.

### 🧠 **Feature Additions**

- **Repository-to-Knowledge-Graph Parsing:**  
  Parse entire GitHub repos to structured knowledge graphs (see `parse_github_repository` tool).
- **AI Hallucination Detection:**  
  Validate AI-generated Python code against real repo structures (see `check_ai_script_hallucinations`).
- **Interactive Knowledge Graph Queries:**  
  Explore and search codebases via an interactive CLI (`query_knowledge_graph.py --interactive`).
- **Advanced RAG Strategies:**  
  Contextual embeddings, hybrid search, agentic RAG, reranking, and more (configurable via `.env`).

### 💡 **What’s Gone / Deprecated**

- **OpenAI and Qdrant as defaults:**  
  All cloud endpoints are now opt-in, not default.
- **Bloated .env files:**  
  Only use the variables you need—less confusion, fewer mistakes.
- **Manual, error-prone orchestration:**  
  Docker Compose and helper scripts handle service startup, health, and dependencies.

---

## 🛠️ Usage Overview

### **1. Crawling & Parsing a Web or GitHub Repository**

- Use **HTTPS clone URLs** (e.g., `https://github.com/owner/repo.git`) for best results.
- The system will:
  - Detect optimal crawl strategy (sitemap, robots.txt, direct traversal, repo scan)
  - Respect robots.txt and rate limits
  - Parse and store content/code, extract metadata for RAG and knowledge graph

**Do NOT:**

- Try to crawl private repos without credentials
- Use SSH URLs unless your Docker environment supports SSH keys
- Over-crawl massive sites or repos unnecessarily

---

### **2. AI Hallucination Detection**

- Analyze any Python script for hallucinated classes, methods, attributes, or imports using:
  ```bash
  python ai_hallucination_detector.py path/to/your_script.py
  ```
- The tool:
  - Parses the script with AST
  - Cross-references every usage against the Neo4j graph
  - Flags "not found" or mismatched elements as likely hallucinations

**Best Practices:**

- Only analyze scripts relevant to codebases present in your graph
- Investigate flagged hallucinations—sometimes they're new code, sometimes they're errors

---

### **3. Interactive Knowledge Graph Querying**

- Explore your knowledge graph in a CLI:
  ```bash
  python query_knowledge_graph.py --interactive
  ```
- Actions include:
  - `list repos`, `list classes in <repo>`, `list functions in <repo>`
  - `show class <ClassName>`, `show function <FunctionName>`
  - `search <term>`
  - `help` for command list

**Tips:**

- Use exact names for best results
- Data must be present in the graph to be found

---

### **4. Enhancing Knowledge Graphs with LLMs**

- Enrich code structure in Neo4j with LLM-generated summaries, tags, and relationships using:
  ```bash
  python ollama_knowledge_extractor.py /path/to/repo
  ```
- **Note:**  
  By default, only Python code is supported (customize for other languages)

---

## ⚠️ What Not To Do

- ❌ **Do NOT** set or use OpenAI API keys unless you have re-enabled cloud features
- ❌ **Do NOT** set `OLLAMA_URL` to `localhost` from inside containers—use `host.docker.internal`
- ❌ **Do NOT** leave unused variables in `.env`
- ❌ **Do NOT** expect the system to work on codebases you haven’t loaded into the graph

---

## ⚡ Tool Reference

### Core Tools (Always Available)

| Tool Name                        | What it Does                                                          | Usage Example                                   |
| -------------------------------- | --------------------------------------------------------------------- | ----------------------------------------------- |
| `crawl_single_page`              | Crawl a single web page and store its content                         | _See API/CLI_                                   |
| `smart_crawl_url`                | Intelligently crawl websites (sitemap/docs/recursive)                 | _See API/CLI_                                   |
| `get_available_sources`          | List all crawled sources (domains/repos)                              | _See API/CLI_                                   |
| `perform_rag_query`              | Semantic search with optional source filtering and reranking          | _See API/CLI_                                   |
| `parse_github_repository`        | Parse a GitHub repo into a Neo4j knowledge graph                      | _See API/CLI or scripts_                        |
| `check_ai_script_hallucinations` | Validate AI-generated Python code against repository knowledge graphs | `python ai_hallucination_detector.py script.py` |
| `query_knowledge_graph`          | Interactive CLI for exploring the knowledge graph                     | `python query_knowledge_graph.py --interactive` |
| `ollama_knowledge_extractor.py`  | Enhance graph nodes with LLM-generated summaries/tags/relationships   | `python ollama_knowledge_extractor.py repo_dir` |

---

## 🧩 RAG and Knowledge Graph Strategies

- **Contextual Embeddings:** For richer semantic search
- **Hybrid Search:** Combines vector and keyword retrieval
- **Agentic RAG:** Specialized code example extraction
- **Reranking:** Improve result relevance using cross-encoders
- **Knowledge Graph Integration:** For code validation and hallucination detection

Configure strategies via `.env`:

```env
USE_CONTEXTUAL_EMBEDDINGS=true
USE_HYBRID_SEARCH=true
USE_AGENTIC_RAG=false
USE_RERANKING=true
USE_KNOWLEDGE_GRAPH=true
```

---

## 🏗️ Architecture & Setup (Brief)

- **All services run in Docker Compose** (`docker compose up -d`)
- **Local LLMs/embeddings:**  
  Set `MODEL_CHOICE` and `LOCAL_EMBEDDING_MODEL` in `.env`
- **Neo4j & Supabase:**  
  Configurable via `.env`, run as containers by default
- **No OpenAI or Qdrant unless explicitly configured**

---

## 📝 Contributing & Advanced Info

- Fork, branch, and submit PRs with clear descriptions
- Add tests and update docs for new features
- For advanced queries or integration, see code comments and scripts in `knowledge_graphs/` and `src/`

---

## 🙏 Acknowledgments

- **Original Project:** [coleam00/mcp-crawl4ai-rag](https://github.com/coleam00/mcp-crawl4ai-rag)
- **Crawl4AI, Supabase, Neo4j, Ollama** for foundational tech
- **Local-AI-Packaged Ecosystem** for seamless LLM/embedding integration

---

**🚀 Ready to build safer, smarter AI with local-first RAG and knowledge graphs?**  
Get started today!
