---

# Coder 工具详细规范

## 工具说明

Coder 是可配置的代码执行工具，需要用户自行配置后端模型。推荐使用 GLM-4.7 作为参考案例，也可选用其他支持 Claude Code API 的模型（如 Minimax、DeepSeek 等）。

Coder 运行在 **workspace-write** 环境中，具备真实写入副作用，因此调用时必须提供清晰、可控、可验收的指令。

---

## 外部工程约束（可选，但强烈推荐）

在部分项目中，调用方可能提供外部工程约束作为权威上下文，例如项目内 `ai/` 目录中的以下文件：

- `ai/contracts/current.md`（本次变更的 Implementation Contract）
- `ai/implementer_guardrails.md`（实现边界与禁止项）
- `ai/engineering_codex.md`（工程默认判断）

**当上述约束被提供时**：

- Coder 应视其为本次执行的边界条件
- 所有修改必须在约束允许的范围内进行
- 如发现约束不清晰或相互冲突，应停止执行并请求澄清

> **注**：Coder 不负责自动发现或加载这些文件，其内容应由调用方显式注入到 PROMPT 中。

---

## 参数说明

| 参数                | 类型    | 必填 | 说明                                                   |
|---------------------|---------|------|--------------------------------------------------------|
| PROMPT              | string  | ✅   | 任务指令（需包含完整上下文与约束）                     |
| cd                  | Path    | ✅   | 工作目录                                               |
| sandbox             | string  |      | 默认 `workspace-write`                                 |
| SESSION_ID          | string  |      | 会话 ID，复用保持上下文                                |
| return_all_messages | boolean |      | 调试时设为 True                                        |
| return_metrics      | boolean |      | 返回值中包含指标数据，默认 False                       |
| timeout             | int     |      | 空闲超时（秒），默认 300，无输出超过此时间触发         |
| max_duration        | int     |      | 总时长硬上限（秒），默认 1800（30 分钟），0 表示无限制 |
| max_retries         | int     |      | 最大重试次数，默认 0（不重试）                         |
| log_metrics         | boolean |      | 将指标输出到 stderr                                    |

---

## 返回值

**成功返回**：

```json
{
  "success": true,
  "tool": "coder",
  "SESSION_ID": "uuid-string",
  "result": "Coder 回复内容"
}
````

**失败返回**：

```json
{
  "success": false,
  "tool": "coder",
  "error": "错误摘要信息",
  "error_kind": "idle_timeout | timeout | command_not_found | upstream_error | ...",
  "error_detail": {
    "message": "错误简述",
    "exit_code": 1,
    "last_lines": ["最后20行输出..."],
    "json_decode_errors": 2,
    "idle_timeout_s": 300,
    "max_duration_s": 1800,
    "retries": 0
  }
}
```

---

## error_kind 枚举

| 值                          | 说明                  |
|-----------------------------|----------------------|
| `idle_timeout`              | 空闲超时（无输出）    |
| `timeout`                   | 总时长超时            |
| `command_not_found`         | claude CLI 未安装     |
| `upstream_error`            | CLI 返回错误          |
| `json_decode`               | JSON 解析失败         |
| `protocol_missing_session`  | 未获取 SESSION_ID     |
| `empty_result`              | 无响应内容            |
| `subprocess_error`          | 进程退出码非零        |
| `config_error`              | 配置加载失败          |
| `unexpected_exception`      | 未预期异常            |

---

## Prompt 模板

```
请执行以下代码任务：

【Implementation Contract】（如存在，必须优先遵守）
- （粘贴 ai/contracts/current.md 内容）

【Implementer Guardrails】（如存在）
- （粘贴 ai/implementer_guardrails.md 内容）

**任务类型**：[新增功能 / 修复 Bug / 重构 / 其他]
**目标文件**：[文件路径]

**具体要求**：
1. [要求1]
2. [要求2]

**约束条件**：
- [约束1]
- [约束2]

**验收标准**：
- [标准1]

请严格按照上述范围修改代码，不得扩展 Scope 或引入未说明的行为。完成后请说明改动内容。
```

---

## 使用规范

1. 必须保存 `SESSION_ID` 以便多轮对话
2. 检查 `success` 字段判断执行是否成功
3. 从 `result` 字段获取回复内容
4. 失败时检查 `error_kind` 决定是否可重试
5. 调试时设置 `return_all_messages=True` 或 `return_metrics=True`

**当存在外部工程约束时**：

- 若执行结果违反 Contract 或 Guardrails，应视为执行失败
- 不应通过"看起来更好"的实现绕过既定约束

---

## Assumptions 与会话失效处理

当存在 Assumptions / Open Questions 时：
- Coder 只能在 Assumptions 范围内执行
- 不得基于假设扩展 Scope 或引入新行为

当 SESSION_ID 失效或丢失时：
- 立即开启新会话
- 重新注入最小上下文包（目标、Contract、变更范围、Assumptions、验收标准）
- 避免对非幂等写操作进行盲目重试

---

## 重试策略

Coder 默认不自动重试（有写入副作用），如需重试：

- 显式设置 `max_retries=1` 或更高
- 仅对幂等操作启用重试
- 重试采用指数退避（0.5s → 1s → 2s）
- 在存在工程约束时，严禁对非幂等写操作盲目重试
