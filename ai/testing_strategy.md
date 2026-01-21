# 测试策略决策树

> **目标**：为 CCG 协作流程提供清晰的测试类型选择指南，确保代码质量和可维护性。

---

## 一、测试类型定义

### 1.1 单元测试 (Unit Tests)

**定义**：测试单个函数、类或模块的隔离行为，不依赖外部系统。

**特征**：
- ✅ 快速执行（毫秒级）
- ✅ 完全隔离（使用 mock/stub）
- ✅ 测试单一职责
- ✅ 易于定位问题

**适用场景**：
- 纯函数（无副作用）
- 业务逻辑计算
- 数据转换和验证
- 算法实现
- 工具函数

**工具推荐**：
- Python: `pytest`, `unittest`
- JavaScript/TypeScript: `Jest`, `Vitest`, `Mocha`
- Go: `testing` 包
- Java: `JUnit`, `TestNG`

---

### 1.2 集成测试 (Integration Tests)

**定义**：测试多个组件之间的交互，验证接口契约和数据流。

**特征**：
- ⏱️ 中等执行速度（秒级）
- 🔗 测试组件协作
- 🗄️ 可能涉及真实依赖（数据库、文件系统）
- 🎯 验证接口契约

**适用场景**：
- API 端点测试
- 数据库操作
- 文件系统交互
- 第三方服务集成
- 模块间通信

**工具推荐**：
- API 测试: `Postman`, `REST Assured`, `Supertest`
- 数据库: `Testcontainers`, `SQLite in-memory`
- Python: `pytest` + fixtures
- JavaScript: `Jest` + `supertest`

---

### 1.3 端到端测试 (E2E Tests)

**定义**：从用户视角测试完整业务流程，模拟真实使用场景。

**特征**：
- 🐢 执行较慢（分钟级）
- 🌐 测试完整用户流程
- 🖥️ 涉及 UI 交互（Web/移动端）
- 🔄 验证端到端数据流

**适用场景**：
- 关键用户流程（登录、支付、注册）
- 跨系统业务流程
- UI 交互验证
- 回归测试（防止破坏现有功能）

**工具推荐**：
- Web: `Playwright`, `Cypress`, `Selenium`
- 移动端: `Appium`, `Detox`
- API E2E: `Newman` (Postman CLI)

---

## 二、测试决策树

### 2.1 快速决策流程图

```
开始
  ↓
是否涉及 UI 交互？
  ├─ 是 → 是否关键用户流程？
  │        ├─ 是 → E2E 测试（必须）
  │        └─ 否 → 集成测试（UI 组件级）
  │
  └─ 否 → 是否涉及外部依赖？
           ├─ 是 → 是否可 mock？
           │        ├─ 是 → 单元测试 + 集成测试
           │        └─ 否 → 集成测试
           │
           └─ 否 → 是否纯逻辑计算？
                    ├─ 是 → 单元测试
                    └─ 否 → 根据复杂度选择
```

---

### 2.2 详细决策表

| 场景 | 单元测试 | 集成测试 | E2E 测试 | 理由 |
|------|---------|---------|---------|------|
| **纯函数/工具函数** | ✅ 必须 | ❌ 不需要 | ❌ 不需要 | 无副作用，易隔离 |
| **业务逻辑计算** | ✅ 必须 | ⚠️ 可选 | ❌ 不需要 | 核心逻辑需充分覆盖 |
| **数据库操作** | ⚠️ 可选 | ✅ 必须 | ❌ 不需要 | 需验证 SQL 正确性 |
| **API 端点** | ❌ 不需要 | ✅ 必须 | ⚠️ 可选 | 验证接口契约 |
| **第三方服务集成** | ⚠️ mock | ✅ 必须 | ❌ 不需要 | 验证集成逻辑 |
| **UI 组件（无状态）** | ✅ 必须 | ❌ 不需要 | ❌ 不需要 | 快照测试 + 属性测试 |
| **UI 组件（有状态）** | ✅ 必须 | ⚠️ 可选 | ❌ 不需要 | 测试状态变化 |
| **关键用户流程** | ⚠️ 可选 | ⚠️ 可选 | ✅ 必须 | 防止回归 |
| **支付/安全功能** | ✅ 必须 | ✅ 必须 | ✅ 必须 | 高风险，全覆盖 |
| **性能敏感代码** | ✅ 必须 | ✅ 必须 | ⚠️ 可选 | 需性能基准测试 |

---

## 三、测试覆盖率标准

### 3.1 按风险等级分类

| 风险等级 | 单元测试覆盖率 | 集成测试覆盖率 | E2E 测试覆盖率 | 说明 |
|---------|--------------|--------------|--------------|------|
| **高风险** | ≥ 90% | ≥ 80% | ≥ 90% | 支付、安全、数据完整性 |
| **中风险** | ≥ 80% | ≥ 60% | ≥ 50% | 核心业务逻辑 |
| **低风险** | ≥ 60% | ≥ 40% | ≥ 20% | 辅助功能、工具函数 |
| **实验性** | ≥ 40% | ≥ 20% | 可选 | 原型、POC 代码 |

### 3.2 覆盖率计算方式

**单元测试覆盖率**：
```
覆盖率 = (已测试的代码行数 / 总代码行数) × 100%
```

**集成测试覆盖率**：
```
覆盖率 = (已测试的接口数 / 总接口数) × 100%
```

**E2E 测试覆盖率**：
```
覆盖率 = (已测试的关键流程数 / 总关键流程数) × 100%
```

### 3.3 覆盖率豁免条件

以下情况可申请覆盖率豁免：
- ✅ 自动生成的代码（如 ORM 模型）
- ✅ 第三方库的封装（已有测试）
- ✅ 简单的 getter/setter
- ✅ 配置文件和常量定义
- ✅ 废弃代码（标记为 @deprecated）

**豁免流程**：
1. 在代码中添加 `# pragma: no cover` 或等效注释
2. 在 Contract 中说明豁免理由
3. Codex 审核时确认豁免合理性

---

## 四、测试编写原则

### 4.1 FIRST 原则

| 原则 | 说明 | 示例 |
|------|------|------|
| **Fast** | 快速执行 | 单元测试 < 100ms |
| **Independent** | 测试独立 | 不依赖执行顺序 |
| **Repeatable** | 可重复 | 任何环境都能运行 |
| **Self-validating** | 自验证 | 明确的 pass/fail |
| **Timely** | 及时编写 | 与代码同步开发 |

### 4.2 AAA 模式

```python
def test_example():
    # Arrange（准备）
    user = User(name="Alice", age=30)

    # Act（执行）
    result = user.is_adult()

    # Assert（断言）
    assert result is True
```

### 4.3 测试命名规范

**推荐格式**：`test_<方法名>_<场景>_<预期结果>`

**示例**：
```python
# ✅ 好的命名
def test_calculate_discount_with_valid_coupon_returns_discounted_price():
    pass

def test_login_with_invalid_password_raises_authentication_error():
    pass

# ❌ 不好的命名
def test_1():
    pass

def test_discount():
    pass
```

---

## 五、Failure Path 测试策略

> **核心原则**：关键逻辑必须测试失败路径，确保错误处理健壮。

### 5.1 何时需要 Failure Path 测试

**必须测试**：
- ✅ 用户输入验证（非法输入）
- ✅ 外部依赖失败（网络超时、数据库连接失败）
- ✅ 权限校验（未授权访问）
- ✅ 资源不足（内存、磁盘空间）
- ✅ 并发冲突（竞态条件）

**可选测试**：
- ⚠️ 内部断言失败（开发阶段错误）
- ⚠️ 配置错误（启动时检查）

### 5.2 Failure Path 测试模板

```python
def test_api_endpoint_with_network_timeout_returns_503():
    # Arrange
    mock_service = Mock(side_effect=TimeoutError("Network timeout"))

    # Act
    response = api_call(mock_service)

    # Assert
    assert response.status_code == 503
    assert "timeout" in response.error_message.lower()
```

### 5.3 常见 Failure Path 清单

| 失败类型 | 测试场景 | 预期行为 |
|---------|---------|---------|
| **输入验证** | 空值、超长字符串、非法字符 | 返回 400 错误 + 明确错误信息 |
| **权限校验** | 未登录、权限不足 | 返回 401/403 错误 |
| **资源不存在** | 查询不存在的 ID | 返回 404 错误 |
| **并发冲突** | 同时修改同一资源 | 返回 409 错误或重试 |
| **外部依赖失败** | 数据库连接失败、API 超时 | 返回 503 错误 + 重试机制 |
| **资源耗尽** | 内存不足、磁盘满 | 优雅降级或返回 507 错误 |

---

## 六、Mock 和依赖注入最佳实践

### 6.1 何时使用 Mock

**应该 Mock**：
- ✅ 外部 API 调用
- ✅ 数据库操作（单元测试）
- ✅ 文件系统操作
- ✅ 时间依赖（`datetime.now()`）
- ✅ 随机数生成

**不应该 Mock**：
- ❌ 被测试的核心逻辑
- ❌ 简单的数据结构（如 DTO）
- ❌ 纯函数

### 6.2 Mock 示例

**Python (pytest + unittest.mock)**：
```python
from unittest.mock import Mock, patch

def test_fetch_user_data_with_api_failure():
    # Mock 外部 API
    with patch('requests.get') as mock_get:
        mock_get.side_effect = ConnectionError("API unavailable")

        # 测试错误处理
        result = fetch_user_data(user_id=123)
        assert result is None
```

**JavaScript (Jest)**：
```javascript
test('fetchUserData handles API failure', async () => {
  // Mock fetch
  global.fetch = jest.fn(() =>
    Promise.reject(new Error('API unavailable'))
  );

  const result = await fetchUserData(123);
  expect(result).toBeNull();
});
```

### 6.3 依赖注入模式

**推荐**：通过构造函数或参数注入依赖

```python
# ✅ 好的设计（可测试）
class UserService:
    def __init__(self, db_client):
        self.db = db_client

    def get_user(self, user_id):
        return self.db.query(f"SELECT * FROM users WHERE id={user_id}")

# 测试时注入 Mock
def test_get_user():
    mock_db = Mock()
    mock_db.query.return_value = {"id": 1, "name": "Alice"}

    service = UserService(db_client=mock_db)
    user = service.get_user(1)

    assert user["name"] == "Alice"
```

---

## 七、测试执行策略

### 7.1 测试金字塔

```
        /\
       /  \  E2E Tests (10%)
      /____\
     /      \
    / Integration \ (30%)
   /___Tests______\
  /                \
 /  Unit Tests (60%) \
/____________________\
```

**比例建议**：
- 单元测试：60%（快速反馈）
- 集成测试：30%（验证协作）
- E2E 测试：10%（关键流程）

### 7.2 CI/CD 集成

**推荐流程**：
```yaml
# .github/workflows/test.yml
name: Test Pipeline

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Run Unit Tests
        run: pytest tests/unit --cov=src --cov-report=xml

      - name: Run Integration Tests
        run: pytest tests/integration

      - name: Run E2E Tests (on main branch only)
        if: github.ref == 'refs/heads/main'
        run: pytest tests/e2e

      - name: Upload Coverage
        uses: codecov/codecov-action@v3
```

### 7.3 测试执行时机

| 阶段 | 执行测试 | 触发条件 |
|------|---------|---------|
| **本地开发** | 单元测试 | 每次保存文件 |
| **提交前** | 单元 + 集成 | Git pre-commit hook |
| **PR 创建** | 单元 + 集成 | CI 自动触发 |
| **合并到主分支** | 全部测试 | CI 自动触发 |
| **发布前** | 全部测试 + 性能测试 | 手动触发 |

---

## 八、与 CCG 工作流集成

### 8.1 Contract 中的测试要求

在 `ai/contracts/contract_template.md` 的 **Section 5: Test Requirements** 中：

```markdown
## 5. Test Requirements

### 5.1 测试类型（根据决策树选择）
- [ ] 单元测试（必须）：覆盖率 ≥ 80%
- [ ] 集成测试（必须）：覆盖关键 API 端点
- [ ] E2E 测试（可选）：覆盖登录流程

### 5.2 Failure Path 测试
- [ ] 输入验证失败（空值、非法格式）
- [ ] 权限校验失败（未授权访问）
- [ ] 外部依赖失败（数据库连接超时）

### 5.3 测试工具
- 单元测试：pytest
- 集成测试：pytest + Testcontainers
- E2E 测试：Playwright

### 5.4 验收标准
- [ ] 所有测试通过（绿色）
- [ ] 覆盖率达标（见上）
- [ ] 无 flaky tests（不稳定测试）
```

### 8.2 Codex 审核检查点

在 `ai/codex_review_gate.md` 中已包含：

**Blocking Rule 5**：
> 新增/修改关键逻辑缺少 failure path 测试

**Codex 审核时需验证**：
- ✅ 测试类型选择合理（符合决策树）
- ✅ 覆盖率达标（符合风险等级）
- ✅ Failure path 测试完整
- ✅ 测试命名清晰
- ✅ 无重复测试

### 8.3 Coder 执行指南

**Coder 在编写代码时应**：
1. 根据测试决策树确定需要的测试类型
2. 先写测试（TDD 模式，可选）
3. 确保测试覆盖 happy path 和 failure path
4. 运行测试并确保通过
5. 在 Contract 中记录测试结果

---

## 九、常见问题 (FAQ)

### Q1: 什么时候可以跳过测试？

**A**: 仅在以下情况可跳过：
- 一次性脚本（不会复用）
- 原型代码（明确标记为 POC）
- 配置文件修改（无逻辑）

**必须在 Contract 中说明跳过理由，并经 Codex 审核批准。**

---

### Q2: 测试失败了怎么办？

**A**: 按以下流程处理：
1. **本地调试**：运行失败的测试，查看错误信息
2. **修复代码**：根据错误修复实现代码或测试代码
3. **重新运行**：确保所有测试通过
4. **提交前验证**：运行完整测试套件

**如果测试持续失败**：
- 检查是否为 flaky test（不稳定测试）
- 考虑是否需要调整测试策略
- 向 Codex 或 Gemini 咨询

---

### Q3: 如何处理遗留代码（无测试）？

**A**: 采用增量策略：
1. **新增功能**：必须有测试
2. **修改现有代码**：为修改部分添加测试
3. **重构**：逐步补充测试覆盖

**不要求一次性为所有遗留代码补测试。**

---

### Q4: 测试执行太慢怎么办？

**A**: 优化策略：
1. **并行执行**：使用 `pytest -n auto`（pytest-xdist）
2. **分层执行**：本地只跑单元测试，CI 跑全部
3. **缓存依赖**：使用 Docker 缓存、依赖缓存
4. **优化 E2E**：减少 E2E 测试数量，只覆盖关键流程

---

### Q5: 如何测试异步代码？

**A**: 使用异步测试框架：

**Python (pytest-asyncio)**：
```python
import pytest

@pytest.mark.asyncio
async def test_async_function():
    result = await async_fetch_data()
    assert result is not None
```

**JavaScript (Jest)**：
```javascript
test('async function', async () => {
  const result = await fetchData();
  expect(result).not.toBeNull();
});
```

---

## 十、总结

### 10.1 核心要点

1. **测试类型选择**：根据决策树选择单元/集成/E2E 测试
2. **覆盖率标准**：按风险等级设定目标（高风险 ≥ 90%）
3. **Failure Path**：关键逻辑必须测试失败路径
4. **测试金字塔**：60% 单元 + 30% 集成 + 10% E2E
5. **与 CCG 集成**：在 Contract 中明确测试要求，Codex 审核验证

### 10.2 快速参考

| 场景 | 测试类型 | 覆盖率 | 工具 |
|------|---------|--------|------|
| 纯函数 | 单元 | ≥ 80% | pytest/Jest |
| API 端点 | 集成 | ≥ 60% | Supertest/REST Assured |
| 关键流程 | E2E | ≥ 90% | Playwright/Cypress |
| 支付功能 | 全部 | ≥ 90% | 全栈测试 |

---

**文档版本**: v1.0
**最后更新**: 2026-01-17
**维护者**: CCG Team
