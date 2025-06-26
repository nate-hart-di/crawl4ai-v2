# Crawl4AI – Tool Usage & Best-Practice Guide

## 1. Crawl4AI Tooling Overview

Crawl4AI provides a suite of tools for crawling, parsing, analyzing, and validating content (websites, code repositories, scripts) using local language models, knowledge graphs, and RAG strategies.

**This document is for:**

- Step-by-step usage instructions for each tool.
- Explicit “what not to do” guidance.
- Contextual considerations for each workflow.

---

## 2. Core Tool Workflows

### A. Crawling & Parsing Web or GitHub Repositories

**Purpose:**  
Discover, index, and ingest content for downstream RAG, search, and validation.

#### How to Use:

- Initiate a crawl specifying a target (web URL or GitHub repo).
- The system will:
  1. Detect the optimal crawl strategy (sitemap, robots.txt, direct page traversal, or repo tree scan).
  2. Respect rate limits and robots.txt rules (where applicable).
  3. Parse and store content, extracting code, documentation, and metadata.

#### Considerations / Best Practices:

- For GitHub repos, always use the HTTPS clone URL (e.g., `https://github.com/owner/repo.git`).
- For crawling websites, ensure you have permission to crawl and you are not violating robots.txt or TOS.
- Large repos or sites may take significant time and resources to crawl—monitor logs for progress.
- Only crawl what you need; avoid over-crawling large, irrelevant, or third-party content.

#### What NOT to Do:

- ❌ Do not use SSH clone URLs unless your environment is configured for SSH keys.
- ❌ Do not attempt to crawl private repos without proper credentials.
- ❌ Do not crawl sites in violation of their terms or robots.txt.

---

### B. Script Analysis & Hallucination Detection

**Purpose:**  
Validate AI-generated Python scripts for hallucinated (non-existent or misused) imports, classes, methods, attributes, or functions using the knowledge graph.

#### How to Use:

- Provide the script file path to the analysis tool.
- The tool will:
  1. Parse the script’s structure (imports, classes, methods, etc.) using AST.
  2. Cross-reference every usage against the Neo4j knowledge graph.
  3. Report any potential hallucinations or mismatches with detailed context.

#### Considerations / Best Practices:

- Use on scripts targeting codebases that are already present in your knowledge graph for best results.
- Review the generated report—items marked “not found” or “invalid” are candidates for hallucination.
- Regularly update your knowledge graph with the latest repositories for high validation coverage.

#### What NOT to Do:

- ❌ Don’t analyze scripts for libraries or frameworks not represented in your graph—the tool will mark these as “uncertain” or “external.”
- ❌ Don’t ignore warnings about missing dependencies—ensure your analysis environment matches the code’s requirements.

---

### C. Knowledge Graph Querying

**Purpose:**  
Explore what’s actually stored in Neo4j: repositories, classes, functions, relationships.

#### How to Use:

- Use the interactive query tool or CLI to:
  - List repositories, classes, or functions.
  - Drill down into specific classes (methods/attributes).
  - Search for specific code elements or relationships.

#### Considerations / Best Practices:

- Use specific class or method names for most accurate results.
- Combine queries to explore relationships (e.g., “list all methods of class X in repo Y”).

#### What NOT to Do:

- ❌ Don’t expect accurate results for code/repos not loaded into the graph.
- ❌ Don’t run expensive, unfiltered graph traversals on large graphs—this may cause performance issues.

---

### D. Ollama Knowledge Extraction

**Purpose:**  
Enhance the knowledge graph with semantic metadata (purpose, relationships, complexity) extracted by local LLMs.

#### How to Use:

- Point the extractor at a local code repository.
- The tool will:
  1. Parse all Python files.
  2. Use the configured LLM to generate summaries, tags, and dependency graphs for classes and functions.
  3. Store these insights back into Neo4j.

#### Considerations / Best Practices:

- Ensure your `MODEL_CHOICE` and `OLLAMA_URL` are correctly set in your environment.
- Only run on code you own or have permission to analyze.
- Use for understanding/refactoring legacy code, exploring new projects, or enhancing RAG retrieval.

#### What NOT to Do:

- ❌ Don’t use the extractor on non-Python code without customizing the tool.
- ❌ Don’t expect perfect results on obfuscated or minified code.

---

## 3. General “What Not To Do” (Anti-patterns)

- ❌ Never use cloud endpoints (OpenAI, Qdrant, etc.) unless you have explicitly enabled and configured them—this project is local-first by default.
- ❌ Never use `localhost` as the Ollama host from inside Docker; always use `host.docker.internal`.
- ❌ Don’t leave unnecessary or unused variables in your `.env`—they may cause confusion.
- ❌ Don’t run multiple conflicting model pulls or crawls at once on the same data.

---

## 4. LLM-Friendly Digest

- **Crawl only what you need; use proper URLs; obey robots.txt.**
- **Analyze scripts only for codebases in your knowledge graph.**
- **Query the graph for data you know is present; avoid unbounded queries.**
- **Enhance with Ollama for code you can legally analyze; Python-only by default.**
- **Keep environment variables minimal and correct for your stack.**
- **Never assume cloud APIs are active unless explicitly configured.**

---
