"""配置模块单元测试"""
import pytest
from pathlib import Path
from unittest.mock import patch
from ccg_mcp.config import load_config, get_config_path, reset_config_cache


def test_load_config_from_file(mock_config_file, monkeypatch):
    """测试从文件加载配置"""
    # 重置配置缓存
    reset_config_cache()

    # Mock get_config_path 返回测试配置文件路径
    with patch('ccg_mcp.config.get_config_path', return_value=mock_config_file):
        config = load_config()

    assert config["coder"]["api_token"] == "test-token"
    assert config["coder"]["base_url"] == "https://test.example.com"
    assert config["coder"]["model"] == "test-model"


def test_load_config_from_env(mock_env_vars, tmp_path):
    """测试从环境变量加载配置"""
    # 重置配置缓存
    reset_config_cache()

    # Mock get_config_path 返回不存在的路径，强制使用环境变量
    fake_config_path = tmp_path / "nonexistent" / "config.toml"
    with patch('ccg_mcp.config.get_config_path', return_value=fake_config_path):
        config = load_config()

    assert config["coder"]["api_token"] == "env-test-token"
    assert config["coder"]["base_url"] == "https://env-test.example.com"
    assert config["coder"]["model"] == "env-test-model"
