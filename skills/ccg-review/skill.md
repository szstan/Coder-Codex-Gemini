---
name: ccg:review
description: Claude 验收检查清单（Coder 执行后的快速质量检查）
category: Quality Assurance
tags: [review, quality, checklist, acceptance]
---

# Claude 验收检查清单

> **用途**：Coder 执行后的快速验收，确保代码在进入测试阶段前达到基本质量要求

## 核心定位

### 在 CCG 工作流中的位置

```
Coder 执行
    ↓
【Claude 快速验收】← 第一道人工检查（本 Skill）
    ↓
通过 → 运行测试
不通过 → Claude 修复或重新委托 Coder
```

### Claude 验收 vs Codex 审核

| 维度 | Claude 验收 | Codex 审核 |
|------|------------|-----------|
| **时机** | Coder 执行后立即进行 | 测试通过后进行 |
| **目标** | 快速发现明显问题 | 深度审核代码质量 |
| **深度** | 浅层检查（5-10 分钟） | 深度审核（15-30 分钟） |
| **标准** | 基本质量标准 | 严格质量标准（8 条 Blocking 规则） |
| **结果** | 通过/修复 | 通过/建议优化/需要修改 |

### 核心价值

**快速发现明显问题**：
- ✅ Scope 超出（做了不该做的）
- ✅ 代码风格明显违规
- ✅ 缺少必要的测试
- ✅ 明显的逻辑错误

**避免浪费测试和审核时间**：
- 如果代码有明显问题，直接在 Claude 验收阶段修复
- 避免运行测试后才发现基本问题
- 避免 Codex 审核时发现大量低级问题

## 验收检查清单

### 1. Contract 符合性检查（Blocking）

**如果存在 Contract，必须检查以下项目**：

#### ✅ Scope 检查
```markdown
- [ ] 是否只修改了 Contract 中列出的文件？
- [ ] 是否只实现了 Contract 中定义的功能？
- [ ] 是否没有添加 Contract 之外的新功能？
```

**检查方法**：
1. 对比 `git diff` 输出和 Contract 的 Scope
2. 确认所有改动都在 Scope 范围内

**不通过示例**：
- ❌ Contract 只要求修改 `user.py`，但也修改了 `admin.py`
- ❌ Contract 只要求实现登录，但也实现了注册功能

#### ✅ Must-not-change 检查
```markdown
- [ ] 是否保持了 Contract 中列出的不能改变的行为？
- [ ] 是否没有破坏现有的 API 接口？
- [ ] 是否保持了向后兼容性？
```

**不通过示例**：
- ❌ Contract 要求保持 API 接口不变，但修改了参数名称
- ❌ Contract 要求保持向后兼容，但删除了旧的配置项

#### ✅ Forbidden patterns 检查
```markdown
- [ ] 是否避免了 Contract 中禁止的模式？
- [ ] 是否没有使用全局变量（如 Contract 禁止）？
- [ ] 是否没有添加缓存（如 Contract 禁止）？
```

**不通过示例**：
- ❌ Contract 禁止全局变量，但代码中使用了 `global user_cache`
- ❌ Contract 禁止添加缓存，但代码中添加了 Redis 缓存

### 2. 代码风格检查（Blocking）

#### ✅ 命名规范
```markdown
- [ ] 变量名是否使用了正确的命名风格？
  - Python: snake_case
  - Java: camelCase
  - JavaScript: camelCase
- [ ] 类名是否使用了 PascalCase？
- [ ] 常量是否使用了 UPPER_SNAKE_CASE？
- [ ] 函数名是否清晰描述了功能？
```

**不通过示例**：
- ❌ Python 中使用 `userName` 而不是 `user_name`
- ❌ 类名使用 `userService` 而不是 `UserService`
- ❌ 函数名使用 `func1()` 而不是 `calculate_total()`

#### ✅ 代码格式
```markdown
- [ ] 缩进是否一致（4 空格或 2 空格）？
- [ ] 是否有过长的行（> 100 字符）？
- [ ] 是否有多余的空行或缺少空行？
```

**不通过示例**：
- ❌ 混用 Tab 和空格缩进
- ❌ 单行代码超过 150 字符
- ❌ 函数之间没有空行分隔

### 3. 代码质量检查（Blocking）

#### ✅ 明显的逻辑错误
```markdown
- [ ] 是否有明显的逻辑错误？
- [ ] 是否有未处理的异常？
- [ ] 是否有空指针风险？
```

**不通过示例**：
- ❌ `if user is None: return user.name`（空指针）
- ❌ `result = 10 / count`（除零风险）
- ❌ `file = open('data.txt')`（未关闭文件）

#### ✅ 代码重复
```markdown
- [ ] 是否有明显的代码重复？
- [ ] 是否可以提取公共函数？
```

**不通过示例**：
- ❌ 同样的验证逻辑在 3 个地方重复
- ❌ 同样的数据库查询在多个函数中重复

#### ✅ 过度复杂
```markdown
- [ ] 函数是否过长（> 50 行）？
- [ ] 嵌套是否过深（> 3 层）？
- [ ] 是否有过度设计？
```

**不通过示例**：
- ❌ 单个函数超过 100 行
- ❌ 嵌套 5 层 if-else
- ❌ 为简单功能创建了复杂的抽象层

### 4. 测试完整性检查（Blocking）

#### ✅ 测试文件存在
```markdown
- [ ] 是否为新增的功能添加了测试？
- [ ] 测试文件命名是否正确？
  - Python: test_*.py
  - Java: *Test.java
  - JavaScript: *.test.js
```

**不通过示例**：
- ❌ 添加了新功能但没有测试文件
- ❌ 测试文件命名为 `user_tests.py` 而不是 `test_user.py`

#### ✅ 测试覆盖关键路径
```markdown
- [ ] 是否测试了成功路径（Happy Path）？
- [ ] 是否测试了失败路径（Failure Path）？
- [ ] 是否测试了边界条件？
```

**不通过示例**：
- ❌ 只测试了成功情况，没有测试错误情况
- ❌ 没有测试边界条件（如空输入、最大值）

## 快速验收流程（5-10 分钟）

### 步骤 1：查看改动文件（1 分钟）
- 运行 `git diff --name-only`
- 确认改动文件是否在预期范围内

### 步骤 2：Contract 符合性检查（2 分钟）
- 如果存在 Contract，检查 Scope、Must-not-change、Forbidden patterns
- 如果不存在 Contract，跳过此步骤

### 步骤 3：代码风格快速检查（2 分钟）
- 快速浏览代码，检查命名、格式、注释
- 只关注明显的问题

### 步骤 4：代码质量快速检查（2 分钟）
- 快速阅读核心逻辑，检查明显的逻辑错误
- 检查是否有明显的代码重复或过度复杂

### 步骤 5：测试完整性检查（2 分钟）
- 确认是否添加了测试文件
- 快速浏览测试代码，检查是否覆盖关键场景

### 步骤 6：给出验收结论（1 分钟）
- ✅ 通过：进入测试阶段
- ❌ 不通过：列出问题，Claude 修复或重新委托 Coder

## 验收结论模板

### 通过示例
```markdown
✅ Claude 验收通过

代码质量良好，符合基本标准：
- ✅ Scope 符合 Contract 要求
- ✅ 代码风格符合规范
- ✅ 无明显逻辑错误
- ✅ 测试覆盖关键场景

进入测试阶段。
```

### 不通过示例
```markdown
❌ Claude 验收不通过

发现以下问题：
1. ❌ Scope 超出：修改了 Contract 之外的文件 `admin.py`
2. ❌ 命名不规范：变量 `userName` 应改为 `user_name`
3. ❌ 缺少测试：未添加失败路径测试

我将修复这些问题。
```

## 使用示例

**调用方式**：
```
Coder 执行完成后
→ Claude 自动执行 /ccg:review
→ 快速验收（5-10 分钟）
→ 给出通过/不通过结论
```

**典型场景**：
1. Coder 完成代码生成/修改后
2. 进入测试阶段前的质量检查
3. 发现明显问题时立即修复

## 相关文档

- 详细文档：`ai/claude_review_checklist.md`
- Contract 模板：`ai/contracts/CONTRACT_TEMPLATE.md`
- Codex 审核门禁：`ai/codex_review_gate.md`
- 代码质量指南：`ai/coder_quality_guide.md`

## 注意事项

1. **快速检查**：5-10 分钟，只关注明显问题，不做深度审核
2. **Contract 优先**：如果存在 Contract，必须先检查符合性
3. **Blocking 问题**：发现 Blocking 问题必须修复后才能进入测试
4. **与 Codex 审核的区别**：Claude 验收是浅层检查，Codex 审核是深度审核
