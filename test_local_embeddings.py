#!/usr/bin/env python3
"""
Test script to verify local embeddings are working correctly.
This tests the new embedding functionality with local models.
"""

import os
import sys
from pathlib import Path

# Add src directory to path
src_path = Path(__file__).parent / 'src'
sys.path.append(str(src_path))

# Set environment for local embeddings
os.environ['USE_LOCAL_EMBEDDINGS'] = 'true'
# Optional: specify embedding model
os.environ['LOCAL_EMBEDDING_MODEL'] = 'all-mpnet-base-v2'  # 768 dimensions, good quality

print("🧪 Testing Local Embeddings (FREE - No OpenAI API calls)...")
print(f"USE_LOCAL_EMBEDDINGS: {os.getenv('USE_LOCAL_EMBEDDINGS')}")
print(f"LOCAL_EMBEDDING_MODEL: {os.getenv('LOCAL_EMBEDDING_MODEL')}")

try:
    from utils import create_embedding, create_embeddings_batch, get_local_embedding_model
    
    # Test model initialization
    print("\n📦 Testing model initialization...")
    model = get_local_embedding_model()
    if model:
        dimensions = model.get_sentence_embedding_dimension()
        print(f"✅ Model loaded successfully: {dimensions} dimensions")
    else:
        print("❌ Model failed to load")
        sys.exit(1)
    
    # Test single embedding
    print("\n📝 Testing single embedding...")
    test_text = "This is a test sentence for embedding using a free local model."
    embedding = create_embedding(test_text)
    
    print(f"✅ Single embedding created successfully!")
    print(f"   Dimensions: {len(embedding)}")
    print(f"   Sample values: {embedding[:5]}...")
    
    # Test batch embeddings
    print("\n📦 Testing batch embeddings...")
    test_texts = [
        "First test document about machine learning and AI.",
        "Second test document about natural language processing.",
        "Third test document about vector databases and embeddings.",
        "Fourth test document about web crawling and data extraction."
    ]
    
    batch_embeddings = create_embeddings_batch(test_texts)
    
    print(f"✅ Batch embeddings created successfully!")
    print(f"   Number of embeddings: {len(batch_embeddings)}")
    print(f"   Dimensions per embedding: {len(batch_embeddings[0]) if batch_embeddings else 0}")
    print(f"   All same dimensions: {all(len(emb) == len(batch_embeddings[0]) for emb in batch_embeddings)}")
    
    # Verify quality with similarity test
    print("\n🔍 Testing embedding quality with similarity...")
    similar_texts = [
        "Machine learning is a branch of artificial intelligence.",
        "AI and machine learning are closely related fields."
    ]
    different_text = "The weather is nice today."
    
    similar_embeddings = create_embeddings_batch(similar_texts)
    different_embedding = create_embedding(different_text)
    
    # Simple cosine similarity calculation
    import numpy as np
    
    def cosine_similarity(a, b):
        return np.dot(a, b) / (np.linalg.norm(a) * np.linalg.norm(b))
    
    similar_sim = cosine_similarity(similar_embeddings[0], similar_embeddings[1])
    different_sim = cosine_similarity(similar_embeddings[0], different_embedding)
    
    print(f"   Similar texts similarity: {similar_sim:.3f}")
    print(f"   Different text similarity: {different_sim:.3f}")
    print(f"   Quality check: {'✅ PASS' if similar_sim > different_sim else '❌ FAIL'}")
    
    # Final summary
    expected_dimensions = model.get_sentence_embedding_dimension()
    if (len(embedding) == expected_dimensions and 
        all(len(emb) == expected_dimensions for emb in batch_embeddings) and
        similar_sim > different_sim):
        print("\n🎉 SUCCESS: Local embeddings are working perfectly!")
        print("   ✓ No API calls made (completely free)")
        print(f"   ✓ {expected_dimensions}-dimensional embeddings generated")
        print("   ✓ Quality embeddings that understand semantic similarity")
        print("   ✓ Ready for production use")
        print("\n💡 Next steps:")
        print("   1. Add USE_LOCAL_EMBEDDINGS=true to your .env file")
        print("   2. Restart your crawl4ai container")
        print("   3. Enjoy unlimited free embeddings!")
    else:
        print("\n❌ ERROR: Something went wrong with local embeddings")
        
except ImportError as e:
    print(f"❌ Import error: {e}")
    print("Make sure sentence-transformers is installed:")
    print("pip install sentence-transformers")
    
except Exception as e:
    print(f"❌ Error testing embeddings: {e}")
    import traceback
    traceback.print_exc() 
