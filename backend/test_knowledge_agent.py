"""
Test script for knowledge base agent
知识库代理测试脚本
"""

import asyncio
from knowledge_base_agent import create_knowledge_base_agent
from google.adk import Runner
from google.adk.runners import types
from google.adk.sessions.in_memory_session_service import InMemorySessionService
from google.adk.sessions.session import Session


async def test_agent_async():
    """Test agent with async runner / 使用异步运行器测试代理"""
    print("=" * 60)
    print("Testing Knowledge Base Agent (Async)")
    print("测试知识库代理（异步）")
    print("=" * 60)
    
    # Create agent / 创建代理
    agent = create_knowledge_base_agent()
    
    # Create session service / 创建会话服务
    session_service = InMemorySessionService()
    
    # Create session / 创建会话
    session_service.create_session_sync(
        user_id="test_user",
        session_id="test_session_async",
        app_name="knowledge"
    )
    
    # Create runner / 创建运行器
    runner = Runner(app_name="knowledge", agent=agent, session_service=session_service)
    
    # Create content / 创建内容
    content = types.Content(parts=[{"text": "如何使用 Python 虚拟环境？"}])
    
    print("\nRunning agent asynchronously...")
    print("异步运行代理...\n")
    
    events = []
    try:
        # Use run_async / 使用 run_async
        async for event in runner.run_async(
            parent_context=None
        ):
            events.append(event)
            print(f"Event received: {type(event).__name__}")
            # Print event details / 打印事件详情
            if hasattr(event, '__dict__'):
                for key, value in event.__dict__.items():
                    if not key.startswith('_'):
                        print(f"  {key}: {str(value)[:100]}")
    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()
    
    print(f"\nTotal events: {len(events)}")
    
    # Extract response / 提取响应
    from main import _extract_response_from_events
    response = _extract_response_from_events(events, debug=True)
    
    print(f"\n{'='*60}")
    print("Response / 响应:")
    print(f"{'='*60}")
    print(response)
    print(f"{'='*60}\n")


def test_agent_sync():
    """Test agent with sync runner / 使用同步运行器测试代理"""
    print("=" * 60)
    print("Testing Knowledge Base Agent (Sync)")
    print("测试知识库代理（同步）")
    print("=" * 60)
    
    # Create agent / 创建代理
    agent = create_knowledge_base_agent()
    
    # Create session service / 创建会话服务
    session_service = InMemorySessionService()
    
    # Create session / 创建会话
    session_service.create_session_sync(
        user_id="test_user",
        session_id="test_session_sync",
        app_name="knowledge"
    )
    
    # Create runner / 创建运行器
    runner = Runner(app_name="knowledge", agent=agent, session_service=session_service)
    
    # Create content / 创建内容
    content = types.Content(parts=[{"text": "如何使用 Python 虚拟环境？"}])
    
    print("\nRunning agent synchronously...")
    print("同步运行代理...\n")
    
    try:
        events = list(runner.run(
            user_id="test_user",
            session_id="test_session_sync",
            new_message=content
        ))
        
        print(f"Total events: {len(events)}")
        
        # Print event types / 打印事件类型
        for i, event in enumerate(events):
            print(f"\nEvent {i+1}: {type(event).__name__}")
            if hasattr(event, '__dict__'):
                for key, value in list(event.__dict__.items())[:5]:  # First 5 attributes
                    if not key.startswith('_'):
                        val_str = str(value)
                        if len(val_str) > 100:
                            val_str = val_str[:100] + "..."
                        print(f"  {key}: {val_str}")
        
        # Extract response / 提取响应
        from main import _extract_response_from_events
        response = _extract_response_from_events(events, debug=True)
        
        print(f"\n{'='*60}")
        print("Response / 响应:")
        print(f"{'='*60}")
        print(response)
        print(f"{'='*60}\n")
        
    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    print("\nTesting Knowledge Base Agent")
    print("测试知识库代理\n")
    
    # Test sync first / 先测试同步
    test_agent_sync()
    
    # Then test async / 然后测试异步
    # asyncio.run(test_agent_async())

