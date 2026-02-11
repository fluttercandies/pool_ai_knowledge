---
tags: 快速开始,部署,教程
language: zh-CN
---

## 快速开始

本文将帮助您在几分钟内启动并运行 Pool AI Knowledge。

### 1. 环境准备

确保您的系统已安装以下组件：

- **Python 3.10+**
- **MySQL 8.0+**
- **Node.js 18+**（前端开发需要）

### 2. 后端部署

```bash
# 克隆项目
git clone <repository-url>
cd pool_ai_knowledge/backend

# 创建虚拟环境
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# 安装依赖
pip install -r requirements.txt

# 配置环境变量
cp .env.example .env
# 编辑 .env 文件，填写数据库连接和 API 密钥

# 初始化数据库
python init_db.py

# 启动服务
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

### 3. 环境变量配置

在 `.env` 文件中配置以下关键变量：

| 变量名 | 说明 | 必填 |
|--------|------|------|
| `DATABASE_URL` | MySQL 连接字符串 | 是 |
| `OPENAI_API_KEY` | OpenAI API 密钥（用于文本嵌入） | 是 |
| `GOOGLE_API_KEY` | Google API 密钥（用于 AI 对话） | 是 |
| `SECRET_KEY` | JWT 签名密钥 | 是 |

### 4. 登录管理后台

服务启动后，使用默认管理员账号登录：

- **用户名**：`admin`
- **密码**：`admin123456`

> ⚠️ 请在首次登录后立即修改默认密码！

### 5. 开始使用

1. 在管理后台添加文章和知识内容
2. 配置 API 密钥（OpenAI + Google）
3. 通过前端页面进行智能搜索或 AI 对话
4. 文章更新后，RAG 向量索引会自动重建

### 常见问题

**Q: 搜索结果不理想怎么办？**

A: 确保 OpenAI API Key 已正确配置，文章内容尽量详细、结构化。

**Q: AI 对话没有响应？**

A: 检查 Google API Key 是否有效，以及网络是否可以访问 Google API。
