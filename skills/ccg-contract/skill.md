---
name: ccg:contract
description: Contract 创建和检查（确保 Contract 质量和规范性）
category: Quality Assurance
tags: [contract, checklist, scope, constraints]
---

# Contract 创建和检查

> **用途**：指导 Claude 创建符合规范的 Implementation Contract，并提供检查清单

## 核心原则

一个好的 Implementation Contract 是：
- **简短**：10-30 行填充内容，不超过 1 页
- **可执行**：所有条款都可以在实现和审查时检查
- **可审查**：明确的决策，而非哲学讨论

**黄金法则**：如果无法在审查时检查，就不应该写入 Contract

## Contract 的价值

1. **明确边界**：防止 Scope 隐式扩展
2. **约束决策**：提前做出关键技术决策
3. **审查基准**：为 Codex 审核提供明确标准
4. **避免返工**：在实现前达成共识

## Contract 必需章节

### 1. Scope（范围）

**必须包含**：
- ✅ **In Scope**：明确要实现/修改的内容
- ✅ **Out of Scope**：明确不做的事情

**检查清单**：
```markdown
- [ ] 列出了要修改的文件/模块
- [ ] 列出了明确的功能目标
- [ ] 列出了明确的 Out of Scope 区域
```

**常见错误**：
- ❌ 只写 In Scope，不写 Out of Scope
- ❌ Scope 描述过于宽泛（如"优化性能"）
- ❌ 隐式扩展 Scope（实现时添加未列出的功能）

### 2. Intent（意图）

**必须包含**：
- ✅ **主要职责**：一个清晰的主要目标
- ✅ **成功标准**：可验证的标准

**检查清单**：
```markdown
- [ ] 有一个明确的主要职责
- [ ] 成功标准是可验证的
- [ ] 避免了多个不相关的目标
```

### 3. Must-not-change Behaviors（不可改变的行为）

**必须包含**：
- ✅ **演进安全**：明确列出不能改变的行为
- ✅ **向后兼容**：明确兼容性要求

**检查清单**：
```markdown
- [ ] 列出了必须保持的行为
- [ ] 列出了向后兼容性要求
- [ ] 列出了禁止的 breaking change
```

**常见错误**：
- ❌ 忘记列出现有 API 接口
- ❌ 忘记列出现有配置项
- ❌ 假设"显而易见"的兼容性要求

### 4. Performance Trigger（性能触发器）

**必须包含**：
- ✅ **明确决策**：YES 或 NO（绝不是"maybe"）

**如果 YES**：
```markdown
- [ ] 列出了预期规模（n ≈ ?）
- [ ] 列出了预期复杂度（O(?)）
- [ ] 列出了瓶颈类型（CPU/Memory/IO）
- [ ] 列出了性能策略
```

**如果 NO**：
```markdown
- [ ] 明确声明"默认优先简单性，不做优化"
```

**常见错误**：
- ❌ 留空或写"maybe"
- ❌ YES 但没有列出规模和复杂度
- ❌ NO 但代码中添加了优化

### 5. Forbidden Patterns（禁止模式）

**必须包含**：
- ✅ **禁止的优化**：缓存、并发、全局变量等
- ✅ **禁止的依赖**：不允许引入的库或抽象

**检查清单**：
```markdown
- [ ] 列出了禁止的优化模式
- [ ] 列出了禁止的依赖或抽象
- [ ] 说明了禁止的原因
```

**常见错误**：
- ❌ 忘记列出禁止的全局变量
- ❌ 忘记列出禁止的缓存
- ❌ 没有说明禁止的原因

### 6. Tests（测试）

**必须包含**：
- ✅ **单元测试**：是否必需
- ✅ **失败路径测试**：是否必需
- ✅ **集成测试**：是否必需

**检查清单**：
```markdown
- [ ] 明确了单元测试要求
- [ ] 明确了失败路径测试要求
- [ ] 明确了集成测试要求（如需要）
```

**常见错误**：
- ❌ 忘记要求失败路径测试
- ❌ 测试要求过于宽泛（如"添加测试"）
- ❌ 没有明确测试覆盖范围

## 表单规则检查（Hard Rules）

在创建 Contract 后，必须检查以下硬性规则：

### 规则 1：只包含决策和约束
```markdown
- [ ] Contract 只包含决策和约束
- [ ] 没有聊天历史或讨论文本
- [ ] 没有哲学性描述
```

**错误示例**：
- ❌ "我们应该考虑性能优化..."（讨论）
- ❌ "代码应该优雅且可维护"（哲学）

**正确示例**：
- ✅ "Performance trigger: NO"（决策）
- ✅ "禁止使用全局变量"（约束）

### 规则 2：Performance Trigger 必须是 YES 或 NO
```markdown
- [ ] Performance trigger 是 YES 或 NO
- [ ] 绝不是"maybe"或留空
```

### 规则 3：大小控制
```markdown
- [ ] 填充内容在 10-30 行之间
- [ ] 总长度不超过 1 页
```

**如果超过 1 页**：
- 你在写设计文档，而非 Contract
- 需要简化和聚焦

## Contract 创建流程

### 步骤 1：理解需求（2 分钟）
- 阅读用户需求
- 识别核心目标
- 识别约束条件

### 步骤 2：定义 Scope（3 分钟）
- 列出 In Scope 项目
- 列出 Out of Scope 项目
- 列出要修改的文件

### 步骤 3：做出关键决策（5 分钟）
- Performance Trigger：YES 或 NO
- Must-not-change behaviors
- Forbidden patterns
- 测试要求

### 步骤 4：编写 Contract（5 分钟）
- 使用 `ai/contracts/contract_template.md` 模板
- 填写所有必需章节
- 保持简洁（10-30 行）

### 步骤 5：检查 Contract（3 分钟）
- 运行表单规则检查
- 检查所有必需章节
- 确认没有哲学性描述

### 步骤 6：保存 Contract（1 分钟）
- 保存到 `ai/contracts/current.md`
- 准备开始实现

## 使用示例

**调用方式**：
```
用户："我需要实现用户登录功能"
→ Claude 调用 /ccg:contract
→ 创建 Contract（约 15-20 分钟）
→ 保存到 ai/contracts/current.md
→ 开始实现
```

**典型场景**：
1. 复杂任务开始前创建 Contract
2. 需要明确边界和约束时
3. 多人协作需要统一标准时

## 相关文档

- Contract 模板：`ai/contracts/contract_template.md`
- Contract 质量标准：`ai/contract_quality_standards.md`
- Contract 编写原则：`ai/contract_principles.md`
- Contract 快速入门：`ai/contracts/contract_quickstart.md`

## 注意事项

1. **简洁优先**：10-30 行填充内容，不超过 1 页
2. **决策而非讨论**：只写决策和约束，不写哲学
3. **Performance Trigger 必须明确**：YES 或 NO，绝不是"maybe"
4. **Out of Scope 同样重要**：明确不做什么和做什么一样重要
