"""MCP 服务器集成测试"""
import pytest
from ccg_mcp.server import mcp


def test_mcp_server_initialization():
    """测试 MCP 服务器初始化"""
    assert mcp is not None
    assert hasattr(mcp, 'tool')


def test_mcp_tools_registered():
    """测试 MCP 工具是否注册"""
    # 这里可以添加更多的工具注册检查
    # 例如检查 coder, codex, gemini 工具是否正确注册
    pass
