---
tags: dev-diary,Flutter,mobile,optimization
language: en
---

## April 2025 — Mobile App and Optimization

### April 7 — Flutter Project Started

Began mobile development with Flutter for cross-platform support (Android + iOS + Desktop).

Initialized the project and added core dependencies:
- `flutter_riverpod` — state management
- `window_manager` — desktop window control
- `dio` — HTTP requests

Desktop window defaults to 1200x800, minimum 800x600 — feels close to a native app.

### April 14 — Core App Features

Completed the main app screens:
- Home — latest articles + quick search
- Article Browser — list + detail view (Markdown rendering)
- AI Chat — conversation with the knowledge base Agent
- Settings — API host configuration, language switching

The API Host is stored in `assets/app_config.json` so it can be modified via script after building — users don't need Flutter installed on their servers.

### April 21 — Performance Optimization

Completed a round of performance tuning:

**Backend:**
- FAISS index now updates incrementally instead of full rebuilds
- Database connection pool tuning (pool_pre_ping + pool_recycle)
- Added gzip compression to API responses

**Frontend:**
- Lazy loading for article lists to reduce initial requests
- 7-day browser cache for images
- CDN-friendly Cache-Control headers in Nginx

### April 28 — APK Repackaging Design

Designed the APK repackaging workflow: build a template APK on the dev machine, then use apktool on the server to decompile, modify the app_name and api_host, re-sign, and host on Nginx for download.

This way users can provide an App download link right after deploying the backend — no need to install Flutter on the server.
