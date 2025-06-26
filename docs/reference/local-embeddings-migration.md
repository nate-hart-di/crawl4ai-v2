# Local Embeddings Migration Guide

## Overview

This document outlines the complete migration from OpenAI embeddings to local embedding models in the crawl4ai-v2 project. The migration ensures complete privacy, eliminates API costs, and provides better control over the embedding process.

## Migration Summary

### What Changed

1. **Removed OpenAI Embedding Dependencies**: All OpenAI embedding API calls have been replaced with local alternatives
2. **Dual Local Embedding Support**: Support for both Ollama HTTP API and sentence-transformers library
3. **Automatic Fallback**: Ollama embeddings with sentence-transformers fallback for reliability
4. **Local LLM Integration**: All text generation now uses local Ollama models
5. **Environment Cleanup**: Removed OpenAI API key requirements and simplified configuration

### Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Text Input    │───▶│  Ollama HTTP API │───▶│  Vector Store   │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                │
                                ▼ (fallback)
                       ┌──────────────────┐
                       │ Sentence-Trans.  │
                       └──────────────────┘
```

## Environment Configuration

### Required Environment Variables

```bash
# Local embedding configuration
USE_LOCAL_EMBEDDINGS=true
LOCAL_EMBEDDING_MODEL=nomic-embed-text:latest
MODEL_CHOICE=qwen2.5:7b-instruct-q4_K_M
OLLAMA_URL=http://host.docker.internal:11434

# Database configuration
SUPABASE_URL=http://localhost:8000
SUPABASE_SERVICE_KEY=your_service_key
NEO4J_URI=bolt://neo4j:7687
NEO4J_USER=neo4j
NEO4J_PASSWORD=your_password
```

### Removed Variables

The following OpenAI-related variables are **no longer needed**:

```bash
# ❌ REMOVED - No longer required
OPENAI_API_KEY=...
USE_LOCAL_EMBEDDINGS=false # Now defaults to true
```

## Implementation Details

### Primary Embedding Method: Ollama HTTP API

The system now primarily uses Ollama's HTTP API for embeddings:

```python
def _create_ollama_embeddings_batch(texts: List[str]) -> List[List[float]]:
    """Create embeddings using Ollama HTTP API."""
    ollama_url, model_name = get_ollama_embedding_model()

    for text in texts:
        response = requests.post(
            f"{ollama_url}/api/embeddings",
            json={
                "model": model_name,
                "prompt": text
            },
            timeout=30
        )
        # Process response...
```

### Fallback Method: Sentence Transformers

If Ollama fails, the system falls back to sentence-transformers:

```python
def _create_local_embeddings_batch(texts: List[str]) -> List[List[float]]:
    """Create embeddings using local sentence-transformers model."""
    model = get_local_embedding_model()
    embeddings = model.encode(texts, normalize_embeddings=True)
    return [emb.tolist() for emb in embeddings]
```

### Local LLM Integration

All text generation (contextual embeddings, summaries, etc.) now uses Ollama:

```python
def generate_contextual_embedding(full_document: str, chunk: str) -> Tuple[str, bool]:
    """Generate contextual information using local Ollama LLM."""
    response = requests.post(
        f"{ollama_url}/api/generate",
        json={
            "model": model_choice,
            "prompt": prompt,
            "stream": False,
            "options": {
                "temperature": 0.3,
                "num_predict": 200
            }
        },
        timeout=60
    )
```

## Model Configuration

### Supported Embedding Models

| Model                     | Dimensions | Use Case                     |
| ------------------------- | ---------- | ---------------------------- |
| `nomic-embed-text:latest` | 768        | General purpose, recommended |
| `all-MiniLM-L6-v2`        | 384        | Lightweight, faster          |
| `all-mpnet-base-v2`       | 768        | High quality, slower         |

### Supported LLM Models

| Model                         | Size | Use Case            |
| ----------------------------- | ---- | ------------------- |
| `qwen2.5:7b-instruct-q4_K_M`  | ~4GB | Recommended balance |
| `llama3.2:3b-instruct-q4_K_M` | ~2GB | Lightweight         |
| `mistral:7b-instruct-q4_K_M`  | ~4GB | Alternative option  |

## Migration Benefits

### Privacy & Security

- ✅ **No data leaves your infrastructure**
- ✅ **No API keys required**
- ✅ **Complete control over models and data**

### Cost Efficiency

- ✅ **Zero API costs**
- ✅ **Predictable resource usage**
- ✅ **One-time model download**

### Performance

- ✅ **No network latency for API calls**
- ✅ **Consistent availability**
- ✅ **Customizable model selection**

### Reliability

- ✅ **Automatic fallback mechanisms**
- ✅ **No rate limiting**
- ✅ **Offline capability**

## Troubleshooting

### Common Issues

#### 1. Ollama Connection Failed

```bash
❌ Ollama embedding failed: Connection refused
```

**Solution**: Ensure Ollama is running and accessible:

```bash
# Check if Ollama is running
curl http://host.docker.internal:11434/api/tags

# Pull required models
docker compose run --rm ollama-pull-models-cpu
```

#### 2. Model Not Found

```bash
❌ Ollama API error: 404
```

**Solution**: Pull the required embedding model:

```bash
# From host machine
ollama pull nomic-embed-text:latest

# Or from Docker
docker exec ollama ollama pull nomic-embed-text:latest
```

#### 3. Sentence Transformers Fallback

```bash
❌ sentence-transformers not available
```

**Solution**: Install sentence-transformers:

```bash
pip install sentence-transformers
```

#### 4. Dimension Mismatch

```bash
❌ Embedding dimension mismatch
```

**Solution**: Ensure consistent model usage and clear existing embeddings if changing models.

## Verification

### Test Local Embeddings

```python
from src.utils import create_embedding

# Test embedding creation
embedding = create_embedding("Hello world")
print(f"Embedding dimensions: {len(embedding)}")
print(f"First 5 values: {embedding[:5]}")
```

### Verify Configuration

```bash
# Check environment variables
echo $USE_LOCAL_EMBEDDINGS  # Should be 'true'
echo $LOCAL_EMBEDDING_MODEL # Should be 'nomic-embed-text:latest'
echo $OLLAMA_URL            # Should be 'http://host.docker.internal:11434'

# Test Ollama connectivity
curl $OLLAMA_URL/api/tags
```

## Performance Optimization

### Memory Usage

- **Ollama**: Uses shared model cache across requests
- **Sentence-transformers**: Loads model once, reuses globally

### Batch Processing

- Optimized for batch embedding creation
- Automatic retry logic with exponential backoff
- Parallel processing where possible

### Caching

- Models are cached in memory after first load
- Ollama maintains its own model cache
- Zero embedding fallbacks for failed requests

## Future Considerations

### Model Updates

- Models can be updated by changing `LOCAL_EMBEDDING_MODEL`
- Restart services after model changes
- Consider re-embedding existing data for consistency

### Scaling

- Ollama can be scaled horizontally
- Consider GPU acceleration for large workloads
- Monitor memory usage with multiple concurrent requests

### Integration

- Easy to add new embedding models
- Extensible architecture for different backends
- Maintains compatibility with existing vector stores

---

**Note**: This migration ensures your crawl4ai-v2 project is completely self-contained and private. No external API calls are made for embeddings or text generation.
