# CCG 项目接手指南

> **用途**：中途接手项目时的完整流程，确保快速理解项目并建立可靠的开发环境

## 概述

当 Claude 中途接手一个已有项目时，需要系统化地了解项目状态、建立开发环境、把控进度。本文档提供完整的接手流程和检查清单。

---

## 项目接手三阶段

```
第一阶段：项目理解（30-60分钟）
    ↓
第二阶段：环境建立（30-90分钟）
    ↓
第三阶段：进度把控（持续）
```

---

## 第一阶段：项目理解

### 1.1 项目基本信息收集

**执行顺序**：
```
1. 读取项目根目录文件
2. 识别项目类型和技术栈
3. 查找项目文档
4. 理解项目结构
```

**检查清单**：

#### ✅ 项目元数据
```bash
# 检查项目配置文件
ls -la | grep -E "package.json|pyproject.toml|pom.xml|Cargo.toml|go.mod"

# Python 项目
cat pyproject.toml
cat requirements.txt
cat setup.py

# Node.js 项目
cat package.json

# Java 项目
cat pom.xml
cat build.gradle

# Go 项目
cat go.mod
```

**记录信息**：
- 项目名称
- 项目版本
- 主要依赖和版本
- 构建工具
- 测试框架

#### ✅ 项目文档
```bash
# 查找文档文件
find . -maxdepth 2 -name "README*" -o -name "CONTRIBUTING*" -o -name "ARCHITECTURE*"

# 查找 docs 目录
ls -la docs/ 2>/dev/null
```

**优先阅读**：
1. README.md - 项目概述
2. ARCHITECTURE.md - 架构设计
3. CONTRIBUTING.md - 开发规范
4. docs/ - 详细文档

#### ✅ 项目结构分析
```bash
# 查看目录结构（限制深度）
tree -L 2 -d

# 或使用 ls
ls -la
```

**识别关键目录**：
- `src/` - 源代码
- `tests/` - 测试代码
- `docs/` - 文档
- `config/` - 配置文件
- `scripts/` - 脚本工具
- `.github/` - CI/CD 配置

#### ✅ Git 历史分析
```bash
# 查看最近提交
git log --oneline -20

# 查看活跃分支
git branch -a

# 查看最近修改的文件
git log --name-only --pretty=format: -20 | sort | uniq -c | sort -rn | head -20

# 查看贡献者
git shortlog -sn
```

**记录信息**：
- 最近的开发活动
- 主要贡献者
- 活跃的功能分支
- 最近修改的核心文件

### 1.2 技术栈识别

**自动检测脚本**：
```bash
# 检测技术栈
if [ -f "package.json" ]; then
    echo "Node.js 项目"
    cat package.json | jq '.dependencies, .devDependencies'
elif [ -f "pyproject.toml" ]; then
    echo "Python 项目"
    cat pyproject.toml
elif [ -f "pom.xml" ]; then
    echo "Java Maven 项目"
elif [ -f "build.gradle" ]; then
    echo "Java Gradle 项目"
elif [ -f "Cargo.toml" ]; then
    echo "Rust 项目"
elif [ -f "go.mod" ]; then
    echo "Go 项目"
fi
```

**记录到项目上下文**：
```json
{
  "project_name": "项目名称",
  "tech_stack": {
    "language": "Python",
    "version": "3.11",
    "framework": "FastAPI",
    "database": "PostgreSQL",
    "cache": "Redis"
  },
  "dependencies": {
    "core": ["fastapi", "sqlalchemy", "pydantic"],
    "dev": ["pytest", "black", "mypy"]
  }
}
```

---

## 第二阶段：环境建立

### 2.1 开发环境依赖记录

**目标**：建立完整的开发环境依赖清单，确保可复现

#### ✅ 系统级依赖
```bash
# 检查系统依赖
which python3 node npm java mvn go cargo

# 记录版本
python3 --version
node --version
npm --version
```

**记录到 `.ccg/project-context.json`**：
```json
{
  "environment": {
    "system_dependencies": {
      "python": "3.11.5",
      "node": "20.10.0",
      "npm": "10.2.3"
    },
    "required_tools": ["git", "docker", "postgresql-client"]
  }
}
```

#### ✅ 项目依赖安装
```bash
# Python 项目
pip install -r requirements.txt
pip install -r requirements-dev.txt

# Node.js 项目
npm install

# 记录安装结果
pip freeze > .ccg/installed-packages.txt  # Python
npm list --depth=0 > .ccg/installed-packages.txt  # Node.js
```

#### ✅ 环境验证脚本

**创建验证脚本** `.ccg/verify-environment.sh`：
```bash
#!/bin/bash
# 环境验证脚本

echo "=== 环境验证开始 ==="

# 1. 检查系统工具
echo "1. 检查系统工具..."
for tool in python3 node npm git; do
    if command -v $tool &> /dev/null; then
        echo "✅ $tool: $(command -v $tool)"
    else
        echo "❌ $tool: 未安装"
    fi
done

# 2. 检查 Python 依赖
if [ -f "requirements.txt" ]; then
    echo "2. 检查 Python 依赖..."
    pip check
fi

# 3. 检查 Node.js 依赖
if [ -f "package.json" ]; then
    echo "3. 检查 Node.js 依赖..."
    npm list --depth=0
fi

# 4. 运行测试
echo "4. 运行测试..."
if [ -f "pytest.ini" ] || [ -f "pyproject.toml" ]; then
    pytest --collect-only
elif [ -f "package.json" ]; then
    npm test -- --listTests 2>/dev/null || echo "测试配置未找到"
fi

echo "=== 环境验证完成 ==="
```

### 2.2 配置文件管理

#### ✅ 识别配置文件
```bash
# 查找配置文件
find . -maxdepth 2 -name "*.env*" -o -name "config.*" -o -name "settings.*"
```

**常见配置文件**：
- `.env` - 环境变量
- `config.yaml` - 应用配置
- `settings.py` - Python 配置
- `.env.example` - 配置模板

#### ✅ 记录配置依赖

**创建配置清单** `.ccg/config-checklist.md`：
```markdown
# 配置清单

## 必需配置
- [ ] DATABASE_URL - 数据库连接
- [ ] REDIS_URL - Redis 连接
- [ ] SECRET_KEY - 应用密钥

## 可选配置
- [ ] DEBUG - 调试模式
- [ ] LOG_LEVEL - 日志级别
```

---

## 第三阶段：进度把控

### 3.1 当前状态评估

#### ✅ 代码完成度分析
```bash
# 查找 TODO/FIXME
grep -r "TODO\|FIXME\|XXX\|HACK" --include="*.py" --include="*.js" --include="*.ts" src/

# 统计数量
grep -r "TODO" --include="*.py" src/ | wc -l
```

#### ✅ 测试覆盖率检查
```bash
# Python 项目
pytest --cov=src --cov-report=term-missing

# Node.js 项目
npm test -- --coverage
```

**记录结果**：
```json
{
  "test_coverage": {
    "total": "75%",
    "critical_modules": {
      "auth": "90%",
      "api": "80%",
      "utils": "60%"
    },
    "missing_tests": ["src/legacy.py", "src/experimental.js"]
  }
}
```

#### ✅ 未完成功能识别
```bash
# 查找未完成的功能分支
git branch -a | grep -E "feature|wip|dev"

# 查看 Issue 和 PR
gh issue list --state open
gh pr list --state open
```

### 3.2 进度跟踪机制

#### ✅ 创建项目状态快照

**保存到** `.ccg/project-snapshot.json`：
```json
{
  "snapshot_date": "2026-01-21",
  "project_status": {
    "phase": "development",
    "completion": "60%",
    "next_milestone": "v1.0 Beta"
  },
  "code_metrics": {
    "total_files": 150,
    "total_lines": 15000,
    "test_coverage": "75%",
    "todo_count": 23,
    "fixme_count": 8
  },
  "open_tasks": [
    "完成用户认证模块",
    "修复支付接口 Bug",
    "添加单元测试"
  ]
}
```

#### ✅ 建立进度检查点

**每周检查清单**：
```markdown
# 项目进度检查（Week N）

## 本周完成
- [ ] 功能 A 开发
- [ ] Bug #123 修复
- [ ] 测试覆盖率提升到 80%

## 下周计划
- [ ] 功能 B 开发
- [ ] 性能优化
- [ ] 文档更新

## 风险和阻塞
- 数据库迁移需要 DBA 支持
- 第三方 API 不稳定
```

---

## Claude 自动化接手流程

### 自动执行步骤

当 Claude 检测到接手新项目时，自动执行以下流程：

#### 步骤 1：项目扫描（5分钟）
```
1. 读取项目根目录文件列表
2. 识别项目类型（Python/Node.js/Java/Go）
3. 读取 README.md 和主要文档
4. 分析 Git 历史（最近 20 次提交）
```

#### 步骤 2：环境检查（10分钟）
```
1. 检查系统依赖是否安装
2. 尝试安装项目依赖
3. 运行环境验证脚本
4. 记录环境状态到 .ccg/project-context.json
```

#### 步骤 3：状态评估（15分钟）
```
1. 统计代码指标（文件数、行数、TODO数）
2. 检查测试覆盖率
3. 识别未完成功能
4. 生成项目状态快照
```

#### 步骤 4：向用户报告（5分钟）
```
生成接手报告，包含：
- 项目基本信息
- 技术栈和依赖
- 当前进度和完成度
- 发现的问题和风险
- 建议的下一步行动
```

### 接手报告模板

```markdown
# 项目接手报告

**生成时间**：2026-01-21 15:30
**项目路径**：/path/to/project

---

## 1. 项目概览

**项目名称**：MyApp
**项目类型**：Python Web 应用
**技术栈**：
- 语言：Python 3.11
- 框架：FastAPI
- 数据库：PostgreSQL
- 缓存：Redis

**项目规模**：
- 文件数：150
- 代码行数：15,000
- 测试覆盖率：75%

---

## 2. 环境状态

### ✅ 已安装依赖
- Python 3.11.5
- PostgreSQL 15.2
- Redis 7.0

### ⚠️ 缺失依赖
- Docker（推荐安装）

### ✅ 项目依赖
- 核心依赖：已安装（45个包）
- 开发依赖：已安装（12个包）

---

## 3. 当前进度

**整体完成度**：60%

**已完成模块**：
- ✅ 用户认证（90%）
- ✅ API 基础框架（100%）
- ✅ 数据库模型（80%）

**进行中模块**：
- 🔄 支付集成（40%）
- 🔄 通知系统（30%）

**未开始模块**：
- ❌ 管理后台
- ❌ 数据分析

---

## 4. 发现的问题

### 🔴 高优先级
1. 支付接口存在 Bug（Issue #123）
2. 测试覆盖率不足（目标 80%，当前 75%）

### 🟡 中优先级
1. 23 个 TODO 待处理
2. 8 个 FIXME 待修复

### 🟢 低优先级
1. 文档需要更新
2. 代码风格不统一

---

## 5. 建议的下一步

1. **立即行动**：修复支付接口 Bug
2. **本周完成**：提升测试覆盖率到 80%
3. **下周计划**：开始管理后台开发

---

## 6. 风险提示

- 数据库迁移脚本未测试
- 第三方 API 依赖不稳定
- 缺少性能测试

```

