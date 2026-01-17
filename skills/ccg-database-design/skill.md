# CCG 数据库设计 Skill

> **角色定位**：数据库架构师
> **核心目标**：在代码开发前完成数据库设计，确保数据一致性和架构合理性

---

## 何时使用此 Skill

**强制触发条件**（必须执行数据库设计）：
- ✅ 新增数据表/集合
- ✅ 修改现有数据结构（字段增删改）
- ✅ 涉及数据迁移
- ✅ 修改数据关系（外键、索引）
- ✅ 新功能涉及持久化存储

**可选触发条件**（建议执行）：
- 🔶 复杂查询优化
- 🔶 性能调优（索引设计）
- 🔶 数据安全性增强

---

## 执行流程

### 步骤 1：需求分析（2-5 分钟）

**Claude 的职责**：
1. 分析用户需求，识别数据实体
2. 确定数据关系和约束
3. 评估是否需要数据库设计

**输出示例**：
```
📋 需求分析结果：
- 数据实体：用户(User)、订单(Order)、商品(Product)
- 关系：User 1:N Order, Order N:M Product
- 约束：订单金额必须 > 0，用户邮箱唯一
- 需要设计：✅ 是（涉及新增 3 张表）
```

---

### 步骤 2：选择设计方式（1 分钟）

**方式 A：用户自行设计**
- 用户提供数据库设计文档（SQL DDL、ER 图、文字描述等）
- Claude 直接跳到步骤 4（Codex 审核）

**方式 B：AI 辅助设计（推荐）**
- 调用 Codex 进行架构设计
- 适用于复杂场景或用户不确定最佳实践

**Claude 询问示例**：
```
🤔 数据库设计方式选择：

1. 您自行提供设计（SQL DDL、ER 图或文字描述）
2. 由 Codex 辅助设计（推荐，适合复杂场景）

请选择：[1/2]
```

---

### 步骤 3：Codex 架构设计（方式 B）（5-10 分钟）

**调用 Codex 进行设计**：

```markdown
**Prompt 模板**：

请设计以下需求的数据库架构：

**需求描述**：
[用户需求的详细描述]

**现有数据库信息**：
- 数据库类型：[MySQL/PostgreSQL/MongoDB/SQLite 等]
- 现有表结构：[如果有，列出相关表]
- ORM 框架：[如果使用，如 SQLAlchemy/Django ORM/Prisma 等]

**请提供**：
1. **数据表设计**：
   - 表名、字段名、数据类型、约束（主键、外键、唯一、非空等）
   - 索引设计（普通索引、唯一索引、复合索引）

2. **数据关系**：
   - ER 图（文字描述或 Mermaid 语法）
   - 关系类型（1:1, 1:N, N:M）

3. **SQL DDL**：
   - CREATE TABLE 语句
   - CREATE INDEX 语句
   - 数据迁移脚本（如果修改现有表）

4. **设计说明**：
   - 设计理由和权衡
   - 性能考虑（查询优化、索引策略）
   - 数据一致性保证（事务、约束）
   - 潜在风险和注意事项

**约束条件**：
- [如：必须兼容现有系统、必须支持分页查询等]
```

**Codex 输出示例**：
```sql
-- 用户表
CREATE TABLE users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 订单表
CREATE TABLE orders (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL CHECK (total_amount > 0),
    status ENUM('pending', 'paid', 'shipped', 'completed') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_status_created (status, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 设计说明：
-- 1. 使用 InnoDB 引擎支持事务和外键
-- 2. email 字段添加唯一索引，支持快速登录查询
-- 3. orders 表添加复合索引 (status, created_at)，优化订单列表查询
-- 4. 使用 DECIMAL 存储金额，避免浮点精度问题
-- 5. 外键设置 ON DELETE CASCADE，用户删除时自动清理订单
```

---

### 步骤 4：Codex 审核设计（强制）（3-5 分钟）

**无论设计来源（用户或 AI），都必须经过 Codex 审核**

**调用 Codex 进行审核**：

```markdown
**Prompt 模板**：

请审核以下数据库设计：

**设计内容**：
[粘贴完整的数据库设计，包括 SQL DDL]

**审核要点**：
1. **数据一致性**：
   - 主键、外键设计是否合理
   - 约束是否完整（唯一、非空、检查约束）
   - 是否存在数据冗余或不一致风险

2. **性能优化**：
   - 索引设计是否合理（避免过度索引或索引缺失）
   - 数据类型选择是否恰当
   - 是否存在 N+1 查询风险

3. **可维护性**：
   - 命名规范是否一致
   - 是否易于扩展
   - 迁移脚本是否安全

4. **潜在问题**：
   - 并发冲突风险
   - 数据迁移风险
   - 性能瓶颈

**请给出明确结论**：
- ✅ 通过：设计合理，可以开始开发
- ⚠️ 建议优化：[具体建议]
- ❌ 需要修改：[具体问题]
```

**Codex 审核输出示例**：
```
✅ 审核通过

**优点**：
1. 外键约束保证了数据一致性
2. 索引设计合理，覆盖了常见查询场景
3. 使用 DECIMAL 存储金额，避免精度问题

⚠️ 建议优化：
1. orders 表建议添加 updated_at 字段，便于追踪订单修改历史
2. 考虑为 users.username 添加索引，如果有按用户名搜索的需求
3. 建议添加软删除字段 deleted_at，而不是物理删除用户

**结论**：设计整体合理，建议采纳优化建议后开始开发。
```

---

### 步骤 5：记录设计文档（2 分钟）

**Claude 的职责**：
1. 将最终设计保存到项目文档
2. 更新数据库迁移脚本（如果使用 ORM）

**推荐文档位置**：
```
项目根目录/
├── docs/
│   └── database/
│       ├── schema.sql          # 完整的数据库结构
│       ├── migrations/         # 迁移脚本目录
│       │   └── 001_add_users_orders.sql
│       └── design-notes.md     # 设计说明和决策记录
```

**Claude 操作示例**：
```
我已将数据库设计保存到：
- docs/database/schema.sql（完整结构）
- docs/database/migrations/001_add_users_orders.sql（迁移脚本）
- docs/database/design-notes.md（设计说明）

接下来可以继续执行 Git 安全检查和代码开发。
```

---

## 与 CCG 工作流集成

**完整流程**：
```
1. 需求分析
   ↓
2. 数据库设计（本 Skill）
   - 识别是否需要设计
   - 选择设计方式（用户/AI）
   - Codex 设计（如果选择 AI）
   - Codex 审核（强制）
   - 记录设计文档
   ↓
3. Git 安全检查（/ccg-git-safety）
   ↓
4. Coder 执行代码
   ↓
5. Codex 审核代码
```

---

## Prompt 快速参考

### Codex 设计 Prompt（精简版）
```
请设计数据库架构：
需求：[描述]
数据库：[类型]
现有表：[列表]

输出：
1. 表结构（字段、类型、约束、索引）
2. ER 图（文字描述）
3. SQL DDL
4. 设计说明（理由、性能、风险）
```

### Codex 审核 Prompt（精简版）
```
请审核数据库设计：
[粘贴 SQL DDL]

审核要点：
1. 数据一致性（主键、外键、约束）
2. 性能优化（索引、数据类型）
3. 可维护性（命名、扩展性）
4. 潜在问题（并发、迁移、瓶颈）

结论：✅ 通过 / ⚠️ 建议优化 / ❌ 需要修改
```

---

## 常见场景示例

### 场景 1：新增功能（需要新表）
```
用户需求：添加用户评论功能

1. Claude 分析：需要新增 comments 表
2. Claude 询问：用户自行设计 or Codex 辅助？
3. 用户选择：Codex 辅助
4. 调用 Codex 设计 comments 表
5. 调用 Codex 审核设计
6. Claude 保存设计文档
7. 继续 Git 安全检查 → Coder 执行
```

### 场景 2：修改现有表结构
```
用户需求：users 表添加 phone 字段

1. Claude 分析：需要修改现有表
2. Claude 询问：用户自行设计 or Codex 辅助？
3. 用户选择：用户自行设计
4. 用户提供：ALTER TABLE users ADD COLUMN phone VARCHAR(20);
5. 调用 Codex 审核（检查数据类型、索引、迁移风险）
6. Codex 建议：phone 应该是 VARCHAR(20) UNIQUE，并添加索引
7. Claude 保存修正后的设计
8. 继续 Git 安全检查 → Coder 执行
```

### 场景 3：性能优化（不涉及结构变更）
```
用户需求：优化订单查询性能

1. Claude 分析：可能需要添加索引，但不修改表结构
2. Claude 询问：是否需要 Codex 分析索引策略？
3. 用户确认：是
4. 调用 Codex 分析现有查询和索引
5. Codex 建议：添加复合索引 (user_id, created_at)
6. Claude 保存索引优化方案
7. 继续 Git 安全检查 → Coder 执行
```

---

## 注意事项

### ⚠️ 强制规则
1. **涉及数据结构变更，必须先设计后开发**
2. **所有设计必须经过 Codex 审核**
3. **设计文档必须保存到项目中**

### 💡 最佳实践
1. **优先使用 Codex 辅助设计**：AI 更了解最佳实践和潜在风险
2. **保留设计历史**：迁移脚本按时间顺序编号（001, 002, ...）
3. **考虑向后兼容**：修改现有表时，评估对现有数据的影响
4. **索引适度**：过多索引影响写入性能，过少索引影响查询性能

### 🚫 常见错误
1. ❌ 跳过设计直接写代码 → 导致数据不一致
2. ❌ 不审核用户提供的设计 → 可能存在性能或安全问题
3. ❌ 不保存设计文档 → 后续维护困难
4. ❌ 忽略数据迁移脚本 → 生产环境部署失败

---

## 总结

**核心价值**：
- ✅ 保证数据一致性
- ✅ 避免后期重构成本
- ✅ 提前发现性能瓶颈
- ✅ 规范化设计流程

**关键原则**：
- 📐 **设计先行**：代码开发前必须完成数据库设计
- 🔍 **强制审核**：所有设计必须经过 Codex 审核
- 📝 **文档留痕**：设计和迁移脚本必须保存

**与 CCG 协作**：
- Claude：需求分析、流程协调、文档管理
- Codex：架构设计、设计审核、风险评估
- Coder：执行代码实现（在设计完成后）

