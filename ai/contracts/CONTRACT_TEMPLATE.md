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

## 4. Code Quality & Style Standards

### 4.1 质量标准

**必须遵守**：`ai/coder_quality_guide.md`
- 质量优先于速度
- 简单清晰优于复杂巧妙
- 严禁过度工程
- 严禁破坏现有代码

### 4.2 代码风格规范

**通用规范**（所有语言必读）：
- `ai/code_style_guide.md` - 命名、格式化、注释、文件组织

**语言特定规范**（根据项目技术栈选择一个）：
- [ ] `ai/python_guide.md` - Python 项目
- [ ] `ai/java_guide.md` - Java 项目
- [ ] `ai/frontend_guide.md` - 前端项目（JavaScript/TypeScript/React/Vue）

### 4.3 规范优先级

**执行顺序**：
1. 首先遵守质量标准（coder_quality_guide.md）
2. 然后应用通用代码风格（code_style_guide.md）
3. 最后应用语言特定规范

**冲突处理**：
- 质量原则 > 风格规范
- 项目现有风格 > 标准规范
- 简单性 > 一致性（当一致性导致过度复杂时）

---

## 5. Performance Decision

- Performance trigger: **YES / NO**

If YES:
- Expected scale (n ≈ ?):
- Primary bottleneck: CPU / Memory / IO / Network
- Performance strategy (high level):

If NO:
- Rationale: 默认优先简单性与可读性，不做性能优化

---

## 6. Test & Observability Requirements

### 6.1 测试类型（根据 ai/testing_strategy.md 决策树选择）

**风险等级评估**：
- [ ] 高风险（支付、安全、数据完整性）
- [ ] 中风险（核心业务逻辑）
- [ ] 低风险（辅助功能、工具函数）
- [ ] 实验性（原型、POC 代码）

**测试类型**：
- [ ] 单元测试（必须/可选）：覆盖率目标 ≥ ___%
  - 测试范围：[具体模块/函数]
- [ ] 集成测试（必须/可选）：覆盖 ___
  - 测试范围：[API 端点/数据库操作]
- [ ] E2E 测试（必须/可选）：覆盖 ___
  - 测试范围：[关键用户流程]

### 6.2 Failure Path 测试（参考 ai/failure_path_testing.md）

**必须测试的失败场景**：
- [ ] 输入验证失败（空值、非法格式、超长字符串）
- [ ] 权限校验失败（未登录、权限不足）
- [ ] 外部依赖失败（数据库超时、API 失败）
- [ ] 并发冲突（乐观锁冲突）
- [ ] 资源耗尽（磁盘满、内存不足）
- [ ] 其他：___

### 6.3 测试工具

- 单元测试：[pytest / Jest / JUnit / ___]
- 集成测试：[Supertest / REST Assured / ___]
- E2E 测试：[Playwright / Cypress / ___]
- Mock 工具：[unittest.mock / Jest / ___]

### 6.4 验收标准（参考 ai/test_acceptance_criteria.md）

- [ ] 所有测试通过（绿色）
- [ ] 覆盖率达标（见 6.1）
- [ ] 无 flaky tests（不稳定测试）
- [ ] 测试执行时间合理（单元测试 < 5 分钟）

### 6.5 测试豁免（如适用）

**豁免代码**：
- [文件/函数名]: [豁免理由]
  - 示例：`models/generated.py`: ORM 自动生成的代码

### 6.6 Observability

- [日志要求]
- [错误信息/上下文字段]
- [必要的指标或事件]

---

## 7. Assumptions & Open Questions

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

## 8. Acceptance Criteria

本次变更被视为完成，需满足：
- [功能正确性标准]
- [测试通过标准]
- [不违反 Contract 中的 Constraints 与 Assumptions]

---

## 9. Clearance Rule (Mandatory)

- 所有 Assumptions 必须在一次完整 Review / Decision 后被：
  - 确认成立，或
  - 收敛进 Contract，或
  - 显式废弃
- Assumptions 不得跨多个迭代无条件携带
- 若 Assumption 被判定为 High Risk 且无缓解方案，应触发 Hard Stop

---

## 10. Change Control

- 是否涉及配置 / schema / public API 变更：YES / NO
- 是否需要 migration / changelog：YES / NO
