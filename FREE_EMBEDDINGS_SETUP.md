# FREE Local Embeddings Setup

This guide will help you switch from OpenAI embeddings to **completely free** local embeddings to avoid rate limiting.

## 🎯 What This Solves

- ✅ **No More Rate Limits**: Unlimited embeddings without API calls
- ✅ **No More API Costs**: Completely free to run
- ✅ **Better Privacy**: Your data never leaves your machine
- ✅ **Faster Processing**: No network latency for embeddings
- ✅ **High Quality**: Uses state-of-the-art sentence-transformers models

## 🚀 Quick Setup

### 1. Update Your .env File

Add these lines to your `.env` file:

```bash
# Keep your OpenAI key for other features if needed
OPENAI_API_KEY=your_key_here

# Enable free local embeddings
USE_LOCAL_EMBEDDINGS=true

# Optional: Choose your embedding model (default: all-mpnet-base-v2)
LOCAL_EMBEDDING_MODEL=all-mpnet-base-v2
```

### 2. Restart Your Container

Use the restart script:

```bash
./restart_crawl4ai.sh
```

### 3. Test It Works

The container will download the embedding model on first use. You'll see:

```
🔄 Initializing local embedding model (all-mpnet-base-v2)...
✅ Local embedding model loaded successfully (768 dimensions)
```

## 📊 Model Options

Choose the best model for your needs:

| Model                        | Dimensions | Quality    | Size   | Best For                       |
| ---------------------------- | ---------- | ---------- | ------ | ------------------------------ |
| `all-mpnet-base-v2`          | 768        | ⭐⭐⭐⭐⭐ | ~400MB | **Recommended** - Best balance |
| `all-MiniLM-L6-v2`           | 384        | ⭐⭐⭐     | ~90MB  | Fast & lightweight             |
| `all-MiniLM-L12-v2`          | 384        | ⭐⭐⭐⭐   | ~130MB | Good quality, smaller          |
| `multi-qa-mpnet-base-dot-v1` | 768        | ⭐⭐⭐⭐⭐ | ~400MB | Excellent for Q&A              |

## 🔧 Configuration

### Environment Variables

```bash
# Required
USE_LOCAL_EMBEDDINGS=true

# Optional
LOCAL_EMBEDDING_MODEL=all-mpnet-base-v2 # Default model
USE_KNOWLEDGE_GRAPH=true                # Enable knowledge graph features
```

### Switching Models

To change models, update your `.env` file and restart:

```bash
# For faster, smaller embeddings
LOCAL_EMBEDDING_MODEL=all-MiniLM-L6-v2

# For Q&A focused embeddings
LOCAL_EMBEDDING_MODEL=multi-qa-mpnet-base-dot-v1
```

## 🎯 Dimension Compatibility

The new implementation automatically handles dimensions:

- **Local Models**: Various dimensions (384, 768, etc.)
- **OpenAI Models**: 1536 dimensions
- **Automatic Fallback**: Correct zero embeddings for errors

## 🧪 Testing

Test your setup with the provided test script:

```bash
# Test local embeddings
python3 test_local_embeddings.py
```

Expected output:

```
🎉 SUCCESS: Local embeddings are working perfectly!
   ✓ No API calls made (completely free)
   ✓ 768-dimensional embeddings generated
   ✓ Quality embeddings that understand semantic similarity
   ✓ Ready for production use
```

## 🚀 Usage

Once configured, everything works exactly the same:

```bash
# Crawl with free embeddings
./restart_crawl4ai.sh

# Use any MCP tool - embeddings are now free!
```

## 🔄 Switching Back to OpenAI

If you want to switch back to OpenAI embeddings:

```bash
# In your .env file
USE_LOCAL_EMBEDDINGS=false
# or remove the line entirely

# Restart container
./restart_crawl4ai.sh
```

## 🛠 Troubleshooting

### Model Download Issues

If model download fails:

1. Check internet connection
2. Restart container
3. Model will retry download automatically

### Dimension Errors

If you get dimension errors:

1. Clear your Supabase data
2. Restart with consistent embedding model
3. Re-crawl your content

### Memory Issues

For low-memory systems:

```bash
# Use smaller model
LOCAL_EMBEDDING_MODEL=all-MiniLM-L6-v2
```

## 🎉 Benefits

### Cost Savings

- **OpenAI**: $0.02 per 1M tokens (~$20-50/month for heavy usage)
- **Local**: $0.00 forever ✅

### Performance

- **OpenAI**: Network latency + rate limits
- **Local**: Instant processing ✅

### Privacy

- **OpenAI**: Data sent to external API
- **Local**: Data never leaves your machine ✅

### Availability

- **OpenAI**: Dependent on API availability
- **Local**: Works offline ✅

## 📚 Technical Details

### Model Architecture

The local models use transformer-based architectures similar to BERT/RoBERTa, optimized for sentence-level embeddings.

### Quality Comparison

Local models like `all-mpnet-base-v2` often perform as well as or better than OpenAI's models on sentence similarity tasks.

### Resource Usage

- **RAM**: ~1-2GB for model + processing
- **CPU**: Efficient inference, scales with batch size
- **Storage**: ~400MB per model (downloaded once)

## 🔗 Next Steps

1. ✅ Switch to local embeddings
2. ✅ Test with your typical workload
3. ✅ Enjoy unlimited free embeddings!
4. ✅ Crawl your auto-sbm repository without limits

---

**Ready to go unlimited?** Just add `USE_LOCAL_EMBEDDINGS=true` to your `.env` file and restart! 🚀
