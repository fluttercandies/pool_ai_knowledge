"""
Knowledge Base Agent with RAG (Retrieval-Augmented Generation)
基于 RAG（检索增强生成）的知识库代理

This module implements a knowledge base agent that can:
- Search through posts/articles
- Answer questions based on retrieved content
- Show related posts and reasoning
此模块实现了一个知识库代理，可以：
- 搜索文章/帖子
- 基于检索到的内容回答问题
- 显示相关文章和推理过程
"""

from typing import Dict, List, Optional, Tuple
import json
import os
from pathlib import Path
from dotenv import load_dotenv

# Load environment variables / 加载环境变量
load_dotenv()

from google.adk.agents import Agent
from google.adk.tools import BaseTool
from pydantic import BaseModel, Field


# ==================== Data Models 数据模型 ====================

class Post(BaseModel):
    """Post/Article model / 文章/帖子模型"""
    id: str
    title: str
    content: str
    tags: List[str] = Field(default_factory=list)
    created_at: Optional[str] = None


class SearchResult(BaseModel):
    """Search result model / 搜索结果模型"""
    post_id: str
    title: str
    relevance_score: float
    matched_content: str
    reason: str  # Why this post is relevant / 为什么这篇文章相关


# ==================== Knowledge Base Storage 知识库存储 ====================

class KnowledgeBase:
    """
    Simple in-memory knowledge base for posts / 简单的内存知识库用于存储文章
    In production, you might want to use a vector database like Chroma, Pinecone, or Vertex AI Vector Search
    在生产环境中，你可能想使用向量数据库如 Chroma、Pinecone 或 Vertex AI Vector Search
    """
    
    def __init__(self, storage_path: str = "knowledge_base.json"):
        """
        Initialize knowledge base / 初始化知识库
        
        Args:
            storage_path: Path to JSON file storing posts / 存储文章的 JSON 文件路径
        """
        self.storage_path = storage_path
        self.posts: Dict[str, Post] = {}
        self.load_posts()
    
    def load_posts(self):
        """Load posts from storage / 从存储加载文章"""
        if os.path.exists(self.storage_path):
            try:
                with open(self.storage_path, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                    for post_data in data.get('posts', []):
                        post = Post(**post_data)
                        self.posts[post.id] = post
                print(f"Loaded {len(self.posts)} posts from {self.storage_path}")
            except Exception as e:
                print(f"Error loading posts: {e}")
    
    def save_posts(self):
        """Save posts to storage / 保存文章到存储"""
        try:
            data = {
                'posts': [post.model_dump() for post in self.posts.values()]
            }
            with open(self.storage_path, 'w', encoding='utf-8') as f:
                json.dump(data, f, ensure_ascii=False, indent=2)
            print(f"Saved {len(self.posts)} posts to {self.storage_path}")
        except Exception as e:
            print(f"Error saving posts: {e}")
    
    def add_post(self, post: Post):
        """Add a new post / 添加新文章"""
        self.posts[post.id] = post
        self.save_posts()
    
    def search_posts(self, query: str, top_k: int = 3) -> List[SearchResult]:
        """
        Search posts by keyword matching / 通过关键词匹配搜索文章
        
        Args:
            query: Search query / 搜索查询
            top_k: Number of results to return / 返回结果数量
        
        Returns:
            List of search results with relevance scores / 带相关性分数的搜索结果列表
        """
        query_lower = query.lower()
        query_words = set(query_lower.split())
        
        results = []
        
        for post_id, post in self.posts.items():
            # Calculate relevance score / 计算相关性分数
            title_lower = post.title.lower()
            content_lower = post.content.lower()
            
            # Count matches in title (weighted higher) / 统计标题中的匹配（权重更高）
            title_matches = sum(1 for word in query_words if word in title_lower)
            content_matches = sum(1 for word in query_words if word in content_lower)
            
            # Simple scoring: title matches count more / 简单评分：标题匹配权重更高
            score = title_matches * 2 + content_matches
            
            if score > 0:
                # Find a snippet of matched content / 找到匹配内容的片段
                matched_content = self._extract_relevant_snippet(content_lower, query_words, max_length=200)
                
                # Generate reason / 生成原因
                reason = self._generate_reason(post, query_words, title_matches, content_matches)
                
                results.append(SearchResult(
                    post_id=post.id,
                    title=post.title,
                    relevance_score=score,
                    matched_content=matched_content,
                    reason=reason
                ))
        
        # Sort by relevance score / 按相关性分数排序
        results.sort(key=lambda x: x.relevance_score, reverse=True)
        
        return results[:top_k]
    
    def _extract_relevant_snippet(self, content: str, query_words: set, max_length: int = 200) -> str:
        """Extract a relevant snippet from content / 从内容中提取相关片段"""
        # Find first sentence containing query words / 找到包含查询词的第一个句子
        sentences = content.split('.')
        for sentence in sentences:
            if any(word in sentence.lower() for word in query_words):
                snippet = sentence.strip()
                if len(snippet) > max_length:
                    snippet = snippet[:max_length] + "..."
                return snippet
        
        # If no sentence matches, return beginning / 如果没有匹配的句子，返回开头
        return content[:max_length] + "..." if len(content) > max_length else content
    
    def _generate_reason(self, post: Post, query_words: set, title_matches: int, content_matches: int) -> str:
        """Generate reason why post is relevant / 生成文章相关的原因"""
        reasons = []
        
        if title_matches > 0:
            matched_words = [word for word in query_words if word in post.title.lower()]
            reasons.append(f"标题包含关键词: {', '.join(matched_words)}")
        
        if content_matches > 0:
            reasons.append(f"内容包含 {content_matches} 个匹配的关键词")
        
        if post.tags:
            matched_tags = [tag for tag in post.tags if any(word in tag.lower() for word in query_words)]
            if matched_tags:
                reasons.append(f"标签匹配: {', '.join(matched_tags)}")
        
        return "；".join(reasons) if reasons else "部分内容相关"


# ==================== ADK Tool for Knowledge Base Search ADK 知识库搜索工具 ====================

# Global knowledge base instance / 全局知识库实例
_knowledge_base = KnowledgeBase()


def search_knowledge_base(query: str, top_k: int = 3) -> Dict:
    """
    Search the knowledge base for relevant posts / 在知识库中搜索相关文章
    
    This is a tool function that ADK agents can use / 这是 ADK 代理可以使用的工具函数
    
    Args:
        query: Search query / 搜索查询
        top_k: Number of results to return / 返回结果数量
    
    Returns:
        Dictionary with search results / 包含搜索结果的字典
    """
    results = _knowledge_base.search_posts(query, top_k)
    
    if not results:
        return {
            "status": "not_found",
            "message": "No relevant posts found for your query.",
            "query": query,
            "results": []
        }
    
    return {
        "status": "found",
        "query": query,
        "results_count": len(results),
        "results": [
            {
                "post_id": r.post_id,
                "title": r.title,
                "relevance_score": r.relevance_score,
                "matched_content": r.matched_content,
                "reason": r.reason
            }
            for r in results
        ]
    }


def add_post_to_knowledge_base(title: str, content: str, tags: List[str] = None, post_id: Optional[str] = None) -> Dict:
    """
    Add a new post to the knowledge base / 向知识库添加新文章
    
    Args:
        title: Post title / 文章标题
        content: Post content / 文章内容
        tags: List of tags / 标签列表
        post_id: Optional post ID (auto-generated if not provided) / 可选的文章 ID（如未提供则自动生成）
    
    Returns:
        Dictionary with status and post info / 包含状态和文章信息的字典
    """
    import uuid
    
    if post_id is None:
        post_id = str(uuid.uuid4())
    
    post = Post(
        id=post_id,
        title=title,
        content=content,
        tags=tags or []
    )
    
    _knowledge_base.add_post(post)
    
    return {
        "status": "success",
        "message": "Post added successfully",
        "post_id": post_id,
        "title": title
    }


# ==================== Knowledge Base Agent 知识库代理 ====================

def create_knowledge_base_agent() -> Agent:
    """
    Create a knowledge base agent that can answer questions from posts / 创建可以从文章中回答问题的知识库代理
    
    Returns:
        Agent instance configured for knowledge base queries / 配置用于知识库查询的代理实例
    """
    return Agent(
        model='gemini-2.0-flash-exp',
        name='knowledge_base_agent',
        description="""
        A knowledge base assistant that answers questions by searching through posts/articles.
        If no relevant posts are found, it will say that nothing was found and cannot solve the question.
        When answering, it always shows the related posts and explains why they are relevant.
        
        一个知识库助手，通过搜索文章/帖子来回答问题。
        如果找不到相关文章，它会说没有找到任何内容，无法解决问题。
        回答时，它总是显示相关文章并解释为什么它们相关。
        """,
        instruction="""
        You are a helpful knowledge base assistant. Your job is to answer user questions by searching 
        through available posts/articles.
        
        IMPORTANT RULES:
        1. ALWAYS use the search_knowledge_base tool first when a user asks a question
        2. If search_knowledge_base returns status "not_found", you MUST say:
           "I couldn't find any relevant posts to answer your question. I cannot solve this based on the available knowledge base."
        3. If search_knowledge_base returns results, you MUST:
           - Answer the question based on the retrieved posts
           - List ALL related posts with their titles
           - Explain WHY each post is relevant (use the "reason" field from results)
           - Cite the post IDs when referencing information
        
        Example response format when posts are found:
        "Based on the knowledge base, [your answer].
        
        Related posts:
        1. [Post Title] (ID: [post_id])
           Reason: [reason from search result]
           Relevant content: [matched_content]
        
        2. [Post Title] (ID: [post_id])
           Reason: [reason from search result]
           Relevant content: [matched_content]"
        
        Example response when nothing found:
        "I couldn't find any relevant posts to answer your question. I cannot solve this based on the available knowledge base."
        
        你是一个有用的知识库助手。你的工作是通过搜索可用的文章/帖子来回答用户问题。
        
        重要规则：
        1. 当用户提问时，总是首先使用 search_knowledge_base 工具
        2. 如果 search_knowledge_base 返回状态 "not_found"，你必须说：
           "我找不到任何相关文章来回答你的问题。我无法基于现有知识库解决这个问题。"
        3. 如果 search_knowledge_base 返回结果，你必须：
           - 基于检索到的文章回答问题
           - 列出所有相关文章及其标题
           - 解释为什么每篇文章相关（使用结果中的 "reason" 字段）
           - 引用信息时注明文章 ID
        
        找到文章时的响应格式示例：
        "基于知识库，[你的回答]。
        
        相关文章：
        1. [文章标题] (ID: [post_id])
           原因：[搜索结果中的原因]
           相关内容：[matched_content]
        
        2. [文章标题] (ID: [post_id])
           原因：[搜索结果中的原因]
           相关内容：[matched_content]"
        
        未找到内容时的响应示例：
        "我找不到任何相关文章来回答你的问题。我无法基于现有知识库解决这个问题。"
        """,
        tools=[search_knowledge_base, add_post_to_knowledge_base]
    )


# ==================== Helper Functions 辅助函数 ====================

def initialize_sample_posts():
    """Initialize knowledge base with sample posts / 用示例文章初始化知识库"""
    sample_posts = [
        Post(
            id="post_001",
            title="Python 虚拟环境使用指南",
            content="Python 虚拟环境是隔离项目依赖的重要工具。使用 python -m venv venv 创建虚拟环境，使用 source venv/bin/activate 激活。虚拟环境可以避免不同项目之间的依赖冲突。",
            tags=["Python", "虚拟环境", "开发工具"]
        ),
        Post(
            id="post_002",
            title="FastAPI 快速入门",
            content="FastAPI 是一个现代、快速的 Web 框架。它基于 Python 类型提示，自动生成 API 文档。使用 @app.get() 装饰器定义路由，支持异步请求处理。",
            tags=["FastAPI", "Python", "Web开发"]
        ),
        Post(
            id="post_003",
            title="Google ADK 代理开发",
            content="Google ADK (Agent Development Kit) 是用于构建 AI 代理的框架。它支持自定义工具、插件和多代理系统。使用 Agent 类创建代理，通过 Runner 运行代理。",
            tags=["Google ADK", "AI", "代理开发"]
        )
    ]
    
    for post in sample_posts:
        _knowledge_base.add_post(post)
    
    print(f"Initialized knowledge base with {len(sample_posts)} sample posts")


# Initialize with sample data if knowledge base is empty / 如果知识库为空，用示例数据初始化
if len(_knowledge_base.posts) == 0:
    initialize_sample_posts()

