
---
name: ccg-workflow
description: |
  CCG (Coder-Codex-Gemini) collaboration for code and document tasks.
  Use when: writing/modifying code, editing documents, implementing features, fixing bugs, refactoring, or code review.
  协调 Coder 执行代码/文档改动，Codex 审核代码质量。
---

# CCG 协作流程

## 角色分工

- **Claude**：架构师 + 验收者 + 最终决策者
- **Coder**：执行者（代码/文档改动）
- **Codex**：审核者 + 高级代码顾问
- **Gemini**：高阶顾问（按需） → 详见 `/gemini-collaboration`

> 说明：
> Gemini 属于**按需调用的专家型 Skill**，用于获取第二视角或高阶判断，
> **不作为默认执行或审核链路的一部分**。
> 当存在明确的执行或合规判断需求时，应优先使用 Coder / Codex。
> Gemini 的输出仅作为参考意见，由 Claude 统一裁决。

---

## 外部工程约束（可选，但强烈推荐）

某些项目会提供外部的工程约束与事实源（例如项目内 `ai/` 目录），用于保证执行与审核的一致性。

当提供以下任一项时，视为 **权威上下文** 并注入到后续调用中：

**核心约束**：
- `ai/contracts/current.md`（本次变更的 Implementation Contract）
- `ai/contract_quality_standards.md`（Contract 质量标准和验收检查清单）
- `ai/engineering_codex.md`（工程原则 / 默认判断）
- `ai/implementer_guardrails.md`（实现边界）
- `ai/codex_review_gate.md`（审核闸门）

**质量标准**：
- `ai/coder_quality_guide.md`（Coder 质量指南）
- `ai/claude_review_checklist.md`（Claude 验收检查清单）
- `ai/code_style_guide.md`（通用代码风格规范）
- `ai/design_principles.md`（设计原则：SOLID、DRY、KISS、YAGNI）

**语言特定规范**（根据项目技术栈选择）：
- `ai/python_guide.md`（Python 项目专用规范）
- `ai/java_guide.md`（Java 项目专用规范）
- `ai/frontend_guide.md`（前端项目专用规范）

**测试策略**：
- `ai/testing_strategy.md`（测试类型决策树、覆盖率标准）
- `ai/failure_path_testing.md`（Failure path 测试指南）
- `ai/test_acceptance_criteria.md`（测试验收标准）

**Git 工作流**：
- `ai/git_workflow.md`（Git 提交和推送规范、分支策略、与 CCG 集成）

**环境准备**：
- `ai/environment_setup.md`（环境检查清单、验证脚本）
- `ai/project_settings.template.json`（项目配置模板）

**需求文档编写**：
- `ai/requirement_guide.md`（需求文档编写指南、模板和案例）
- `ai/requirement_acceptance.md`（需求验收标准和检查清单）

**自动化检查集成**：
- `ai/automation_integration.md`（自动化检查工具集成指南）

**项目上下文**（可选）：
- `ai/PROJECT_CONTEXT.md`（项目特定上下文）

> 约束不要求 workflow 自动读取路径。
> **由 Claude 在每次调用时显式把内容注入 Prompt**。

---

## Context Retrieval（默认启用：Ace MCP）

当需要跨文件/跨模块定位实现位置、追踪调用链、查找配置/事件 key、或需求涉及多个目录时：

- Claude **必须优先**使用 MCP：`acemcp` 的 `search_context`（或等价检索工具）
- 目标是先拿到：**文件路径 + 行号/片段 + 相关符号**
- 若已明确目标文件且改动很小，可跳过检索以减少噪音

检索结果用于：
- 填写 Contract 的 Scope / Constraints / Assumptions
- 给 Coder 提供最小改动范围（文件清单 + 证据）
- 给 Codex 提供 review 定位依据

---

## 自动推进策略（Autopilot Policy）

默认策略：在 **不扩展 Scope、不引入新需求、不破坏兼容性** 的前提下，
**自动选择下一步并继续执行**，尽量减少反问。

### 默认假设（无需询问）
- 默认不扩 Scope，仅做最小必要改动
- 默认不做性能优化（除非明确触发性能需求）
- 默认保持向后兼容
- 默认补齐必要测试（unit 优先）与最小可观测性（日志 / 错误上下文）

### 允许先做后报（无需询问，但需显式标注 Assumption）
- 文件路径 / 命名存在轻微不确定但可从上下文合理推断
- 多种等价实现，选择最简单、侵入性最小方案
- 为可测试性 / 可读性进行小范围重构，但不改变行为

### Hard Stop（必须询问）
- 可能造成 breaking change（行为 / 接口 / 配置 / schema）
- 需要新增依赖或升级关键依赖
- 涉及数据写入 / 删除、权限或安全相关
- 需要性能优化但缺少规模、指标或触发条件不明
- 缺失关键信息，无法保证正确性

---

## Assumptions / Open Questions 自动生成规则（Autopilot）

在自动推进（Autopilot）模式下：

- 如存在任何不确定性，且未触发 Hard Stop：
  - **必须继续推进**
  - **不得向用户提问**
  - **必须严格按以下模板生成 Assumptions / Open Questions**
- 并在后续 Coder / Codex 调用中原样传递

### 固定输出模板（必须遵守）

```md
---

### Assumptions (Auto-Advance)

> 以下假设用于在不触发 Hard Stop 的前提下继续推进，
> 均采用最安全、最小侵入的判断。

- A1: [具体假设]
  - Reason: [为什么这是最安全/最小的假设]
  - Risk: Low / Medium / High
  - Validation: Codex Review / Claude Decision

### Open Questions (Non-blocking)

> 以下问题当前不影响正确性或范围，
> 已设置后续清算点。

- Q1: [问题描述]
  - Impact if wrong: Low / Medium / High
  - Planned resolution: Review / Contract Update / Ignore

---
````

---

## 任务拆分原则（分发给 Coder）

> ⚠️ **一次调用，一个目标**。禁止向 Coder 堆砌多个不相关需求。

* **精准 Prompt**：目标明确、上下文充分、验收标准清晰
* **按模块拆分**：相关改动可合并，独立模块分开
* **阶段性 Review**：每模块 Claude 验收，里程碑后 Codex 审核

---

## 核心流程

### 0.（推荐）冻结本次变更约束

当任务具备以下任一特征时，建议先形成或更新 Implementation Contract：

* 多文件 / 多模块改动
* 存在演进风险（兼容性 / 行为变化）
* 存在性能敏感点（规模 / IO / SLA）
* 需要明确测试与可观测性要求

后续 Coder / Codex 均以该 Contract 作为约束输入。

> 若变更范围不明确，先使用 Context Retrieval（Ace MCP）定位证据，再写 Contract。

---

### 1. 执行：Coder 处理所有改动

所有代码、文档等内容改动任务，**直接委托 Coder 执行**。

执行前（复杂任务推荐）：

* 搜索受影响的文件 / 符号（优先 Ace MCP）
* 在 PROMPT 中列出修改清单
* 必要时先咨询 Codex 或 Gemini，再委托 Coder

当存在工程约束时：

* 在 Coder Prompt 顶部注入 Contract / Guardrails / Assumptions
* 明确声明其为本次执行的边界，不得扩展 Scope

---

### 2. 验收：Claude 快速检查

Coder 执行完毕后，Claude 快速验收：

* **无误** → 继续下一任务
* **有误** → Claude 自行修复或重新委托

当存在 Contract 时，验收应优先检查：

* 是否超出 Scope
* 是否违反 Must-not-change behaviors
* 是否引入 Forbidden patterns
* 是否遗漏测试或可观测性要求

---

### 3. 审核：Codex 阶段性 Review

阶段性开发完成后，调用 Codex review：

* 检查代码质量、潜在 Bug
* 给出明确结论：✅ 通过 / ⚠️ 优化 / ❌ 修改

当存在工程约束时：

* Codex 输入必须包含 Contract / Review Gate / Assumptions
* Blocking 问题应尽量引用相关条款
* 不应引入 Contract 之外的新需求

---

## Session Recovery（会话失效恢复）

SESSION_ID 仅用于提升上下文连贯性，不作为权威状态源。

当出现 SESSION_ID 丢失或失效（如 `protocol_missing_session`、`empty_result`）时：

* 立即开启新会话（SESSION_ID 置空）
* 重新注入**最小上下文包**：

  * 本次任务的一句话目标
  * Implementation Contract（如存在）
  * 明确的变更范围或文件列表
  * 当前 Assumptions / Open Questions
  * 验收标准
* 对写入型工具（Coder / Gemini）避免盲目重试，必要时先执行只读确认

---

## 工具参考

| 工具     | 用途    | sandbox                | 重试     |
| ------ | ----- | ---------------------- | ------ |
| Coder  | 执行改动  | workspace-write        | 默认不重试  |
| Codex  | 代码审核  | read-only              | 默认 1 次 |
| Gemini | 顾问/执行 | workspace-write (yolo) | 默认 1 次 |

**会话复用**：保存 `SESSION_ID` 保持上下文。

---

## 独立决策

Coder / Codex / Gemini 的意见仅供参考。
你（Claude）是最终决策者，需批判性思考，做出最优决策。

当出现 Contract 与实现 / 审核意见冲突时：

* 实现违反 Contract → 优先修实现
* Contract 本身不合理 → 先修 Contract，再重新执行 / 审核
* 禁止绕过 Contract 直接合入"看起来更好"的方案

---

## 标准 Prompt 模板

你每次只要复制这段，然后填空：

```text
TASK:
[一句话说明要做什么]

CONTEXT:
- Project/module: [xxx]
- Known files/dirs: [如果不确定写 "unknown"；让 acemcp 搜]

AUTHORITY CONTEXT (paste if present):
- ai/contracts/current.md: [paste or say "none"]
- ai/engineering_codex.md: [paste or say "none"]
- ai/implementer_guardrails.md: [paste or say "none"]
- ai/codex_review_gate.md: [paste or say "none"]

RETRIEVAL:
If the change is not obviously single-file/trivial, use acemcp.search_context to locate relevant files and cite paths/line snippets before drafting or revising the contract.

SUCCESS CRITERIA:
- [如何判断完成/正确：功能、测试、兼容性]

AUTOPILOT MODE:
Proceed automatically unless a Hard Stop is explicitly triggered.
Do NOT ask questions by default.
If any uncertainty exists that does NOT trigger a Hard Stop:
- Continue with the safest, minimal assumption
- Append the required “Assumptions / Open Questions” section using the exact template
- Do not expand scope or introduce new requirements
Only stop and ask for clarification if a Hard Stop condition is met
(breaking behavior, config/schema/API change, data/security risk,
or performance decision without scale assumptions).
```

---

## Context Pack（运行时上下文注入 · 强制）

在任何跨工具调用（Claude → Coder / Codex / Gemini）时，
必须在 Prompt 顶部按以下顺序注入 Context Pack，
以保证运行时上下文一致性。

### Context Pack v1（必须遵守）

1. Task-ID + 一句话目标
2. Scope（In / Out）
3. Assumptions / Open Questions（来自 current.md）
4. Affected files（基于 acemcp 检索的证据）
5. Success criteria
6. Hard constraints（如性能触发、兼容性）

> Contract（ai/contracts/current.md）是权威事实源，
> Context Pack 仅用于运行时注入，不作为持久文档保存。


