# 测试验收标准

> **目标**：定义测试通过/失败的明确标准，避免模糊判断。

---

## 一、测试通过标准

### 1.1 必须满足的条件

以下条件**必须全部满足**才能认为测试通过：

| 条件 | 说明 | 验证方式 |
|------|------|---------|
| **所有测试用例通过** | 所有测试显示绿色（PASSED） | 运行测试套件，检查输出 |
| **覆盖率达标** | 按风险等级达到目标覆盖率 | 运行覆盖率工具（如 pytest-cov） |
| **无 flaky tests** | 测试结果稳定可重复 | 多次运行测试，结果一致 |
| **测试执行时间合理** | 单元测试 < 5 分钟，集成测试 < 15 分钟 | 检查 CI/CD 执行时间 |

### 1.2 可选满足的条件

以下条件**建议满足**，但不强制：

- ⚠️ 性能基准测试通过（如适用）
- ⚠️ 安全扫描通过（如适用）
- ⚠️ 代码质量检查通过（如 SonarQube）

---

## 二、测试失败处理流程

### 2.1 本地开发阶段

**流程**：
1. **运行失败的测试**：使用 `pytest tests/test_file.py::test_name` 单独运行
2. **查看错误信息**：分析断言失败原因、堆栈跟踪
3. **修复代码**：根据错误修复实现代码或测试代码
4. **重新运行**：确保修复后测试通过
5. **运行完整测试套件**：确保没有破坏其他测试
6. **提交代码**：通过后再提交

**示例**：
```bash
# 1. 运行失败的测试
pytest tests/test_user.py::test_create_user_with_valid_data -v

# 2. 查看详细错误信息
pytest tests/test_user.py::test_create_user_with_valid_data -vv

# 3. 修复代码后重新运行
pytest tests/test_user.py::test_create_user_with_valid_data

# 4. 运行完整测试套件
pytest tests/

# 5. 检查覆盖率
pytest tests/ --cov=src --cov-report=term-missing
```

---

### 2.2 CI/CD 阶段

**流程**：
1. **测试失败** → CI 自动阻止合并
2. **开发者修复** → 推送新提交
3. **CI 重新运行** → 自动触发测试
4. **所有测试通过** → 允许合并

**CI 配置示例**：
```yaml
# .github/workflows/test.yml
name: Test Pipeline

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Run tests
        run: pytest tests/ --cov=src --cov-report=xml

      - name: Check coverage
        run: |
          coverage report --fail-under=80

      - name: Block merge if tests fail
        if: failure()
        run: exit 1
```

---

## 三、测试豁免条件

### 3.1 可申请豁免的情况

以下情况可申请测试覆盖率豁免：

| 情况 | 说明 | 豁免标记 |
|------|------|---------|
| **自动生成的代码** | ORM 模型、Protobuf 生成的代码 | `# pragma: no cover` |
| **第三方库封装** | 已有上游测试的简单封装 | `# pragma: no cover` |
| **简单的 getter/setter** | 无逻辑的属性访问 | `# pragma: no cover` |
| **配置文件和常量** | 纯数据定义 | `# pragma: no cover` |
| **废弃代码** | 标记为 @deprecated 的代码 | `# pragma: no cover` |

### 3.2 豁免流程

**步骤**：
1. **在代码中添加豁免标记**：
   ```python
   def get_name(self):  # pragma: no cover
       return self.name
   ```

2. **在 Contract 中说明理由**：
   ```markdown
   ## 5. Test Requirements

   ### 5.6 测试豁免
   - `User.get_name()`: 简单的 getter，无逻辑
   - `models/generated.py`: ORM 自动生成的代码
   ```

3. **Codex 审核时确认合理性**：
   - 检查豁免理由是否充分
   - 确认豁免代码确实无需测试

---

## 四、Flaky Tests 处理

### 4.1 识别标准

**Flaky test 的特征**：
- 同一测试在相同环境下时而通过时而失败
- 依赖执行顺序或时间
- 依赖外部不稳定因素（网络、随机数）

**识别方法**：
```bash
# 多次运行测试，检查是否稳定
pytest tests/test_flaky.py --count=10
```

### 4.2 处理策略

**立即处理**：
1. **修复根本原因**：
   - 移除对执行顺序的依赖
   - Mock 不稳定的外部依赖
   - 固定随机数种子

2. **临时禁用**（如无法立即修复）：
   ```python
   @pytest.mark.skip(reason="Flaky test, tracking in issue #123")
   def test_flaky_function():
       pass
   ```

3. **使用重试机制**（临时方案，最多 3 次）：
   ```python
   @pytest.mark.flaky(reruns=3)
   def test_with_retry():
       pass
   ```

**不允许**：
- ❌ 合并包含 flaky tests 的代码
- ❌ 忽略 flaky tests 的存在
- ❌ 长期依赖重试机制

---

## 五、覆盖率验证

### 5.1 覆盖率工具配置

**Python (pytest-cov)**：
```bash
# 运行测试并生成覆盖率报告
pytest tests/ --cov=src --cov-report=term-missing --cov-report=html

# 检查覆盖率是否达标
pytest tests/ --cov=src --cov-fail-under=80
```

**配置文件 (.coveragerc)**：
```ini
[run]
source = src
omit =
    */tests/*
    */migrations/*
    */__pycache__/*

[report]
exclude_lines =
    pragma: no cover
    def __repr__
    raise AssertionError
    raise NotImplementedError
    if __name__ == .__main__.:
```

### 5.2 覆盖率报告解读

**关键指标**：
- **Line Coverage**: 代码行覆盖率
- **Branch Coverage**: 分支覆盖率（if/else）
- **Missing Lines**: 未覆盖的代码行

**示例输出**：
```
Name                 Stmts   Miss  Cover   Missing
--------------------------------------------------
src/user.py             50      5    90%   23-27
src/order.py            30      0   100%
--------------------------------------------------
TOTAL                   80      5    94%
```

---

## 六、与 CCG 工作流集成

### 6.1 Contract 中的验收标准

在 `ai/contracts/CONTRACT_TEMPLATE.md` Section 5 中应明确：

```markdown
## 5. Test Requirements

### 5.5 验收标准
- [ ] 所有测试通过（绿色）
- [ ] 单元测试覆盖率 ≥ 80%
- [ ] 集成测试覆盖率 ≥ 60%
- [ ] 无 flaky tests
- [ ] 测试执行时间 < 5 分钟（单元测试）
```

### 6.2 Codex 审核验证

**Codex 在审核时应检查**：
- ✅ 所有测试是否通过
- ✅ 覆盖率是否达标
- ✅ 是否存在 flaky tests
- ✅ 测试豁免是否合理

---

## 七、总结

### 7.1 核心要点

1. **测试通过标准**：所有测试通过 + 覆盖率达标 + 无 flaky tests
2. **测试失败处理**：本地调试 → 修复 → 重新运行 → 提交
3. **测试豁免**：仅限自动生成代码、简单 getter/setter 等
4. **Flaky tests**：立即修复或禁用，不允许合并

### 7.2 快速参考

| 检查项 | 标准 | 工具 |
|--------|------|------|
| 测试通过 | 所有测试绿色 | pytest |
| 覆盖率 | 按风险等级 60-90% | pytest-cov |
| Flaky tests | 无 | pytest --count=10 |
| 执行时间 | 单元 < 5 分钟 | CI/CD 日志 |

---

**文档版本**: v1.0
**最后更新**: 2026-01-17
**维护者**: CCG Team
