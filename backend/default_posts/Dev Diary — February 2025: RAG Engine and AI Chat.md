---
tags: dev-diary,RAG,AI-chat,FAISS
language: en
---

## February 2025 — RAG Engine and AI Chat

### February 3 — OpenAI Embedding Integration

Today we integrated OpenAI's `text-embedding-ada-002` model for generating text vectors. Each article is formatted as `"title. content"` before being sent to the model, producing a 1536-dimensional vector.

Tested the results — semantic understanding is far superior to keyword search. For example, searching "how to deploy" can find articles titled "Installation Guide".

### February 10 — FAISS Vector Index

Integrated FAISS using `IndexFlatL2` for exact L2 distance search. With our current article volume, exact search is more than sufficient.

The workflow:
1. On server startup, load all articles from MySQL
2. Batch-generate embedding vectors
3. Store in FAISS in-memory index
4. On query, generate query embedding and perform top-k nearest neighbor search

Found an issue: the vector index wasn't syncing after article updates. Added a trigger mechanism to automatically rebuild the index on article create/update/delete.

### February 17 — Google Gemini Agent Chat

Integrated Google ADK (Agent Development Kit) and created the knowledge base Agent. How it works:
1. User asks a question
2. Agent calls the `search_knowledge_base` tool function
3. The tool function performs FAISS retrieval and returns relevant articles
4. Agent generates an answer based on the retrieved content

Testing went well — asking "what database does the project use" correctly returns "MySQL" with article references.

### February 24 — Multi-Language Support

Added multi-language support. Each article has a `language` field (zh-CN, en, etc.), and search/chat can filter by language.

AI chat also supports specifying the response language by appending a language instruction to the prompt.
