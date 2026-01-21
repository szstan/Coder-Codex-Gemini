# CCG 上下文感知决策机制

> **用途**：根据任务上下文（紧急程度、重要性、复杂度）动态调整决策策略

## 概述

不同的任务有不同的特征和要求。上下文感知决策机制允许 Claude 根据任务的具体情况，动态调整决策权限等级和策略。

---

## 任务上下文维度

### 1. 任务优先级（Priority）

| 等级 | 名称 | 说明 | 典型场景 |
|------|------|------|---------|
| **P0** | 紧急修复 | 生产环境故障，需要立即修复 | 线上 Bug、安全漏洞 |
| **P1** | 高优先级 | 重要功能，需要尽快完成 | 核心功能开发、重要重构 |
| **P2** | 正常优先级 | 常规开发任务 | 新功能、优化、文档 |
| **P3** | 低优先级 | 探索性任务，不紧急 | 技术调研、实验性功能 |

### 2. 任务复杂度（Complexity）

| 等级 | 名称 | 判断标准 |
|------|------|---------|
| **简单** | Simple | 1-2 个文件，< 200 行代码，无架构变更 |
| **中等** | Medium | 3-5 个文件，200-1000 行代码，局部架构调整 |
| **复杂** | Complex | > 5 个文件，> 1000 行代码，涉及架构变更 |

### 3. 风险等级（Risk）

| 等级 | 名称 | 判断标准 |
|------|------|---------|
| **低风险** | Low | 只读操作、可逆操作、有完整测试 |
| **中风险** | Medium | 写入操作、部分可逆、测试覆盖不完整 |
| **高风险** | High | 不可逆操作、无测试、涉及生产数据 |

---

## 上下文感知决策规则

### 规则 1：P0 紧急修复模式

**触发条件**：
- 任务优先级 = P0
- 或用户明确说明"紧急"、"线上故障"

**决策调整**：
```
Level 2 → Level 1（减少询问，提升速度）
Level 1 → Level 0（部分低风险操作自动化）
超时阈值 × 0.5（缩短超时，快速失败）
重试次数 × 2（增加重试，提高成功率）
```

**示例**：
```
用户："线上认证服务挂了，紧急修复！"

Claude 检测：P0 紧急修复
→ 启用紧急模式
→ 语法错误自动修复（Level 2 → Level 1）
→ 依赖安装自动执行（Level 1 → Level 0）
→ 超时缩短为 1 分钟（快速失败）

报告：
"🚨 已启用紧急修复模式
- 自动修复明显错误
- 减少确认步骤
- 快速失败重试
正在修复..."
```

### 规则 2：P3 探索模式

**触发条件**：
- 任务优先级 = P3
- 或用户明确说明"探索"、"实验"、"调研"

**决策调整**：
```
Level 1 → Level 2（增加确认，更保守）
Level 0 → Level 1（增加透明度）
允许更长的超时（探索性任务可能耗时）
降低自动重试次数（避免浪费资源）
```

**示例**：
```
用户："我想探索一下使用 GraphQL 替代 REST API 的可行性"

Claude 检测：P3 探索模式
→ 启用保守模式
→ 所有改动都需要确认（Level 1 → Level 2）
→ 允许更长的分析时间
→ 减少自动重试

报告：
"🔍 已启用探索模式
- 所有改动需要您确认
- 允许更长的分析时间
- 我会详细说明每个决策
开始探索..."
```

### 规则 3：高风险任务模式

**触发条件**：
- 风险等级 = High
- 或涉及：删除操作、生产数据、不可逆操作

**决策调整**：
```
所有决策 → Level 3（强制询问）
要求明确的用户确认
建议创建备份/快照
禁用批量操作
```

**示例**：
```
任务：批量删除旧数据

Claude 检测：高风险操作
→ 启用高风险模式
→ 所有操作强制询问
→ 建议备份

报告：
"⚠️ 高风险操作检测
- 涉及数据删除（不可逆）
- 已启用最高安全级别
- 建议先备份数据

是否继续？请明确确认。"
```

---

## 上下文检测算法

```python
def detect_task_context(task_description, user_message):
    """检测任务上下文"""
    context = {
        "priority": "P2",  # 默认正常优先级
        "complexity": "medium",
        "risk": "medium"
    }
    
    # 检测优先级
    urgent_keywords = ["紧急", "线上", "故障", "urgent", "critical", "production"]
    explore_keywords = ["探索", "实验", "调研", "explore", "experiment", "research"]
    
    if any(kw in user_message.lower() for kw in urgent_keywords):
        context["priority"] = "P0"
    elif any(kw in user_message.lower() for kw in explore_keywords):
        context["priority"] = "P3"
    
    # 检测复杂度
    if task_description.file_count > 5 or task_description.line_count > 1000:
        context["complexity"] = "complex"
    elif task_description.file_count <= 2 and task_description.line_count < 200:
        context["complexity"] = "simple"
    
    # 检测风险
    high_risk_operations = ["delete", "drop", "truncate", "remove"]
    if any(op in task_description.operations for op in high_risk_operations):
        context["risk"] = "high"
    
    return context
```

---

## 上下文感知决策矩阵

| 上下文 | Level 0 | Level 1 | Level 2 | Level 3 | 超时 | 重试 |
|-------|---------|---------|---------|---------|------|------|
| **P0 紧急** | 保持 | → Level 0 | → Level 1 | 保持 | × 0.5 | × 2 |
| **P1 高优** | 保持 | 保持 | 保持 | 保持 | × 1 | × 1 |
| **P2 正常** | 保持 | 保持 | 保持 | 保持 | × 1 | × 1 |
| **P3 探索** | → Level 1 | → Level 2 | 保持 | 保持 | × 1.5 | × 0.5 |
| **高风险** | → Level 3 | → Level 3 | → Level 3 | 保持 | × 1 | × 0 |

---

## 与用户配置的关系

**优先级**：
```
上下文感知调整 > 用户配置 > 默认规则
```

**示例**：
```
用户配置：auto_fix_syntax = level_1
任务上下文：P0 紧急修复
→ 最终决策：level_0（上下文优先）

用户配置：auto_fix_syntax = level_1
任务上下文：高风险操作
→ 最终决策：level_3（安全性优先）
```

---

## 相关文档

- **决策权限矩阵**：`ai/decision_authority_matrix.md`
- **决策冲突解决**：`ai/decision_conflict_resolution.md`
- **决策可追溯性**：`ai/decision_traceability.md`

