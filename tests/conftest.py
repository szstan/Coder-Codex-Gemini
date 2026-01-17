"""Pytest 配置文件"""
import pytest
import os
from pathlib import Path


@pytest.fixture
def test_config_dir(tmp_path):
    """创建临时配置目录"""
    config_dir = tmp_path / ".ccg-mcp"
    config_dir.mkdir()
    return config_dir


@pytest.fixture
def mock_config_file(test_config_dir):
    """创建模拟配置文件"""
    config_file = test_config_dir / "config.toml"
    config_content = """
[coder]
api_token = "test-token"
base_url = "https://test.example.com"
model = "test-model"

[codex]
api_token = "test-codex-token"

[gemini]
api_token = "test-gemini-token"
"""
    config_file.write_text(config_content)
    return config_file


@pytest.fixture
def mock_env_vars(monkeypatch):
    """设置模拟环境变量"""
    monkeypatch.setenv("CODER_API_TOKEN", "env-test-token")
    monkeypatch.setenv("CODER_BASE_URL", "https://env-test.example.com")
    monkeypatch.setenv("CODER_MODEL", "env-test-model")
