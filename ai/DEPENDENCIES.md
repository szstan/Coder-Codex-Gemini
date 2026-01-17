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

## Claude Code Skills

### 1. CCG Skills（项目内置，克隆即用）

| Skill 名称 | 用途 | 调用方式 |
|-----------|------|---------|
| `/ccg-workflow` | CCG 协作流程指导 | 调用 Coder/Codex 前必须先执行 |
| `/gemini-collaboration` | Gemini 协作指南 | 调用 Gemini 前必须先执行 |
| `/ccg:plan` | 规划生成器 | 为复杂任务生成详细实施计划 |
| `/ccg:execute` | 计划执行器 | 执行已生成的实施计划 |
| `/ccg:parallel` | 并行任务执行器 | 将大型任务拆分为多个独立子任务并行执行 |
| `/ccg:contract` | Contract 创建和检查 | 复杂任务前创建 Contract（15-20 分钟） |
| `/ccg:review` | Claude 验收检查清单 | Coder 执行后快速验收（5-10 分钟） |
| `/ccg:codex-gate` | Codex 审核门禁 | Codex 审核前明确 Blocking 规则 |
| `/ccg:checkpoint` | 配置检查点 | 定期重申核心配置和状态（每完成主要任务后） |
| `/ccg:test-fix` | 测试失败自动修复 | 单层 Coder 修复（最多 3 次重试） |
| `/ccg:test-fix-advanced` | 测试失败多层级修复 | 4 层修复策略（Coder → Codex → Claude → Gemini） |
| `/codex-code-review-enterprise` | 企业级 PR 代码评审 | 严格范围内的评审，按优先级输出问题清单 |

**位置**：`skills/` 目录

**自动化程度**：✅ **克隆项目后自动可用，无需配置**

**使用规则**：
- 在调用任何 CCG MCP 工具之前，必须先执行对应的 Skill
- Skills 提供最佳实践指导和 Prompt 模板

### 2. Superpowers Skills（官方插件，强烈推荐）

**来源**：Claude Code 官方插件

**自动化程度**：✅ **Claude Code 自动安装和更新，无需任何配置**

**核心 Skills**：

| Skill 名称 | 用途 | 使用场景 |
|-----------|------|---------|
| `/superpowers:brainstorming` | 创意探索和需求分析 | 创建功能、构建组件、修改行为前必须使用 |
| `/superpowers:writing-plans` | 编写实施计划 | 多步骤任务，需要用户审查计划 |
| `/superpowers:executing-plans` | 执行实施计划 | 有书面实施计划需要执行时 |
| `/superpowers:test-driven-development` | 测试驱动开发 | 实现任何功能或 bugfix 前使用 |
| `/superpowers:systematic-debugging` | 系统化调试 | 遇到 bug、测试失败或意外行为时 |
| `/superpowers:requesting-code-review` | 请求代码审核 | 完成任务、实现主要功能或合并前 |
| `/superpowers:verification-before-completion` | 完成前验证 | 声称工作完成、修复或通过前必须使用 |

**位置**：`~/.claude/plugins/cache/claude-plugins-official/superpowers/`

**安装状态**：Claude Code 自动安装和更新

### 3. OpenSpec-CN（规范驱动开发，项目内置）

**来源**：OpenSpec 中文版工具

**自动化程度**：✅ **克隆项目后自动可用，无需配置**

**核心命令**：

| 命令 | 用途 | 使用场景 |
|------|------|---------|
| `openspec:proposal` | 创建变更提案 | 添加功能、重大变更、架构变更 |
| `openspec:apply` | 应用变更 | 实施已批准的提案 |
| `openspec:archive` | 归档变更 | 部署后归档变更 |

**位置**：`.claude/commands/openspec/`

**使用场景**：
- 需要规范驱动开发流程
- 多人协作项目
- 需要变更追踪和审批流程

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

### 阶段 6：配置持久化和状态管理

**核心问题**：长期工作后容易忘记初始配置，SESSION_ID 丢失或混用。

**使用的工具**：
- ✅ `/ccg:checkpoint` Skill - 定期重申核心配置和状态
- ✅ `.ccg/state.json` - 状态文件持久化

**状态文件位置**：`.ccg/state.json`

**状态文件内容**：
```json
{
  "version": "1.0",
  "session_ids": {
    "coder": "",
    "codex": "",
    "gemini": ""
  },
  "current_contract": "",
  "workflow_stage": "idle",
  "mandatory_rules": [
    "所有代码改动必须委托 Coder 执行",
    "Coder 完成后必须 Claude 验收（/ccg:review）",
    "阶段性完成后必须 Codex 审核（/ccg:codex-gate）",
    "必须保存和复用 SESSION_ID"
  ],
  "checkpoint_counter": 0,
  "last_checkpoint": ""
}
```

**检查点触发时机**：
- ✅ 每完成一个主要任务后
- ✅ 对话轮次达到阈值（建议 50 轮）
- ✅ 用户明确请求（调用 `/ccg:checkpoint`）

**文档参考**：
- `skills/ccg-checkpoint/skill.md` - 检查点 Skill 说明
- `.ccg/state.json` - 状态文件模板

## 初始化检查清单

> **自动化说明**：
> - ✅ **CCG Skills**：克隆项目后自动可用
> - ✅ **OpenSpec-CN**：克隆项目后自动可用
> - ✅ **Superpowers**：Claude Code 自动安装
> - ⚙️ **CCG MCP 工具**：需要手动配置 API
> - ⚙️ **acemcp**：需要手动安装

### 步骤 1：克隆项目（自动获得 Skills 和 OpenSpec）

```bash
# 克隆项目
git clone https://github.com/szstan/Coder-Codex-Gemini.git
cd Coder-Codex-Gemini
```

**自动获得的功能**：
- ✅ CCG Skills（6 个）
- ✅ OpenSpec-CN 命令（3 个）
- ✅ 完整的 AI 治理框架文档

### 步骤 2：安装 CCG MCP 服务器

```bash
# 运行安装脚本
# Windows:
setup.bat

# Unix/macOS:
./setup.sh
```

### 步骤 3：配置 CCG MCP 工具

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

### 步骤 4：安装 acemcp（强烈推荐）

```bash
npm install -g acemcp-node
```

**验证安装**：
```bash
npx acemcp-node --version
```

### 步骤 5：配置 Claude Code 全局 Prompt（重要）

> ⚠️ **为什么必须配置全局 Prompt？**
> - **防止上下文过长时跑偏**：全局配置始终生效，不受对话长度影响
> - **确保开发环境配置一致**：CCG 协作规则、工具说明等始终可用
> - **避免重复说明**：无需每次对话都重复配置信息

将 CCG 全局 Prompt 复制到 Claude Code 配置：

```bash
# 复制模板到全局配置
cp templates/ccg-global-prompt.md ~/.claude/CLAUDE.md
```

**全局配置包含的内容**：
- CCG 协作规则（强制规则、Skill 前置条件）
- 已集成工具说明（CCG Skills、OpenSpec-CN、Superpowers）
- AI 治理框架概览
- 核心依赖清单


### 步骤 6：验证配置

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

### Q5: Superpowers Skills 是什么？必须使用吗？

**A**: Superpowers 是 Claude Code 官方插件，提供最佳实践工作流。

**核心价值**：
- **自动安装**：Claude Code 自动安装和更新，无需手动配置
- **最佳实践**：提供经过验证的开发工作流程
- **质量保障**：确保代码质量和开发规范

**是否必须使用**：
- ❌ 不是强制要求
- ✅ 强烈推荐使用，特别是以下场景：
  - 创建新功能前使用 `/superpowers:brainstorming`
  - 实现功能前使用 `/superpowers:test-driven-development`
  - 遇到 bug 时使用 `/superpowers:systematic-debugging`
  - 完成工作前使用 `/superpowers:verification-before-completion`

### Q6: OpenSpec-CN 是什么？什么时候需要使用？

**A**: OpenSpec-CN 是规范驱动开发工具，用于管理变更提案和规范。

**核心价值**：
- **规范驱动**：先写规范，再写代码，确保需求明确
- **变更追踪**：记录所有变更的提案、设计和实施过程
- **审批流程**：支持提案审批，避免盲目开发

**使用场景**：
- ✅ 多人协作项目（需要变更审批）
- ✅ 大型功能开发（需要详细规范）
- ✅ 架构变更（需要设计文档）
- ❌ 小型个人项目（可选）
- ❌ 简单 bug 修复（不需要）

**是否必须使用**：
- ❌ 不是强制要求
- ✅ 推荐用于企业级项目和多人协作

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
│   ├── mcp__acemcp__search_context（语义搜索）
│   └── Superpowers Skills（官方插件，自动安装）
│
└── 可选组件
    ├── mcp__ccg__gemini（专家咨询）
    └── OpenSpec-CN（规范驱动开发）
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

