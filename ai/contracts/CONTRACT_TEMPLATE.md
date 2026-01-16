# Implementation Contract

> This document defines the binding scope, constraints, and assumptions
> for the current change.
> All implementation and review must conform to this contract.

---

## 1. Scope & Goals

### In Scope
- [明确要实现/修改的内容]
- [功能、行为或文档层面的目标]

### Out of Scope
- [明确不做的事情，防止隐式扩展]
- [暂不处理的相关问题]

---

## 2. Non-Goals

本次变更 **明确不会解决** 以下问题：
- [非目标 1]
- [非目标 2]

---

## 3. Constraints

### Technical Constraints
- [语言 / 框架 / 版本限制]
- [架构边界 / 模块边界]

### Compatibility
- [向后兼容要求]
- [禁止的 breaking change]

### Security / Permissions
- [权限、安全、数据处理约束]
- [禁止的危险操作]

---

## 4. Performance Decision

- Performance trigger: **YES / NO**

If YES:
- Expected scale (n ≈ ?):
- Primary bottleneck: CPU / Memory / IO / Network
- Performance strategy (high level):

If NO:
- Rationale: 默认优先简单性与可读性，不做性能优化

---

## 5. Test & Observability Requirements

### Tests
- [必须新增/更新的单元测试]
- [是否需要集成测试]

### Observability
- [日志要求]
- [错误信息/上下文字段]
- [必要的指标或事件]

---

## 6. Assumptions & Open Questions

### Assumptions (Auto-Advance)

以下假设用于在不触发 Hard Stop 的前提下继续推进，
均采用最安全、最小侵入的判断。

- A1: [具体假设]
  - Reason: [为什么这是最安全/最小的假设]
  - Risk: Low / Medium / High
  - Validation: Codex Review / Claude Decision

- A2: ...

### Open Questions (Non-blocking)

以下问题当前不影响正确性或范围，
将在后续阶段被消化。

- Q1: [问题描述]
  - Impact if wrong: Low / Medium / High
  - Planned resolution: Ignore / Review / Contract Update

---

## 7. Acceptance Criteria

本次变更被视为完成，需满足：
- [功能正确性标准]
- [测试通过标准]
- [不违反 Contract 中的 Constraints 与 Assumptions]

---

## 8. Clearance Rule (Mandatory)

- 所有 Assumptions 必须在一次完整 Review / Decision 后被：
  - 确认成立，或
  - 收敛进 Contract，或
  - 显式废弃
- Assumptions 不得跨多个迭代无条件携带
- 若 Assumption 被判定为 High Risk 且无缓解方案，应触发 Hard Stop

---

## 9. Change Control

- 是否涉及配置 / schema / public API 变更：YES / NO
- 是否需要 migration / changelog：YES / NO
