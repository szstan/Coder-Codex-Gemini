# Gemini 工具详细规范

## 工具说明

Gemini 是用于提供高阶建议或执行任务的灵活工具，适合用于架构咨询、方案评估、复杂问题拆解，或在明确授权下直接执行任务。

Gemini 默认运行在高自由度模式（`yolo=true`），其输出应由调用方（Claude）进行最终判断与裁决。

---

## 外部工程约束（可选，但建议遵守）

在部分项目中，调用方可能提供外部工程约束作为权威上下文，例如项目内 `ai/` 目录中的以下文件：

- `ai/contracts/current.md`（本次变更的 Implementation Contract）
- `ai/engineering_codex.md`（工程原则 / 默认判断）
- `ai/PROJECT_CONTEXT.md`（项目上下文，可选）

**当上述约束被提供时**：

- Gemini 应将其作为重要参考上下文
- 不应主动提出明显违反 Contract 的执行方案
- 如认为 Contract 本身存在明显问题，可指出并建议回到决策阶段修订

> **注**：Gemini 不负责自动发现或加载这些文件，其内容应由调用方显式注入到 PROMPT 中。

---

## 参数说明

| 参数                | 类型    | 必填 | 说明                             |
|---------------------|---------|------|----------------------------------|
| PROMPT              | string  | ✅   | 任务指令，需提供充分背景         |
| cd                  | Path    | ✅   | 工作目录                         |
| sandbox             | string  |      | 默认 `workspace-write`，灵活控制 |
| yolo                | boolean |      | 默认 `true`，跳过审批            |
| SESSION_ID          | string  |      | 会话 ID，复用保持上下文          |
| model               | string  |      | 默认 `gemini-3-pro-preview`      |
| return_all_messages | boolean |      | 调试时设为 True                  |
| return_metrics      | boolean |      | 返回值中包含指标数据             |
| timeout             | int     |      | 空闲超时（秒），默认 300         |
| max_duration        | int     |      | 总时长硬上限（秒），默认 1800    |
| max_retries         | int     |      | 最大重试次数，默认 1             |
| log_metrics         | boolean |      | 将指标输出到 stderr              |

---

## 返回值

**成功返回**：

```json
{
  "success": true,
  "tool": "gemini",
  "SESSION_ID": "uuid-string",
  "result": "Gemini 回复内容",
  "duration": "1m30s"
}
```

**失败返回**：

```json
{
  "success": false,
  "tool": "gemini",
  "error": "错误摘要信息",
  "error_kind": "idle_timeout | timeout | command_not_found | upstream_error | ...",
  "error_detail": {
    "message": "错误简述",
    "exit_code": 1,
    "last_lines": ["最后20行输出..."],
    "idle_timeout_s": 300,
    "max_duration_s": 1800,
    "retries": 1
  },
  "duration": "0m30s"
}
```

---

## Prompt 模板

```
请提供专业意见 / 执行任务：

【工程上下文】（如存在）
- （粘贴 ai/contracts/current.md 或 ai/engineering_codex.md 内容）

**任务类型**：[咨询 / 审核 / 执行]
**背景信息**：[项目上下文]

**具体问题 / 任务**：
1. [问题/任务1]
2. [问题/任务2]

**期望输出**：
- [输出格式 / 内容要求]

如信息不足，请在不扩展 Scope 的前提下，基于最安全、最小假设继续推进，并显式标注 Assumption。
```

---

## 使用规范

1. **必须保存** `SESSION_ID` 以便多轮对话
2. 检查 `success` 字段判断执行是否成功
3. 从 `result` 字段获取回复内容
4. 失败时检查 `error_kind` 决定是否可重试
5. **提供充分背景**：Gemini 需要完整上下文才能给出高质量回复
6. **灵活控制权限**：咨询用 `read-only`，执行用 `workspace-write`

**当在 Autopilot 模式下使用时**：

- 优先选择最小、最安全的方案
- 不应在未说明风险的情况下扩大问题范围

---

## Autopilot 与会话失效处理

在自动推进（Autopilot）模式下：
- Gemini 应基于最安全、最小假设给出建议或执行结果
- 不应在未明确说明风险的情况下扩大 Scope

当 SESSION_ID 失效或丢失时：
- 直接开启新会话
- 重新注入工程上下文与 Contract（如存在）
- 不依赖历史对话隐式状态

---

## 重试策略

Gemini 默认允许 **1 次自动重试**：

- 超时、网络错误等会自动重试
- `command_not_found` 不会重试（需用户干预）
- 重试采用指数退避（0.5s → 1s → 2s）