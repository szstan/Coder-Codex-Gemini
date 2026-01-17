---
name: gemini-collaboration
description: |
  Gemini expert consultation for architecture design, second opinions, and code review.
  Use when: user requests Gemini, need alternative perspective, or get independent review.
  Gemini 是与 Claude 同等级别的顶级 AI 专家，按需调用。
---

# Gemini 协作流程

## 角色定位

**Gemini** 是与 Claude 同等级别的顶级 AI 专家（**按需调用**）：

- 🧠 **高阶顾问**：架构设计、技术选型、复杂方案讨论
- ⚖️ **独立审核**：代码 Review、方案评审、质量把关
- 🔨 **代码执行**：原型开发、功能实现（尤其擅长前端/UI）

> **注**：能力等级不等于工程权限等级。
>
> Gemini 的输出仅作为专家意见；最终工程决策仍由 Claude/用户裁决。

## 触发场景

1. **用户明确要求**：用户指定使用 Gemini
2. **Claude 自主调用**：需要第二意见或独立视角时
3. **Codex + Gemini 双顾问模式**：复杂前端问题需要架构指导 + 实现

## Codex + Gemini 双顾问协作模式

**适用场景**：复杂前端问题，单独使用 Gemini 无法完全理解或解决时。

**核心思路**：
```
Codex 先行（架构分析）→ Gemini 执行（基于指导实现）→ Codex 审核（质量把关）
```

**具体流程**：

1. **第一步：Codex 架构分析**
   - 调用 Codex 理解需求和现有代码结构
   - 让 Codex 提供架构设计建议和最佳实践
   - 明确技术约束和实现边界
   - Prompt 示例：
     ```
     请分析以下前端需求的架构设计：
     [需求描述]

     请提供：
     1. 推荐的组件结构和状态管理方案
     2. 关键技术选型和最佳实践
     3. 需要注意的性能和可维护性问题
     4. 实现的边界和约束条件
     ```

2. **第二步：Git 安全检查（强制）**
   - 在调用 Gemini 改动代码前，必须执行 `/ccg-git-safety`
   - 创建 Git stash 安全点
   - 确保可以随时回退

3. **第三步：Gemini 实现**
   - 将 Codex 的架构指导作为上下文传递给 Gemini
   - Gemini 基于指导进行代码实现
   - 保持在架构约束内，不偏离设计
   - Prompt 示例：
     ```
     基于以下架构指导实现前端功能：

     【Codex 架构指导】
     [粘贴 Codex 的输出]

     【实现需求】
     [具体需求]

     请严格按照架构指导实现，不要偏离设计。
     ```

4. **第四步：Codex 审核**
   - 调用 Codex 审核 Gemini 的实现
   - 检查是否符合架构设计
   - 验证代码质量和最佳实践
   - 如有问题，返回第三步修复

**触发条件**（满足任一即可）：

- ✅ 复杂前端架构（状态管理、组件设计、性能优化）
- ✅ 不确定最佳实践，需要先明确技术方案
- ✅ 高质量要求，需要严格的代码审核
- ✅ Gemini 单独处理失败或理解不完整

**与其他模式的对比**：

| 模式 | 适用场景 | 流程 |
|------|---------|------|
| Coder 模式 | 明确的代码改动 | Coder 执行 → Claude 验收 → Codex 审核 |
| Gemini 单独模式 | 简单前端实现、原型开发 | Gemini 执行 → Claude 验收 |
| **Codex + Gemini 模式** | **复杂前端问题** | **Codex 分析 → Gemini 实现 → Codex 审核** |

**注意事项**：

- Codex 的架构指导是**建议**，不是强制约束
- Claude 作为最终决策者，可以调整或否决建议
- 保持 Codex 和 Gemini 的 SESSION_ID 独立
- 如果 Codex 审核不通过，可以迭代修复

## 不建议触发的场景（边界）

以下情况通常不建议优先调用 Gemini：

- 仅需要按既定范围执行改动（应优先交给 Coder）
- 仅需要判断实现是否合规或可合入（应优先交给 Codex）
- 已进入明确的执行/审核阶段且不存在重大决策分歧

## 外部工程约束（可选，但强烈推荐）

在部分项目中，调用方可能提供外部工程约束作为权威上下文，例如项目内 `ai/` 目录：

- `ai/contracts/current.md`（本次变更的 Implementation Contract）
- `ai/engineering_codex.md`（工程原则 / 默认判断）
- `ai/PROJECT_CONTEXT.md`（项目上下文，可选）

当上述约束被提供时：

- Claude 调用 Gemini 时应将其作为上下文一并提供
- Gemini 不应在未说明风险的情况下提出明显超出 Contract Scope 的建议或执行方案
- 若认为 Contract 本身存在明显缺陷，应指出并建议回到决策阶段修订，而非绕过

> 约束不要求工具自动读取路径；由 Claude 在 Prompt 中显式注入内容。

## 工具参考

| 参数        | 默认值               | 说明                 |
| ----------- | -------------------- | -------------------- |
| sandbox     | workspace-write      | 沙箱策略（灵活控制） |
| yolo        | true                 | 跳过审批             |
| model       | gemini-3-pro-preview | 默认模型             |
| max_retries | 1                    | 自动重试             |

**使用约定**：

Gemini 为按需专家咨询，不进入默认执行链路。自动推进（Autopilot）模式下，仅用于辅助决策或补充视角，不应引入新的 Scope 或替代既定 Contract。

**会话复用**：保存 `SESSION_ID` 保持上下文。

## 自动推进（与主流程一致）

默认策略：在不扩展 Scope、不引入新需求、不破坏兼容性的前提下，基于最安全、最小假设继续推进，并显式标注 `Assumption:`。

**Hard Stop（必须请求澄清）**：

- 可能造成 breaking change（行为 / 接口 / 配置 / schema）
- 需要新增依赖或升级关键依赖
- 涉及数据写入/删除、权限或安全相关
- 需要性能优化但缺少规模、指标或触发条件不明
- 缺失关键信息，无法保证正确性

## Gemini vs Codex 的使用边界（决策速查）

| 场景 / 目的                           | 优先使用 | 原因说明                 |
|--------------------------------------|----------|--------------------------|
| 需要第二视角、方案对比、架构讨论     | Gemini   | 擅长发散思考与高阶判断   |
| 评估多种实现路径的优劣               | Gemini   | 可提出替代方案与权衡     |
| 对现有代码进行质量/风险审查          | Codex    | 只读环境，更克制、更稳定 |
| 判断是否违反既定 Contract / Gate     | Codex    | 适合做一致性与合规检查   |
| 提供"还能不能更好"的建议             | Gemini   | 允许超出当前实现层面     |
| 判断"现在这样是否可以合入"           | Codex    | 不引入新需求，结论导向   |

**基本原则**：

- **Gemini 用于"想得更远"**
- **Codex 用于"守住当前"**
- 两者输出冲突时，由 Claude 统一裁决

## 独立决策

Gemini 的意见仅供参考。你（Claude）是最终决策者，需批判性思考，做出最优决策。

详细参数：[gemini-guide.md](gemini-guide.md)
