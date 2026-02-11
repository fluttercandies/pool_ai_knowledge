---
tags: RAG,FAISS,vector-search,AI-technology
language: en
---

## What is RAG?

**RAG (Retrieval-Augmented Generation)** is a paradigm that combines information retrieval with Large Language Models (LLMs). It addresses two core limitations of standalone LLMs:

1. **Knowledge Staleness**: LLM training data has a cutoff date and cannot access recent information
2. **Hallucination**: LLMs may generate plausible-sounding but factually incorrect content

### How RAG Works

```
User Query
   ↓
① Vectorize the query (Embedding)
   ↓
② Retrieve relevant documents from vector store (FAISS)
   ↓
③ Inject retrieved context into the prompt
   ↓
④ LLM generates an answer based on context (Gemini)
   ↓
Return to user
```

### Implementation in Pool AI Knowledge

Here is how the RAG pipeline works in this project:

#### Document Embedding Phase

```python
# Each article is converted to text: "title. content"
# OpenAI text-embedding-ada-002 generates the embedding vector
# Vectors are stored in an in-memory FAISS index
```

- Embedding dimensions: 1536
- Index type: FAISS IndexFlatL2 (exact L2 distance search)
- Trigger: Full rebuild on startup; incremental updates on article changes

#### Retrieval Phase

- The user query is also embedded into a vector
- FAISS performs top-k nearest neighbor search (default k=3)
- Returns the most relevant article content

#### Generation Phase

- Retrieved document content is injected into the Gemini Agent prompt
- The agent generates structured, accurate answers based on context
- If no relevant content exists, the agent honestly informs the user

### Why FAISS?

| Feature | FAISS | Traditional DB |
|---------|-------|----------------|
| Search Method | Semantic similarity | Keyword matching |
| Speed | Milliseconds (in-memory) | Depends on index |
| Understanding | Understands meaning & intent | Literal matching only |
| Best For | Q&A, recommendations | Exact queries |

### Best Practices

1. **Content Quality**: More detailed, well-structured articles yield better retrieval
2. **Proper Segmentation**: Split long documents into focused, topic-specific articles
3. **Language Separation**: Tag content with the appropriate language label
4. **Regular Updates**: Keep your knowledge base current and accurate
