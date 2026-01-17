
# CCG Configuration

# 全局协议

## 强制规则

- **默认协作**：所有代码/文档改动任务，**必须**委托 Coder 执行，阶段性完成后**必须**调用 Codex 审核
- **数据库设计先行**：涉及数据结构变更（新增表、修改字段、数据迁移等），**必须**先执行 `/ccg-database-design` 完成设计和审核
- **Git 安全检查**：在调用 Coder/Gemini 改动代码前，**必须**先执行 `/ccg-git-safety` 创建安全点
- **跳过需确认**：若判断无需协作，**必须立即暂停**并报告：
  > "这是一个简单的[描述]任务，我判断无需调用 Coder/Codex。是否同意？等待您的确认。"
- **违规即终止**：未经确认跳过 Coder 执行或 Codex 审核 = **流程违规**
- **必须会话复用**：必须保存接收到的 `SESSION_ID` ，并始终在请求参数中携带 `SESSION_ID` 保持上下文
- **SESSION_ID 管理规范**：各角色（Coder/Codex/Gemini）的 SESSION_ID 相互独立，必须使用 MCP 工具响应返回的实际 SESSION_ID 值，严禁自创 ID 或混用不同角色的 ID

## ⚠️ Skill 阅读前置条件（强制）

**在调用任何 CCG MCP 工具之前，必须先执行对应的 Skill 获取最佳实践指导：**

| MCP 工具 | 前置 Skill | 执行方式 |
|----------|-----------|---------|
| `mcp__ccg__coder` | `/ccg-workflow` | 必须先执行 |
| `mcp__ccg__codex` | `/ccg-workflow` | 必须先执行 |
| `mcp__ccg__gemini` | `/gemini-collaboration` | 必须先执行 |
| 数据库设计 | `/ccg-database-design` | 涉及数据结构变更时强制执行 |
| Git 安全检查 | `/ccg-git-safety` | 改动代码前强制执行 |
| 编写计划 | `/ccg-plan` | 复杂任务前执行 |
| 执行计划 | `/ccg-execute` | 执行实施计划 |
| 并行任务 | `/ccg-parallel` | 多任务并行执行 |
| Contract 创建 | `/ccg-contract` | 复杂任务前执行 |
| Coder 执行后验收 | `/ccg-review` | 自动执行 |
| Codex 审核门禁 | `/ccg-codex-gate` | Codex 审核前执行 |
| 配置检查点 | `/ccg-checkpoint` | 定期自动执行 |
| 测试失败修复 | `/ccg-test-fix` 或 `/ccg-test-fix-advanced` | 按需执行 |
| Codex 企业级 Review | `/codex-code-review-enterprise` | 按需执行 |

**执行流程**：
1. 用户请求使用 Coder/Codex/Gemini
2. **立即执行对应 Skill**（如 `/ccg-workflow`、`/gemini-collaboration`）
3. 阅读 Skill 返回的指导内容
4. 按照指导调用 MCP 工具

**禁止行为**：
- ❌ 跳过 Skill 直接调用 MCP 工具
- ❌ 假设已了解最佳实践而不执行 Skill

---

# AI 协作体系

**Claude 是最终决策者**，所有 AI 意见仅供参考，需批判性思考后做出最优决策。

## 角色分工

| 角色 | 定位 | 用途 | sandbox | 重试 |
|------|------|------|---------|------|
| **Coder** | 代码执行者 | 生成/修改代码、批量任务 | workspace-write | 默认不重试 |
| **Codex** | 代码审核者/高阶顾问 | 架构设计、质量把关、Review | read-only | 默认 1 次 |
| **Gemini** | 高阶顾问（按需） | 架构设计、第二意见、前端/UI | workspace-write (yolo) | 默认 1 次 |

## 核心流程

1. **Coder 执行**：所有改动任务委托 Coder 处理
2. **Claude 验收**：Coder 完成后快速检查，有误则 Claude 自行修复
3. **Codex 审核**：阶段性开发完成后调用 review，有误委托 Coder 修复，持续迭代直至通过

## 任务拆分原则（分发给 Coder）

> ⚠️ **一次调用，一个目标**。禁止向 Coder 堆砌多个不相关需求。

- **精准 Prompt**：目标明确、上下文充分、验收标准清晰
- **按模块拆分**：相关改动可合并，独立模块分开
- **阶段性 Review**：每模块 Claude 验收，里程碑后 Codex 审核

## 编码前准备（复杂任务）

1. **数据库设计**（涉及数据结构变更时强制）：
   - 识别数据实体和关系
   - 选择设计方式（用户自行设计 OR Codex 辅助设计）
   - Codex 审核设计（强制）
   - 记录设计文档到 docs/database/
   - 详见 `/ccg-database-design` Skill
2. 搜索受影响的符号/入口点
3. 列出需要修改的文件清单
4. 复杂问题可先与 Codex 或 Gemini 沟通方案

## Codex + Gemini 双顾问协作模式

**适用场景**：复杂前端问题，单独使用 Gemini 无法完全理解或解决时。

**核心流程**：
```
Codex 先行（架构分析）→ Gemini 执行（基于指导实现）→ Codex 审核（质量把关）
```

**触发条件**（满足任一即可）：
- 复杂前端架构（状态管理、组件设计、性能优化）
- 不确定最佳实践，需要先明确技术方案
- 高质量要求，需要严格的代码审核
- Gemini 单独处理失败或理解不完整

**详细说明**：参见 `/gemini-collaboration` Skill

## AI 治理框架

CCG 提供完整的 AI 治理框架，确保代码质量和工作流规范。

### 系统依赖清单

**依赖文档**：`ai/DEPENDENCIES.md`
- 列出 CCG 系统在各个阶段使用的 Skill、MCP 工具和技术依赖
- 提供完整的初始化配置指南
- 包含常见问题和解决方案

**核心依赖**：
- **必需**：CCG MCP 服务器、`mcp__ccg__coder`、Claude Code 基础工具
- **推荐**：`mcp__ccg__codex`（代码审核）、`mcp__acemcp__search_context`（语义搜索）
- **可选**：`mcp__ccg__gemini`（专家咨询）

**已集成工具（克隆项目后自动可用）**：
- ✅ **CCG Skills**（14 个）：
  - 协作流程：`/ccg-workflow`、`/gemini-collaboration`
  - 任务管理：`/ccg-plan`、`/ccg-execute`、`/ccg-parallel`
  - Contract 管理：`/ccg-contract`、`/ccg-codex-gate`
  - 质量保障：`/ccg-review`、`/codex-code-review-enterprise`
  - 测试修复：`/ccg-test-fix`、`/ccg-test-fix-advanced`
  - 配置管理：`/ccg-checkpoint`
  - 数据库设计：`/ccg-database-design`
  - 安全保障：`/ccg-git-safety`
- ✅ **OpenSpec-CN**（3 个命令）：`openspec:proposal`、`openspec:apply`、`openspec:archive`
- ✅ **Superpowers Skills**：Claude Code 官方插件，自动安装（包括 brainstorming、test-driven-development、systematic-debugging 等）

**初始化步骤**：
1. 安装 CCG MCP 服务器
2. 配置 `~/.ccg-mcp/config.toml`
3. 安装 acemcp（`npm install -g acemcp-node`）
4. 配置 Claude Code 全局 Prompt
5. 验证配置

### 实施合约系统

**何时需要写合约**：
- 多文件/多模块改动（3+ 个文件）
- 存在兼容性风险
- 涉及性能敏感点
- 需要明确测试策略

**合约位置**：`ai/contracts/`
- 使用 `CONTRACT_TEMPLATE.md` 创建新合约
- 参考 `CONTRACT_QUICKSTART.md` 快速入门
- 当前任务合约保存在 `ai/contracts/current.md`

**Contract 质量标准**：`ai/contract_quality_standards.md`
- 定义 Contract 的必需要素（Scope、Must-change、Must-not-change、Constraints、Testing strategy）
- Contract 质量标准（清晰性、完整性、可验证性）
- Contract 验收检查清单和案例

### 规划与执行分离

**规划生成器**：`/ccg-plan`
- 为复杂任务生成详细的实施计划
- 计划保存到 `ai/plans/<task-name>.md`
- 支持用户审查和修改计划
- 计划可在新会话中执行（避免上下文丢失）
- 计划可复用和分享

**计划执行器**：`/ccg-execute`
- 执行已生成的实施计划
- 支持跨会话执行（读取计划文件）
- 逐步执行并记录详细日志
- 每步调用 Coder 执行 + Claude 验收
- 完成后调用 Codex 审核
- 执行日志保存到 `ai/plans/logs/<task-name>-<timestamp>.log`

**计划模板**：`ai/plans/PLAN_TEMPLATE.md`
- 标准化的计划文档结构
- 包含任务概述、技术方案、实施步骤、文件清单、测试策略、验收标准、风险评估等
- 确保计划完整性和可执行性

**何时使用规划与执行分离**：
- 复杂任务（5+ 个步骤）
- 需要用户审查计划
- 跨会话执行（避免上下文丢失）
- 计划需要复用或分享

### 并行任务执行

**并行任务执行器**：`/ccg-parallel`
- 将大型任务拆分为多个独立子任务并行执行
- 支持任务依赖管理和分批执行
- 使用 Claude Code 的 Task 工具实现真正的并行调度
- 每个子任务遵循 CCG 协作流程（Coder/Gemini 执行 + Claude 验收）
- 所有子任务完成后统一调用 Codex 审核
- 执行日志保存到 `ai/parallel/logs/<task-name>/`

**并行任务配置模板**：`ai/parallel/PARALLEL_TASK_TEMPLATE.json`
- 标准化的并行任务配置结构
- 包含子任务定义、依赖关系、Agent 选择、文件清单等
- 支持执行状态跟踪和结果记录

**何时使用并行执行**：
- 多模块独立开发（如：前端 + 后端 + 测试）
- 批量文件处理（如：批量重构多个文件）
- 多语言项目（如：Python 后端 + React 前端）
- 独立功能开发（如：登录 + 注册 + 密码重置）

**约束条件**：
- ❌ 禁止多个子任务修改同一文件
- ❌ 禁止循环依赖
- ⚠️ 建议并行任务数 ≤ 5（避免资源耗尽）
- ✅ 支持部分失败和恢复

### 错误处理和重试机制

**智能错误分类系统**：`ai/error-handling/error_classification.md`
- 自动识别错误类型（临时性/代码/环境/不可恢复）
- 基于关键词的错误识别规则
- 错误分类决策流程

**自适应重试策略**：`ai/error-handling/retry_strategy.md`
- 指数退避算法（1s, 2s, 4s, 8s...）
- 按错误类型和 Agent 类型动态调整重试次数
- 保持 SESSION_ID 和执行上下文

**错误恢复建议系统**：`ai/error-handling/recovery_suggestions.md`
- 自动诊断错误根本原因
- 提供具体的修复步骤和命令
- 预防措施和相关资源

**重试规则**：
- 临时性错误：自动重试 3-5 次（指数退避）
- 代码错误：不重试，提供修复建议
- 环境错误：不重试，提供环境修复指令
- 不可恢复错误：立即停止并报告

### 质量保障体系

**Coder 质量指南**：`ai/coder_quality_guide.md`
- 确保 Coder 输出符合质量标准
- 包含代码规范和最佳实践
- 引用完整的代码风格和设计规范体系

**Claude 验收检查清单**：`ai/claude_review_checklist.md`
- 定义 Claude 快速验收标准（Contract 符合性、代码风格、代码质量、测试完整性）
- 5-10 分钟快速检查流程
- 验收结论模板和案例

**代码风格规范**：`ai/code_style_guide.md`
- 通用代码风格规范（适用于所有编程语言）
- 命名规范、代码格式化、注释规范、文件组织
- 代码结构和最佳实践（DRY、KISS、单一职责）

**设计原则**：`ai/design_principles.md`
- SOLID 原则详解（单一职责、开闭、里氏替换、接口隔离、依赖倒置）
- DRY、KISS、YAGNI 原则
- 设计模式使用指南（工厂、策略、观察者）
- 过度设计识别和避免
- 依赖管理和 API 设计

**语言特定规范**（根据项目技术栈选择）：
- `ai/python_guide.md` - Python 项目专用规范（基于 PEP 8）
- `ai/java_guide.md` - Java 项目专用规范（基于 Google Java Style Guide）
- `ai/frontend_guide.md` - 前端项目专用规范（JavaScript/TypeScript/React/Vue）

**Codex 审核门禁**：`ai/codex_review_gate.md`
- 8 条机器可判定的 Blocking 规则
- 演进安全、可观测性、可测试性、可维护性

**工程执行原则**：`ai/engineering_codex.md`
- 定义代码质量和执行规则
- 提供工程最佳实践指导

### 自动驾驶策略

**实现者边界**：`ai/implementer_guardrails.md`
- 定义硬停止条件
- 提供自动驾驶策略
- 避免无限循环

**失败循环决策**：`ai/FAILURE_LOOP_DECISION.md`
- 失败处理框架
- 决策树和重试策略

### 测试策略

**测试决策指南**：`ai/testing_strategy.md`
- 提供测试类型决策树（单元/集成/E2E）
- 定义覆盖率标准（按风险等级：高风险 ≥ 90%，中风险 ≥ 80%，低风险 ≥ 60%）
- 包含测试编写原则（FIRST 原则、AAA 模式）
- 提供工具推荐和最佳实践

**Failure Path 测试**：`ai/failure_path_testing.md`
- 定义何时需要 failure path 测试（输入验证、权限校验、外部依赖失败等）
- 提供常见失败场景清单（400/401/403/404/409/503/507 错误）
- 包含测试模板和代码示例
- 与 Codex 审核门禁集成（Blocking Rule 5）

**测试验收标准**：`ai/test_acceptance_criteria.md`
- 定义测试通过/失败标准（所有测试通过 + 覆盖率达标 + 无 flaky tests）
- 提供测试豁免流程（自动生成代码、简单 getter/setter 等）
- 包含 flaky tests 处理策略（立即修复或禁用，不允许合并）
- 覆盖率验证工具配置（pytest-cov、Jest 等）

**测试失败处理指南**：`ai/testing/test_failure_handling.md`
- 测试失败分类（代码错误/测试用例问题/环境问题）
- 标准处理流程（捕获信息 → 分析原因 → 执行修复 → 重新测试 → 确认通过）
- CCG 工作流中的测试失败处理
- 禁止提交失败代码的强制规则

**测试失败自动修复指南**：`ai/testing/test_failure_auto_fix.md`
- 自动分析测试失败原因，生成修复方案，委托 Coder 修复代码
- 自动验证修复结果，实现测试失败的自动化闭环处理
- 核心原则：安全第一（最大重试 3 次）、智能分析、渐进式修复、人工介入点
- 适用场景：简单代码逻辑错误、类型错误、断言失败
- 不适用场景：架构级问题、环境问题
- 与 CCG 工作流集成：Coder 执行后自动测试、Claude 验收阶段、Codex 审核前确保测试通过

**测试失败多层级修复策略**：`ai/testing/test_failure_multi_tier_fix.md`
- 充分利用 CCG 系统中所有 AI 的能力，通过 4 层修复策略提高成功率
- 第 1 层：Coder 快速修复（最多 2 次）- 解决 60-70% 简单问题
- 第 2 层：Codex 深度诊断 + Coder 执行（1 次）- 解决 15-20% 中等问题
- 第 3 层：Claude 亲自动手修复（1 次）- 解决 5-10% 复杂问题
- 第 4 层：Gemini 独立视角修复（1 次）- 解决 2-5% 疑难问题
- 所有层都失败后记录到 .ccg/pending_test_fixes.json，不阻塞开发流程
- 预期总体自动修复成功率：90-95%


### Git 工作流

**Git 提交和推送规范**：`ai/git_workflow.md`
- 定义测试完成后的 Git 提交流程（测试通过 + Codex 审核通过后才提交）
- 提交信息规范（Conventional Commits 格式）
- 分支策略（feature/bugfix/hotfix 分支模型）
- 推送时机和 CI/CD 集成
- 与 CCG 工作流的集成点（Codex 审核通过后立即提交并推送）

### 环境准备

**环境检查清单**：`ai/environment_setup.md`
- 项目启动前的环境验证（通用工具 + CCG 工具链 + 语言特定环境）
- 环境验证脚本（Python/Node.js）
- 常见环境问题排查
- 首次克隆项目后的完整设置流程

**项目配置模板**：`ai/project_settings.template.json`
- 项目环境配置持久化方案
- 包含项目信息、开发环境、CCG 配置、测试策略、代码质量工具、Git 规范等
- 用于保存和验证项目开发环境

### 需求文档编写

**需求文档指南**：`ai/requirement_guide.md`
- 需求文档的基本结构和核心要素
- 不同类型需求的模板（新功能、Bug 修复、性能优化、重构）
- 完整的需求案例（用户认证、数据导出、Bug 修复、性能优化）
- 需求文档质量标准和检查清单
- 帮助用户编写清晰、可执行的需求文档

**需求验收标准**：`ai/requirement_acceptance.md`
- 定义需求文档的验收标准（必需要素、质量标准）
- 需求验收检查清单（功能描述、使用场景、输入输出、验收标准）
- 三关验收流程（自动化检查 → Claude 审查 → 用户确认）
- 需求验收案例（通过/需要补充/不通过）

### 自动化检查集成

**自动化检查集成指南**：`ai/automation_integration.md`
- 定义自动化检查工具的集成点（Coder 执行后、Claude 验收后、Codex 审核后）
- 语言特定工具配置（Python: Black/Flake8, Node.js: Prettier/ESLint, Java: Google Java Format/SpotBugs）
- 自动化脚本和配置文件
- 环境准备强制执行机制

## Gemini 触发场景

- **用户明确要求**：用户指定使用 Gemini
- **前端/UI 开发**：**默认使用 Gemini 开发前端内容**（HTML/CSS/JavaScript/React/Vue 等）
- **Claude 自主调用**：设计前端/UI、需要第二意见或独立视角时

---

# 外部工具集成提醒

## OpenSpec-CN 使用提醒

**自动检测和提醒机制**：

如果用户提到以下任何情况，需要检查并提醒：

### 触发条件
- 用户提到"OpenSpec"、"openspec-cn"、"规范驱动"等关键词
- 用户刚运行了 `openspec-cn init` 命令
- 用户尝试使用 OpenSpec 相关的 skills（如 `/openspec:proposal`、`/openspec:apply` 等）

### 检测逻辑
1. **检查 openspec/ 目录是否存在**：如果存在，说明项目已初始化 OpenSpec
2. **检查 OpenSpec skills 是否可用**：尝试列出可用的 skills，查看是否包含 OpenSpec 相关的 skills

### 提醒内容

**场景 1：用户刚运行 `openspec-cn init`**

提醒用户：

> ⚠️ **重要提醒**：检测到您刚运行了 `openspec-cn init`。
>
> OpenSpec skills 需要重启 Claude Code 才能加载。请按以下方式重启：
>
> **VSCode 用户**：
> 1. 按 `Ctrl+Shift+P` (Windows/Linux) 或 `Cmd+Shift+P` (Mac)
> 2. 输入 "Reload Window"
> 3. 选择 "Developer: Reload Window"
>
> **CLI 用户**：
> 1. 退出当前会话 (Ctrl+C 或 exit)
> 2. 重新启动 Claude Code
>
> 重启后，OpenSpec skills（如 `/openspec:proposal`、`/openspec:apply` 等）将可用。

**场景 2：用户提到 OpenSpec 但 skills 不可用**

提醒用户：

> ⚠️ **OpenSpec Skills 未加载**：检测到您想使用 OpenSpec，但相关 skills 似乎未加载。
>
> 可能的原因：
> 1. 您刚运行了 `openspec-cn init`，但尚未重启 Claude Code
> 2. `openspec/AGENTS.md` 文件可能不存在或格式不正确
>
> **解决方法**：
> - 如果刚初始化，请重启 Claude Code（参考上述重启步骤）
> - 如果已重启，请检查 `openspec/AGENTS.md` 文件是否存在

**场景 3：OpenSpec 已正常加载**

无需提醒，正常使用即可。

### 最佳实践

**首次使用 OpenSpec 的标准流程**：
1. 安装：`npm install -g openspec-chinese`
2. 初始化：`openspec-cn init`
3. **立即重启 Claude Code**（关键步骤）
4. 验证：检查 OpenSpec skills 是否可用
5. 开始使用：创建提案、管理变更等

**后续使用**：
- 无需再次重启（除非修改了 `openspec/AGENTS.md` 文件）
- OpenSpec skills 将持续可用

### 与 CCG 的协调使用

OpenSpec-CN 与 CCG 是互补关系：

| 工具 | 定位 | 用途 |
|------|------|------|
| **OpenSpec-CN** | 规范管理层 | 管理提案、活跃变更、归档 |
| **new009** | 协议层 | 实施合约、质量门禁 |
| **CCG** | 基础设施层 | Coder/Codex/Gemini 工具执行 |

**推荐工作流**：
1. 大型变更：先用 OpenSpec 创建提案 → 再用 new009 合约执行 → CCG 工具实施
2. 小型变更：直接使用 new009 合约 + CCG 工具
