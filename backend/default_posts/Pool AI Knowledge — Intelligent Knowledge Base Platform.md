---
tags: introduction,knowledge-base,RAG,AI
language: en
---

## What is Pool AI Knowledge?

Pool AI Knowledge is an intelligent knowledge base platform powered by **RAG (Retrieval-Augmented Generation)** technology. It combines traditional content management with cutting-edge AI to make your knowledge truly accessible and interactive.

### Core Capabilities

- **Semantic Search**: Powered by OpenAI Embeddings + FAISS vector retrieval — understands intent, not just keywords
- **AI-Powered Q&A**: Integrated with Google Gemini models for natural language conversations with your knowledge base
- **Multi-Language Support**: Manage and search content in Chinese, English, Japanese, Korean, and more
- **Markdown Editing**: Full Markdown support for rich, flexible content formatting

### Architecture Overview

```
Frontend (Vue 3 + Element Plus)
    ↕
Backend (FastAPI + Python)
    ↕
┌──────────────────────────────────────┐
│  MySQL — Structured data storage     │
│  FAISS — Vector index (semantic)     │
│  OpenAI — Text embedding generation  │
│  Google Gemini — AI chat generation  │
└──────────────────────────────────────┘
```

### Use Cases

1. **Internal Knowledge Base**: Capture team expertise, accelerate onboarding
2. **Product Documentation**: Users find answers instantly via AI chat
3. **Technical Blog**: Markdown authoring + intelligent search
4. **Customer Support**: AI retrieves answers from the knowledge base automatically

> Pool AI Knowledge — Let knowledge flow, let AI empower.
