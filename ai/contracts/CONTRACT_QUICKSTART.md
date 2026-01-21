# Contract Quickstart Guide

> 一页教你「什么时候要写 Contract、什么时候不用」

> **相关文档**：
> - [编写原则](../contract_principles.md) - 如何写好 Contract
> - [质量标准](../contract_quality_standards.md) - Contract 验收标准
> - [空白模板](contract_template.md) - 创建新 Contract

---

## 快速决策树

```
任务开始
  ↓
是否满足以下任一条件？
  - 多文件/多模块改动
  - 存在兼容性风险
  - 涉及性能敏感点
  - 需要明确测试策略
  - 存在不确定性但需自动推进
  ↓
  YES → 写 Contract
  NO  → 直接执行
```

---

## ✅ 必须写 Contract 的场景

### 1. 多文件/多模块改动
**触发条件**：
- 改动涉及 3+ 个文件
- 跨越多个模块或子系统
- 需要协调多个组件的行为

**为什么**：
- 防止执行过程中 Scope 漂移
- 给 Codex Review 提供明确边界

---

### 2. 存在演进风险
**触发条件**：
- 可能影响现有行为
- 涉及 public API / 配置 / schema 变更
- 需要考虑向后兼容性

**为什么**：
- 明确 Must-not-change behaviors
- 防止意外引入 breaking change

---

### 3. 性能敏感
**触发条件**：
- 涉及循环、递归、大数据处理
- IO 密集型操作
- 用户明确提出性能要求

**为什么**：
- 需要明确规模假设（n ≈ ?）
- 避免过早优化或优化不足

---

### 4. 测试策略不明确
**触发条件**：
- 不确定需要哪些测试
- 涉及边界情况或异常路径
- 需要集成测试或 E2E 测试

**为什么**：
- 明确测试覆盖范围
- 防止遗漏关键测试场景

---

### 5. 存在不确定性但需自动推进
**触发条件**：
- 有多种实现方案
- 部分细节不明确但不阻塞
- 需要做出假设才能继续

**为什么**：
- 结构化记录 Assumptions
- 为后续 Review 提供清算点

---

## ❌ 不需要 Contract 的场景

### 简单任务
- 单文件小改动（< 50 行）
- 纯文档更新
- 明显的 typo 修复
- 简单的日志添加

### 探索性任务
- 代码阅读/理解
- 问题诊断
- 性能分析（未到实施阶段）

### 已有明确 Contract 的后续执行
- Contract 已存在且未过期
- 仅执行 Contract 中已定义的子任务

---

## 使用流程

### Step 1: 判断是否需要 Contract
使用上面的决策树快速判断

### Step 2: 创建 Contract
```bash
cp ai/contracts/CONTRACT_TEMPLATE.md ai/contracts/current.md
```

### Step 3: 让 Claude 填写
提供任务描述，让 Claude 填充 Contract 各章节

### Step 4: 执行与审核
- Coder 执行时携带 Contract
- Codex Review 时对照 Contract
- 所有 Assumptions 必须被清算

---

## Contract 生命周期

```
创建 → 执行 → Review → 清算 → 归档/废弃
  ↑                              ↓
  └──────── 需要修订时 ←──────────┘
```

### 何时更新 Contract
- 发现原 Contract 不合理
- Scope 需要调整（需明确说明原因）
- Assumptions 被证实或证伪

### 何时废弃 Contract
- 任务完成且所有 Assumptions 已清算
- 任务取消或方向变更

---

## 常见问题

### Q: Contract 写得太详细会不会浪费时间？
A: Contract 不是"事前设计文档"，而是"执行边界"。
   只需明确 Scope、Constraints 和 Assumptions，
   不需要详细设计每个函数。

### Q: 简单任务也要写 Contract 吗？
A: 不需要。单文件小改动直接执行即可。
   Contract 是为了防止复杂任务失控。

### Q: Assumptions 什么时候必须清算？
A: 在一次完整的 Codex Review 后，
   或在任务完成前，必须逐条确认或废弃。

### Q: Contract 可以跨多个任务复用吗？
A: 不建议。每个独立任务应有独立 Contract。
   如果是同一大任务的多个阶段，可以更新同一 Contract。

---

## 最佳实践

1. **Contract 优先于实现**
   - 先冻结 Contract，再委托 Coder 执行

2. **Assumptions 必须显式**
   - 不要让假设只存在于对话中
   - 所有假设必须进入 Contract 第 6 节

3. **Review 必须对照 Contract**
   - Codex Review 时必须检查是否违反 Contract
   - 不符合 Contract 的实现必须修正或修订 Contract

4. **清算点不可跳过**
   - 所有 High Risk Assumptions 必须在合入前清算
   - Medium Risk 可在 Review 后清算
   - Low Risk 可在后续迭代清算

---

## 示例：何时需要 Contract

### ✅ 需要 Contract
```
任务：实现用户认证系统
- 涉及多个文件（auth.ts, middleware.ts, routes.ts）
- 需要考虑安全性
- 存在多种认证方案（JWT vs Session）
→ 必须写 Contract
```

### ❌ 不需要 Contract
```
任务：修复 README 中的拼写错误
- 单文件改动
- 无技术风险
- 无不确定性
→ 直接执行
```

### ✅ 需要 Contract
```
任务：优化数据库查询性能
- 不确定数据规模
- 需要明确优化目标
- 可能影响现有行为
→ 必须写 Contract，明确性能假设
```

---

## 总结

**一句话原则**：
> 如果任务复杂到"可能失控"，就写 Contract；
> 如果简单到"一眼看穿"，就直接做。

**记住**：
Contract 不是负担，而是保险。
它让你在自动推进时有底气，在 Review 时有依据。
