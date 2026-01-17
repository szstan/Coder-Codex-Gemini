# Git 工作流规范

> **目标**：定义测试完成后的 Git 提交、推送和合并流程，确保代码质量和团队协作效率。

---

## 一、核心原则

### 1.1 提交前置条件

**必须满足以下所有条件才能提交代码**：

| 条件 | 说明 | 验证方式 |
|------|------|---------|
| ✅ **所有测试通过** | 单元测试 + 集成测试全部绿色 | `pytest tests/` |
| ✅ **覆盖率达标** | 按风险等级达到目标覆盖率 | `pytest --cov=src --cov-fail-under=80` |
| ✅ **无 flaky tests** | 测试结果稳定可重复 | `pytest --count=3` |
| ✅ **代码风格检查通过** | 符合项目代码规范 | `black . && flake8` (Python) |
| ✅ **Codex 审核通过** | 阶段性开发完成后必须通过 Codex 审核 | 调用 Codex MCP 工具 |

### 1.2 禁止行为

**严禁以下行为**：
- ❌ 测试失败时提交代码
- ❌ 跳过 Codex 审核直接提交
- ❌ 提交包含 `TODO` 或 `FIXME` 的关键代码（除非在 Contract 中明确说明）
- ❌ 提交包含调试代码（`console.log`、`print` 等）
- ❌ 提交包含敏感信息（密码、API Key 等）

---

## 二、Git 提交流程

### 2.1 本地开发完整流程

```bash
# 1. 确保在正确的分支上
git status
git branch

# 2. 运行完整测试套件
pytest tests/ --cov=src --cov-report=term-missing

# 3. 运行代码风格检查（Python 示例）
black .
flake8 src/ tests/

# 4. 查看改动文件
git status
git diff

# 5. 添加文件到暂存区
git add <file1> <file2>
# 或添加所有改动（谨慎使用）
git add .

# 6. 提交代码（使用规范的提交信息）
git commit -m "feat: 添加用户认证功能

- 实现 JWT token 生成和验证
- 添加登录和注册接口
- 覆盖率：单元测试 92%，集成测试 85%
- Codex 审核：✅ 通过

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

# 7. 推送到远程仓库
git push origin <branch-name>
```

### 2.2 提交信息规范

**格式**：
```
<type>: <subject>

<body>

<footer>
```

**Type 类型**：
- `feat`: 新功能
- `fix`: Bug 修复
- `refactor`: 重构（不改变功能）
- `test`: 添加或修改测试
- `docs`: 文档更新
- `style`: 代码格式化（不影响功能）
- `perf`: 性能优化
- `chore`: 构建工具或辅助工具的变动

**示例**：
```
feat: 添加用户认证功能

- 实现 JWT token 生成和验证
- 添加登录和注册接口
- 覆盖率：单元测试 92%，集成测试 85%
- Codex 审核：✅ 通过

Closes #123

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

---

## 三、推送到远程仓库

### 3.1 何时推送

**立即推送的情况**：
- ✅ 所有测试通过 + Codex 审核通过
- ✅ 功能开发完成（一个完整的功能模块）
- ✅ Bug 修复完成并验证
- ✅ 需要触发 CI/CD 流程

**延迟推送的情况**：
- ⏸️ 功能开发中途（未完成完整功能）
- ⏸️ 实验性代码（不确定是否保留）
- ⏸️ 本地调试中（频繁修改）

### 3.2 推送前检查清单

```bash
# 1. 确认当前分支
git branch

# 2. 拉取最新代码（避免冲突）
git pull origin <branch-name> --rebase

# 3. 解决冲突（如有）
# 编辑冲突文件 → git add <file> → git rebase --continue

# 4. 再次运行测试（确保合并后仍然通过）
pytest tests/

# 5. 推送到远程
git push origin <branch-name>
```

### 3.3 推送失败处理

**常见问题**：

| 错误 | 原因 | 解决方案 |
|------|------|---------|
| `rejected (non-fast-forward)` | 远程有新提交 | `git pull --rebase` 后重新推送 |
| `rejected (pre-receive hook)` | CI 测试失败 | 修复测试后重新推送 |
| `permission denied` | 无推送权限 | 联系仓库管理员 |

---

## 四、分支策略

### 4.1 推荐分支模型

**主分支**：
- `main` / `master`: 生产环境代码，始终保持可部署状态
- `develop`: 开发分支，集成所有功能分支

**辅助分支**：
- `feature/<feature-name>`: 功能开发分支
- `bugfix/<bug-name>`: Bug 修复分支
- `hotfix/<issue-name>`: 紧急修复分支

### 4.2 分支操作流程

**创建功能分支**：
```bash
# 从 develop 分支创建功能分支
git checkout develop
git pull origin develop
git checkout -b feature/user-authentication
```

**开发完成后合并**：
```bash
# 1. 切换到 develop 分支
git checkout develop
git pull origin develop

# 2. 合并功能分支
git merge feature/user-authentication --no-ff

# 3. 推送到远程
git push origin develop

# 4. 删除功能分支（可选）
git branch -d feature/user-authentication
git push origin --delete feature/user-authentication
```

---

## 五、与 CCG 工作流集成

### 5.1 完整开发流程

```
用户需求
  ↓
Claude 分析 + 创建 Contract
  ↓
Coder 执行代码改动
  ↓
Claude 验收（快速检查）
  ↓
运行测试（pytest）
  ↓
Codex 审核（阶段性）
  ↓
【Git 提交点】← 此时才提交代码
  ↓
推送到远程仓库
  ↓
触发 CI/CD 流程
  ↓
完成
```

### 5.2 CCG 工作流中的 Git 操作时机

| 阶段 | Git 操作 | 说明 |
|------|---------|------|
| **Coder 执行** | 无 | Coder 只修改代码，不提交 |
| **Claude 验收** | 无 | Claude 检查代码，不提交 |
| **测试通过** | 无 | 测试通过后仍需 Codex 审核 |
| **Codex 审核通过** | ✅ **提交 + 推送** | 此时才执行 Git 操作 |

### 5.3 自动化 Git 操作（可选）

**在 CCG 工作流中集成 Git 操作**：

```markdown
## Codex 审核通过后的自动化流程

1. **Claude 执行 Git 提交**：
   - 生成规范的提交信息
   - 包含改动摘要、测试覆盖率、Codex 审核结果
   - 添加 Co-Authored-By 标记

2. **Claude 推送到远程**：
   - 检查是否有冲突
   - 推送到对应分支
   - 报告推送结果

3. **触发 CI/CD**：
   - 远程 CI 自动运行测试
   - 如失败，Claude 拉取日志并修复
```

---

## 六、CI/CD 集成

### 6.1 推送后的自动化流程

**GitHub Actions 示例**：
```yaml
# .github/workflows/ci.yml
name: CI Pipeline

on:
  push:
    branches: [ main, develop, feature/* ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install pytest pytest-cov

      - name: Run tests
        run: pytest tests/ --cov=src --cov-report=xml

      - name: Check coverage
        run: coverage report --fail-under=80

      - name: Upload coverage
        uses: codecov/codecov-action@v3
```

### 6.2 CI 失败处理

**流程**：
1. **CI 失败通知** → GitHub 发送邮件/Slack 通知
2. **Claude 拉取 CI 日志** → 分析失败原因
3. **修复问题** → Coder 修复代码
4. **重新测试** → 本地验证通过
5. **提交修复** → 推送新提交
6. **CI 重新运行** → 自动触发

---

## 七、最佳实践

### 7.1 提交频率

**推荐**：
- ✅ 每完成一个独立功能模块就提交
- ✅ 每修复一个 Bug 就提交
- ✅ 每次 Codex 审核通过后就提交

**避免**：
- ❌ 一天只提交一次（粒度太粗）
- ❌ 每改一行就提交（粒度太细）
- ❌ 积累大量改动后一次性提交（难以回滚）

### 7.2 提交粒度

**好的提交**：
- ✅ 一个提交只做一件事
- ✅ 提交信息清晰描述改动
- ✅ 可以独立回滚而不影响其他功能

**不好的提交**：
- ❌ 一个提交包含多个不相关的改动
- ❌ 提交信息模糊（如 "fix bug"）
- ❌ 提交包含未完成的代码

### 7.3 代码审查

**Pull Request 流程**：
```bash
# 1. 创建功能分支并开发
git checkout -b feature/new-feature

# 2. 开发完成后推送
git push origin feature/new-feature

# 3. 在 GitHub 上创建 Pull Request
# 4. 等待 CI 通过 + 人工审查
# 5. 审查通过后合并到 develop
# 6. 删除功能分支
```

---

## 八、总结

### 8.1 核心要点

1. **提交前置条件**：测试通过 + Codex 审核通过
2. **提交时机**：Codex 审核通过后立即提交并推送
3. **提交信息**：使用规范格式，包含改动摘要和审核结果
4. **分支策略**：使用 feature 分支开发，合并到 develop
5. **CI/CD 集成**：推送后自动触发测试，失败则修复

### 8.2 快速参考

| 操作 | 命令 | 时机 |
|------|------|------|
| 提交代码 | `git commit -m "..."` | Codex 审核通过后 |
| 推送代码 | `git push origin <branch>` | 提交后立即推送 |
| 创建分支 | `git checkout -b feature/<name>` | 开始新功能开发前 |
| 合并分支 | `git merge <branch> --no-ff` | 功能开发完成后 |

---

**文档版本**: v1.0
**最后更新**: 2026-01-17
**维护者**: CCG Team
