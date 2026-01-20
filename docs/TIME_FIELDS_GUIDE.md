# CCG 时间字段使用指南

> **最后更新**: 2026-01-20
> **适用版本**: v1.1.0+

---

## 📖 目录

1. [时间格式标准](#时间格式标准)
2. [时间字段清单](#时间字段清单)
3. [使用场景](#使用场景)
4. [计算公式](#计算公式)
5. [最佳实践](#最佳实践)
6. [常见问题](#常见问题)

---

## 时间格式标准

### ISO 8601 格式

**标准格式**：`YYYY-MM-DDTHH:MM:SSZ`

**示例**：`2026-01-20T15:30:00Z`

**格式说明**：
- `YYYY-MM-DD`：日期部分（年-月-日）
- `T`：日期和时间的分隔符
- `HH:MM:SS`：时间部分（时:分:秒，24小时制）
- `Z`：UTC 时区标识（零时区）

### 为什么使用 ISO 8601？

| 优势 | 说明 |
|------|------|
| **国际标准** | 全球通用，无歧义 |
| **可排序** | 字符串排序 = 时间排序 |
| **精确** | 精确到秒，支持毫秒扩展 |
| **时区明确** | Z 后缀表示 UTC，避免时区混淆 |
| **易解析** | 所有编程语言都支持 |

---

## 时间字段清单

### 任务 (Task) 时间字段

| 字段名 | 类型 | 必需 | 说明 | 示例 |
|--------|------|------|------|------|
| `created_at` | string | ✅ 是 | 任务创建时间 | `2026-01-20T09:00:00Z` |
| `started_at` | string | ⚠️ 条件 | 任务开始时间（状态为 in_progress 或 completed 时必需） | `2026-01-20T10:00:00Z` |
| `updated_at` | string | ✅ 是 | 最后更新时间（任何字段变化时更新） | `2026-01-20T15:30:00Z` |
| `due_date` | string | ✅ 是 | 任务截止时间 | `2026-01-20T23:59:59Z` |
| `completed_at` | string | ⚠️ 条件 | 任务完成时间（仅已完成任务） | `2026-01-20T18:00:00Z` |

### 里程碑 (Milestone) 时间字段

| 字段名 | 类型 | 必需 | 说明 | 示例 |
|--------|------|------|------|------|
| `started_at` | string | ✅ 是 | 里程碑开始时间 | `2026-01-16T09:00:00Z` |
| `completion_date` | string | ⚠️ 条件 | 里程碑完成时间（仅已完成里程碑，否则为 null） | `2026-01-19T18:00:00Z` |

### 风险 (Risk) 时间字段

| 字段名 | 类型 | 必需 | 说明 | 示例 |
|--------|------|------|------|------|
| `created_at` | string | ✅ 是 | 风险识别时间 | `2026-01-20T11:00:00Z` |
| `updated_at` | string | ✅ 是 | 最后更新时间 | `2026-01-20T15:00:00Z` |
| `resolved_at` | string | ⚠️ 条件 | 风险解决时间（仅已解决风险，否则为 null） | `2026-01-20T15:00:00Z` |

### 版本 (Version) 时间字段

| 字段名 | 类型 | 必需 | 说明 | 示例 |
|--------|------|------|------|------|
| `start_date` | string | ✅ 是 | 版本开始日期 | `2026-01-16T00:00:00Z` |
| `target_date` | string | ✅ 是 | 版本目标发布日期 | `2026-02-01T23:59:59Z` |

---

## 使用场景

### 场景 1：创建新任务

**操作**：在 `.ccg/progress.json` 的 `active_tasks` 数组中添加任务

**时间字段设置**：
```json
{
  "id": "task-new",
  "title": "实现新功能",
  "priority": "high",
  "status": "pending",
  "assignee": "Claude",
  "created_at": "2026-01-20T16:00:00Z",  // 当前时间
  "started_at": null,                     // pending 状态为 null
  "updated_at": "2026-01-20T16:00:00Z",  // 等于 created_at
  "due_date": "2026-01-22T23:59:59Z",    // 预期截止时间
  "milestone": "m1.1.2",
  "tags": ["feature"]
}
```

### 场景 2：开始任务

**操作**：将任务状态从 `pending` 改为 `in_progress`

**时间字段更新**：
```json
{
  "id": "task-new",
  "status": "in_progress",               // 状态变更
  "started_at": "2026-01-20T17:00:00Z", // 设置开始时间
  "updated_at": "2026-01-20T17:00:00Z"  // 更新最后修改时间
}
```

### 场景 3：完成任务

**操作**：将任务从 `active_tasks` 移到 `completed_tasks`

**时间字段更新**：
```json
// 从 active_tasks 移除，添加到 completed_tasks
{
  "id": "task-new",
  "title": "实现新功能",
  "created_at": "2026-01-20T16:00:00Z",
  "started_at": "2026-01-20T17:00:00Z",
  "completed_at": "2026-01-21T15:00:00Z", // 添加完成时间
  "milestone": "m1.1.2"
}
```

### 场景 4：识别风险

**操作**：在 `risks` 数组中添加风险项

**时间字段设置**：
```json
{
  "id": "risk-new",
  "title": "第三方 API 不稳定",
  "severity": "high",
  "impact": "可能导致功能无法使用",
  "mitigation": "添加重试机制",
  "status": "monitoring",
  "created_at": "2026-01-20T18:00:00Z",  // 风险识别时间
  "updated_at": "2026-01-20T18:00:00Z",  // 等于 created_at
  "resolved_at": null                     // 未解决为 null
}
```

### 场景 5：解决风险

**操作**：更新风险状态为 `resolved`

**时间字段更新**：
```json
{
  "id": "risk-new",
  "status": "resolved",                   // 状态变更
  "updated_at": "2026-01-21T10:00:00Z",  // 更新时间
  "resolved_at": "2026-01-21T10:00:00Z"  // 设置解决时间
}
```

---

## 计算公式

### 任务耗时计算

**实际耗时**（已完成任务）：
```
actual_duration = completed_at - started_at
```

**示例**：
```
started_at:   2026-01-20T10:00:00Z
completed_at: 2026-01-20T18:00:00Z
actual_duration = 8 小时
```

**当前耗时**（进行中任务）：
```
current_duration = 当前时间 - started_at
```

### 延期识别

**是否延期**：
```
is_overdue = (当前时间 > due_date) AND (status != "completed")
```

**延期时长**：
```
overdue_duration = 当前时间 - due_date
```

**示例**：
```
due_date:    2026-01-20T23:59:59Z
当前时间:     2026-01-21T10:00:00Z
status:      "in_progress"
→ 延期 10 小时
```

### 风险解决速度

**解决耗时**：
```
resolution_time = resolved_at - created_at
```

**示例**：
```
created_at:  2026-01-20T11:00:00Z
resolved_at: 2026-01-20T15:00:00Z
resolution_time = 4 小时
```

### 里程碑进度

**里程碑耗时**：
```
milestone_duration = completion_date - started_at
```

**预计剩余时间**（进行中里程碑）：
```
estimated_remaining = (总任务数 - 已完成任务数) × 平均任务耗时
```

---

## 最佳实践

### 1. 时间记录原则

**及时更新**：
- ✅ 任务状态变化时立即更新 `updated_at`
- ✅ 开始任务时立即设置 `started_at`
- ✅ 完成任务时立即设置 `completed_at`

**准确记录**：
- ✅ 使用实际时间，不要估算或回填
- ✅ 时区统一使用 UTC（Z 后缀）
- ✅ 精确到秒，不要省略秒数

**一致性**：
- ✅ 所有时间字段使用相同格式
- ✅ null 表示未发生，不要使用空字符串
- ✅ 已完成/已解决的项目必须有完成/解决时间

### 2. 时间字段维护

**创建时**：
```json
{
  "created_at": "当前时间",
  "started_at": null,        // pending 状态
  "updated_at": "当前时间"
}
```

**开始时**：
```json
{
  "started_at": "当前时间",
  "updated_at": "当前时间"
}
```

**更新时**（任何字段变化）：
```json
{
  "updated_at": "当前时间"
}
```

**完成时**：
```json
{
  "completed_at": "当前时间",
  "updated_at": "当前时间"
}
```

### 3. 时区处理

**统一使用 UTC**：
- 所有时间字段使用 UTC 时区（Z 后缀）
- 避免使用本地时区（+08:00 等）
- 显示时可转换为本地时区，但存储必须是 UTC

**转换示例**（Python）：
```python
from datetime import datetime, timezone

# 获取当前 UTC 时间
now_utc = datetime.now(timezone.utc).isoformat()
# 输出: '2026-01-20T15:30:00+00:00'

# 格式化为标准格式（Z 后缀）
now_utc = datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')
# 输出: '2026-01-20T15:30:00Z'
```

### 4. 数据验证

**必需字段检查**：
- `created_at` 必须存在
- `started_at` 在 in_progress/completed 状态时必须存在
- `completed_at` 在 completed 状态时必须存在
- `resolved_at` 在 resolved 状态时必须存在

**逻辑一致性检查**：
- `started_at >= created_at`
- `completed_at >= started_at`
- `updated_at >= created_at`
- `resolved_at >= created_at`

---

## 常见问题

### Q1: 为什么使用 UTC 而不是本地时区？

**A**: UTC 是国际标准时区，避免时区混淆和夏令时问题。存储使用 UTC，显示时可转换为本地时区。

### Q2: 如何处理跨天的任务？

**A**: ISO 8601 格式天然支持跨天计算，直接相减即可得到准确的时间差。

**示例**：
```
started_at:   2026-01-20T22:00:00Z
completed_at: 2026-01-21T02:00:00Z
duration = 4 小时（自动处理跨天）
```

### Q3: 任务暂停后如何记录时间？

**A**: 当前设计不支持暂停/恢复。如需支持，可添加 `paused_at` 和 `resumed_at` 字段，并在计算耗时时排除暂停时间。

### Q4: 如何批量更新时间字段？

**A**: 使用脚本或工具批量处理 JSON 文件。示例（Python）：

```python
import json
from datetime import datetime, timezone

# 读取配置
with open('.ccg/progress.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

# 更新所有活跃任务的 updated_at
now = datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')
for task in data['active_tasks']:
    task['updated_at'] = now

# 保存配置
with open('.ccg/progress.json', 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
```

### Q5: 时间字段可以为空字符串吗？

**A**: 不可以。时间字段只有两种状态：
- 有值：ISO 8601 格式字符串
- 无值：`null`（JSON null，不是字符串 "null"）

**错误示例**：
```json
{
  "started_at": "",      // ❌ 错误
  "started_at": "null",  // ❌ 错误
  "started_at": "N/A"    // ❌ 错误
}
```

**正确示例**：
```json
{
  "started_at": null,                    // ✅ 正确（未开始）
  "started_at": "2026-01-20T10:00:00Z"  // ✅ 正确（已开始）
}
```

---

## 总结

时间字段是进度管理的核心数据，准确记录和维护时间字段可以：
- ✅ 精确计算任务耗时和效率
- ✅ 及时识别延期和风险
- ✅ 生成准确的进度报告
- ✅ 支持数据分析和优化

**关键要点**：
1. 统一使用 ISO 8601 格式（UTC 时区）
2. 及时更新 `updated_at` 字段
3. 状态变化时同步更新相关时间字段
4. 使用 `null` 表示未发生的时间点
5. 保持数据一致性和逻辑正确性

**立即开始**：检查你的 `.ccg/progress.json` 文件，确保所有时间字段符合标准！
