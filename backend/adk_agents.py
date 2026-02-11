"""
ADK Agent — Knowledge Base Agent
使用 Google ADK (Agent Development Kit) 创建知识库 AI 代理
"""

from typing import Dict, List, Optional
from google.adk.agents import Agent
from knowledge_base_agent import create_knowledge_base_agent
from database import get_current_model


# ==================== Agent Registry 代理注册表 ====================

def _build_registry() -> Dict[str, Agent]:
    """Build the agent registry with the current model setting."""
    return {
        "knowledge": create_knowledge_base_agent(),
    }


AGENT_REGISTRY: Dict[str, Agent] = _build_registry()


def rebuild_agents():
    """Rebuild all agents (e.g. after model change)."""
    global AGENT_REGISTRY
    AGENT_REGISTRY = _build_registry()
    print(f"Agents rebuilt with model: {get_current_model()}")


def get_agent(agent_name: str) -> Optional[Agent]:
    """
    Get an agent by name / 通过名称获取代理
    """
    return AGENT_REGISTRY.get(agent_name.lower())


def list_agents() -> List[str]:
    """
    List all available agent names / 列出所有可用的代理名称
    """
    return list(AGENT_REGISTRY.keys())
