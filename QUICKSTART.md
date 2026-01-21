# CCG 快速开始指南

> 5 分钟快速上手 Coder-Codex-Gemini 多模型协作系统

---

## 📋 前置要求

在开始之前，请确保你已安装：

### 必需工具
- **Python 3.10+** - CCG MCP 服务器运行环境
- **Claude Code CLI** - AI 协作的核心工具
- **uv** - Python 包管理器（推荐）

### 推荐工具
- **Node.js & npm** - 用于安装额外的 MCP 服务器
- **Git** - 版本控制（用于 Git 安全检查功能）

### API 密钥准备
- **GLM API Token** - 从 [智谱 AI](https://open.bigmodel.cn) 获取（用于 Coder）
- **OpenAI API Key** - 从 [OpenAI](https://platform.openai.com) 获取（用于 Codex，可选）
- **Google API Key** - 从 [Google AI Studio](https://aistudio.google.com) 获取（用于 Gemini，可选）

---

## 🚀 安装步骤

### 1. 克隆项目

```bash
git clone https://github.com/szstan/Coder-Codex-Gemini.git
cd Coder-Codex-Gemini
```

### 2. 运行安装脚本

#### Windows 用户（PowerShell）
```powershell
.\setup.ps1
```

#### Windows 用户（CMD）
```cmd
setup.bat
```

#### Unix/macOS 用户
```bash
bash setup.sh
```

### 3. 配置 API Token

安装脚本会引导你完成配置：

```
==================================================================
  Coder Configuration - API Token Required
==================================================================

To get your API Token:
  1. Visit: https://open.bigmodel.cn
  2. Sign up / Login to your account
  3. Navigate to 'API Keys' section
  4. Create a new API key and copy it

Default Configuration:
  Base URL: https://open.bigmodel.cn/api/anthropic
  Model:    glm-4.7

==================================================================

Enter your API Token (required): [粘贴你的 API Token]
Enter Base URL (press Enter for default): [直接回车使用默认值]
Enter Model (press Enter for default): [直接回车使用默认值]
```

### 4. 配置 CLAUDE.md

当提示配置 CLAUDE.md 时，选择合适的选项：

```
CLAUDE.md already exists at: ~/.claude/CLAUDE.md

Choose an option:
  1. Overwrite (replace entire file with CCG configuration)
  2. Append (add CCG configuration to end of file)
  3. Skip (keep existing file unchanged)

Enter your choice [1/2/3] (default: 3):
```

**建议**：
- 首次安装：选择 `1`（覆盖）
- 已有配置：选择 `2`（追加）
- 不确定：选择 `3`（跳过，稍后手动配置）

---

## ✅ 验证安装

### 1. 检查 MCP 服务器

```bash
claude mcp list
```

你应该看到：
- ✅ `ccg` - CCG MCP 服务器
- ✅ `acemcp` - 语义搜索服务器
- ✅ `playwright` - 浏览器测试服务器

### 2. 检查 Skills

在 Claude Code 中输入：
```
/ccg-workflow
```

如果看到详细的工作流指导，说明安装成功！

### 3. 测试 Coder 工具

创建一个测试项目：
```bash
mkdir test-ccg
cd test-ccg
```

在 Claude Code 中尝试：
```
请使用 Coder 创建一个简单的 Python hello world 程序
```

---

## 📚 核心概念

### 角色分工

| 角色 | 定位 | 用途 |
|------|------|------|
| **Claude (你)** | 架构师 + 决策者 | 需求分析、任务拆分、验收审核 |
| **Coder** | 代码执行者 | 生成/修改代码、批量任务 |
| **Codex** | 代码审核者 | 架构设计、质量把关、Review |
| **Gemini** | 高阶顾问 | 前端/UI、第二意见、专家咨询 |

### 核心工作流

```
1. 需求分析（Claude）
   ↓
2. 数据库设计（如需要）→ /ccg-database-design
   ↓
3. Git 安全检查 → /ccg-git-safety
   ↓
4. Coder 执行代码
   ↓
5. Claude 快速验收
   ↓
6. Codex 审核（阶段性）
   ↓
7. 迭代修复（如有问题）
```

---

## 🎯 第一个任务

让我们通过一个简单的例子来体验 CCG 工作流：

### 任务：创建一个用户管理系统

#### 1. 启动 Claude Code
```bash
claude
```

#### 2. 执行数据库设计
```
我需要创建一个用户管理系统，包含用户注册、登录功能。
请先帮我设计数据库。
```

Claude 会：
- 分析需求，识别数据实体（User 表）
- 询问你选择设计方式（自行设计 or Codex 辅助）
- 调用 Codex 审核设计
- 保存设计文档到 `docs/database/`

#### 3. 执行代码开发
```
数据库设计完成后，请使用 Coder 实现用户注册和登录功能。
使用 Python + Flask 框架。
```

Claude 会：
- 执行 Git 安全检查（创建安全点）
- 调用 Coder 生成代码
- 快速验收代码质量
- 调用 Codex 审核代码

#### 4. 查看结果
```bash
ls -la
```

你会看到：
- `docs/database/` - 数据库设计文档
- `app.py` - Flask 应用代码
- `models.py` - 数据模型
- `requirements.txt` - 依赖列表

---

## 🔧 常用 Skills

### 协作流程
- `/ccg-workflow` - CCG 协作流程指南
- `/gemini-collaboration` - Gemini 协作指南

### 数据库设计
- `/ccg-database-design` - 数据库设计流程

### 安全保障
- `/ccg-git-safety` - Git 安全检查点

### 任务管理
- `/ccg-plan` - 生成实施计划
- `/ccg-execute` - 执行实施计划
- `/ccg-parallel` - 并行任务执行

### 质量保障
- `/ccg-review` - Claude 验收检查清单
- `/codex-code-review-enterprise` - Codex 企业级审核

### 测试修复
- `/ccg-test-fix` - 测试失败自动修复
- `/ccg-test-fix-advanced` - 多层级修复策略

---

## 💡 最佳实践

### 1. 任务拆分原则
- ⚠️ **一次调用，一个目标**
- ✅ 精准 Prompt：目标明确、上下文充分
- ✅ 按模块拆分：相关改动合并，独立模块分开
- ✅ 阶段性 Review：每模块验收，里程碑审核

### 2. 数据库设计先行
涉及以下场景时，必须先执行 `/ccg-database-design`：
- 新增数据表/集合
- 修改现有数据结构
- 涉及数据迁移
- 修改数据关系（外键、索引）

### 3. Git 安全检查
在调用 Coder/Gemini 改动代码前，必须执行 `/ccg-git-safety`：
- 创建 Git stash 安全点
- 记录改动前状态
- 提供完整回退指导

### 4. Codex + Gemini 双顾问模式
复杂前端问题时使用：
```
Codex 架构分析 → Gemini 实现 → Codex 审核
```

---

## 🐛 常见问题

### Q1: 安装时提示 "npm is not installed"
**解决方案**：安装 Node.js 和 npm
- Windows: 从 [nodejs.org](https://nodejs.org) 下载安装
- macOS: `brew install node`
- Linux: `sudo apt install nodejs npm`

### Q2: Playwright MCP 注册失败
**解决方案**：这是警告，不影响核心功能。可以稍后手动注册：
```bash
# 编辑 ~/.claude/mcp.json，添加：
{
  "mcpServers": {
    "playwright": {
      "command": "cmd",
      "args": ["/c", "npx", "-y", "@executeautomation/playwright-mcp-server"],
      "env": { "SYSTEMROOT": "C:\\Windows" }
    }
  }
}
```

### Q3: Coder 调用失败
**检查配置**：
```bash
cat ~/.ccg-mcp/config.toml
```

确保：
- `api_token` 已正确填写
- `base_url` 可访问
- `model` 名称正确

### Q4: CLAUDE.md 配置未生效
**手动配置**：
```bash
# 复制模板到全局配置
cp templates/ccg-global-prompt.md ~/.claude/CLAUDE.md

# 或追加到现有配置
cat templates/ccg-global-prompt.md >> ~/.claude/CLAUDE.md
```

### Q5: Skills 未加载
**重启 Claude Code**：
- VSCode: `Ctrl+Shift+P` → "Developer: Reload Window"
- CLI: 退出并重新启动 `claude`

---

## 📖 进阶学习

### 文档资源
- `README.md` - 项目概述和架构
- `ai/dependencies.md` - 系统依赖清单
- `ai/contract_quality_standards.md` - Contract 质量标准
- `ai/testing_strategy.md` - 测试策略指南
- `ai/git_workflow.md` - Git 工作流规范

### Skills 文档
- `skills/ccg-workflow/SKILL.md` - 完整工作流文档
- `skills/ccg-database-design/skill.md` - 数据库设计详解
- `skills/ccg-git-safety/skill.md` - Git 安全机制

### 配置文件
- `config.example.toml` - 配置文件示例
- `templates/ccg-global-prompt.md` - 全局 Prompt 模板

---

## 🎉 开始使用

现在你已经准备好使用 CCG 了！

**推荐的第一步**：
1. 阅读 `/ccg-workflow` 了解完整工作流
2. 尝试一个简单的任务（如创建 Hello World）
3. 体验数据库设计流程（`/ccg-database-design`）
4. 探索 Git 安全检查（`/ccg-git-safety`）

**需要帮助？**
- 查看 [GitHub Issues](https://github.com/szstan/Coder-Codex-Gemini/issues)
- 阅读项目文档
- 参考 `cases/` 目录中的实测案例

祝你使用愉快！🚀
