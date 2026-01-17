---
name: ccg:checkpoint
description: 配置检查点（定期重申核心配置和状态，防止长对话遗忘）
category: System
tags: [checkpoint, config, state, session]
---

# CCG 配置检查点

> **用途**：定期重申核心配置和当前状态，防止长对话后遗忘关键规则

## 核心问题

**长期工作后忘记初始配置**：
- ❌ 上下文过长，早期配置被"稀释"
- ❌ SESSION_ID 丢失或混用
- ❌ 工作流规则被遗忘
- ❌ 当前状态不明确

## 检查点机制

**自动触发时机**：
1. 每完成一个主要任务后
2. 对话轮次达到阈值（建议 50 轮）
3. 用户明确请求（调用 `/ccg:checkpoint`）

**检查点内容**：
- ✅ 强制规则重申
- ✅ 当前 SESSION_ID 状态
- ✅ 当前工作流阶段
- ✅ 当前 Contract 位置

## 检查点执行流程

### 步骤 1：读取状态文件（1 分钟）
- 读取 `.ccg/state.json`
- 获取当前 SESSION_ID
- 获取当前工作流阶段
- 获取当前 Contract

### 步骤 2：重申强制规则（2 分钟）
```markdown
## ⚠️ CCG 强制规则（始终有效）

1. **所有代码改动必须委托 Coder 执行**
   - 使用 `mcp__ccg__coder` 工具
   - 保存并复用 SESSION_ID

2. **Coder 完成后必须 Claude 验收**
   - 调用 `/ccg:review` Skill
   - 快速检查（5-10 分钟）

3. **阶段性完成后必须 Codex 审核**
   - 调用 `/ccg:codex-gate` Skill
   - 严格遵守 Blocking 规则

4. **必须保存和复用 SESSION_ID**
   - 每个角色独立的 SESSION_ID
   - 使用 MCP 工具返回的实际值
```

### 步骤 3：报告当前状态（1 分钟）
```markdown
## 📊 当前状态

**SESSION_ID**：
- Coder: {从 state.json 读取}
- Codex: {从 state.json 读取}
- Gemini: {从 state.json 读取}

**工作流阶段**：{从 state.json 读取}
- idle: 空闲
- contract: Contract 创建中
- implementation: 实现中
- review: 验收中
- audit: 审核中

**当前 Contract**：{从 state.json 读取}
```

### 步骤 4：更新检查点计数（1 分钟）
- 更新 `.ccg/state.json` 中的 `checkpoint_counter`
- 更新 `last_checkpoint` 时间戳
- 保存文件

## 使用示例

**自动触发**：
```
完成一个主要任务后
→ Claude 自动调用 /ccg:checkpoint
→ 重申核心配置
→ 报告当前状态
```

**手动触发**：
```
用户："检查一下当前配置"
→ Claude 调用 /ccg:checkpoint
→ 读取状态文件
→ 重申规则和状态
```

## 状态文件管理

### 状态文件位置
`.ccg/state.json`

### 状态字段说明
```json
{
  "version": "1.0",                    // 状态文件版本
  "last_updated": "2026-01-17T...",    // 最后更新时间
  "session_ids": {                     // SESSION_ID 记录
    "coder": "session-xxx",
    "codex": "session-yyy",
    "gemini": "session-zzz"
  },
  "current_contract": "ai/contracts/current.md",  // 当前 Contract
  "workflow_stage": "implementation",  // 工作流阶段
  "mandatory_rules": [...],            // 强制规则列表
  "checkpoint_counter": 5,             // 检查点计数
  "last_checkpoint": "2026-01-17T..."  // 最后检查点时间
}
```

### 更新状态文件
每次调用 MCP 工具后，应该更新对应的 SESSION_ID：
```bash
# 读取状态文件
cat .ccg/state.json

# 手动更新（或通过脚本）
# 更新 session_ids.coder 字段
```

## 相关文档

- 状态文件：`.ccg/state.json`
- 全局配置：`~/.claude/CLAUDE.md`
- 项目配置：`./CLAUDE.md`
- CCG 工作流：`/ccg-workflow` Skill

## 注意事项

1. **定期调用**：建议每完成一个主要任务后调用一次
2. **状态同步**：每次获得新的 SESSION_ID 后立即更新状态文件
3. **不可跳过**：强制规则始终有效，不受对话长度影响
4. **状态文件优先**：状态文件是唯一的真实来源
