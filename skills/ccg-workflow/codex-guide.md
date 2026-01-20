---
# Codex 工具详细规范

## 工具说明

Codex 是只读环境下的代码审核工具，运行于 **read-only sandbox**，用于对代码改动进行质量、风险与一致性审查，不具备任何写入能力。

Codex 的定位是 **独立审核者 + 高级代码顾问**，不负责实现，不负责重构，不替代最终决策。

---

## 外部工程约束（可选，但强烈推荐）

在部分项目中，审核阶段可能提供外部工程约束作为权威上下文，例如项目内 `ai/` 目录中的以下文件：

- `ai/contracts/current.md`（本次变更的 Implementation Contract）
- `ai/codex_review_gate.md`（审核闸门 / 输出约束）
- `ai/engineering_codex.md`（工程默认判断）
- `ai/PROJECT_CONTEXT.md`（项目上下文，可选）

**当上述约束被提供时**：

- Codex 应优先对照这些约束进行审核
- 发现违反 Contract / Review Gate 的问题，应明确指出
- 不应引入 Contract 之外的新需求或设计方向

> **注**：Codex 不负责自动发现或加载这些文件，其内容应由调用方显式注入到 PROMPT 中。

---

## 参数说明

| 参数                | 类型       | 必填 | 说明                                                   |
|---------------------|------------|------|--------------------------------------------------------|
| PROMPT              | string     | ✅   | 审核任务描述（需包含完整上下文与约束）                 |
| cd                  | Path       | ✅   | 工作目录                                               |
| sandbox             | string     |      | **必须** `read-only`                                   |
| SESSION_ID          | string     |      | 会话 ID                                                |
| return_all_messages | boolean    |      | 调试时设为 True                                        |
| return_metrics      | boolean    |      | 返回值中包含指标数据，默认 False                       |
| image               | List[Path] |      | 附加图片                                               |
| model               | string     |      | 指定模型                                               |
| timeout             | int        |      | 空闲超时（秒），默认 300，无输出超过此时间触发         |
| max_duration        | int        |      | 总时长硬上限（秒），默认 1800（30 分钟），0 表示无限制 |
| max_retries         | int        |      | 最大重试次数，默认 1（可安全重试）                     |
| log_metrics         | boolean    |      | 将指标输出到 stderr                                    |

---

## 返回值

**成功返回**：

```json
{
  "success": true,
  "tool": "codex",
  "SESSION_ID": "uuid-string",
  "result": "Codex 审核结论"
}
````

**失败返回**：

```json
{
  "success": false,
  "tool": "codex",
  "error": "错误摘要信息",
  "error_kind": "idle_timeout | timeout | command_not_found | upstream_error | ...",
  "error_detail": {
    "message": "错误简述",
    "exit_code": 1,
    "last_lines": ["最后20行输出..."],
    "json_decode_errors": 0,
    "idle_timeout_s": 300,
    "max_duration_s": 1800,
    "retries": 1
  }
}
```

---

## error_kind 枚举

| 值                          | 说明                  |
|-----------------------------|----------------------|
| `idle_timeout`              | 空闲超时（无输出）    |
| `timeout`                   | 总时长超时            |
| `command_not_found`         | codex CLI 未安装      |
| `upstream_error`            | CLI 返回错误          |
| `json_decode`               | JSON 解析失败         |
| `protocol_missing_session`  | 未获取 SESSION_ID     |
| `empty_result`              | 无响应内容            |
| `subprocess_error`          | 进程退出码非零        |
| `unexpected_exception`      | 未预期异常            |

---

## Codex Review 模式

Codex 提供两种审核模式，适用于不同的开发阶段：

### 标准审核模式（日常开发）

**适用场景**：日常开发迭代、快速反馈

**审核范围**：当前改动的业务代码

**测试代码策略**：
- ✅ **需要审核**：复杂测试逻辑、集成测试、测试工具类、性能/安全测试
- ❌ **可豁免**：简单单元测试（仅验证输入输出）、自动生成的测试、纯数据 Mock

**工具**：直接调用 `mcp__ccg__codex`

### 企业级审核模式（PR 合入前）

**适用场景**：准备合入主分支前的最终质量把关

**审核范围**：完整 Git diff（包括所有测试代码）

**审核标准**：8 条 Blocking 规则
1. 架构边界被破坏
2. 业务逻辑直接读取环境变量/硬编码配置
3. 吞异常（silent swallow）
4. 关键错误信息缺少定位上下文
5. 新增/修改关键逻辑缺少 failure path 测试
6. 可观测性缺失（日志、指标、追踪）
7. 演进安全性问题（破坏向后兼容）
8. 可维护性严重问题（过度复杂、缺少文档）

**工具**：使用 `/codex-code-review-enterprise` Skill

**输出格式**：结构化（Blocking / Non-blocking / Nit），最多 10 个问题

**优先级**：演进安全 → 可观测性 → 可测试性 → 可读性

---

## Prompt 模板

### 标准审核模板

```
请 review 以下代码改动：

【Implementation Contract】（如存在，应作为主要审核依据）
- （粘贴 ai/contracts/current.md 内容）

【Review Gate】（如存在）
- （粘贴 ai/codex_review_gate.md 内容）

**改动文件**：[文件列表]
**改动目的**：[简要描述]

**请检查**：
1. 是否违反 Implementation Contract（如存在）
2. 代码质量（可读性、可维护性）
3. 潜在 Bug 或边界情况
4. 是否引入未声明的行为变化

**请给出明确结论**：
- ✅ 通过：代码质量良好，可以合入
- ⚠️ 建议优化：[具体建议]
- ❌ 需要修改：[具体问题，尽量引用 Contract / Review Gate 条款]
```

### 企业级审核模板

使用 `/codex-code-review-enterprise` Skill，该 Skill 会自动提供结构化的审核流程和输出格式。

---

## 使用规范

1. **严格边界**：必须 `sandbox="read-only"`，Codex 严禁修改代码
2. **必须保存** `SESSION_ID` 以便多轮对话
3. 检查 `success` 字段判断审核是否成功
4. 从 `result` 字段获取审核结论
5. 失败时检查 `error_kind` 了解失败原因

**当存在外部工程约束时**：

- 审核结论应优先对照 Contract / Review Gate
- 不应在未指出问题的情况下引入新的需求或设计建议
- 若发现 Contract 本身存在明显缺陷，应建议回写而非绕过

---

## Assumptions 的审核要求

当审核内容包含 Assumptions / Open Questions 时：

- Codex 应明确指出这些假设带来的潜在风险
- 若 Assumption 可能影响正确性或演进安全，应标记为 Blocking
- Codex 不应基于 Assumptions 引入新的需求或设计方向

---

## 重试策略

Codex 默认允许 **1 次自动重试**（只读操作无副作用）：

- 超时、网络错误等会自动重试
- `command_not_found` 不会重试（需用户干预）
- 重试采用指数退避（0.5s → 1s → 2s）
