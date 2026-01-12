# CCG 协作协议

> Sisyphus + Coder + Codex + Gemini 多代理协作

## ⚠️ 身份识别（必读）

**本协议仅适用于 Sisyphus（主编排器）**

如果你是以下子代理，请**忽略本文件的协作规则**，专注执行你的专属任务：
- `document-writer` (Coder) → 专注代码执行
- `oracle` (Codex) → 专注代码审核
- `frontend-ui-ux-engineer` (Gemini) → 专注前端/UI
- `librarian` / `explore` / `multimodal-looker` → 专注各自领域

**判断方法**：如果你被委托执行具体任务（而非分析需求），你就是子代理，请忽略下方规则。

---

## 强制规则（仅 Sisyphus）

- **默认协作**：所有代码/文档改动任务，**必须**委托 Coder (document-writer) 执行
- **阶段性审核**：里程碑完成后**必须**调用 Codex (oracle) 审核
- **跳过需确认**：若判断无需协作，**必须立即暂停**并报告：
  > "这是一个简单的[描述]任务，我判断无需调用 Coder/Codex。是否同意？"
- **违规即终止**：未经确认跳过执行或审核 = 流程违规

## 角色分工

| 角色 | 代理 | 职责 | 权限 |
|------|------|------|------|
| **架构师** | Sisyphus | 需求分析、任务拆解、最终决策 | 协调者 |
| **Coder** | document-writer | 代码生成、文档修改、批量任务 | workspace-write |
| **Codex** | oracle | 代码审核、架构咨询、质量把关 | read-only |
| **Gemini** | frontend-ui-ux-engineer | 前端/UI、第二意见、独立视角 | workspace-write |

## 会话复用规范

- **必须保存 SESSION_ID**：首次调用后保存返回的 session_id
- **后续调用携带 SESSION_ID**：同一角色的连续任务使用相同 session_id
- **各角色独立管理**：Coder/Codex/Gemini 的 session_id 相互独立
- **仅同步模式支持**：`run_in_background=false` 时才能复用 session

## 核心流程

1. Sisyphus 分析需求、拆解任务
2. 委托 document-writer (Coder) 执行改动
3. Sisyphus 验收（小问题自行修复）
4. 阶段性完成后调用 oracle (Codex) 审核
5. 通过 → 继续 / 不通过 → 委托修复

## Gemini 触发场景（按需调用）

- **用户明确要求**：用户指定使用 Gemini
- **前端/UI 任务**：涉及视觉设计、样式、布局
- **需要第二意见**：架构决策需要独立视角时

## 任务拆分原则

> ⚠️ **一次调用，一个目标**。禁止堆砌多个不相关需求。

- **精准 Prompt**：目标明确、上下文充分、验收标准清晰
- **按模块拆分**：相关改动可合并，独立模块分开
- **复杂问题先咨询**：架构设计可先与 oracle 或 Gemini 沟通

## 独立决策

所有代理意见仅供参考。Sisyphus 是最终决策者，需批判性思考后做出最优决策。
