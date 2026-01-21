# AI 治理框架文档索引

> CCG 项目的完整 AI 治理框架文档导航

---

## 📖 快速开始

**新用户必读**：
1. [系统依赖清单](dependencies.md) - 了解 CCG 系统依赖
2. [环境准备](environment_setup.md) - 配置开发环境
3. [AI 入门指南](ai_onboarding.md) - 快速上手 CCG

**核心工作流**：
- [CCG 工作流](../skills/ccg-workflow/SKILL.md) - 完整的协作流程
- [Gemini 协作指南](../skills/gemini-collaboration/SKILL.md) - Gemini 使用指南

---

## 📋 Contract 系统

**核心文档**：
- [Contract 快速入门](contracts/contract_quickstart.md) - 何时需要 Contract
- [Contract 编写原则](contract_principles.md) - 如何写好 Contract
- [Contract 质量标准](contract_quality_standards.md) - Contract 验收标准
- [Contract 模板](contracts/contract_template.md) - 创建新 Contract

**示例**：
- [Contract 示例](contracts/examples/sample_contract.md)
- [当前 Contract](contracts/current.md)

---

## 🎯 决策机制

**核心框架**：
- [决策框架](decision_framework.md) - 完整的决策体系
- [决策权限矩阵](decision_authority_matrix.md) - 4 级决策权限

**决策增强**：
- [决策可追溯性](decision_traceability.md) - 决策日志和推理记录
- [批量决策优化](batch_decision_optimization.md) - 批量处理相似场景
- [决策冲突解决](decision_conflict_resolution.md) - 5 级优先级体系
- [上下文感知决策](context_aware_decision.md) - 动态调整决策策略

**失败处理**：
- [失败循环决策](failure_loop_decision.md) - 失败处理框架

---

## 🔧 质量保障

**代码质量**：
- [Coder 质量指南](coder_quality_guide.md) - Coder 输出质量标准
- [代码风格规范](code_style_guide.md) - 通用代码风格
- [设计原则](design_principles.md) - SOLID、DRY、KISS 原则
- [工程规范](engineering_codex.md) - 工程最佳实践

**语言特定规范**：
- [Python 指南](python_guide.md) - Python 项目规范
- [Java 指南](java_guide.md) - Java 项目规范
- [前端指南](frontend_guide.md) - JavaScript/TypeScript/React/Vue 规范

**审核机制**：
- [Claude 验收清单](claude_review_checklist.md) - Claude 快速验收
- [Codex 审核门禁](codex_review_gate.md) - 8 条 Blocking 规则

---

## 🧪 测试策略

**核心文档**：
- [测试策略指南](testing_strategy.md) - 测试类型决策树
- [测试验收标准](test_acceptance_criteria.md) - 测试通过标准
- [Failure Path 测试](failure_path_testing.md) - 失败场景测试

**测试失败处理**：
- [测试失败处理指南](testing/test_failure_handling.md) - 标准处理流程
- [测试失败自动修复](testing/test_failure_auto_fix.md) - 单层修复（最多 3 次）
- [测试失败多层级修复](testing/test_failure_multi_tier_fix.md) - 4 层修复策略（90-95% 成功率）

---

## ⚠️ 错误处理

**核心文档**：
- [错误分类](error-handling/error_classification.md) - 自动识别错误类型
- [重试策略](error-handling/retry_strategy.md) - 自适应重试算法
- [恢复建议](error-handling/recovery_suggestions.md) - 自动诊断和修复建议
- [自动降级](error-handling/auto_degradation.md) - 服务降级策略

---

## 🔄 Git 工作流

- [Git 工作流规范](git_workflow.md) - 提交、推送、分支策略

---

## 📦 规划与执行

- [规划模板](plans/PLAN_TEMPLATE.md) - 标准化的计划文档结构

---

## 🚀 项目接手

- [项目接手指南](project_handover_guide.md) - 三阶段接手流程
- [项目接手清单](project_handover_checklist.md) - 40+ 项检查清单

---

## 📝 需求管理

- [需求编写指南](requirement_guide.md) - 需求文档模板和案例
- [需求验收标准](requirement_acceptance.md) - 需求质量检查清单

---

## 🛡️ 安全边界

- [实现者边界](implementer_guardrails.md) - 硬停止条件和自动驾驶策略
- [超时保护](timeout_guardrails.md) - 超时检测和处理

---

## 🔌 集成与配置

- [自动化检查集成](automation_integration.md) - 代码格式化、Lint 工具集成
- [API 配额处理](api_quota_handling.md) - API 限流和配额管理
- [多项目隔离](multi_project_isolation.md) - 多项目环境隔离方案
- [日志分析指南](logging/log_analysis_guide.md) - 日志收集和分析

---

## 🏗️ 架构与角色

- [Claude 架构师](claude_architect.md) - Claude 的角色定位和职责

---

## 📚 其他文档

- [文档整合计划](doc_consolidation_plan.md) - 文档重命名和整合方案

---

## 📊 文档统计

- **总文档数**：49 个
- **核心文档**：15 个
- **支持文档**：34 个

---

## 🔗 相关资源

- **项目根目录**：[../README.md](../README.md)
- **快速开始**：[../QUICKSTART.md](../QUICKSTART.md)
- **项目路线图**：[../PROJECT_ROADMAP.md](../PROJECT_ROADMAP.md)
- **Skills 文档**：[../skills/](../skills/)

---

> 💡 **提示**：建议按照"快速开始"部分的顺序阅读核心文档，然后根据需要查阅其他文档。
