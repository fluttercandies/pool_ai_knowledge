---
tags: dev-diary,frontend,deployment,Vue
language: en
---

## March 2025 — Frontend Development and Deployment

### March 3 — Vue 3 Frontend Initialized

Created the Vue 3 frontend project with Vite, added Element Plus components and vue-i18n for internationalization.

Planned four main routes:
- `/` — Home page
- `/posts` — Article listing
- `/posts/:id` — Article detail (Markdown rendering)
- `/chat` — AI chat page

Vite's development experience is excellent — hot reload is practically instant.

### March 10 — Article List and Search

Completed the article listing page with pagination and language filtering. Search is powered by the backend's RAG semantic search API.

Search results include highlighted terms for a good user experience. Article detail pages use markdown-it for rendering with syntax-highlighted code blocks.

### March 17 — AI Chat Interface

Built a ChatGPT-style conversation interface:
- Message bubbles styled differently for user and AI
- AI responses rendered as Markdown
- Referenced articles shown at the bottom with clickable links
- Language toggle for conversation

One challenge: AI response times can be 3-5 seconds. Added loading animations and an "AI is thinking" indicator.

### March 24 — Admin Dashboard Integration

The admin dashboard is based on the vue-element-admin template (Vue 2), which already includes login, route guards, and permission management.

Connected to the backend admin APIs:
- Article management (CRUD + Markdown editor)
- API key management (add/remove OpenAI and Google keys)
- Model switching (choose between Gemini versions)
- Admin account management

### March 31 — Linux Deployment Script

Wrote a one-click deployment script `deploy.sh` supporting Ubuntu/Debian/CentOS:
- Auto-installs Python, Node.js, MySQL, Nginx
- Builds and deploys the frontend to Nginx
- Configures systemd service for auto-start
- Generates the `.env` configuration file

Tested deployment on an Alibaba Cloud 2C4G ECS instance — the entire process took about 5 minutes.
