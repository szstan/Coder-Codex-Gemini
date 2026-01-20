# CCG 会话管理使用指南

> 本文档面向 CCG 系统的用户，介绍会话管理功能的使用方法。

---

## 概述

CCG 会话管理系统解决了以下核心问题：
- ✅ **上下文连续性**：会话中断后能快速恢复
- ✅ **SESSION_ID 管理**：自动保存和复用 Coder/Codex/Gemini 的会话 ID
- ✅ **任务追踪**：记录任务进度、受影响文件、质量信号
- ✅ **多任务切换**：支持暂停当前任务，开始新任务，稍后恢复

---

## 快速开始

### 对用户：完全透明

会话管理功能**完全自动化**，无需任何手动操作：

1. **正常开发**：Claude 会自动保存会话状态
2. **会话中断**：重启 Claude 后自动检测并提示恢复
3. **任务完成**：自动归档到历史记录

### 对 Claude：自动执行

每次会话启动时，Claude 会自动：
1. 加载项目配置（`.ccg/project-context.json`）
2. 检测未完成任务（`.ccg/sessions/current.json`）
3. 提示用户选择操作（继续/保存/放弃）

---

## 使用场景

### 场景 1：正常开发流程

```
10:00 - 用户："实现用户认证功能"
10:01 - Claude 自动创建会话，开始任务
10:05 - 调用 Coder 执行代码
10:06 - Claude 自动保存 Coder SESSION_ID
10:20 - 调用 Codex 审核
10:21 - Claude 自动保存 Codex 结果
10:30 - 任务完成，自动归档到 history/
```

**用户体验**：无感知，一切自动完成

---

### 场景 2：会话中断恢复

```
10:00 - 用户："实现用户认证功能"
10:05 - Coder 执行中...
10:10 - ⚠️ Claude 会话崩溃（网络断开/电脑重启）

--- 重新启动 Claude ---

10:15 - Claude 启动
10:15 - 自动检测到未完成任务
10:15 - 提示："检测到未完成任务：实现用户认证功能（Coder 执行中）"
10:16 - 用户选择："继续"
10:16 - Claude 恢复上下文，继续等待 Coder 结果
```

**用户体验**：无缝恢复，不丢失任何进度

---

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

**用户体验**：灵活切换，不丢失任何任务

---

## 文件结构

```
.ccg/
├── project-context.json          # 项目静态信息（手动维护 + git commit）
├── state.json                    # 全局状态（自动更新，gitignore）
└── sessions/
    ├── template.json             # 空模板（供重置使用）
    ├── current.json              # 当前会话状态（自动更新，gitignore）
    └── history/                  # 历史归档（自动生成，gitignore）
        ├── 2026-01-20-task-001.json
        ├── 2026-01-20-task-002.json
        └── ...
```

### 文件说明

| 文件 | 用途 | 维护方式 | Git 状态 |
|------|------|----------|---------|
| `project-context.json` | 项目静态信息 | 手动维护 | ✅ Commit |
| `state.json` | 全局状态 | 自动更新 | ❌ Gitignore |
| `sessions/template.json` | 空模板 | 手动维护 | ✅ Commit |
| `sessions/current.json` | 当前会话 | 自动更新 | ❌ Gitignore |
| `sessions/history/` | 历史归档 | 自动生成 | ❌ Gitignore |

---

## 配置文件详解

### 1. project-context.json

**用途**：存储项目静态信息，会话启动时自动加载

**内容**：
- 项目名称、描述、版本
- 技术栈（语言、框架、依赖）
- 架构信息（类型、模式、组件）
- 当前阶段
- 关键模块状态
- 最近决策
- 已知问题
- 外部资源

**维护方式**：手动编辑，重大变更时更新

**示例**：参见 `.ccg/project-context.json`

---

### 2. sessions/current.json

**用途**：存储当前会话状态，自动保存和恢复

**内容**：
- session_id：会话唯一标识
- status：idle / in_progress / completed / failed
- current_task：任务描述、类型、阶段
- task_context：Contract、OpenSpec、受影响文件、Git 分支
- execution_state：当前步骤、已完成步骤、待执行步骤、迭代次数、错误记录
- tool_sessions：Coder/Codex/Gemini 的 SESSION_ID 和调用记录
- quality_signals：测试状态、审核状态、门禁状态
- notes：备注信息

**维护方式**：Claude 自动更新

**示例**：参见 `.ccg/sessions/current.json`

---

## 常见问题

### Q1：会话文件损坏怎么办？

**A**：Claude 会自动检测并重置为空模板，提示："会话文件已重置"

### Q2：如何手动清空会话？

**A**：删除或清空 `.ccg/sessions/current.json`，或将其内容替换为 `template.json` 的内容

### Q3：历史记录会占用多少空间？

**A**：每个任务约 5-10 KB，100 个任务约 500 KB - 1 MB。系统会自动清理 30 天前的记录。

### Q4：如何查看历史任务？

**A**：查看 `.ccg/sessions/history/` 目录，文件名格式为 `YYYY-MM-DD-task-id.json`

### Q5：会话管理会影响性能吗？

**A**：不会。保存操作是异步的，失败不阻塞任务执行。

---

## 高级用法

### 手动编辑 project-context.json

你可以手动编辑 `project-context.json` 来更新项目信息：

```json
{
  "project_name": "你的项目名称",
  "description": "项目描述",
  "tech_stack": {
    "language": "Python",
    "framework": "FastMCP"
  },
  "recent_decisions": [
    {
      "date": "2026-01-20",
      "decision": "集成会话管理系统",
      "rationale": "解决上下文连续性问题"
    }
  ]
}
```

### 手动恢复历史任务

如果需要恢复某个历史任务：

1. 找到对应的历史文件：`.ccg/sessions/history/YYYY-MM-DD-task-id.json`
2. 复制内容到 `.ccg/sessions/current.json`
3. 重启 Claude，会自动检测并提示恢复

---

## 最佳实践

### 1. 定期更新 project-context.json

建议在以下时机更新：
- 重大技术决策后
- 架构变更后
- 新增关键模块后
- 项目里程碑完成后

### 2. 及时完成任务

避免长时间挂起任务，建议：
- 单个任务控制在 1-2 小时内
- 复杂任务拆分为多个子任务
- 及时归档完成的任务

### 3. 合理使用多任务切换

建议：
- 紧急任务才切换
- 切换前确认当前任务可暂停
- 完成紧急任务后及时恢复

---

## 故障排查

### 问题 1：会话启动时未加载项目配置

**原因**：`project-context.json` 不存在或格式错误

**解决**：
1. 检查文件是否存在：`.ccg/project-context.json`
2. 验证 JSON 格式是否正确
3. 参考模板创建新文件

### 问题 2：会话恢复失败

**原因**：`current.json` 损坏或缺少必需字段

**解决**：
1. 备份 `current.json`
2. 重置为 `template.json` 的内容
3. 手动填写关键信息（如果需要）

### 问题 3：SESSION_ID 丢失

**原因**：工具调用后未正确保存

**解决**：
1. 检查 `current.json` 中的 `tool_sessions` 字段
2. 如果为空，重新调用工具会生成新的 SESSION_ID
3. 后续调用会自动复用新的 SESSION_ID

---

## 相关资源

- **Skill 文档**：`/ccg-session-manager`
- **全局配置模板**：`templates/ccg-global-prompt.md`
- **项目配置示例**：`.ccg/project-context.json`
- **会话模板**：`.ccg/sessions/template.json`

---

**最后更新**：2026-01-20
