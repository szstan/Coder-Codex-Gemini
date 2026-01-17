# 智能错误分类系统

## 概述

智能错误分类系统用于自动识别和分类 CCG 执行过程中的错误，并为每种错误类型提供相应的处理策略。

## 错误分类体系

### 1. 临时性错误 (Transient Errors)

**特征**：短暂的、可恢复的错误，通常由外部因素引起。

**错误类型**：
- `network_timeout` - 网络超时
- `api_rate_limit` - API 限流
- `resource_busy` - 资源繁忙
- `temporary_unavailable` - 服务临时不可用
- `connection_reset` - 连接重置

**处理策略**：
- ✅ 自动重试（指数退避）
- ✅ 最大重试次数：3-5 次
- ✅ 保持 SESSION_ID 和上下文

**示例**：
```
错误信息：Connection timeout after 30s
分类：network_timeout
建议：自动重试（第 1/3 次），等待 2 秒后重试
```

### 2. 代码错误 (Code Errors)

**特征**：代码本身的问题，需要修改代码才能解决。

**错误类型**：
- `syntax_error` - 语法错误
- `type_error` - 类型错误
- `name_error` - 变量未定义
- `import_error` - 导入错误
- `logic_error` - 逻辑错误
- `test_failure` - 测试失败

**处理策略**：
- ❌ 不自动重试（重试无效）
- ✅ 提供错误分析和修复建议
- ✅ 标记失败位置和上下文

**示例**：
```
错误信息：SyntaxError: invalid syntax at line 42
分类：syntax_error
建议：
1. 检查第 42 行的语法
2. 常见原因：缺少括号、引号不匹配、缩进错误
3. 修复后重新执行
```

### 3. 环境错误 (Environment Errors)

**特征**：环境配置或依赖问题，需要修复环境才能解决。

**错误类型**：
- `dependency_missing` - 依赖缺失
- `config_error` - 配置错误
- `permission_denied` - 权限不足
- `path_not_found` - 路径不存在
- `version_mismatch` - 版本不匹配

**处理策略**：
- ❌ 不自动重试
- ✅ 提供环境修复指令
- ✅ 检查环境配置清单

**示例**：
```
错误信息：ModuleNotFoundError: No module named 'requests'
分类：dependency_missing
建议：
1. 安装缺失的依赖：pip install requests
2. 或者安装所有依赖：pip install -r requirements.txt
3. 验证安装：python -c "import requests"
```

### 4. 不可恢复错误 (Unrecoverable Errors)

**特征**：无法通过重试或修复解决的错误，需要人工介入。

**错误类型**：
- `auth_failure` - 认证失败
- `resource_not_found` - 资源不存在
- `quota_exceeded` - 配额超限
- `invalid_request` - 无效请求
- `upstream_error` - 上游服务错误

**处理策略**：
- ❌ 不重试
- ✅ 立即停止并报告
- ✅ 提供详细错误信息和建议

**示例**：
```
错误信息：Authentication failed: Invalid API token
分类：auth_failure
建议：
1. 检查 API token 是否正确配置
2. 验证 token 是否过期
3. 确认 token 权限是否足够
4. 更新配置文件：~/.ccg-mcp/config.toml
```

## 错误识别规则

### 基于关键词的识别

**临时性错误关键词**：
- `timeout`, `timed out`
- `rate limit`, `too many requests`
- `connection refused`, `connection reset`
- `temporarily unavailable`, `service unavailable`
- `busy`, `overloaded`

**代码错误关键词**：
- `SyntaxError`, `IndentationError`
- `TypeError`, `ValueError`, `AttributeError`
- `NameError`, `ImportError`, `ModuleNotFoundError`
- `AssertionError`, `test failed`

**环境错误关键词**：
- `No module named`, `cannot import`
- `permission denied`, `access denied`
- `not found`, `does not exist`
- `version mismatch`, `incompatible version`

**不可恢复错误关键词**：
- `authentication failed`, `invalid token`
- `unauthorized`, `forbidden`
- `quota exceeded`, `limit reached`
- `invalid request`, `bad request`

### 错误分类决策流程

```
错误发生
    ↓
检查错误信息关键词
    ↓
┌─────────────────────────────────┐
│ 是否包含临时性错误关键词？        │
│ (timeout, rate limit, etc.)     │
└─────────────────────────────────┘
    ↓ 是                    ↓ 否
分类为临时性错误          继续检查
    ↓
┌─────────────────────────────────┐
│ 是否包含代码错误关键词？          │
│ (SyntaxError, TypeError, etc.)  │
└─────────────────────────────────┘
    ↓ 是                    ↓ 否
分类为代码错误            继续检查
    ↓
┌─────────────────────────────────┐
│ 是否包含环境错误关键词？          │
│ (missing, permission, etc.)     │
└─────────────────────────────────┘
    ↓ 是                    ↓ 否
分类为环境错误            分类为不可恢复错误
```

## 使用指南

### Claude 如何使用错误分类

1. **捕获错误信息**
   - 从 MCP 工具返回的 error_detail 中提取错误信息
   - 读取最后 20 行输出日志

2. **分析错误类型**
   - 使用关键词匹配识别错误类型
   - 参考错误分类决策流程

3. **执行相应策略**
   - 临时性错误：自动重试
   - 代码错误：提供修复建议，等待用户确认
   - 环境错误：提供环境修复指令
   - 不可恢复错误：停止并报告

### 错误分类示例

**示例 1：网络超时（临时性错误）**
```
原始错误：
  HTTPConnectionPool: Max retries exceeded with url: /api/v1/chat
  Caused by: ConnectTimeoutError: Connection to api.example.com timed out

分类结果：
  类型：network_timeout (临时性错误)

处理策略：
  自动重试（第 1/3 次）
  等待 2 秒后重试
  保持 SESSION_ID: abc123
```

**示例 2：语法错误（代码错误）**
```
原始错误：
  File "src/main.py", line 42
    def calculate(x, y
                      ^
  SyntaxError: invalid syntax

分类结果：
  类型：syntax_error (代码错误)

处理策略：
  不重试
  建议：检查第 42 行，缺少右括号
  等待用户修复后重新执行
```

**示例 3：依赖缺失（环境错误）**
```
原始错误：
  ModuleNotFoundError: No module named 'pandas'

分类结果：
  类型：dependency_missing (环境错误)

处理策略：
  不重试
  修复指令：pip install pandas
  验证命令：python -c "import pandas"
```

## 总结

智能错误分类系统通过自动识别错误类型，为每种错误提供最合适的处理策略，从而提升 CCG 系统的稳定性和用户体验。
