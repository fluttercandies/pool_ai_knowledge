"""
Knowledge Base Agent Usage Examples

This file demonstrates how to use the knowledge base agent with RAG.
"""

import asyncio
from knowledge_base_agent import (
    create_knowledge_base_agent,
    add_post_to_knowledge_base,
    _knowledge_base
)
from google.adk import Runner
from google.adk.runners import types
from google.adk.sessions.in_memory_session_service import InMemorySessionService


async def example_add_posts():
    """Example: Add posts to knowledge base"""
    print("=" * 60)
    print("Example: Adding Posts to Knowledge Base")
    print("=" * 60)
    
    # Add some posts
    posts = [
        {
            "title": "Python Virtual Environment Best Practices",
            "content": "Virtual environments isolate project dependencies. Use 'python -m venv venv' to create, and 'source venv/bin/activate' to activate. This helps avoid package conflicts between different projects.",
            "tags": ["Python", "Virtual Environment", "Development"]
        },
        {
            "title": "FastAPI Routes and Middleware",
            "content": "FastAPI uses decorators to define routes, supporting path parameters and query parameters. You can use middleware to handle requests and responses. Async routes are defined with 'async def'.",
            "tags": ["FastAPI", "Web Development", "Python"]
        },
        {
            "title": "Google ADK Tool Development",
            "content": "In Google ADK, you can create custom tool functions. Tool functions are automatically converted to tools available to agents. Use the @tool decorator or define functions directly.",
            "tags": ["Google ADK", "AI", "Tool Development"]
        }
    ]
    
    for post in posts:
        result = add_post_to_knowledge_base(
            title=post["title"],
            content=post["content"],
            tags=post["tags"]
        )
        print(f"\n✅ Added post: {result['title']} (ID: {result['post_id']})")
    
    print(f"\nTotal posts in knowledge base: {len(_knowledge_base.posts)}")
    print("\n" + "=" * 60 + "\n")


async def example_query_knowledge_base():
    """Example: Query knowledge base with agent using RAG"""
    print("=" * 60)
    print("Example: Querying Knowledge Base with RAG")
    print("=" * 60)
    
    # Create agent
    agent = create_knowledge_base_agent()
    
    # Create runner
    session_service = InMemorySessionService()
    runner = Runner(app_name="knowledge", agent=agent, session_service=session_service)
    
    # Create session before running queries
    session_id = "test_session"
    user_id = "test_user"
    
    # Create session
    try:
        session_service.create_session_sync(
            user_id=user_id,
            session_id=session_id,
            app_name="knowledge"
        )
    except Exception:
        # Session might already exist, try to get it
        try:
            session_service.get_session_sync(
                user_id=user_id,
                session_id=session_id,
                app_name="knowledge"
            )
        except Exception:
            pass  # If both fail, continue anyway
    
    # Test queries
    queries = [
        "How to use Python virtual environment?",
        "How does FastAPI define routes?",
        "How to create Google ADK tools?",
        "How to learn machine learning?"  # This should return "not found"
    ]
    
    for query in queries:
        print(f"\n{'='*60}")
        print(f"Query: {query}")
        print(f"{'='*60}")
        
        try:
            content = types.Content(parts=[{"text": query}])
            events = list(runner.run(
                user_id=user_id,
                session_id=session_id,
                new_message=content
            ))
            
            # Extract response
            response_parts = []
            for event in events:
                try:
                    if hasattr(event, 'is_final_response') and event.is_final_response():
                        if hasattr(event, 'content') and event.content:
                            if hasattr(event.content, 'parts') and event.content.parts:
                                for part in event.content.parts:
                                    if isinstance(part, dict) and 'text' in part:
                                        response_parts.append(part['text'])
                                    elif hasattr(part, 'text') and part.text:
                                        response_parts.append(part.text)
                except:
                    pass
                
                # Fallback: extract from any content
                if hasattr(event, 'content') and event.content:
                    content_obj = event.content
                    if hasattr(content_obj, 'parts') and content_obj.parts:
                        for part in content_obj.parts:
                            if isinstance(part, dict) and 'text' in part:
                                response_parts.append(part['text'])
                            elif hasattr(part, 'text') and part.text:
                                response_parts.append(part.text)
            
            response = ' '.join(response_parts) if response_parts else "No response"
            print(f"\nResponse:\n{response}\n")
            
        except Exception as e:
            print(f"Error: {e}")
            import traceback
            traceback.print_exc()
            print(f"\nResponse:\nNo response\n")
    
    print("\n" + "=" * 60 + "\n")


async def example_direct_search():
    """Example: Direct RAG search without agent"""
    print("=" * 60)
    print("Example: Direct Knowledge Base Search with RAG")
    print("=" * 60)
    
    from knowledge_base_agent import search_knowledge_base
    
    query = "How does FastAPI define routes?"
    result = search_knowledge_base(query, top_k=2)
    
    print(f"\nQuery: {query}")
    print(f"Status: {result['status']}")
    print(f"Results Count: {result.get('results_count', 0)}")
    
    if result['status'] == 'found':
        print("\nResults:")
        for i, r in enumerate(result['results'], 1):
            print(f"\n{i}. {r['title']} (ID: {r['post_id']})")
            print(f"   Relevance Score: {r['relevance_score']}")
            print(f"   Reason: {r['reason']}")
            print(f"   Matched Content: {r['matched_content'][:100]}...")
    
    print("\n" + "=" * 60 + "\n")


async def run_all_examples():
    """Run all examples using RAG"""
    print("\n" + "=" * 60)
    print("Knowledge Base Agent Examples (RAG Only)")
    print("=" * 60 + "\n")
    
    # Example 1: Add posts
    # await example_add_posts()
    
    # Example 2: Direct RAG search
    # await example_direct_search()
    
    # Example 3: Query with agent using RAG
    await example_query_knowledge_base()
    
    print("\n" + "=" * 60)
    print("All examples completed!")
    print("=" * 60 + "\n")


if __name__ == "__main__":
    asyncio.run(run_all_examples())

