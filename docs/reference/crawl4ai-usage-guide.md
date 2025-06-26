# Crawl4AI – Robust, Unambiguous Usage Guide

## 1. Purpose

Crawl4AI is a local-first, containerized Retrieval-Augmented Generation (RAG) and Knowledge Graph platform for crawling, analyzing, and validating code and web content using local LLMs (via Ollama), Neo4j, and Supabase.  
**This guide provides clear, step-by-step rules for correct usage, as well as explicit anti-patterns and caveats.**

---

## 2. How to Use Crawl4AI

### 2.1. Initial Setup

1. **Clone the repository and prepare your `.env` file:**

   - Copy `.env.example` to `.env` and edit as needed (see project README).
   - Set only the variables your stack actually uses:
     - `MODEL_CHOICE` (e.g., `qwen2.5:7b-instruct-q4_K_M`)
     - `LOCAL_EMBEDDING_MODEL` (e.g., `nomic-embed-text:latest`)
     - `OLLAMA_URL` (`http://host.docker.internal:11434` if using Docker)
     - `USE_LOCAL_EMBEDDINGS=true`
     - Credentials for Neo4j, Supabase/Postgres, etc.

2. **Pull required models (if not already):**

   ```bash
   docker compose run --rm ollama-pull-models-cpu
   ```

   - Or for GPU:  
     `docker compose run --rm ollama-pull-models-gpu`

3. **Start all services:**
   ```bash
   docker compose down
   docker compose up -d
   ```
   - Always restart services after `.env` changes.

---

### 2.2. Running Core Features

**A. Crawl a website or repo**

- Run the crawl server:
  ```bash
  python crawl4ai_mcp.py
  ```
- Specify your crawl targets (URL, repo, etc.) as per CLI or API instructions.

**B. Analyze AI-generated scripts for hallucinations**

- Run:
  ```bash
  python ai_hallucination_detector.py your_script.py
  ```

**C. Query the knowledge graph**

- Interactive mode:
  ```bash
  python query_knowledge_graph.py --interactive
  ```

**D. Enhance the knowledge graph with LLM insights**

- Use the `ollama_knowledge_extractor.py` script:
  ```bash
  python ollama_knowledge_extractor.py path/to/repo
  ```

---

### 2.3. Model and Embedding Selection

- To change the LLM or embedding model, edit `.env`:
  ```env
  MODEL_CHOICE=qwen2.5:7b-instruct-q4_K_M
  LOCAL_EMBEDDING_MODEL=nomic-embed-text:latest
  ```
- Then restart services (`docker compose down && docker compose up -d`).

---

### 2.4. Resetting / Troubleshooting

- **Restart stack after changes:**
  ```bash
  docker compose down
  docker compose up -d
  ```
- **To fully reset data (DANGER: removes all volumes!):**
  ```bash
  docker volume prune
  ```
- **Tail logs:**
  ```bash
  docker compose logs -f
  ```

---

## 3. What NOT To Do

### ❌ Never...

1. **Do NOT set or use OpenAI API keys**  
   (unless you have re-enabled OpenAI-specific features, which are off by default).

2. **Do NOT set Qdrant variables or use Qdrant endpoints**  
   (unless you have explicitly enabled Qdrant as your vector DB).

3. **Do NOT point `OLLAMA_URL` to `localhost`**  
   from inside a Docker container; always use `http://host.docker.internal:11434`.

4. **Do NOT edit Docker Compose files to expose ports to the public internet without security controls.**

5. **Do NOT use `.env` variables that are not actually read by your current codebase.**  
   (Keep your `.env` minimal and clear.)

6. **Do NOT run `docker compose up` without first pulling required models if this is your first setup.**

7. **Do NOT expect OpenAI or cloud models to be used:**  
   All RAG, summarization, and validation is local unless you change the stack.

---

## 4. Best Practices

- **Always keep `.env` and Docker Compose in sync with your desired stack.**
- **Document all changes to your model or embedding configuration.**
- **Regularly prune unused models from Ollama storage if disk space is a concern.**
- **Use `host.docker.internal` for all host-to-container connections.**
- **When in doubt, restart the stack after configuration changes.**
- **Monitor logs for errors and confirm the correct models are loaded on startup.**

---

## 5. Advanced/Edge Cases

- **If running outside Docker**, set `OLLAMA_URL=http://localhost:11434`.
- **To use a GPU, switch to the appropriate Ollama service/profile and ensure drivers are installed.**
- **For multi-repo or multi-language RAG, modularize the extractor logic (see code comments).**
- **If adding cloud providers back, update both `.env` and code—this is not supported by default.**

---

## 6. Summary Table

| Task                  | Command/Action                                   | Key Variables/Notes                 |
| --------------------- | ------------------------------------------------ | ----------------------------------- |
| Setup                 | `cp .env.example .env` + edit                    | Only keep needed vars               |
| Pull models           | `docker compose run --rm ollama-pull-models-cpu` | Must match `.env` models            |
| Start services        | `docker compose up -d`                           | Always restart after config changes |
| Crawl                 | `python crawl4ai_mcp.py ...`                     | Uses local LLMs + embeddings        |
| Hallucination detect  | `python ai_hallucination_detector.py ...`        | Uses Neo4j and Ollama               |
| Query knowledge graph | `python query_knowledge_graph.py --interactive`  | Neo4j must be running               |
| Logs                  | `docker compose logs -f`                         | Check for errors, model loads       |
| Reset all             | `docker compose down && docker compose up -d`    | Full stack restart                  |

---

## 7. LLM-friendly Summary

- **Always use local models (Ollama) and local embeddings.**
- **Never reference disabled or deprecated cloud endpoints.**
- **Always set `OLLAMA_URL` to `host.docker.internal` when using Docker.**
- **Restart services after changes to `.env` or models.**
- **Keep configuration minimal and in sync.**
- **Monitor logs for confirmation of correct model loading.**
- **Use project scripts as documented above; avoid ad-hoc changes.**

---

**If you follow these rules, Crawl4AI will work reliably, privately, and efficiently.**
