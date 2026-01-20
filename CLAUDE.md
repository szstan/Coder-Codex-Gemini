<!-- OPENSPEC:START -->
# OpenSpec 使用说明

这些说明适用于在此项目中工作的AI助手。

## 语言偏好设置

**默认使用中文**：除非明确说明使用英文，否则所有输出都应使用中文，包括：
- 文档内容
- 代码注释
- 提交信息
- 规范说明

## 工作流程

当请求满足以下条件时，始终打开`@/openspec/AGENTS.md`：
- 提及规划或提案（如提案、规范、变更、计划等词语）
- 引入新功能、重大变更、架构变更或大型性能/安全工作时
- 听起来不明确，需要在编码前了解权威规范时

使用`@/openspec/AGENTS.md`了解：
- 如何创建和应用变更提案
- 规范格式和约定
- 项目结构和指南

保持此托管块，以便'openspec-cn update'可以刷新说明。

<!-- OPENSPEC:END -->

# Coder-Codex-Gemini (CCG)

> Claude + Coder + Codex + Gemini 多模型协作 MCP 服务器

## 项目定位

一个统一的 MCP 服务器，让 Claude (Opus) 作为架构师调度 Coder 执行代码任务、Codex 审核代码质量、Gemini 提供专家咨询，形成自动化的多方协作闭环。

## 核心价值

| 维度 | 价值 |
|------|------|
| **成本优化** | Opus 负责思考（贵但强），Coder 负责执行（量大管饱） |
| **能力互补** | Opus 补足 Coder 创造力短板，Codex 提供独立审核视角，Gemini 提供多元化专家意见 |
| **质量保障** | 双重审核机制（Claude 初审 + Codex 终审） |
| **全自动闭环** | 拆解 → 执行 → 审核 → 重试，无需人工干预 |

## 角色分工

```
Claude (Opus)     →  架构师 + 初审官 + 终审官 + 协调者
Coder (可配置)    →  代码执行者（生成、修改、批量任务）
Codex (OpenAI)    →  独立代码审核者（质量把关）
Gemini (可选)     →  多面手专家（架构设计、第二意见、前端/UI）
```

## 项目结构

```
Coder-Codex-Gemini/
├── src/ccg_mcp/              # 源代码
│   ├── __init__.py
│   ├── cli.py                # 入口点
│   ├── server.py             # MCP 服务器主体
│   ├── config.py             # 配置加载
│   └── tools/
│       ├── coder.py          # Coder 工具
│       ├── codex.py          # Codex 工具
│       └── gemini.py         # Gemini 工具
├── skills/                   # Skills 工作流指导（15 个）
│   ├── ccg-workflow/         # CCG 协作流程
│   ├── ccg-session-manager/  # 会话管理器（自动上下文保持）
│   ├── ccg-iteration-loop/   # 持续迭代循环
│   ├── ccg-plan/             # 规划生成器
│   ├── ccg-execute/          # 计划执行器
│   ├── ccg-parallel/         # 并行任务执行
│   ├── ccg-contract/         # Contract 创建
│   ├── ccg-review/           # Claude 验收检查
│   ├── ccg-codex-gate/       # Codex 审核门禁
│   ├── ccg-checkpoint/       # 配置检查点
│   ├── ccg-test-fix/         # 测试失败修复
│   ├── ccg-test-fix-advanced/# 测试失败多层级修复
│   ├── ccg-database-design/  # 数据库设计
│   ├── ccg-git-safety/       # Git 安全检查
│   ├── codex-code-review-enterprise/ # Codex 企业级 Review
│   └── gemini-collaboration/ # Gemini 协作指南
├── .ccg/                     # 会话管理配置（gitignore）
│   ├── project-context.json  # 项目静态信息
│   ├── state.json            # 全局状态
│   └── sessions/
│       ├── template.json     # 空模板
│       ├── current.json      # 当前会话状态
│       └── history/          # 历史归档
├── templates/                # 模板文件
│   └── ccg-global-prompt.md  # 全局 CLAUDE.md 模板
├── cases/                    # 实测案例
├── pyproject.toml
├── config.example.toml       # 配置文件示例
├── setup.sh                  # Unix/macOS 安装脚本
├── setup.ps1                 # Windows PowerShell 安装脚本
├── setup.bat                 # Windows 批处理入口
├── README.md                 # 项目说明（中文）
├── README_EN.md              # 项目说明（英文）
└── CLAUDE.md                 # 本文件
```

## 开发里程碑

| 阶段 | 内容 | 状态 |
|------|------|------|
| M0 | 方案设计、技术验证 | ✅ 完成 |
| M1 | 最小可用版本（coder 工具） | ✅ 完成 |
| M2 | 集成 codex 工具 | ✅ 完成 |
| M3 | 协作 Prompt 优化 | ✅ 完成 |
| M4 | 集成 gemini 工具 | ✅ 完成 |
| M5 | 文档、发布 | ✅ 完成 |

## 会话管理系统

CCG 集成了完整的会话管理系统，解决上下文连续性问题。

### 核心功能

1. **自动加载项目配置**（会话启动时）
   - 读取 `.ccg/project-context.json`
   - 显示项目基本信息、技术栈、最近决策

2. **自动检测未完成任务**（会话启动时）
   - 检查 `.ccg/sessions/current.json`
   - 如果有未完成任务 → 提示恢复
   - 如果无任务 → 准备开始新任务

3. **自动保存会话状态**（任务执行过程中）
   - 任务开始时：创建 session
   - 工具调用后：更新 SESSION_ID 和受影响文件
   - 阶段切换时：记录完成步骤和待执行步骤
   - 任务完成时：归档到 history/

4. **会话恢复**（中断后重启）
   - 恢复任务描述和目标
   - 恢复 SESSION_ID（Coder/Codex/Gemini）
   - 恢复 Contract / OpenSpec
   - 从当前步骤继续执行

### 使用方式

**对用户**：完全透明，无需任何操作
- 正常开发 → 自动保存
- 会话中断 → 重启后自动提示恢复

**对 Claude**：每次会话启动时自动执行
- 加载项目配置
- 检测未完成任务
- 提示用户选择操作
- 任务执行过程中自动保存状态

**详细说明**：参见 `/ccg-session-manager` Skill

## 技术要点

### MCP 工具

- `coder`: 调用可配置后端模型执行代码生成/修改，默认 `workspace-write`
- `codex`: 调用 Codex 进行代码审核，默认 `read-only`
- `gemini`: 调用 Gemini CLI 进行专家咨询或代码执行，默认 `workspace-write`

### 核心特性

#### 结构化错误
失败时返回 `error_kind` 和 `error_detail`，便于上层决策是否重试：
```json
{
  "success": false,
  "error": "错误摘要",
  "error_kind": "timeout | upstream_error | ...",
  "error_detail": {
    "message": "错误简述",
    "exit_code": 1,
    "last_lines": ["最后20行输出..."],
    "retries": 0
  }
}
```

#### 重试策略
- **Codex**：默认允许 1 次重试（只读操作无副作用）
- **Coder**：默认不重试（有写入副作用），可通过 `max_retries` 显式启用
- **Gemini**：默认允许 1 次重试

#### 可观察性指标
- `return_metrics=True`：在返回值中包含耗时、Prompt 长度等指标
- `log_metrics=True`：将指标输出到 stderr（JSONL 格式）

#### 命令行参数策略
- **设置源**：`--setting-sources "project"` 仅加载项目级设置
- **System Prompt**：`--append-system-prompt` 通过命令行参数追加角色指令
- **对话 Prompt**：通过 stdin 传递（支持换行符，无长度限制）

### 配置方案

优先级：`~/.ccg-mcp/config.toml` > 环境变量

```toml
# ~/.ccg-mcp/config.toml
[coder]
api_token = "your-api-token"  # 可配置任意支持 Claude Code API 的模型后端
base_url = "https://open.bigmodel.cn/api/anthropic"  # 示例：GLM API
model = "glm-4.7"  # 示例：GLM-4.7，可替换为其他模型
```

### 跨平台实现

通过 `subprocess.Popen(env=custom_env)` 注入环境变量，无需依赖脚本文件。

## 参考资源

- [CodexMCP](https://github.com/GuDaStudio/codexmcp) - 核心参考实现
- [FastMCP](https://github.com/jlowin/fastmcp) - MCP 框架
- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code)
- [Codex CLI](https://developers.openai.com/codex/quickstart)
- [Gemini CLI](https://github.com/google-gemini/gemini-cli)

---

> 📅 项目创建: 2026-01-01
> 📅 重命名为 CCG: 2026-01-03
