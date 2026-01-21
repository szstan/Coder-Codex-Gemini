# CCG 日志系统使用指南

> **用途**：监控和分析 CCG 系统的决策行为、服务降级、超时事件

## 概述

CCG 系统提供 3 种日志文件，用于记录和分析系统运行状态：

| 日志文件 | 用途 | 格式 |
|---------|------|------|
| `.ccg/decision_log.jsonl` | 记录所有重要决策 | JSONL |
| `.ccg/degradation_log.jsonl` | 记录服务降级事件 | JSONL |
| `.ccg/timeout_log.jsonl` | 记录超时事件 | JSONL |

---

## 日志文件说明

### 1. 决策日志 (decision_log.jsonl)

**用途**：记录 Claude 的所有重要决策（Level 1+ 权限）

**日志格式**：
```jsonl
{"timestamp": "2026-01-21T14:00:00Z", "decision": "auto_retry", "reason": "network_timeout", "attempt": 1, "max": 3, "service": "coder", "task": "code_generation"}
{"timestamp": "2026-01-21T14:05:00Z", "decision": "auto_fix", "reason": "test_failure", "confidence": 0.8, "file": "src/main.py"}
{"timestamp": "2026-01-21T14:10:00Z", "decision": "ask_user", "reason": "low_confidence", "context": "repeated test failures"}
```

**字段说明**：

| 字段 | 类型 | 说明 | 示例 |
|------|------|------|------|
| `timestamp` | string | ISO 8601 时间戳 | "2026-01-21T14:00:00Z" |
| `decision` | string | 决策类型 | "auto_retry", "auto_fix", "ask_user" |
| `reason` | string | 决策原因 | "network_timeout", "test_failure" |
| `attempt` | number | 尝试次数（如适用） | 1 |
| `max` | number | 最大尝试次数（如适用） | 3 |
| `service` | string | 涉及的服务 | "coder", "codex", "gemini" |
| `task` | string | 任务描述 | "code_generation", "code_review" |
| `confidence` | number | 置信度（如适用） | 0.8 |
| `file` | string | 相关文件（如适用） | "src/main.py" |

**常见决策类型**：

- `auto_retry` - 自动重试（网络超时、API 限流）
- `auto_fix` - 自动修复（测试失败、语法错误）
- `auto_degrade` - 自动降级（服务不可用）
- `ask_user` - 询问用户（置信度低、需要确认）
- `stop_task` - 停止任务（超过重试次数、问题加重）

---

### 2. 降级日志 (degradation_log.jsonl)

**用途**：记录所有服务降级事件

**日志格式**：
```jsonl
{"timestamp": "2026-01-21T14:00:00Z", "service": "codex", "reason": "api_quota_exceeded", "fallback": "coder_review", "task": "code_review", "impact": "lower_quality", "success": true}
{"timestamp": "2026-01-21T14:15:00Z", "service": "gemini", "reason": "api_unavailable", "fallback": "codex_coder_combo", "task": "frontend_implementation", "impact": "reduced_ui_optimization", "success": true}
{"timestamp": "2026-01-21T14:30:00Z", "service": "coder", "reason": "timeout", "fallback": "claude_manual", "task": "simple_fix", "impact": "slower_execution", "success": true}
```

**字段说明**：

| 字段 | 类型 | 说明 | 示例 |
|------|------|------|------|
| `timestamp` | string | ISO 8601 时间戳 | "2026-01-21T14:00:00Z" |
| `service` | string | 失败的服务 | "codex", "gemini", "coder" |
| `reason` | string | 失败原因 | "api_quota_exceeded", "timeout" |
| `fallback` | string | 降级方案 | "coder_review", "codex_coder_combo" |
| `task` | string | 任务类型 | "code_review", "frontend_implementation" |
| `impact` | string | 影响描述 | "lower_quality", "slower_execution" |
| `success` | boolean | 降级是否成功 | true, false |

**常见失败原因**：

- `api_quota_exceeded` - API 额度不足
- `api_unavailable` - API 服务不可用
- `auth_failure` - 认证失败
- `timeout` - 超时
- `error` - 其他错误

**常见降级方案**：

- `coder_review` - 使用 Coder 审核（Codex 降级）
- `codex_coder_combo` - Codex + Coder 组合（Gemini 降级）
- `coder_only` - 仅使用 Coder（Gemini 降级）
- `claude_manual` - Claude 手动执行（Coder 降级）

---

### 3. 超时日志 (timeout_log.jsonl)

**用途**：记录任务级和决策级超时事件

**日志格式**：
```jsonl
{"timestamp": "2026-01-21T14:00:00Z", "type": "task_timeout", "agent": "coder", "task": "generate_auth", "duration": 125, "threshold": 120, "action": "warning"}
{"timestamp": "2026-01-21T14:10:00Z", "type": "task_timeout", "agent": "coder", "task": "generate_auth", "duration": 610, "threshold": 600, "action": "terminated"}
{"timestamp": "2026-01-21T14:15:00Z", "type": "decision_timeout", "behavior": "repeated_reads", "file": "src/main.py", "count": 5, "action": "stopped"}
```

**字段说明**：

| 字段 | 类型 | 说明 | 示例 |
|------|------|------|------|
| `timestamp` | string | ISO 8601 时间戳 | "2026-01-21T14:00:00Z" |
| `type` | string | 超时类型 | "task_timeout", "decision_timeout" |
| `agent` | string | Agent 名称（任务超时） | "coder", "codex", "gemini" |
| `task` | string | 任务描述 | "generate_auth" |
| `duration` | number | 执行时长（秒） | 125 |
| `threshold` | number | 超时阈值（秒） | 120 |
| `action` | string | 采取的行动 | "warning", "terminated", "stopped" |
| `behavior` | string | 异常行为（决策超时） | "repeated_reads", "consecutive_failures" |
| `file` | string | 相关文件（如适用） | "src/main.py" |
| `count` | number | 次数（如适用） | 5 |

**超时类型**：

- `task_timeout` - 任务级超时（Coder/Codex/Gemini 执行时间过长）
- `decision_timeout` - 决策级超时（Claude 陷入循环）

**超时行动**：

- `warning` - 警告（超过默认超时，但未达最大）
- `terminated` - 终止（超过最大超时）
- `stopped` - 停止（检测到异常行为）

---

## 日志查看命令

### 查看最近的决策

**查看最后 10 条决策**：
```bash
tail -n 10 .ccg/decision_log.jsonl | jq .
```

**查看特定类型的决策**：
```bash
cat .ccg/decision_log.jsonl | jq 'select(.decision == "auto_retry")'
```

**统计决策类型分布**：
```bash
cat .ccg/decision_log.jsonl | jq -r '.decision' | sort | uniq -c
```

### 查看降级事件

**查看所有降级事件**：
```bash
cat .ccg/degradation_log.jsonl | jq .
```

**查看 Codex 降级事件**：
```bash
cat .ccg/degradation_log.jsonl | jq 'select(.service == "codex")'
```

**统计降级原因**：
```bash
cat .ccg/degradation_log.jsonl | jq -r '.reason' | sort | uniq -c
```

### 查看超时事件

**查看所有超时**：
```bash
cat .ccg/timeout_log.jsonl | jq .
```

**查看任务级超时**：
```bash
cat .ccg/timeout_log.jsonl | jq 'select(.type == "task_timeout")'
```

**查看 Coder 超时统计**：
```bash
cat .ccg/timeout_log.jsonl | jq 'select(.agent == "coder")' | wc -l
```

---

## 日志分析示例

### 示例 1：分析决策模式

**目标**：了解 Claude 最常做的决策

```bash
# 统计各类决策的次数
cat .ccg/decision_log.jsonl | jq -r '.decision' | sort | uniq -c | sort -rn

# 输出示例：
#  15 auto_retry
#  12 auto_fix
#   5 auto_degrade
#   3 ask_user
#   1 stop_task
```

**分析**：
- 自动重试是最常见的决策（15 次）
- 自动修复也很频繁（12 次）
- 较少需要询问用户（3 次）

### 示例 2：分析降级频率

**目标**：了解哪个服务最不稳定

```bash
# 统计各服务的降级次数
cat .ccg/degradation_log.jsonl | jq -r '.service' | sort | uniq -c | sort -rn

# 输出示例：
#  12 codex
#   5 gemini
#   2 coder
```

**分析**：
- Codex 降级最频繁（12 次），可能是 API 额度问题
- Gemini 偶尔降级（5 次）
- Coder 很稳定（仅 2 次降级）

### 示例 3：分析超时问题

**目标**：找出哪些任务容易超时

```bash
# 查看超时任务分布
cat .ccg/timeout_log.jsonl | jq -r '.task' | sort | uniq -c | sort -rn

# 查看平均超时时长
cat .ccg/timeout_log.jsonl | jq -s 'map(.duration) | add / length'
```

### 示例 4：时间范围分析

**目标**：分析今天的决策情况

```bash
# 查看今天的所有决策
TODAY=$(date +%Y-%m-%d)
cat .ccg/decision_log.jsonl | jq "select(.timestamp | startswith(\"$TODAY\"))"

# 统计今天的决策类型
cat .ccg/decision_log.jsonl | jq -r "select(.timestamp | startswith(\"$TODAY\")) | .decision" | sort | uniq -c
```

---

## 日志统计报告生成

### 生成每日报告

创建一个简单的脚本来生成日志报告：

```bash
#!/bin/bash
# 文件：.ccg/generate_daily_report.sh

TODAY=$(date +%Y-%m-%d)
REPORT_FILE=".ccg/reports/report-$TODAY.md"

mkdir -p .ccg/reports

cat > "$REPORT_FILE" <<EOF
# CCG 日志报告 - $TODAY

## 决策统计

### 决策类型分布
\`\`\`
$(cat .ccg/decision_log.jsonl | jq -r "select(.timestamp | startswith(\"$TODAY\")) | .decision" | sort | uniq -c)
\`\`\`

### 决策详情
- 总决策数：$(cat .ccg/decision_log.jsonl | jq -r "select(.timestamp | startswith(\"$TODAY\"))" | wc -l)
- 自动重试：$(cat .ccg/decision_log.jsonl | jq -r "select(.timestamp | startswith(\"$TODAY\")) | select(.decision == \"auto_retry\")" | wc -l)
- 自动修复：$(cat .ccg/decision_log.jsonl | jq -r "select(.timestamp | startswith(\"$TODAY\")) | select(.decision == \"auto_fix\")" | wc -l)
- 询问用户：$(cat .ccg/decision_log.jsonl | jq -r "select(.timestamp | startswith(\"$TODAY\")) | select(.decision == \"ask_user\")" | wc -l)

## 降级统计

### 降级服务分布
\`\`\`
$(cat .ccg/degradation_log.jsonl | jq -r "select(.timestamp | startswith(\"$TODAY\")) | .service" | sort | uniq -c)
\`\`\`

### 降级原因
\`\`\`
$(cat .ccg/degradation_log.jsonl | jq -r "select(.timestamp | startswith(\"$TODAY\")) | .reason" | sort | uniq -c)
\`\`\`

## 超时统计

### 超时事件数
- 任务超时：$(cat .ccg/timeout_log.jsonl | jq -r "select(.timestamp | startswith(\"$TODAY\")) | select(.type == \"task_timeout\")" | wc -l)
- 决策超时：$(cat .ccg/timeout_log.jsonl | jq -r "select(.timestamp | startswith(\"$TODAY\")) | select(.type == \"decision_timeout\")" | wc -l)

### 平均执行时长
- 平均：$(cat .ccg/timeout_log.jsonl | jq -r "select(.timestamp | startswith(\"$TODAY\")) | select(.type == \"task_timeout\") | .duration" | awk '{s+=$1; n++} END {if(n>0) print s/n; else print 0}') 秒

---
生成时间：$(date)
EOF

echo "报告已生成：$REPORT_FILE"
cat "$REPORT_FILE"
```

**使用方法**：
```bash
chmod +x .ccg/generate_daily_report.sh
./.ccg/generate_daily_report.sh
```

---

## 日志维护

### 日志清理

**按保留天数清理**（配置：`logging.log_retention_days`）：

```bash
# 删除 30 天前的日志行
find .ccg/*.jsonl -type f -exec bash -c '
  FILE="$1"
  CUTOFF=$(date -d "30 days ago" +%Y-%m-%d)
  grep -v "^{\"timestamp\":\"$CUTOFF" "$FILE" > "$FILE.tmp"
  mv "$FILE.tmp" "$FILE"
' _ {} \;
```

**手动清空日志**：
```bash
# 清空所有日志（谨慎使用！）
> .ccg/decision_log.jsonl
> .ccg/degradation_log.jsonl
> .ccg/timeout_log.jsonl
```

**备份日志**：
```bash
# 备份当前日志
DATE=$(date +%Y%m%d)
cp .ccg/decision_log.jsonl .ccg/backups/decision_log.$DATE.jsonl
cp .ccg/degradation_log.jsonl .ccg/backups/degradation_log.$DATE.jsonl
cp .ccg/timeout_log.jsonl .ccg/backups/timeout_log.$DATE.jsonl
```

---

## 日志格式验证

**验证日志文件格式是否正确**：

```bash
# 检查 JSONL 格式
cat .ccg/decision_log.jsonl | jq empty
# 无输出 = 格式正确
# 有错误 = 格式错误，显示错误行

# 统计日志条数
wc -l .ccg/*.jsonl
```

---

## 常见问题

### Q1: 日志文件太大怎么办？

**A**: 定期清理旧日志，或者按月归档：

```bash
# 按月归档
MONTH=$(date +%Y-%m)
mkdir -p .ccg/archives/$MONTH
mv .ccg/*.jsonl .ccg/archives/$MONTH/
touch .ccg/decision_log.jsonl
touch .ccg/degradation_log.jsonl
touch .ccg/timeout_log.jsonl
```

### Q2: 如何快速查看最近的异常？

**A**: 使用 grep 过滤关键词：

```bash
# 查看所有 "ask_user" 决策（需要人工介入）
cat .ccg/decision_log.jsonl | jq 'select(.decision == "ask_user")'

# 查看所有失败的降级
cat .ccg/degradation_log.jsonl | jq 'select(.success == false)'

# 查看所有终止的超时
cat .ccg/timeout_log.jsonl | jq 'select(.action == "terminated")'
```

### Q3: 如何导出为 CSV 格式？

**A**: 使用 jq 转换：

```bash
# 导出决策日志为 CSV
cat .ccg/decision_log.jsonl | jq -r '[.timestamp, .decision, .reason, .service] | @csv' > decision_log.csv
```

---

## 相关文档

- **决策框架**：`ai/decision_framework.md`
- **决策权限**：`ai/decision_authority_matrix.md`
- **超时机制**：`ai/timeout_guardrails.md`
- **降级策略**：`ai/error-handling/auto_degradation.md`
- **用户配置**：`.ccg/user_preferences.json`

---

## 快速参考

### 常用命令速查

```bash
# 查看最近 10 条决策
tail -n 10 .ccg/decision_log.jsonl | jq .

# 统计决策类型
cat .ccg/decision_log.jsonl | jq -r '.decision' | sort | uniq -c

# 查看今天的降级事件
TODAY=$(date +%Y-%m-%d)
cat .ccg/degradation_log.jsonl | jq "select(.timestamp | startswith(\"$TODAY\"))"

# 查看超时统计
cat .ccg/timeout_log.jsonl | jq -r '.agent' | sort | uniq -c

# 生成日志报告
./.ccg/generate_daily_report.sh
```
