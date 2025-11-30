# RAG Implementation Guide

## Overview

This document explains how RAG (Retrieval-Augmented Generation) is implemented in the knowledge base agent.

## What is RAG?

RAG combines:
1. **Retrieval**: Finding relevant documents/posts using semantic search
2. **Augmentation**: Using retrieved content as context
3. **Generation**: LLM generates answers based on retrieved context

## Implementation Details

### 1. Vector Embeddings

**Location**: `knowledge_base_agent.py` - `KnowledgeBase` class

**How it works**:

```python
# Initialize embedding model using LangChain
from langchain_community.embeddings import HuggingFaceEmbeddings
from langchain_community.vectorstores import FAISS
from langchain_core.documents import Document

self.embeddings = HuggingFaceEmbeddings(
    model_name='all-MiniLM-L6-v2',
    model_kwargs={'device': 'cpu'}
)

# Create document and add to vector store
text = f"{post.title}. {post.content}"
doc = Document(
    page_content=text,
    metadata={'post_id': post.id, 'title': post.title}
)
# Vector store is created from all documents
self.vector_store = FAISS.from_documents([doc], self.embeddings)
```

**What happens**:
- Each post (title + content) is converted to a vector (embedding)
- Embeddings capture semantic meaning, not just keywords
- Similar meanings have similar vectors

### 2. Semantic Search

**Location**: `_search_with_rag()` method

**How it works**:

```python
# 1. Use FAISS similarity search
docs_with_scores = self.vector_store.similarity_search_with_score(query, k=top_k)

# 2. Extract post information from results
for doc, score in docs_with_scores:
    post_id = doc.metadata.get('post_id')
    # Convert distance to similarity score
    similarity_score = 1.0 / (1.0 + float(score))

# 3. Return top-k most similar posts
```

**What happens**:
- Query is converted to embedding
- Cosine similarity finds semantically similar posts
- Returns posts with highest similarity scores

### 3. RAG Flow

```
User Query
    ↓
Generate Query Embedding
    ↓
Calculate Similarity with All Posts
    ↓
Retrieve Top-K Most Relevant Posts
    ↓
Pass to LLM as Context
    ↓
LLM Generates Answer
```

### 4. Integration with ADK Agent

**Location**: `search_knowledge_base()` function

**How it works**:

1. User asks question via ADK agent
2. Agent calls `search_knowledge_base()` tool
3. Tool uses RAG to find relevant posts
4. Agent receives search results
5. Agent generates answer using retrieved context

## Key Components

### KnowledgeBase Class

- **`__init__()`**: Initializes embedding model
- **`_generate_all_embeddings()`**: Generates embeddings for all posts
- **`_add_post_to_vector_store()`**: Adds single post to vector store
- **`search_posts()`**: Main search method (RAG or keyword)
- **`_search_with_rag()`**: RAG-based semantic search
- **`_search_with_keywords()`**: Fallback keyword search

### Search Flow

```python
# User query
query = "How to use Python virtual environment?"

# RAG search
results = knowledge_base.search_posts(query, top_k=3)

# Results contain:
# - post_id: Article ID
# - title: Article title
# - relevance_score: Similarity score (0-1)
# - matched_content: Relevant snippet
# - reason: Why it's relevant
```

## Advantages of RAG

1. **Semantic Understanding**
   - Understands meaning, not just keywords
   - Handles synonyms and related concepts

2. **Better Search Quality**
   - Finds relevant content even without exact keyword matches
   - Handles paraphrased queries

3. **English Language Support**
   - Uses English-optimized embedding model
   - Optimized for English text processing

## Fallback Mechanism

If `LangChain` is not installed, the system automatically falls back to keyword matching:

```python
if self.use_rag and self.vector_store:
    return self._search_with_rag(query, top_k)
else:
    return self._search_with_keywords(query, top_k)
```

## Installation

```bash
pip install langchain>=0.1.0 langchain-community>=0.0.20 numpy>=1.24.0 faiss-cpu>=1.7.4
```

**Note**: `HuggingFaceEmbeddings` may install `sentence-transformers` as a dependency, but LangChain provides a cleaner interface and better vector store management with FAISS.

## Usage Example

```python
from knowledge_base_agent import KnowledgeBase, search_knowledge_base

# Knowledge base automatically uses RAG if available
kb = KnowledgeBase(use_rag=True)

# Search using RAG
results = search_knowledge_base("How to use Python virtual environment?", top_k=3)

# Results are semantically relevant
for result in results['results']:
    print(f"Title: {result['title']}")
    print(f"Similarity: {result['relevance_score']:.3f}")
    print(f"Reason: {result['reason']}")
```

## Future Improvements

1. **Chunking**
   - Split long posts into chunks
   - Search at chunk level
   - More precise retrieval

2. **Vector Database**
   - Use Chroma, Pinecone, or Vertex AI Vector Search
   - Better scalability
   - Persistent storage

3. **Hybrid Search**
   - Combine semantic and keyword search
   - Weighted scoring

4. **Re-ranking**
   - Use cross-encoder for better ranking
   - Improve top-k results

## Summary

The RAG implementation provides:
- Semantic search capabilities
- Better query understanding
- English language support
- Automatic fallback to keyword matching
