---
name: ccg:codex-gate
description: Codex 审核门禁（明确 Blocking 规则和失败循环决策）
category: Quality Assurance
tags: [codex, review, gate, blocking, contract]
---

# Codex 审核门禁

> **用途**：明确 Codex 审核的 Blocking 规则，提供失败循环决策指导

## 核心原则

**Contract 是约束性的（Binding）**：
- 任何违反 Scope、Intent 或 Forbidden patterns 的行为都是 **BLOCKING**
- 所有 Blocking 问题必须引用 Contract 条款
- 不引入新需求，不审查超出 diff 和 Contract 的内容

**黄金法则**：
- 代码违反 Contract → 修复代码
- Contract 错误或不完整 → 修复 Contract

## Codex 审核输入

**必需输入**：
1. **Git diff**：实际的代码改动
2. **ai/contracts/current.md**：当前的 Contract

**审核范围**：
- ✅ 只审查 Git diff 中的改动
- ✅ 只对照 Contract 中的条款
- ❌ 不引入新需求
- ❌ 不审查超出范围的代码

## Blocking 规则

### 规则 1：Scope 违规（BLOCKING）

**检查项**：
```markdown
- [ ] 是否只修改了 Contract 中列出的文件？
- [ ] 是否只实现了 Contract 中定义的功能？
- [ ] 是否没有添加 Contract 之外的新功能？
```

**Blocking 示例**：
- ❌ Contract 只要求修改 `user.py`，但也修改了 `admin.py`
- ❌ Contract 只要求实现登录，但也实现了注册功能

**处理方式**：
- 引用 Contract 的 Scope 章节
- 要求回滚超出范围的改动

### 规则 2：Must-not-change 违规（BLOCKING）

**检查项**：
```markdown
- [ ] 是否保持了 Contract 中列出的不能改变的行为？
- [ ] 是否没有破坏现有的 API 接口？
- [ ] 是否保持了向后兼容性？
```

**Blocking 示例**：
- ❌ Contract 要求保持 API 接口不变，但修改了参数名称
- ❌ Contract 要求保持向后兼容，但删除了旧的配置项

**处理方式**：
- 引用 Contract 的 Must-not-change 章节
- 要求恢复被破坏的行为

### 规则 3：Forbidden Patterns 违规（BLOCKING）

**检查项**：
```markdown
- [ ] 是否避免了 Contract 中禁止的模式？
- [ ] 是否没有使用禁止的全局变量？
- [ ] 是否没有添加禁止的缓存？
```

**Blocking 示例**：
- ❌ Contract 禁止全局变量，但代码中使用了 `global user_cache`
- ❌ Contract 禁止添加缓存，但代码中添加了 Redis 缓存

**处理方式**：
- 引用 Contract 的 Forbidden patterns 章节
- 要求移除禁止的模式

### 规则 4：Performance Gate 违规（BLOCKING）

**如果 Performance trigger = YES**：
```markdown
- [ ] 是否提供了复杂度分析？
- [ ] 是否提供了规模假设？
- [ ] 是否符合性能策略？
```

**Blocking 示例**：
- ❌ Contract 要求 O(n) 复杂度，但实现是 O(n²)
- ❌ Contract 要求规模 n ≈ 10000，但实现无法处理

**如果 Performance trigger = NO**：
```markdown
- [ ] 是否避免了不必要的优化？
- [ ] 是否保持了简单性？
```

**Blocking 示例**：
- ❌ Contract 声明 NO，但代码中添加了复杂的缓存机制

**处理方式**：
- 引用 Contract 的 Performance Decision 章节
- 要求调整实现或更新 Contract

## 失败循环决策

当审核产生 Blocking 问题时，必须决定修复目标。

### 决策流程

**步骤 1：判断问题类型**
- 代码违反 Contract？→ 修复代码
- Contract 错误或不完整？→ 修复 Contract

**步骤 2：修复代码的场景**
- ✅ Scope 超出
- ✅ Must-not-change 行为被破坏
- ✅ 引入了 Forbidden pattern
- ✅ 缺少必需的测试或日志
- ✅ 违反 Performance gate

**步骤 3：修复 Contract 的场景**
- ✅ 需求相互矛盾
- ✅ 发现了新的约束条件
- ✅ Performance trigger 决策错误
- ✅ Scope 合理变更

**步骤 4：执行修复**
1. 决定修复目标（代码 vs Contract）
2. 修复选定的目标
3. 重新运行审核
4. 只有在审核通过后才提交

**重要原则**：
- ❌ 绝不绕过审核门禁
- ❌ 绝不在有 Blocking 问题时提交

## 使用示例

**调用方式**：
```
测试通过后
→ Claude 调用 /ccg:codex-gate
→ 准备审核输入（Git diff + Contract）
→ 调用 Codex 审核
→ 根据审核结果决策
```

**典型场景**：
1. 阶段性开发完成后的质量审核
2. 发现 Blocking 问题时的决策指导
3. 确保代码符合 Contract 约束

## 相关文档

- Codex 审核门禁：`ai/codex_review_gate.md`
- 失败循环决策：`ai/FAILURE_LOOP_DECISION.md`
- Contract 模板：`ai/contracts/CONTRACT_TEMPLATE.md`
- Codex 企业级审核：`/codex-code-review-enterprise` Skill

## 注意事项

1. **Contract 是约束性的**：所有 Blocking 问题必须引用 Contract 条款
2. **不引入新需求**：只审查 diff 和 Contract，不超出范围
3. **明确修复目标**：代码违反 Contract → 修复代码；Contract 错误 → 修复 Contract
4. **绝不绕过门禁**：有 Blocking 问题时绝不提交
