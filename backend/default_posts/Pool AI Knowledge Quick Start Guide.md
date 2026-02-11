---
tags: quickstart,deployment,tutorial
language: en
---

## Quick Start

This guide will help you get Pool AI Knowledge up and running in minutes.

### 1. Prerequisites

Make sure your system has the following installed:

- **Python 3.10+**
- **MySQL 8.0+**
- **Node.js 18+** (for frontend development)

### 2. Backend Setup

```bash
# Clone the project
git clone <repository-url>
cd pool_ai_knowledge/backend

# Create a virtual environment
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Configure environment variables
cp .env.example .env
# Edit .env and fill in database connection and API keys

# Initialize the database
python init_db.py

# Start the server
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

### 3. Environment Variables

Configure these key variables in the `.env` file:

| Variable | Description | Required |
|----------|-------------|----------|
| `DATABASE_URL` | MySQL connection string | Yes |
| `OPENAI_API_KEY` | OpenAI API key (for text embeddings) | Yes |
| `GOOGLE_API_KEY` | Google API key (for AI chat) | Yes |
| `SECRET_KEY` | JWT signing secret | Yes |

### 4. Log In to Admin Panel

Once the server is running, log in with the default admin credentials:

- **Username**: `admin`
- **Password**: `admin123456`

> ⚠️ Change the default password immediately after your first login!

### 5. Getting Started

1. Add articles and knowledge content via the admin panel
2. Configure API keys (OpenAI + Google)
3. Use the frontend for semantic search or AI chat
4. The RAG vector index rebuilds automatically when articles are updated

### FAQ

**Q: Search results are not relevant?**

A: Ensure your OpenAI API Key is properly configured. Write detailed, well-structured articles for best results.

**Q: AI chat is not responding?**

A: Check that your Google API Key is valid and that your network can reach the Google API.
