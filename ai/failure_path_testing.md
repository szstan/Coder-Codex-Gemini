# Failure Path 测试指南

> **核心原则**：关键逻辑必须测试失败路径，确保错误处理健壮。

---

## 一、何时需要 Failure Path 测试

### 1.1 必须测试的场景

以下场景**必须**编写 failure path 测试：

| 场景 | 说明 | 示例 |
|------|------|------|
| **用户输入验证** | 防止非法输入导致系统崩溃 | 空值、超长字符串、SQL 注入 |
| **外部依赖失败** | 确保外部服务不可用时系统仍可用 | 网络超时、数据库连接失败 |
| **权限校验** | 防止未授权访问 | 未登录、权限不足 |
| **资源不足** | 优雅处理资源耗尽 | 内存不足、磁盘满 |
| **并发冲突** | 处理竞态条件 | 同时修改同一资源 |

### 1.2 可选测试的场景

以下场景**可选**编写 failure path 测试：

- ⚠️ 内部断言失败（开发阶段错误，生产环境不应出现）
- ⚠️ 配置错误（启动时检查，运行时不应出现）
- ⚠️ 硬件故障（难以模拟，通常由基础设施处理）

---

## 二、常见 Failure Path 清单

### 2.1 输入验证失败

**测试场景**：
- ✅ 空值（null、undefined、空字符串）
- ✅ 超长字符串（超过最大长度限制）
- ✅ 非法字符（特殊字符、SQL 注入、XSS）
- ✅ 类型错误（字符串传入数字字段）
- ✅ 格式错误（邮箱、电话号码、日期）

**预期行为**：
- 返回 400 Bad Request
- 提供明确的错误信息（哪个字段、什么问题）
- 不泄露敏感信息

**测试示例**：
```python
def test_create_user_with_empty_name_returns_400():
    # Arrange
    user_data = {"name": "", "email": "test@example.com"}

    # Act
    response = client.post("/users", json=user_data)

    # Assert
    assert response.status_code == 400
    assert "name" in response.json()["errors"]
    assert "cannot be empty" in response.json()["errors"]["name"]
```

---

### 2.2 权限校验失败

**测试场景**：
- ✅ 未登录访问需要认证的资源
- ✅ 权限不足访问受限资源
- ✅ Token 过期
- ✅ Token 伪造

**预期行为**：
- 未登录：返回 401 Unauthorized
- 权限不足：返回 403 Forbidden
- 不泄露资源是否存在

**测试示例**：
```python
def test_access_admin_page_without_login_returns_401():
    # Act
    response = client.get("/admin/users")

    # Assert
    assert response.status_code == 401
    assert "authentication required" in response.json()["message"].lower()

def test_access_admin_page_as_regular_user_returns_403():
    # Arrange
    token = create_token(role="user")

    # Act
    response = client.get("/admin/users", headers={"Authorization": f"Bearer {token}"})

    # Assert
    assert response.status_code == 403
    assert "insufficient permissions" in response.json()["message"].lower()
```

---

### 2.3 资源不存在

**测试场景**：
- ✅ 查询不存在的 ID
- ✅ 访问已删除的资源
- ✅ 访问不属于当前用户的资源

**预期行为**：
- 返回 404 Not Found
- 提供友好的错误信息
- 不泄露其他用户的资源信息

**测试示例**：
```python
def test_get_nonexistent_user_returns_404():
    # Act
    response = client.get("/users/99999")

    # Assert
    assert response.status_code == 404
    assert "user not found" in response.json()["message"].lower()
```

---

### 2.4 外部依赖失败

**测试场景**：
- ✅ 数据库连接失败
- ✅ 网络超时
- ✅ 第三方 API 返回错误
- ✅ 消息队列不可用

**预期行为**：
- 返回 503 Service Unavailable
- 实现重试机制（如适用）
- 记录详细日志
- 提供降级方案（如适用）

**测试示例**：
```python
from unittest.mock import patch, Mock

def test_fetch_user_data_with_database_timeout_returns_503():
    # Arrange
    with patch('database.query') as mock_query:
        mock_query.side_effect = TimeoutError("Database timeout")

        # Act
        response = client.get("/users/1")

        # Assert
        assert response.status_code == 503
        assert "service temporarily unavailable" in response.json()["message"].lower()

def test_external_api_failure_with_retry():
    # Arrange
    with patch('requests.get') as mock_get:
        # 前两次失败，第三次成功
        mock_get.side_effect = [
            ConnectionError("Network error"),
            ConnectionError("Network error"),
            Mock(status_code=200, json=lambda: {"data": "success"})
        ]

        # Act
        result = fetch_external_data(max_retries=3)

        # Assert
        assert result == {"data": "success"}
        assert mock_get.call_count == 3
```

---

### 2.5 并发冲突

**测试场景**：
- ✅ 同时修改同一资源
- ✅ 乐观锁冲突
- ✅ 悲观锁超时

**预期行为**：
- 返回 409 Conflict
- 提供冲突解决建议
- 或自动重试

**测试示例**：
```python
def test_concurrent_update_returns_409():
    # Arrange
    user = create_user(name="Alice", version=1)

    # Act - 模拟两个并发更新
    response1 = client.put(f"/users/{user.id}", json={"name": "Alice Updated", "version": 1})
    response2 = client.put(f"/users/{user.id}", json={"name": "Alice Modified", "version": 1})

    # Assert
    assert response1.status_code == 200
    assert response2.status_code == 409
    assert "conflict" in response2.json()["message"].lower()
```

---

### 2.6 资源耗尽

**测试场景**：
- ✅ 内存不足
- ✅ 磁盘空间不足
- ✅ 连接池耗尽

**预期行为**：
- 返回 507 Insufficient Storage 或 503 Service Unavailable
- 优雅降级
- 触发告警

**测试示例**：
```python
def test_upload_file_with_insufficient_disk_space_returns_507():
    # Arrange
    with patch('os.statvfs') as mock_statvfs:
        mock_statvfs.return_value.f_bavail = 0  # 模拟磁盘满

        # Act
        response = client.post("/upload", files={"file": ("test.txt", b"content")})

        # Assert
        assert response.status_code == 507
        assert "insufficient storage" in response.json()["message"].lower()
```

---

## 三、Failure Path 测试最佳实践

### 3.1 测试命名规范

**推荐格式**：`test_<功能>_with_<失败场景>_<预期结果>`

**示例**：
```python
# ✅ 好的命名
def test_login_with_invalid_password_returns_401():
    pass

def test_create_order_with_insufficient_stock_returns_409():
    pass

# ❌ 不好的命名
def test_login_fail():
    pass

def test_error():
    pass
```

### 3.2 错误信息验证

**必须验证**：
- ✅ HTTP 状态码正确
- ✅ 错误信息清晰易懂
- ✅ 错误信息不泄露敏感信息

**示例**：
```python
def test_error_message_quality():
    response = client.post("/users", json={"email": "invalid"})

    assert response.status_code == 400
    # 验证错误信息清晰
    assert "email" in response.json()["errors"]
    assert "invalid format" in response.json()["errors"]["email"].lower()
    # 验证不泄露敏感信息
    assert "database" not in response.json()["errors"]["email"].lower()
```

---

## 四、与 Codex 审核集成

### 4.1 Codex 审核检查点

在 `ai/codex_review_gate.md` 的 **Blocking Rule 5** 中：

> 新增/修改关键逻辑缺少 failure path 测试

**Codex 审核时需验证**：
- ✅ 关键逻辑是否有 failure path 测试
- ✅ 错误信息是否清晰
- ✅ 错误处理是否健壮
- ✅ 是否有重试机制（如适用）
- ✅ 是否记录详细日志

### 4.2 审核清单

**对于每个关键功能，Codex 应检查**：

| 检查项 | 说明 | 示例 |
|--------|------|------|
| 输入验证 | 是否测试了非法输入 | 空值、超长字符串 |
| 权限校验 | 是否测试了未授权访问 | 未登录、权限不足 |
| 外部依赖 | 是否测试了依赖失败 | 数据库超时、API 失败 |
| 并发冲突 | 是否测试了竞态条件 | 乐观锁冲突 |
| 资源耗尽 | 是否测试了资源不足 | 磁盘满、内存不足 |

---

## 五、总结

### 5.1 核心要点

1. **关键逻辑必须测试失败路径**：确保错误处理健壮
2. **覆盖常见失败场景**：输入验证、权限校验、外部依赖、并发冲突、资源耗尽
3. **验证错误信息质量**：清晰、不泄露敏感信息
4. **与 Codex 审核集成**：Blocking Rule 5 强制要求

### 5.2 快速参考

| 失败类型 | HTTP 状态码 | 测试重点 |
|---------|------------|---------|
| 输入验证 | 400 | 空值、非法字符、格式错误 |
| 权限校验 | 401/403 | 未登录、权限不足 |
| 资源不存在 | 404 | 不存在的 ID |
| 并发冲突 | 409 | 乐观锁冲突 |
| 外部依赖 | 503 | 超时、连接失败 |
| 资源耗尽 | 507 | 磁盘满、内存不足 |

---

**文档版本**: v1.0
**最后更新**: 2026-01-17
**维护者**: CCG Team
