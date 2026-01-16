# 使用案例

## 案例 1：批量代码生成

**场景**：用户要求生成多个 API 接口

**流程**：

1. Claude 拆解需求，明确接口列表（如任务复杂，先形成本次变更的 Implementation Contract）
2. 调用 Coder 批量生成代码
3. Claude 初步验收结果
4. 调用 Codex review
5. 根据 review 结果迭代

**Coder 调用示例**：

```
PROMPT:
【Implementation Contract】（如存在，必须优先遵守）

- （粘贴 ai/contracts/current.md 内容）

请生成以下 REST API 接口：

- GET /users - 获取用户列表
- POST /users - 创建用户
- GET /users/{id} - 获取单个用户

cd: /project/src
SESSION_ID: ""  # 新会话

```

---

## 案例 2：Bug 修复

**场景**：用户报告登录功能异常

**流程**：

1. Claude 分析问题，定位原因（必要时补充/更新 Implementation Contract，明确修复范围）
2. 调用 Coder 修复代码
3. Claude 验收修复结果
4. 调用 Codex review 修复质量

**Coder 调用示例**：

```
PROMPT:
【Implementation Contract】（如存在，必须优先遵守）

- （粘贴 ai/contracts/current.md 内容）

修复登录功能的 token 过期问题

目标文件：src/auth/login.py
问题：token 刷新逻辑缺失

cd: /project
SESSION_ID: "abc-123"  # 复用会话

```

---

## 案例 3：代码审核

**场景**：开发完成后请求 review

**Codex 调用示例**：

```
PROMPT:
【Implementation Contract】（如存在，应作为主要审核依据）

- （粘贴 ai/contracts/current.md 内容）

【Review Gate】（如存在）

- （粘贴 ai/codex_review_gate.md 内容）

请 review src/api/ 目录下的改动
改动目的：新增用户管理 API

请检查：

1. 是否违反 Implementation Contract（如存在）
2. 代码质量和可维护性
3. 潜在 Bug 或边界情况
4. 是否引入未声明的行为变化

cd: /project
sandbox: read-only
SESSION_ID: "abc-123"  # 复用上一步 Coder 的会话，保持上下文连贯

```

**注意**：

- 若之前调用过 Coder 生成或修改代码，**建议复用同一 `SESSION_ID`**，以保持上下文一致
- **当提供 Implementation Contract / Review Gate 时**：
  - 审核应优先对照其约束
  - 不应引入 Contract 之外的新需求