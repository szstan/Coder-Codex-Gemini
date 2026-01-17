# CCG 系统依赖清单

> **用途**：本文档列出 CCG 系统在各个阶段使用的 Skill、MCP 工具和技术依赖，帮助用户完成初始化配置。

## 必需的 MCP 工具

### 1. CCG 核心工具（必需）

**来源**：CCG MCP 服务器（本项目）

| 工具名称 | 用途 | 配置要求 |
|---------|------|---------|
| `mcp__ccg__coder` | 代码执行者，生成和修改代码 | 需配置 Coder 后端 API（如 GLM-4.7） |
| `mcp__ccg__codex` | 代码审核者，质量把关 | 需配置 OpenAI Codex API |
| `mcp__ccg__gemini` | 高阶顾问，架构设计和第二意见 | 需配置 Gemini CLI |

**配置文件**：`~/.ccg-mcp/config.toml`

```toml
[coder]
api_token = "your-api-token"
base_url = "https://open.bigmodel.cn/api/anthropic"
model = "glm-4.7"

[codex]
# Codex 配置（使用 OpenAI API）

[gemini]
# Gemini 配置
```

### 2. acemcp 语义搜索（强烈推荐）

**来源**：https://github.com/yeuxuan/Ace-Mcp-Node

| 工具名称 | 用途 | 配置要求 |
|---------|------|---------|
| `mcp__acemcp__search_context` | 语义搜索相关代码，提高修复准确性 | 需安装 `npx acemcp-node` |

**安装命令**：
```bash
npm install -g acemcp-node
```

**使用场景**：
- 测试失败多层级修复策略（每层修复前搜索相关代码）
- 代码重构和改进（查找类似实现模式）
- 问题诊断（查找相关的辅助函数和工具类）

## CCG Skills（内置）

### 核心 Skills

| Skill 名称 | 用途 | 调用方式 |
|-----------|------|---------|
| `/ccg-workflow` | CCG 协作流程指导 | 调用 Coder/Codex 前必须先执行 |
| `/gemini-collaboration` | Gemini 协作指南 | 调用 Gemini 前必须先执行 |

**位置**：`skills/` 目录

**使用规则**：
- 在调用任何 CCG MCP 工具之前，必须先执行对应的 Skill
- Skills 提供最佳实践指导和 Prompt 模板

## 各阶段依赖清单

### 阶段 1：代码生成和修改

**使用的工具**：
- ✅ `mcp__ccg__coder` - 执行代码生成/修改
- ✅ `/ccg-workflow` Skill - 获取最佳实践

**可选增强**：
- 🔧 `mcp__acemcp__search_context` - 搜索项目中类似实现

**文档参考**：
- `ai/ccg_workflow.md` - CCG 协作流程

### 阶段 2：测试失败自动修复（单层）

**使用的工具**：
- ✅ `mcp__ccg__coder` - 执行代码修复
- ✅ Bash 工具 - 运行测试命令
- ✅ Read 工具 - 读取测试和源代码

**文档参考**：
- `ai/testing/test_failure_auto_fix.md` - 单层自动修复指南
- `ai/error-handling/error_classification.md` - 错误分类系统

### 阶段 3：测试失败多层级修复（推荐）

**使用的工具**：
- ✅ `mcp__ccg__coder` - 第 1 层快速修复
- ✅ `mcp__ccg__codex` - 第 2 层专家诊断
- ✅ `mcp__ccg__gemini` - 第 4 层独立视角
- ✅ Edit 工具 - 第 3 层 Claude 亲自修复
- ✅ `mcp__acemcp__search_context` - 每层修复前语义搜索
- ✅ Bash 工具 - 运行测试命令

**文档参考**：
- `ai/testing/test_failure_multi_tier_fix.md` - 多层级修复策略

### 阶段 4：代码质量审核

**使用的工具**：
- ✅ `mcp__ccg__codex` - 代码审核和质量把关
- ✅ `/ccg-workflow` Skill - 获取审核最佳实践

**文档参考**：
- `ai/code_review.md` - 代码审核指南

### 阶段 5：Gemini 专家咨询（可选）

**使用的工具**：
- ✅ `mcp__ccg__gemini` - 架构设计、第二意见
- ✅ `/gemini-collaboration` Skill - 获取 Gemini 协作指南

**文档参考**：
- `skills/gemini-collaboration/skill.md` - Gemini 协作指南

## 初始化检查清单

### 步骤 1：安装 CCG MCP 服务器

```bash
# 克隆项目
git clone https://github.com/szstan/Coder-Codex-Gemini.git
cd Coder-Codex-Gemini

# 运行安装脚本
# Windows:
setup.bat

# Unix/macOS:
./setup.sh
```

### 步骤 2：配置 CCG MCP 工具

创建配置文件 `~/.ccg-mcp/config.toml`：

```toml
[coder]
api_token = "your-coder-api-token"
base_url = "https://open.bigmodel.cn/api/anthropic"
model = "glm-4.7"

[codex]
api_token = "your-openai-api-token"

[gemini]
# Gemini 配置
```

### 步骤 3：安装 acemcp（强烈推荐）

```bash
npm install -g acemcp-node
```

**验证安装**：
```bash
npx acemcp-node --version
```

### 步骤 4：配置 Claude Code

将 CCG 全局 Prompt 复制到 Claude Code 配置：

```bash
# 复制模板到全局配置
cp templates/ccg-global-prompt.md ~/.claude/CLAUDE.md
```

### 步骤 5：验证配置

**检查清单**：
- [ ] CCG MCP 服务器已安装
- [ ] `~/.ccg-mcp/config.toml` 已配置
- [ ] acemcp 已安装并可用
- [ ] Claude Code 全局配置已设置
- [ ] 可以调用 `mcp__ccg__coder`
- [ ] 可以调用 `mcp__ccg__codex`
- [ ] 可以调用 `mcp__ccg__gemini`
- [ ] 可以调用 `mcp__acemcp__search_context`

## 常见问题

### Q1: 必须安装所有工具吗？

**A**: 不是。最小配置只需要：
- ✅ `mcp__ccg__coder` - 核心代码执行
- ✅ Claude Code 基础工具（Read, Edit, Bash）

**推荐配置**：
- ✅ `mcp__ccg__coder` + `mcp__ccg__codex` - 代码执行 + 质量审核
- ✅ `mcp__acemcp__search_context` - 语义搜索增强

**完整配置**：
- ✅ 所有 CCG 工具 + acemcp

### Q2: acemcp 的作用是什么？

**A**: acemcp 提供语义搜索能力，显著提高修复准确性。

**核心价值**：
- **语义理解**：不只是关键词匹配，理解代码的语义关系
- **自动索引**：搜索前自动增量更新索引，确保结果最新
- **全面覆盖**：找到所有相关代码，包括辅助函数、工具类、类似实现

**使用场景**：
- 测试失败修复：每层修复前搜索相关代码上下文
- 代码重构：查找项目中类似实现模式
- 问题诊断：查找相关的辅助函数和工具类

**预期效果**：
- 提高修复成功率：从 90-95% 提升到 92-97%
- 减少遗漏：避免遗漏相关的辅助函数
- 加快理解：快速了解项目中相关功能的实现方式

### Q3: 如何验证配置是否正确？

**A**: 按照以下步骤验证：

**步骤 1：验证 CCG MCP 服务器**
```bash
# 检查 MCP 服务器是否安装
which ccg-mcp  # Unix/macOS
where ccg-mcp  # Windows
```

**步骤 2：验证配置文件**
```bash
# 检查配置文件是否存在
cat ~/.ccg-mcp/config.toml  # Unix/macOS
type %USERPROFILE%\.ccg-mcp\config.toml  # Windows
```

**步骤 3：验证 acemcp**
```bash
npx acemcp-node --version
```

**步骤 4：在 Claude Code 中测试**
- 尝试调用 `/ccg-workflow` Skill
- 尝试调用 `mcp__ccg__coder` 工具（简单任务）
- 检查是否有错误信息

### Q4: 遇到配置问题怎么办？

**A**: 常见问题和解决方案：

**问题 1：找不到 ccg-mcp 命令**
- 检查是否运行了安装脚本（`setup.bat` 或 `setup.sh`）
- 检查 Python 环境是否正确配置
- 尝试重新安装：`pip install -e .`

**问题 2：MCP 工具调用失败**
- 检查 `~/.ccg-mcp/config.toml` 是否存在
- 检查 API token 是否正确配置
- 检查网络连接是否正常

**问题 3：acemcp 无法使用**
- 检查 Node.js 是否已安装：`node --version`
- 重新安装：`npm install -g acemcp-node`
- 检查 npm 全局路径是否在 PATH 中

**问题 4：Skill 无法加载**
- 检查 `skills/` 目录是否存在
- 检查 Skill 文件格式是否正确
- 重启 Claude Code

## 总结

### 核心依赖关系

```
CCG 系统
├── 必需组件
│   ├── CCG MCP 服务器（本项目）
│   ├── mcp__ccg__coder（代码执行）
│   └── Claude Code 基础工具
│
├── 推荐组件
│   ├── mcp__ccg__codex（代码审核）
│   └── mcp__acemcp__search_context（语义搜索）
│
└── 可选组件
    └── mcp__ccg__gemini（专家咨询）
```

### 快速参考表

| 阶段 | 必需工具 | 推荐工具 | 文档参考 |
|------|---------|---------|---------|
| 代码生成 | Coder, /ccg-workflow | acemcp | `ai/ccg_workflow.md` |
| 单层修复 | Coder, Bash, Read | - | `ai/testing/test_failure_auto_fix.md` |
| 多层修复 | Coder, Codex, Claude, Gemini, acemcp | - | `ai/testing/test_failure_multi_tier_fix.md` |
| 代码审核 | Codex, /ccg-workflow | - | `ai/code_review.md` |
| 专家咨询 | Gemini, /gemini-collaboration | - | `skills/gemini-collaboration/skill.md` |

### 推荐配置路径

**最小配置（快速开始）**：
1. 安装 CCG MCP 服务器
2. 配置 Coder 后端
3. 开始使用代码生成功能

**推荐配置（日常开发）**：
1. 最小配置 +
2. 配置 Codex 审核
3. 安装 acemcp 语义搜索
4. 启用多层级修复策略

**完整配置（企业级）**：
1. 推荐配置 +
2. 配置 Gemini 专家咨询
3. 完善所有文档和流程

