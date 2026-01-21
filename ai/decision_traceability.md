# CCG 决策可追溯性机制

> **用途**：增强决策透明度，让用户理解 Claude 的决策逻辑和依据

## 概述

本文档定义了增强版的决策日志格式，添加决策推理过程、规则引用和上下文信息，使每个决策都可以追溯到具体的规则和原因。

---

## 增强版决策日志格式

### 核心字段

| 字段 | 类型 | 必需 | 说明 |
|------|------|------|------|
| `timestamp` | string | ✅ | 决策时间（ISO 8601） |
| `decision` | string | ✅ | 决策类型（auto_retry/auto_fix/skip_review等） |
| `level` | string | ✅ | 决策权限等级（level_0/level_1/level_2/level_3） |
| `reason` | string | ✅ | 触发原因（network_timeout/syntax_error等） |
| `reasoning` | string | ✅ | 决策推理过程（为什么这样决策） |
| `rule` | string | ✅ | 依据的规则文档和位置 |
| `context` | object | ✅ | 决策上下文（重试次数、置信度等） |
| `action` | string | ✅ | 执行的具体动作 |
| `outcome` | string | ⚪ | 决策结果（success/failure/partial） |
| `user_override` | boolean | ⚪ | 用户是否覆盖了决策 |

---

## 决策日志示例

### 示例 1：网络超时自动重试（Level 0）

```jsonl
{
  "timestamp": "2026-01-21T14:00:00Z",
  "decision": "auto_retry",
  "level": "level_0",
  "reason": "network_timeout",
  "reasoning": "根据 decision_authority_matrix.md，网络超时第1次属于 Level 0（完全自主），可自动重试。使用指数退避算法，等待 1 秒后重试。",
  "rule": "ai/decision_authority_matrix.md#L44",
  "context": {
    "service": "coder",
    "task": "generate_auth_module",
    "retry_count": 1,
    "max_retries": 3,
    "backoff_time": 1
  },
  "action": "retry_with_exponential_backoff",
  "outcome": "success"
}
```

### 示例 2：语法错误修复建议（Level 2）

```jsonl
{
  "timestamp": "2026-01-21T14:05:00Z",
  "decision": "suggest_fix",
  "level": "level_2",
  "reason": "syntax_error",
  "reasoning": "根据 decision_authority_matrix.md，简单语法错误属于 Level 2（提示确认）。错误信息清晰（缺少右括号），可以提供明确的修复建议，但需要用户确认后执行。",
  "rule": "ai/decision_authority_matrix.md#L56",
  "context": {
    "file": "src/auth.py",
    "line": 42,
    "error": "SyntaxError: unexpected EOF while parsing",
    "fix_confidence": 0.95,
    "suggested_fix": "添加缺失的右括号"
  },
  "action": "prompt_user_for_confirmation",
  "outcome": "pending",
  "user_override": false
}
```

### 示例 3：测试失败自动修复（Level 1）

```jsonl
{
  "timestamp": "2026-01-21T14:10:00Z",
  "decision": "auto_fix_test",
  "level": "level_1",
  "reason": "test_failure",
  "reasoning": "根据 decision_authority_matrix.md 和 test_failure_auto_fix.md，测试失败第1次且置信度 ≥ 0.8 属于 Level 1（透明自主）。初始置信度评估为 0.85（简单断言失败+清晰错误信息+完整堆栈），可以自动修复但需要报告。",
  "rule": "ai/decision_authority_matrix.md#L66, ai/testing/test_failure_auto_fix.md#L45",
  "context": {
    "test_file": "tests/test_auth.py",
    "test_name": "test_login_success",
    "failure_type": "assertion_error",
    "initial_confidence": 0.85,
    "confidence_factors": {
      "simple_assertion": 0.3,
      "clear_error_message": 0.2,
      "complete_stack_trace": 0.1,
      "simple_function": 0.2,
      "base_confidence": 0.5
    },
    "fix_attempt": 1,
    "max_attempts": 3
  },
  "action": "delegate_to_coder_for_fix",
  "outcome": "success"
}
```

### 示例 4：服务降级（Level 1）

```jsonl
{
  "timestamp": "2026-01-21T14:15:00Z",
  "decision": "service_degradation",
  "level": "level_1",
  "reason": "api_quota_exceeded",
  "reasoning": "根据 auto_degradation.md，Codex API 额度不足时，自动降级到 Coder 审核。这是 Level 1 决策，需要报告但可以自主执行。降级后使用简化的审核标准，只检查关键问题。",
  "rule": "ai/error-handling/auto_degradation.md#L17",
  "context": {
    "original_service": "codex",
    "fallback_service": "coder",
    "task": "code_review",
    "degradation_level": 1,
    "review_scope": "critical_issues_only"
  },
  "action": "degrade_to_coder_review",
  "outcome": "success"
}
```

### 示例 5：强制停止（Level 3）

```jsonl
{
  "timestamp": "2026-01-21T14:20:00Z",
  "decision": "force_stop",
  "level": "level_3",
  "reason": "consecutive_failures",
  "reasoning": "根据 timeout_guardrails.md，连续 3 次调用同一工具失败且错误相同，触发强制停止。这是 Level 3 决策，必须停止并询问用户。可能的原因：修复方案无效或误判了错误原因。",
  "rule": "ai/timeout_guardrails.md#L177",
  "context": {
    "tool": "mcp__ccg__coder",
    "failure_count": 3,
    "error_type": "syntax_error",
    "same_error": true,
    "failure_history": [
      {"time": "14:00", "error": "SyntaxError at line 42"},
      {"time": "14:03", "error": "SyntaxError at line 42"},
      {"time": "14:06", "error": "SyntaxError at line 42"}
    ]
  },
  "action": "stop_and_ask_user",
  "outcome": "stopped"
}
```

---

## 决策推理模板

### 模板结构

```
根据 [规则文档]，[触发条件] 属于 [权限等级]。[具体分析]。[决策结论]。
```

### Level 0 推理模板

```
根据 decision_authority_matrix.md，[场景] 属于 Level 0（完全自主），可以直接执行。[执行策略]。
```

**示例**：
- "根据 decision_authority_matrix.md，网络超时第1次属于 Level 0（完全自主），可自动重试。使用指数退避算法，等待 1 秒后重试。"
- "根据 decision_authority_matrix.md，创建 Git stash 安全点属于 Level 0，改动前自动创建，完成后报告。"

### Level 1 推理模板

```
根据 decision_authority_matrix.md 和 [相关文档]，[场景] 属于 Level 1（透明自主）。[风险评估]，可以自动执行但需要报告。
```

**示例**：
- "根据 decision_authority_matrix.md，安装 requirements.txt 中的包属于 Level 1（透明自主）。包在依赖清单中，风险低，可以自动安装但需要报告。"
- "根据 decision_authority_matrix.md 和 test_failure_auto_fix.md，测试失败第1次且置信度 ≥ 0.8 属于 Level 1。初始置信度评估为 0.85，可以自动修复但需要报告。"

### Level 2 推理模板

```
根据 decision_authority_matrix.md，[场景] 属于 Level 2（提示确认）。[风险分析]，需要提供建议并等待用户确认。
```

**示例**：
- "根据 decision_authority_matrix.md，简单语法错误属于 Level 2（提示确认）。错误信息清晰，可以提供明确的修复建议，但需要用户确认后执行。"
- "根据 decision_authority_matrix.md，重命名文件属于 Level 2。可能影响其他文件的引用，需要提供影响分析并询问确认。"

### Level 3 推理模板

```
根据 decision_authority_matrix.md，[场景] 属于 Level 3（强制询问）。[高风险说明]，必须停止并等待用户明确指令。
```

**示例**：
- "根据 decision_authority_matrix.md，删除文件属于 Level 3（强制询问）。这是不可逆操作，必须说明理由并等待用户确认。"
- "根据 timeout_guardrails.md，连续 3 次调用同一工具失败且错误相同，触发强制停止。这是 Level 3 决策，必须停止并询问用户。"

---

## 规则引用格式

### 标准格式

```
ai/[文档路径]#L[行号]
```

### 多规则引用

```
ai/decision_authority_matrix.md#L66, ai/testing/test_failure_auto_fix.md#L45
```

### 常用规则引用速查表

| 场景 | 规则引用 |
|------|---------|
| 网络超时重试 | `ai/decision_authority_matrix.md#L44` |
| 语法错误修复 | `ai/decision_authority_matrix.md#L56` |
| 测试失败修复 | `ai/decision_authority_matrix.md#L66` |
| 安装依赖 | `ai/decision_authority_matrix.md#L77` |
| 删除文件 | `ai/decision_authority_matrix.md#L89` |
| Git 提交 | `ai/decision_authority_matrix.md#L101` |
| 服务降级 | `ai/error-handling/auto_degradation.md#L17` |
| 超时强制停止 | `ai/timeout_guardrails.md#L89` |
| 连续失败停止 | `ai/timeout_guardrails.md#L177` |

---

## Claude 决策报告模板

### Level 0 决策报告（事后报告）

```
✅ 已自动执行：[决策描述]

**决策依据**：[推理过程]
**执行结果**：[成功/失败]
**详细信息**：[上下文信息]
```

**示例**：
```
✅ 已自动执行：网络超时自动重试

**决策依据**：根据 decision_authority_matrix.md，网络超时第1次属于 Level 0（完全自主），可自动重试。使用指数退避算法，等待 1 秒后重试。
**执行结果**：成功（第2次重试成功）
**详细信息**：
- 服务：Coder
- 任务：生成认证模块
- 重试次数：2/3
- 总耗时：3.5 秒
```

### Level 1 决策报告（事前报告）

```
🔵 即将自动执行：[决策描述]

**决策依据**：[推理过程]
**风险评估**：[风险等级和说明]
**执行计划**：[具体步骤]

正在执行...
```

**示例**：
```
🔵 即将自动执行：安装依赖包 pytest

**决策依据**：根据 decision_authority_matrix.md，安装 requirements.txt 中的包属于 Level 1（透明自主）。pytest 在依赖清单中，风险低，可以自动安装。
**风险评估**：低风险（标准测试库，广泛使用）
**执行计划**：
1. 检查 pytest 是否已安装
2. 如未安装，执行 pip install pytest
3. 验证安装成功

正在执行...
```

### Level 2 决策报告（询问确认）

```
⚠️ 需要您的确认：[决策描述]

**决策依据**：[推理过程]
**风险分析**：[风险说明]
**建议方案**：[推荐的处理方式]

**您的选择**：
1. [选项1]
2. [选项2]
3. [选项3]

请选择：
```

**示例**：
```
⚠️ 需要您的确认：修复语法错误

**决策依据**：根据 decision_authority_matrix.md，简单语法错误属于 Level 2（提示确认）。错误信息清晰（缺少右括号），可以提供明确的修复建议。
**风险分析**：低风险，修复明确，但涉及代码改动
**建议方案**：在 src/auth.py 第 42 行添加缺失的右括号

**您的选择**：
1. 自动修复（推荐）
2. 显示详细的修复方案，我手动修复
3. 跳过此错误

请选择：
```

### Level 3 决策报告（强制询问）

```
❌ 需要您的明确指令：[问题描述]

**决策依据**：[推理过程]
**风险说明**：[高风险详细说明]
**当前状态**：[系统当前状态]
**可能后果**：[不同选择的后果]

**请提供明确指令**：
[具体问题]

我将等待您的回复。
```

**示例**：
```
❌ 需要您的明确指令：连续3次修复失败

**决策依据**：根据 timeout_guardrails.md，连续 3 次调用同一工具失败且错误相同，触发强制停止。这是 Level 3 决策，必须停止并询问用户。
**风险说明**：继续尝试可能浪费资源且无效，需要重新分析根本原因
**当前状态**：
- 工具：Coder
- 失败次数：3/3
- 错误：SyntaxError at line 42（相同错误）
- 已尝试的修复方案：添加括号、调整缩进、检查语法

**可能后果**：
- 继续尝试：可能继续失败，浪费时间
- 调用 Codex 诊断：可能找到根本原因
- 您手动修复：最快解决

**请提供明确指令**：
1. 允许我调用 Codex 进行深度诊断
2. 您直接告诉我第 42 行应该怎么写
3. 您自己修复这个问题

请告诉我您希望如何处理？
```

---

## 决策日志查询和分析

### 查询最近的决策

```bash
# 查看最近 10 条决策
tail -n 10 .ccg/decision_log.jsonl | jq .

# 查看最近的 Level 2/3 决策（需要用户参与的）
cat .ccg/decision_log.jsonl | jq 'select(.level == "level_2" or .level == "level_3")' | tail -n 10
```

### 按决策类型统计

```bash
# 统计各类决策的数量
cat .ccg/decision_log.jsonl | jq -r '.decision' | sort | uniq -c | sort -rn

# 统计各权限等级的决策数量
cat .ccg/decision_log.jsonl | jq -r '.level' | sort | uniq -c
```

### 查询特定服务的决策

```bash
# 查询 Coder 相关的决策
cat .ccg/decision_log.jsonl | jq 'select(.context.service == "coder")'

# 查询失败的决策
cat .ccg/decision_log.jsonl | jq 'select(.outcome == "failure")'
```

### 追溯决策依据

```bash
# 查询某个决策引用的规则
cat .ccg/decision_log.jsonl | jq -r '.rule' | sort | uniq -c

# 查看特定规则被引用的次数
cat .ccg/decision_log.jsonl | jq 'select(.rule | contains("decision_authority_matrix.md"))' | wc -l
```

---

## 与现有系统集成

### 更新 decision_log.jsonl 格式

**旧格式**（基础版）：
```jsonl
{"timestamp": "2026-01-21T14:00:00Z", "decision": "auto_retry", "reason": "network_timeout", "attempt": 1, "max": 3, "service": "coder"}
```

**新格式**（增强版）：
```jsonl
{"timestamp": "2026-01-21T14:00:00Z", "decision": "auto_retry", "level": "level_0", "reason": "network_timeout", "reasoning": "根据 decision_authority_matrix.md，网络超时第1次属于 Level 0（完全自主），可自动重试。使用指数退避算法，等待 1 秒后重试。", "rule": "ai/decision_authority_matrix.md#L44", "context": {"service": "coder", "task": "generate_auth_module", "retry_count": 1, "max_retries": 3, "backoff_time": 1}, "action": "retry_with_exponential_backoff", "outcome": "success"}
```

### 向后兼容

- 旧格式的日志仍然有效
- 新系统会自动补充缺失的字段
- 建议逐步迁移到新格式

