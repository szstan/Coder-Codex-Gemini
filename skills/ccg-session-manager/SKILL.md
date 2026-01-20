
---
name: ccg-session-manager
description: |
  CCG 会话管理器 - 自动保存和恢复项目上下文
  Use when: 会话启动、任务开始、工具调用完成、任务完成
  自动加载项目配置，保存会话状态，支持断点恢复。
---

# CCG 会话管理器

> 解决上下文连续性问题：保持项目开发期间的上下文，会话断开后快速恢复。

---

## 核心功能

### 1. 自动加载项目配置

**触发时机**：每次 Claude 会话启动时

**加载内容**：
- `.ccg/project-context.json` - 项目静态信息
- `.ccg/sessions/current.json` - 当前会话状态（如果存在）

**示例输出**：

```markdown
📋 **项目上下文已加载**

**项目名称**：Coder-Codex-Gemini
**技术栈**：Python + FastMCP
**当前阶段**：v1.0 已发布，持续优化中

**最近决策**：
- 2026-01-19：模块化拆分 CCG Workflow 文档
- 2026-01-18：新增架构不变性（8 条硬约束）

**关键模块**：
- Skills 系统（已完成）
- 模块化文档（刚完成）
- 会话管理（开发中）
```

---

### 2. 会话状态检测

**触发时机**：加载项目配置后

**检测逻辑**：
```
if .ccg/sessions/current.json 存在 AND status != "idle":
    → 提示用户恢复会话
else:
    → 准备开始新任务
```

**示例输出**：

```markdown
⚠️ **检测到未完成任务**

**任务**：实现会话管理功能（选项 B）
**状态**：执行中（execution 阶段）
**进度**：
  ✅ 已完成：创建配置模板
  🔄 进行中：创建 /ccg-session-manager Skill
  ⏳ 待执行：实现自动保存逻辑、会话恢复逻辑

**上次更新**：2026-01-19 11:30（30 分钟前）

**操作选项**：
1. ✅ 继续此任务（推荐）
2. 💾 保存并开始新任务
3. ❌ 放弃此任务并清空会话
```

---

### 3. 自动保存会话状态

**触发时机**：
- 用户开始新任务
- Coder 执行完成
- Codex 审核完成
- Gemini 调用完成
- 任务状态变更（in_progress → completed / failed）

**保存位置**：`.ccg/sessions/current.json`

**保存内容**：
- 任务描述和类型
- 当前阶段（准备/执行/审核/交付）
- 已完成/待执行步骤
- SESSION_ID（Coder/Codex/Gemini）
- 受影响的文件
- 迭代次数和错误记录
- 质量信号（测试/审核状态）

**实现方式**：

```markdown
## 自动保存规则

**规则 1：任务开始时**
- 创建新的 session_id
- 记录任务描述和路由决策
- 初始化 execution_state

**规则 2：工具调用后**
- 更新 tool_sessions（记录 SESSION_ID 和调用次数）
- 更新 last_updated 时间戳
- 如果有文件变更 → 更新 affected_files

**规则 3：阶段切换时**
- 更新 current_task.phase
- 追加到 completed_steps
- 更新 pending_steps

**规则 4：任务完成时**
- 设置 status = "completed" 或 "failed"
- 归档到 .ccg/sessions/history/
- 清空 current.json（重置为 template.json）
```

---

### 4. 会话恢复

**恢复流程**：

```
用户选择"继续此任务"
  ↓
Claude 读取 current.json
  ↓
恢复以下上下文：
  - 任务描述和目标
  - 当前阶段和步骤
  - SESSION_ID（重用或创建新的）
  - 受影响的文件清单
  - Contract/OpenSpec 路径（如有）
  ↓
提示用户："已恢复上下文，从 [当前步骤] 继续"
  ↓
继续执行
```

**示例**：

```markdown
✅ **会话已恢复**

**任务**：实现商品搜索功能
**当前步骤**：Coder 执行中
**上下文**：
  - Contract：ai/contracts/current.md
  - 已修改：search.py, api.py
  - Coder SESSION_ID：coder-session-abc123（已恢复）
  - 上次 Codex 反馈：需要优化查询性能

**继续执行**：调用 Coder 实现性能优化
```

---

### 5. 任务归档

**触发时机**：任务完成或放弃

**归档位置**：`.ccg/sessions/history/YYYY-MM-DD-task-id.json`

**归档内容**：完整的 current.json + 最终结果

**清理逻辑**：
- 自动清理 30 天前的历史文件
- 保留最近 100 个任务记录

---

## 使用指南

### Claude 的执行流程

#### 会话启动时（自动）

```markdown
1. 读取 .ccg/project-context.json
   ↓
2. 显示项目基本信息
   ↓
3. 检查 .ccg/sessions/current.json
   ↓
4a. 如果有未完成任务 → 提示恢复
4b. 如果无任务 → 准备开始新任务
```

#### 任务开始时（Claude 手动调用）

```markdown
用户："实现 XXX 功能"
  ↓
Claude 执行：
  1. 创建新的 session_id
  2. 更新 current.json：
     - current_task.description = "实现 XXX 功能"
     - status = "in_progress"
     - session_started = 当前时间
  3. 继续路由决策和任务执行
```

#### 工具调用后（Claude 自动执行）

```markdown
Coder 执行完成
  ↓
Claude 执行：
  1. 更新 current.json：
     - tool_sessions.coder.session_id = "xxx"
     - tool_sessions.coder.last_called = 当前时间
     - tool_sessions.coder.call_count += 1
     - affected_files += [修改的文件]
     - last_updated = 当前时间
  2. 继续验收流程
```

#### 任务完成时（Claude 手动调用）

```markdown
Codex 审核通过 + 测试通过
  ↓
Claude 执行：
  1. 归档 current.json → history/YYYY-MM-DD-task-id.json
  2. 重置 current.json = template.json
  3. 提示用户："任务已完成并归档"
```

---

## 文件结构

```
.ccg/
├── project-context.json          # 项目静态信息（手动维护 + git commit）
├── sessions/
│   ├── template.json             # 空模板（供重置使用）
│   ├── current.json              # 当前会话状态（自动更新，gitignore）
│   └── history/                  # 历史归档（自动生成，gitignore）
│       ├── 2026-01-19-task-001.json
│       ├── 2026-01-19-task-002.json
│       └── ...
└── routing_history.jsonl         # 路由决策历史（可选，用于反馈循环）
```

---

## 关键原则

### 1. 最小侵入性

- 不改变现有 CCG 工作流
- 只增加"加载"和"保存"逻辑
- 用户无感知（除非需要恢复）

### 2. 故障容错

- 如果 current.json 损坏 → 自动重置为 template.json
- 如果 project-context.json 不存在 → 提示用户创建
- 如果会话恢复失败 → 允许开始新任务

### 3. 手动可编辑

- 所有文件都是纯 JSON
- 用户可手动编辑 project-context.json
- current.json 可手动清空（等同于放弃任务）

### 4. 隐私安全

- 所有会话文件在 .gitignore 中
- 不记录敏感信息（密钥、密码）
- 仅记录任务描述和文件路径

---

## 与现有系统的集成

### 与 /ccg-workflow 的关系

**ccg-workflow**：定义工作流程（路由 → 执行 → 审核）
**ccg-session-manager**：管理会话状态（加载 → 保存 → 恢复）

**集成点**：
- 会话启动 → 先调用 session-manager 加载上下文 → 再执行 ccg-workflow
- 工具调用后 → ccg-workflow 执行 → session-manager 自动保存
- 任务完成 → ccg-workflow 完成 → session-manager 归档

### 与 Contract / OpenSpec 的关系

**Contract/OpenSpec**：定义任务边界和方案
**session-manager**：记录 Contract/OpenSpec 的文件路径

**集成方式**：
```json
{
  "task_context": {
    "contract_file": "ai/contracts/current.md",
    "openspec_file": "openspec/active/2026-0119-user-auth.md"
  }
}
```

恢复会话时，自动加载这些文件内容。

---

## 示例场景

### 场景 1：正常开发流程

```
10:00 - 用户："实现用户认证"
10:01 - Claude 创建 current.json
10:05 - 调用 Coder 执行
10:06 - 更新 current.json（记录 Coder SESSION_ID）
10:20 - 调用 Codex 审核
10:21 - 更新 current.json（记录 Codex 结果）
10:30 - 任务完成，归档到 history/
```

### 场景 2：会话中断恢复

```
10:00 - 用户："实现用户认证"
10:05 - Coder 执行中...
10:10 - ⚠️ Claude 会话崩溃

--- 重新启动 Claude ---

10:15 - Claude 启动
10:15 - 自动检测到 current.json
10:15 - 提示："检测到未完成任务：实现用户认证（Coder 执行中）"
10:16 - 用户选择："继续"
10:16 - Claude 恢复上下文，继续等待 Coder 结果
```

### 场景 3：多任务切换

```
10:00 - 任务 A：实现用户认证（进行中）
11:00 - 用户："紧急 Bug 修复"
11:01 - Claude："当前有未完成任务，是否保存并切换？"
11:02 - 用户："是"
11:02 - 归档任务 A → history/task-A.json
11:03 - 创建新的 current.json for 任务 B
...
14:00 - 任务 B 完成
14:01 - Claude："是否恢复任务 A？"
14:02 - 用户："是"
14:02 - 从 history/task-A.json 恢复
```

---

## 实现检查清单

### 配置文件
- [x] 创建 .ccg/project-context.json 模板
- [x] 创建 .ccg/sessions/template.json 模板
- [x] 创建 .ccg/sessions/current.json 示例

### 自动化逻辑
- [ ] 会话启动时自动加载（Claude 内置逻辑）
- [ ] 工具调用后自动保存（Claude 内置逻辑）
- [ ] 任务完成时自动归档（Claude 内置逻辑）

### 文档更新
- [ ] 更新 skills/ccg-workflow/SKILL.md
- [ ] 创建用户使用指南

### 测试验证
- [ ] 测试正常流程（新任务 → 执行 → 完成）
- [ ] 测试会话恢复（中断 → 重启 → 恢复）
- [ ] 测试多任务切换（任务 A → 任务 B → 恢复 A）

---

**Skill 结束**
