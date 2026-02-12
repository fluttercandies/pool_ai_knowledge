---
tags: dev-diary,project-launch,architecture
language: en
---

## January 2025 — Project Launch and Architecture Design

### January 6 — Project Kickoff

Today we officially kicked off the Pool AI Knowledge project. The core goal: build a RAG-powered intelligent knowledge base that lets AI understand and retrieve team documents and expertise.

We spent a full day on technology selection and settled on:
- **FastAPI** for the backend — great async performance, built-in Swagger docs
- **Vue 3 + Element Plus** for the frontend — high development efficiency
- **MySQL** for the database — mature and reliable
- **FAISS** for vector search — in-memory speed
- **Google Gemini** for the AI model — excellent cost-performance ratio

### January 13 — Database Design Complete

Designed four core tables:
- `posts` — articles and knowledge content
- `admin_users` — administrator accounts
- `api_keys` — API key management
- `system_config` — system configuration

Schema is managed via pure SQL files. All CREATE TABLE statements use `IF NOT EXISTS` for idempotency.

### January 20 — Backend API Framework

Completed the core API framework:
- Unified response format: `R.ok(data)` / `R.fail(code, message)`
- JWT authentication (HS256, 24-hour expiry)
- bcrypt password hashing
- Global exception handlers

Hit a snag: newer versions of `bcrypt` break `passlib` compatibility. Pinned `bcrypt==4.0.1` to fix it.

### January 27 — Admin CRUD Complete

Finished all admin panel CRUD operations: article management, API key management, and admin user management. Articles support Markdown format. Tags are stored as comma-separated strings in MySQL and returned as arrays in API responses.

API key values are masked in all responses — only the first 4 and last 4 characters are shown.
