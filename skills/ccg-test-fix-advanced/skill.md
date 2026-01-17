---
name: ccg:test-fix-advanced
description: 测试失败多层级修复（3层策略：Codex+Coder → Claude → Gemini，每层3次重试）
category: Testing
tags: [test, fix, multi-tier, advanced]
---

# 测试失败多层级修复策略

> **用途**：使用多层级高质量修复策略，确保测试问题快速解决

## 核心思想

充分利用 CCG 系统中所有 AI 的能力，通过 3 层修复策略（每层 3 次重试）提高测试失败的自动修复成功率。

## 修复策略概述

```
测试失败
  ↓
第 1 层：Codex 深度诊断 + Coder 执行（最多 3 次）
  ↓ 失败
第 2 层：Claude 亲自动手修复（最多 3 次）
  ↓ 失败
第 3 层：Gemini 独立视角修复（最多 3 次）
  ↓ 失败
记录到待修复列表（.ccg/pending_test_fixes.json）
```

**总修复尝试次数**：9 次
**预期成功率**：96-99%

## acemcp 语义搜索集成

在每层修复前，使用 `mcp__acemcp__search_context` 进行语义搜索：

**核心优势**：
- 语义理解：不只是关键词匹配，理解代码的语义关系
- 自动索引：搜索前自动增量更新索引
- 全面覆盖：找到所有相关代码，包括辅助函数、工具类

**使用场景**：
- 第 1 层：深度搜索相关概念和模式
- 第 2 层：全面理解项目架构
- 第 3 层：独立视角的语义搜索

## 第 1 层：Codex 深度诊断 + Coder 执行

**角色**：Codex（诊断）+ Coder（执行）
**尝试次数**：最多 3 次
**预期成功率**：85-90%

### 执行步骤

**步骤 1：使用 acemcp 深度搜索**
```json
{
  "project_root_path": "项目根目录绝对路径",
  "query": "测试失败相关的概念、模式、类似实现"
}
```

**步骤 2：调用 Codex 诊断**
- 调用 `/ccg-workflow` Skill
- 调用 `mcp__ccg__codex` 进行深度分析
- 传递完整上下文：
  - 测试失败信息
  - acemcp 搜索结果
  - 相关代码文件

**步骤 3：Codex 诊断内容**
- 分析根本原因（不只是表面错误）
- 识别架构级问题
- 提供详细修复方案
- 给出具体的代码修改建议

**步骤 4：Coder 执行修复**
- 根据 Codex 的诊断结果
- 调用 `mcp__ccg__coder` 执行修复
- 传递 Codex 的修复方案
- 保持 SESSION_ID 上下文

**步骤 5：验证结果**
- 运行测试
- 如果通过，修复成功
- 如果失败且重试次数 < 3，重新诊断并重试
- 如果失败且重试次数 >= 3，进入第 2 层

## 第 2 层：Claude 亲自动手修复

**角色**：Claude（你自己）
**尝试次数**：最多 3 次
**预期成功率**：+8-12%（累计 93-97%）

### 执行步骤

**步骤 1：使用 acemcp 全面搜索**
```json
{
  "project_root_path": "项目根目录绝对路径",
  "query": "测试失败相关的项目架构、设计模式、完整上下文"
}
```

**步骤 2：深度分析**
- 回顾第 1 层的所有尝试和结果
- 分析为什么 Codex + Coder 都失败了
- 结合 acemcp 搜索结果理解项目架构
- 识别可能的深层次问题

**步骤 3：亲自修复**
- 使用 Edit 工具直接修改代码
- 不依赖 Coder，完全由 Claude 控制
- 可以进行复杂的多文件修改
- 可以重构代码结构

**步骤 4：验证结果**
- 运行测试
- 如果通过，修复成功
- 如果失败且重试次数 < 3，重新分析并重试
- 如果失败且重试次数 >= 3，进入第 3 层

## 第 3 层：Gemini 独立视角修复

**角色**：Gemini（独立专家）
**尝试次数**：最多 3 次
**预期成功率**：+3-5%（累计 96-99%）

### 执行步骤

**步骤 1：准备完整上下文**
- 整理前两层的所有尝试和结果
- 准备测试失败的完整信息
- 准备相关代码文件
- 准备 acemcp 搜索结果

**步骤 2：调用 Gemini**
- 调用 `/gemini-collaboration` Skill
- 调用 `mcp__ccg__gemini` 进行独立分析和修复
- 传递完整上下文和历史尝试

**步骤 3：Gemini 独立视角**
- 不受前面尝试的思维定式影响
- 从全新角度分析问题
- 可能提出完全不同的解决方案
- 直接修改代码（yolo 模式）

**步骤 4：验证结果**
- 运行测试
- 如果通过，修复成功
- 如果失败且重试次数 < 3，重新分析并重试
- 如果失败且重试次数 >= 3，进入失败记录流程

## 失败记录流程

**触发条件**：所有 3 层修复都失败（共 9 次尝试）

### 记录内容

创建或更新 `.ccg/pending_test_fixes.json` 文件：

```json
{
  "pending_fixes": [
    {
      "timestamp": "2026-01-17T10:30:00Z",
      "test_file": "tests/test_example.py",
      "test_name": "test_function_name",
      "error_message": "AssertionError: Expected 5, got 3",
      "error_type": "assertion_failure",
      "source_files": [
        "src/module.py",
        "src/helper.py"
      ],
      "repair_attempts": [
        {
          "tier": 1,
          "agent": "Codex + Coder",
          "attempts": 3,
          "diagnosis": "可能是边界条件处理问题",
          "last_error": "边界条件修复后仍失败"
        },
        {
          "tier": 2,
          "agent": "Claude",
          "attempts": 3,
          "last_error": "重构后仍未解决"
        },
        {
          "tier": 3,
          "agent": "Gemini",
          "attempts": 3,
          "last_error": "独立视角修复后仍失败"
        }
      ],
      "acemcp_searches": [
        "相关功能描述",
        "相关概念和模式",
        "项目架构和设计模式"
      ],
      "suggested_actions": [
        "人工审查测试用例是否正确",
        "检查是否是架构级问题",
        "考虑重新设计该模块"
      ]
    }
  ]
}
```

### 向用户报告

```
多层级修复失败（已尝试 9 次）

**测试信息**：
- 测试文件：tests/test_example.py
- 测试用例：test_function_name
- 错误信息：AssertionError: Expected 5, got 3

**修复尝试**：
- 第 1 层（Codex + Coder）：3 次尝试，失败
- 第 2 层（Claude）：3 次尝试，失败
- 第 3 层（Gemini）：3 次尝试，失败

**建议**：
1. 人工审查测试用例是否正确
2. 检查是否是架构级问题
3. 考虑重新设计该模块

**详细信息已记录到**：`.ccg/pending_test_fixes.json`
```

## 使用示例

**调用方式**：
```
用户："测试失败了，单层修复不行，帮我用多层级修复"
→ Claude 调用 /ccg:test-fix-advanced
→ 执行多层级修复流程
```

**典型场景**：
1. `/ccg:test-fix` 修复失败后自动升级
2. 用户明确要求使用多层级修复
3. 复杂的测试失败需要多方协作

## 相关文档

- 详细文档：`ai/testing/test_failure_multi_tier_fix.md`
- 单层修复：使用 `/ccg:test-fix` Skill
- 错误分类：`ai/error-handling/error_classification.md`
- acemcp 搜索：`mcp__acemcp__search_context` 工具

## 注意事项

1. **SESSION_ID 管理**：每个角色的 SESSION_ID 独立，必须使用实际返回值
2. **acemcp 搜索**：每层修复前都应该使用，提高成功率
3. **失败记录**：所有失败信息都会记录到 `.ccg/pending_test_fixes.json`
4. **人工介入**：4 层修复都失败后，需要人工审查

