# Contract 质量标准

> **目标**：定义 Implementation Contract 的质量标准，确保 Contract 能够有效指导开发和审核。

---

## 一、Contract 的重要性

### 1.1 Contract 是什么？

**Implementation Contract** 是开发任务的正式约定，包含：
- **Scope**：要改动的范围
- **Must-change behaviors**：必须改变的行为
- **Must-not-change behaviors**：不能改变的行为
- **Constraints**：技术约束和限制
- **Testing strategy**：测试策略

### 1.2 为什么需要 Contract？

**Contract 的价值**：
- ✅ **明确边界**：防止 Scope 蔓延
- ✅ **保证兼容性**：明确哪些行为不能改变
- ✅ **指导实现**：提供清晰的约束条件
- ✅ **验证标准**：提供明确的验收标准

### 1.3 何时需要创建 Contract？

**必须创建 Contract 的情况**：
- 🔴 多文件/多模块改动（3+ 个文件）
- 🔴 存在兼容性风险（API 变更、配置变更）
- 🔴 涉及性能敏感点（数据库查询、大数据处理）
- 🔴 需要明确测试策略（复杂业务逻辑）

**可选创建 Contract 的情况**：
- 🟡 单文件改动但逻辑复杂
- 🟡 Bug 修复但影响范围不明确
- 🟡 重构但需要保证行为不变

**不需要 Contract 的情况**：
- 🟢 简单的单文件改动（< 50 行）
- 🟢 明显的 Bug 修复（如拼写错误）
- 🟢 文档更新

---

## 二、Contract 质量标准

### 2.1 必需要素（Blocking）

**以下要素缺一不可，否则 Contract 不通过**：

#### ✅ Scope（范围）
```markdown
**必须包含**：
- [ ] 列出所有要修改的文件
- [ ] 说明每个文件的改动目的
- [ ] 明确不在 Scope 内的文件

**示例**：
```markdown
## Scope

### Files to modify
- `src/api/user.py`: 添加登录接口
- `tests/test_user.py`: 添加登录测试

### Out of scope
- `src/api/admin.py`: 不修改管理员相关代码
- `src/models/user.py`: 不修改用户模型
```
```

#### ✅ Must-change behaviors（必须改变的行为）
```markdown
**必须包含**：
- [ ] 列出所有要实现的新功能
- [ ] 列出所有要修改的现有行为
- [ ] 说明改变的原因

**示例**：
```markdown
## Must-change behaviors

1. **新增登录接口**
   - 接受邮箱和密码
   - 返回 JWT token
   - 原因：用户需要登录功能

2. **修改错误返回格式**
   - 从 `{"error": "message"}` 改为 `{"success": false, "error": "message"}`
   - 原因：统一错误格式
```
```

#### ✅ Must-not-change behaviors（不能改变的行为）
```markdown
**必须包含**：
- [ ] 列出所有要保持不变的行为
- [ ] 说明为什么不能改变
- [ ] 提供验证方法

**示例**：
```markdown
## Must-not-change behaviors

1. **现有注册接口**
   - 接口路径、参数、返回格式保持不变
   - 原因：已有客户端依赖此接口
   - 验证：运行现有注册测试

2. **用户数据结构**
   - 数据库表结构不变
   - 原因：避免数据迁移
   - 验证：检查数据库 schema
```
```

#### ✅ Constraints（约束）
```markdown
**必须包含**：
- [ ] 技术约束（使用的技术栈）
- [ ] 性能约束（响应时间、并发量）
- [ ] 安全约束（权限、加密）

**示例**：
```markdown
## Constraints

### Technical
- 使用 FastAPI 框架
- 使用 PyJWT 生成 token
- 使用 bcrypt 加密密码

### Performance
- 登录接口响应时间 < 200ms
- 支持 100 QPS

### Security
- 密码必须加密存储
- Token 有效期 7 天
```
```

#### ✅ Testing strategy（测试策略）
```markdown
**必须包含**：
- [ ] 单元测试范围
- [ ] 集成测试范围
- [ ] 覆盖率目标

**示例**：
```markdown
## Testing strategy

### Unit tests
- 测试登录逻辑（成功/失败路径）
- 测试 token 生成和验证
- 覆盖率目标：≥ 90%

### Integration tests
- 测试完整登录流程
- 测试 token 在后续 API 调用中的使用
- 覆盖率目标：≥ 80%
```
```

---

### 2.2 质量标准（Blocking）

#### ✅ 清晰性
```markdown
- [ ] 每个要素都用简单直白的语言描述
- [ ] 避免模糊词汇（可能、大概、尽量）
- [ ] 使用具体的例子说明
```

**好的示例**：
```markdown
## Must-not-change behaviors
- 注册接口路径保持 `/api/register`
- 注册接口参数保持 `email`, `password`, `username`
```

**不好的示例**：
```markdown
## Must-not-change behaviors
- 注册接口尽量不要改
```

#### ✅ 完整性
```markdown
- [ ] 包含所有必需要素
- [ ] 列出所有要修改的文件
- [ ] 列出所有要保持不变的行为
```

#### ✅ 可验证性
```markdown
- [ ] 每个行为都可以验证
- [ ] 提供验证方法
- [ ] 测试策略明确
```

---

## 三、Contract 验收检查清单

### 3.1 必需要素检查
```markdown
- [ ] Scope：是否列出了所有要修改的文件？
- [ ] Must-change behaviors：是否列出了所有要实现的功能？
- [ ] Must-not-change behaviors：是否列出了所有要保持不变的行为？
- [ ] Constraints：是否说明了技术、性能、安全约束？
- [ ] Testing strategy：是否定义了测试范围和覆盖率目标？
```

### 3.2 质量标准检查
```markdown
- [ ] 清晰性：是否使用简单直白的语言？
- [ ] 完整性：是否包含所有必要信息？
- [ ] 可验证性：是否每个行为都可以验证？
```

### 3.3 验收结论
```markdown
- [ ] ✅ 通过：Contract 质量良好，可以开始开发
- [ ] ⚠️ 需要补充：[列出需要补充的内容]
- [ ] ❌ 不通过：[列出具体问题]
```

---

## 四、Contract 验收案例

### 案例 1：通过的 Contract

```markdown
# Implementation Contract: 用户登录功能

## Scope

### Files to modify
- `src/api/user.py`: 添加登录接口
- `tests/test_user.py`: 添加登录测试

### Out of scope
- `src/api/admin.py`: 不修改
- `src/models/user.py`: 不修改

## Must-change behaviors

1. **新增登录接口 POST /api/login**
   - 接受 `email` 和 `password`
   - 返回 JWT token 和用户信息
   - 密码错误返回 401
   - 用户不存在返回 404

## Must-not-change behaviors

1. **注册接口保持不变**
   - 路径、参数、返回格式不变
   - 验证：运行现有注册测试

2. **用户数据结构不变**
   - 数据库表结构不变
   - 验证：检查数据库 schema

## Constraints

### Technical
- 使用 FastAPI 框架
- 使用 PyJWT 生成 token
- 使用 bcrypt 验证密码

### Performance
- 响应时间 < 200ms
- 支持 100 QPS

### Security
- Token 有效期 7 天
- 密码验证使用 bcrypt

## Testing strategy

### Unit tests
- 测试登录逻辑（成功/失败路径）
- 测试 token 生成和验证
- 覆盖率：≥ 90%

### Integration tests
- 测试完整登录流程
- 覆盖率：≥ 80%
```

**验收结果**：✅ 通过
- ✅ 包含所有必需要素
- ✅ 清晰、完整、可验证

---

### 案例 2：需要补充的 Contract

```markdown
# Implementation Contract: 用户登录功能

## Scope
- 修改 `src/api/user.py`

## Must-change behaviors
- 添加登录功能

## Testing strategy
- 添加测试
```

**验收结果**：⚠️ 需要补充
- ⚠️ Scope：未列出测试文件
- ⚠️ Must-change behaviors：过于模糊，需要详细说明
- ⚠️ 缺少 Must-not-change behaviors
- ⚠️ 缺少 Constraints
- ⚠️ Testing strategy：过于简单，需要详细说明

---

## 五、总结

### 5.1 核心要点

1. **Contract 是开发的正式约定**：明确边界和约束
2. **必需要素不可缺**：Scope、Must-change、Must-not-change、Constraints、Testing strategy
3. **质量标准必须满足**：清晰、完整、可验证

### 5.2 快速参考

| 要素 | 说明 | 是否必需 |
|------|------|---------|
| Scope | 要修改的文件 | ✅ 必需 |
| Must-change | 要实现的功能 | ✅ 必需 |
| Must-not-change | 要保持不变的行为 | ✅ 必需 |
| Constraints | 技术、性能、安全约束 | ✅ 必需 |
| Testing strategy | 测试范围和覆盖率 | ✅ 必需 |

---

**文档版本**: v1.0
**最后更新**: 2026-01-17
**维护者**: CCG Team
