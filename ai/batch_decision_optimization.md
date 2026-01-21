# CCG 批量决策优化机制

> **用途**：检测批量决策模式，提供"应用到所有"选项，提升决策效率

## 概述

当系统检测到多个相似的决策场景时（如 10 个文件有相同的语法错误），应该提供批量处理选项，避免逐个确认造成的效率低下。

---

## 批量决策触发条件

### 触发规则

| 条件 | 阈值 | 说明 |
|------|------|------|
| 相同错误类型 | ≥ 3 个 | 3 个或以上文件有相同类型的错误 |
| 相同修复方案 | 100% | 所有错误可以用相同的方法修复 |
| 相同决策等级 | 一致 | 所有决策属于同一权限等级 |
| 时间窗口 | 5 分钟内 | 在短时间内连续出现 |

### 典型场景

#### 场景 1：批量导入错误

**检测**：
```
文件 A：ImportError: No module named 'requests'
文件 B：ImportError: No module named 'requests'
文件 C：ImportError: No module named 'requests'
...（共 10 个文件）
```

**批量决策提示**：
```
⚠️ 检测到批量相似问题

**问题类型**：导入错误
**影响文件**：10 个文件
**错误详情**：缺少模块 'requests'
**建议方案**：安装 requests 包

**批量处理选项**：
1. ✅ 批量修复所有（推荐）- 安装 requests 并更新所有文件
2. 📋 显示所有文件列表 - 查看详细信息
3. 🔍 逐个确认 - 逐个文件处理
4. ⏭️ 跳过所有 - 暂不处理

请选择：
```

#### 场景 2：批量语法错误

**检测**：
```
文件 A：SyntaxError: Missing closing parenthesis (line 42)
文件 B：SyntaxError: Missing closing parenthesis (line 38)
文件 C：SyntaxError: Missing closing parenthesis (line 55)
...（共 5 个文件）
```

**批量决策提示**：
```
⚠️ 检测到批量相似问题

**问题类型**：语法错误（缺少右括号）
**影响文件**：5 个文件
**错误位置**：
- src/auth.py:42
- src/user.py:38
- src/session.py:55
- src/token.py:67
- src/utils.py:23

**建议方案**：自动添加缺失的右括号

**批量处理选项**：
1. ✅ 批量修复所有（推荐）- 自动修复所有文件
2. 📋 显示修复预览 - 查看每个文件的修复方案
3. 🔍 逐个确认 - 逐个文件确认修复
4. ⏭️ 跳过所有 - 暂不处理

请选择：
```

#### 场景 3：批量测试失败

**检测**：
```
test_auth.py::test_login - AssertionError: Expected 200, got 401
test_user.py::test_create - AssertionError: Expected 200, got 401
test_session.py::test_start - AssertionError: Expected 200, got 401
...（共 8 个测试）
```

**批量决策提示**：
```
⚠️ 检测到批量相似问题

**问题类型**：测试失败（认证错误）
**影响测试**：8 个测试用例
**失败原因**：所有测试返回 401 Unauthorized（预期 200）
**根本原因分析**：可能是认证逻辑变更导致

**批量处理选项**：
1. 🔍 深度分析根本原因 - 调用 Codex 诊断认证逻辑
2. ✅ 批量修复测试用例 - 更新所有测试的预期值
3. 📋 显示所有失败测试 - 查看详细信息
4. ⏭️ 跳过所有 - 暂不处理

请选择：
```

---

## 批量决策检测算法

### 相似度计算

```python
def calculate_similarity(error1, error2):
    """计算两个错误的相似度（0-1）"""
    similarity_score = 0.0
    
    # 1. 错误类型相同 (+0.4)
    if error1.type == error2.type:
        similarity_score += 0.4
    
    # 2. 错误消息相似 (+0.3)
    if error_message_similarity(error1.message, error2.message) > 0.8:
        similarity_score += 0.3
    
    # 3. 修复方案相同 (+0.3)
    if error1.fix_method == error2.fix_method:
        similarity_score += 0.3
    
    return similarity_score

def detect_batch_pattern(errors):
    """检测批量模式"""
    if len(errors) < 3:
        return None
    
    # 计算所有错误对的相似度
    similarities = []
    for i in range(len(errors)):
        for j in range(i+1, len(errors)):
            sim = calculate_similarity(errors[i], errors[j])
            similarities.append(sim)
    
    # 平均相似度 > 0.8 认为是批量模式
    avg_similarity = sum(similarities) / len(similarities)
    if avg_similarity > 0.8:
        return {
            "pattern_type": errors[0].type,
            "count": len(errors),
            "similarity": avg_similarity,
            "fix_method": errors[0].fix_method
        }
    
    return None
```

### 批量决策分组

```python
def group_similar_decisions(decisions):
    """将相似的决策分组"""
    groups = []
    
    for decision in decisions:
        # 查找匹配的组
        matched_group = None
        for group in groups:
            if calculate_similarity(decision, group[0]) > 0.8:
                matched_group = group
                break
        
        if matched_group:
            matched_group.append(decision)
        else:
            groups.append([decision])
    
    # 只返回包含 ≥ 3 个决策的组
    return [g for g in groups if len(g) >= 3]
```

---

## 批量决策执行策略

### 策略 1：全部应用（推荐）

**适用**：所有决策完全相同，风险低

**执行流程**：
```
用户选择"批量修复所有"
    ↓
Claude 记录批量决策
    ↓
逐个执行修复（静默）
    ↓
汇总报告结果
```

**报告模板**：
```
✅ 批量修复完成

**处理数量**：10 个文件
**成功**：9 个
**失败**：1 个（src/legacy.py - 语法复杂，需要手动处理）

**详细结果**：
✅ src/auth.py - 已修复
✅ src/user.py - 已修复
✅ src/session.py - 已修复
...
❌ src/legacy.py - 修复失败（需要手动处理）

**下一步**：请手动检查 src/legacy.py
```

### 策略 2：显示预览

**适用**：用户想先查看详细信息再决定

**执行流程**：
```
用户选择"显示修复预览"
    ↓
Claude 生成修复预览
    ↓
显示每个文件的修复方案
    ↓
用户确认后执行
```

**预览模板**：
```
📋 批量修复预览

**文件 1/10**：src/auth.py
- 位置：第 42 行
- 当前：if user.is_authenticated(
- 修复：if user.is_authenticated()
- 风险：低

**文件 2/10**：src/user.py
- 位置：第 38 行
- 当前：return self.validate(
- 修复：return self.validate()
- 风险：低

...（显示所有文件）

**确认批量修复？**
1. ✅ 确认，批量修复所有
2. ❌ 取消
```

### 策略 3：逐个确认

**适用**：用户想精细控制每个决策

**执行流程**：
```
用户选择"逐个确认"
    ↓
遍历每个决策
    ↓
逐个询问用户
    ↓
记录用户选择
    ↓
汇总报告结果
```

**逐个确认模板**：
```
🔍 逐个确认（1/10）

**文件**：src/auth.py
**位置**：第 42 行
**问题**：缺少右括号
**修复方案**：添加 )

**您的选择**：
1. ✅ 修复此文件
2. ⏭️ 跳过此文件
3. 🛑 停止，剩余文件也跳过
4. ✅ 修复此文件，并应用到剩余所有文件

请选择：
```

---

## 批量决策日志格式

### 批量决策记录

```jsonl
{
  "timestamp": "2026-01-21T15:00:00Z",
  "decision": "batch_fix",
  "level": "level_2",
  "reason": "batch_syntax_errors",
  "reasoning": "检测到 10 个文件有相同的语法错误（缺少右括号），相似度 0.95。根据批量决策优化机制，提供批量处理选项以提升效率。",
  "rule": "ai/batch_decision_optimization.md#L10",
  "context": {
    "pattern_type": "syntax_error",
    "count": 10,
    "similarity": 0.95,
    "fix_method": "add_closing_parenthesis",
    "affected_files": [
      "src/auth.py:42",
      "src/user.py:38",
      "src/session.py:55",
      "..."
    ]
  },
  "action": "prompt_batch_options",
  "user_choice": "batch_fix_all",
  "outcome": "partial_success",
  "results": {
    "success": 9,
    "failure": 1,
    "failed_files": ["src/legacy.py"]
  }
}
```

---

## 与决策权限等级集成

### 批量决策的权限等级

| 原决策等级 | 批量决策等级 | 说明 |
|-----------|-------------|------|
| Level 0 | Level 0 | 完全自主，批量静默执行 |
| Level 1 | Level 1 | 透明自主，报告后批量执行 |
| Level 2 | Level 2 | 提示确认，提供批量选项 |
| Level 3 | Level 3 | 强制询问，逐个确认 |

**规则**：批量决策不降低权限等级，保持原有的安全性。

