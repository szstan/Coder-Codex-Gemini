# 文档整合计划

> 解决文档冗余和命名不一致问题

---

## 问题分析

### 1. Contract 文档系统

**现状**：4个Contract相关文档
- `CONTRACT_QUICKREF.md` (28行) - 编写原则
- `CONTRACT_QUICKSTART.md` (225行) - 入门指南
- `CONTRACT_CHECKLIST.md` (45行) - 质量标准
- `contracts/CONTRACT_TEMPLATE.md` (197行) - 模板

**问题**：
- 命名不够清晰（QUICKREF vs QUICKSTART 容易混淆）
- 文档关系不明确

**结论**：这4个文档**不冗余**，各有独特价值，但需要优化命名和关系。

---

## 整合方案

### Phase 1: Contract 文档重命名

**目标**：让文档名称准确反映内容

| 原文件名 | 新文件名 | 理由 |
|---------|---------|------|
| `CONTRACT_QUICKREF.md` | `contract_principles.md` | 内容是编写原则，不是速查表 |
| `CONTRACT_CHECKLIST.md` | `contract_quality_standards.md` | 内容是质量标准，不只是清单 |
| `CONTRACT_QUICKSTART.md` | 保持不变 | 名称准确 |
| `contracts/CONTRACT_TEMPLATE.md` | 保持不变 | 名称准确 |

**文档关系图**：
```
contract_principles.md (编写原则)
    ↓
CONTRACT_QUICKSTART.md (入门指南)
    ↓
contracts/CONTRACT_TEMPLATE.md (空白模板)
    ↓
contract_quality_standards.md (质量验收)
```

---

### Phase 2: 全局命名规范统一

**目标**：统一所有文档为小写+下划线格式

**规则**：
- 文件名：`lowercase_with_underscores.md`
- 目录名：`lowercase-with-hyphens/`

**需要重命名的文件**（ai/ 目录）：
- `AI_ONBOARDING.md` → `ai_onboarding.md`
- `CONTRACT_CHECKLIST.md` → `contract_quality_standards.md` (同时改名)
- `CONTRACT_QUICKREF.md` → `contract_principles.md` (同时改名)
- `DEPENDENCIES.md` → `dependencies.md`
- `FAILURE_LOOP_DECISION.md` → `failure_loop_decision.md`

**需要重命名的文件**（contracts/ 目录）：
- `contracts/CONTRACT_QUICKSTART.md` → `contracts/contract_quickstart.md`
- `contracts/CONTRACT_TEMPLATE.md` → `contracts/contract_template.md`

---

### Phase 3: 更新文档内部引用

**目标**：更新所有文档中对重命名文件的引用

**需要更新的引用位置**：
1. 全局 CLAUDE.md 中的 Contract 文档引用
2. ai/ 目录下其他文档中的交叉引用
3. skills/ 中的 Skill 文档引用

**更新策略**：
- 使用 grep 查找所有引用
- 批量替换文件路径
- 验证引用完整性

---

### Phase 4: 优化 Contract 文档关系

**目标**：在各文档开头添加导航链接

**CONTRACT_QUICKSTART.md 开头添加**：
```markdown
> **相关文档**：
> - [编写原则](../contract_principles.md) - 如何写好 Contract
> - [质量标准](../contract_quality_standards.md) - Contract 验收标准
> - [空白模板](CONTRACT_TEMPLATE.md) - 创建新 Contract
```

**contract_principles.md 开头添加**：
```markdown
> **相关文档**：
> - [入门指南](contracts/contract_quickstart.md) - 何时需要 Contract
> - [质量标准](contract_quality_standards.md) - Contract 验收标准
```

---

## 执行计划

### Step 1: 重命名 Contract 文档（优先级：高）

```bash
# ai/ 目录
mv ai/CONTRACT_QUICKREF.md ai/contract_principles.md
mv ai/CONTRACT_CHECKLIST.md ai/contract_quality_standards.md

# contracts/ 目录
mv ai/contracts/CONTRACT_QUICKSTART.md ai/contracts/contract_quickstart.md
mv ai/contracts/CONTRACT_TEMPLATE.md ai/contracts/contract_template.md
```

### Step 2: 重命名其他大写文件（优先级：中）

```bash
mv ai/AI_ONBOARDING.md ai/ai_onboarding.md
mv ai/DEPENDENCIES.md ai/dependencies.md
mv ai/FAILURE_LOOP_DECISION.md ai/failure_loop_decision.md
```

### Step 3: 更新文档引用（优先级：高）

使用 Coder 批量更新所有引用。

### Step 4: 添加导航链接（优先级：低）

在 Contract 文档开头添加相关文档链接。

---

## 预期效果

1. **文档关系清晰**：4个Contract文档各司其职，互相引用
2. **命名规范统一**：所有文档使用小写+下划线格式
3. **易于导航**：文档间有明确的导航链接

