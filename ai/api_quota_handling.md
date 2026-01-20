# API 额度不足处理指南

> **最后更新**: 2026-01-20
> **适用版本**: CCG v1.1.0+

---

## 📖 目录

1. [问题场景](#问题场景)
2. [错误识别](#错误识别)
3. [处理策略](#处理策略)
4. [降级方案](#降级方案)
5. [预防措施](#预防措施)

---

## 问题场景

### 常见错误类型

| 错误类型 | 触发条件 | 影响范围 |
|---------|---------|---------|
| **额度不足** | API 配额用尽 | 单个 AI 不可用 |
| **速率限制** | 请求过于频繁 | 临时不可用 |
| **认证失败** | Token 过期/无效 | 单个 AI 不可用 |
| **服务不可用** | 上游服务故障 | 临时不可用 |

### 典型场景

**场景 1: Coder 额度不足**
```
用户：请实现登录功能
Claude：调用 Coder 生成代码
Coder：❌ Error: API quota exceeded (额度不足)
```

**场景 2: Codex 认证失败**
```
Claude：调用 Codex 审核代码
Codex：❌ Error: Invalid API key (认证失败)
```

**场景 3: Gemini 服务不可用**
```
Claude：调用 Gemini 咨询
Gemini：❌ Error: Service temporarily unavailable (503)
```

---

## 错误识别

### 错误信息关键词

**额度不足**:
- `quota exceeded`
- `rate limit`
- `insufficient credits`
- `billing limit reached`

**认证问题**:
- `invalid api key`
- `authentication failed`
- `unauthorized`
- `token expired`

**服务故障**:
- `service unavailable`
- `timeout`
- `connection refused`
- `503` / `504`

---

## 处理策略

### 策略 1: 自动降级（推荐）

**原则**: 当某个 AI 不可用时，自动切换到备用方案

#### 1.1 Coder 不可用 → Claude 亲自执行

**触发条件**: Coder API 额度不足或服务不可用

**处理流程**:
```
1. 检测到 Coder 错误
2. Claude 提示用户："Coder 当前不可用，我将亲自执行此任务"
3. Claude 使用自己的工具（Read/Write/Edit）完成任务
4. 继续后续流程（Codex 审核）
```

**示例**:
```
用户：请实现登录功能
Claude：调用 Coder
Coder：❌ Error: API quota exceeded

Claude 响应：
⚠️ Coder 当前额度不足，我将亲自执行此任务。

[Claude 使用 Write/Edit 工具实现登录功能]

✅ 代码已完成，现在调用 Codex 审核...
```

#### 1.2 Codex 不可用 → Claude 深度审核

**触发条件**: Codex API 额度不足或服务不可用

**处理流程**:
```
1. 检测到 Codex 错误
2. Claude 提示用户："Codex 当前不可用，我将进行深度审核"
3. Claude 参考 ai/codex_review_gate.md 进行审核
4. 给出审核结论
```

**示例**:
```
Claude：调用 Codex 审核
Codex：❌ Error: Service unavailable

Claude 响应：
⚠️ Codex 当前不可用，我将参考审核标准进行深度审核。

[Claude 按照 Codex 审核门禁标准审核代码]

审核结论：✅ 通过
- 代码质量良好
- 测试覆盖充分
- 无明显问题
```

#### 1.3 Gemini 不可用 → 跳过或 Claude 决策

**触发条件**: Gemini API 额度不足或服务不可用

**处理流程**:
```
1. 检测到 Gemini 错误
2. 判断 Gemini 是否必需：
   - 如果是可选咨询 → 跳过，Claude 自行决策
   - 如果是前端专项 → Claude 尝试处理或建议用户等待
```

**示例**:
```
Claude：调用 Gemini 咨询架构设计
Gemini：❌ Error: Invalid API key

Claude 响应：
⚠️ Gemini 当前不可用，我将基于现有知识提供建议。

[Claude 提供架构设计建议]
```

---

### 策略 2: 用户确认

**原则**: 某些情况下需要用户决策

**触发条件**:
- 多个 AI 同时不可用
- 任务复杂度高，Claude 独立完成困难
- 用户明确要求使用特定 AI

**处理流程**:
```
1. 检测到错误
2. 向用户说明情况
3. 提供可选方案
4. 等待用户决策
```

**示例**:
```
Claude：调用 Coder
Coder：❌ Error: API quota exceeded

Claude 响应：
⚠️ Coder 当前额度不足，无法执行代码生成任务。

**可选方案**：
1. 我亲自执行（可能耗时较长）
2. 等待 Coder 额度恢复后继续
3. 暂停任务，稍后重试

请选择处理方式（1/2/3）：
```

---

### 策略 3: 记录并继续

**原则**: 记录错误但不中断流程

**适用场景**:
- 可选的审核步骤失败
- 非关键路径的 AI 调用失败

**处理流程**:
```
1. 检测到错误
2. 记录到 .ccg/errors.log
3. 提示用户但继续执行
4. 在任务完成后汇总报告
```

---

## 降级方案

### 降级决策树

```
AI 调用失败
    ↓
判断 AI 角色
    ↓
┌─────────────┬─────────────┬─────────────┐
│   Coder     │   Codex     │   Gemini    │
└─────────────┴─────────────┴─────────────┘
      ↓              ↓              ↓
Claude 亲自执行  Claude 深度审核  跳过或 Claude 决策
      ↓              ↓              ↓
继续后续流程    继续后续流程    继续后续流程
```

### 降级优先级

| AI 角色 | 重要性 | 降级方案 | 是否阻塞 |
|---------|--------|---------|---------|
| **Coder** | 高 | Claude 亲自执行 | 否 |
| **Codex** | 中 | Claude 深度审核 | 否 |
| **Gemini** | 低 | 跳过或 Claude 决策 | 否 |

**结论**: 所有 AI 都有降级方案，**不会阻塞任务执行**。

---

## 预防措施

### 1. 监控额度使用

**建议**:
- 定期检查各 AI 的 API 额度
- 设置额度预警（如剩余 20% 时提醒）
- 记录每日使用量

### 2. 配置备用 API Key

**配置方式**:
```toml
# ~/.ccg-mcp/config.toml
[coder]
api_token = "primary-key"
fallback_api_token = "backup-key"  # 备用 key

[codex]
api_token = "primary-key"
fallback_api_token = "backup-key"
```

### 3. 合理分配任务

**原则**:
- 简单任务：Claude 直接执行
- 中等任务：Coder 执行
- 复杂任务：Coder + Codex 协作

**避免浪费**:
- 不要为简单任务调用 Coder
- 不要重复调用同一个 AI

### 4. 错误日志记录

**自动记录**:
```json
// .ccg/errors.log
{
  "timestamp": "2026-01-20T16:00:00Z",
  "ai": "coder",
  "error_type": "quota_exceeded",
  "error_message": "API quota exceeded",
  "task": "实现登录功能",
  "fallback": "claude_executed"
}
```

---

## 快速参考

### 错误处理决策表

| 场景 | AI | 错误类型 | 处理方式 | 是否阻塞 |
|------|----|---------|---------|---------|
| 代码生成 | Coder | 额度不足 | Claude 亲自执行 | 否 |
| 代码审核 | Codex | 服务不可用 | Claude 深度审核 | 否 |
| 架构咨询 | Gemini | 认证失败 | Claude 提供建议 | 否 |
| 前端开发 | Gemini | 额度不足 | Claude 尝试处理 | 否 |

### Claude 处理流程

```
1. 检测 AI 错误
   ↓
2. 识别错误类型（额度/认证/服务）
   ↓
3. 判断 AI 角色（Coder/Codex/Gemini）
   ↓
4. 选择降级方案
   ↓
5. 提示用户并执行降级方案
   ↓
6. 记录错误日志
   ↓
7. 继续后续流程
```

---

## 总结

**核心原则**：
- ✅ **永不阻塞**：所有 AI 都有降级方案
- ✅ **自动降级**：优先自动处理，减少用户干预
- ✅ **透明提示**：明确告知用户发生了什么
- ✅ **记录日志**：便于后续分析和优化

**关键要点**：
1. Coder 不可用 → Claude 亲自执行
2. Codex 不可用 → Claude 深度审核
3. Gemini 不可用 → 跳过或 Claude 决策
4. 所有错误都记录到日志

**用户体验**：
- 任务不会因为某个 AI 不可用而中断
- 用户会收到清晰的提示信息
- 降级方案保证任务质量

---

**最后更新**: 2026-01-20
**维护者**: CCG Team
