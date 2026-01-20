# CCG 会话自动保存逻辑

> 本文档定义 Claude 在 CCG 工作流中自动保存会话状态的详细逻辑。

---

## 触发点定义

### 触发点 1：任务开始

**时机**：用户描述新任务后，Claude 完成路由决策

**执行逻辑**：
```python
# 伪代码
def on_task_start(task_description, routing_decision):
    # 1. 生成 session_id
    session_id = f"session-{datetime.now().strftime('%Y%m%d-%H%M%S')}"
    task_id = f"task-{datetime.now().strftime('%Y%m%d-%H%M%S')}"

    # 2. 创建会话状态
    session_state = {
        "session_id": session_id,
        "session_started": datetime.now().isoformat(),
        "last_updated": datetime.now().isoformat(),
        "status": "in_progress",
        "current_task": {
            "id": task_id,
            "description": task_description,
            "type": infer_task_type(task_description),  # feature/bugfix/refactor
            "routing": routing_decision,  # openspec/standard_ccg/quick_ccg
            "phase": "preparation",  # preparation/execution/review/delivery
            "created_at": datetime.now().isoformat()
        },
        # ... 其他字段使用 template.json 的默认值
    }

    # 3. 写入 current.json
    save_json(".ccg/sessions/current.json", session_state)

    # 4. 输出确认（可选）
    print(f"✅ 会话已创建：{session_id}")
```

**示例输出**：
```markdown
📋 **路由决策**：标准 CCG 流程（评分 5 分）

✅ **会话已创建**：session-20260119-103000
**任务 ID**：task-20260119-103000
**任务描述**：实现用户认证功能

开始执行准备阶段...
```

---

### 触发点 2：阶段切换

**时机**：
- 准备阶段 → 执行阶段（Contract 创建完成）
- 执行阶段 → 审核阶段（Coder 执行完成）
- 审核阶段 → 交付阶段（Codex 审核通过）

**执行逻辑**：
```python
def on_phase_change(new_phase, completed_step=None):
    # 1. 读取 current.json
    session = load_json(".ccg/sessions/current.json")

    # 2. 更新阶段
    session["current_task"]["phase"] = new_phase
    session["last_updated"] = datetime.now().isoformat()

    # 3. 记录已完成步骤
    if completed_step:
        session["execution_state"]["completed_steps"].append({
            "step": completed_step,
            "completed_at": datetime.now().isoformat()
        })

    # 4. 更新待执行步骤
    session["execution_state"]["current_step"] = get_next_step(new_phase)

    # 5. 写回 current.json
    save_json(".ccg/sessions/current.json", session)
```

**示例**：
```markdown
✅ **Contract 创建完成**

阶段切换：preparation → execution
当前步骤：调用 Coder 执行代码改动

[会话已自动保存]
```

---

### 触发点 3：工具调用完成

**时机**：Coder / Codex / Gemini 调用完成后

**执行逻辑**：
```python
def on_tool_call_complete(tool_name, tool_result):
    # 1. 读取 current.json
    session = load_json(".ccg/sessions/current.json")

    # 2. 更新工具会话信息
    tool_session = session["tool_sessions"][tool_name]
    tool_session["session_id"] = extract_session_id(tool_result)
    tool_session["last_called"] = datetime.now().isoformat()
    tool_session["call_count"] += 1

    # 3. 更新受影响的文件
    if "files_changed" in tool_result:
        for file in tool_result["files_changed"]:
            if file not in session["task_context"]["affected_files"]:
                session["task_context"]["affected_files"].append(file)

    # 4. 更新迭代次数
    session["execution_state"]["iteration_count"] += 1

    # 5. 记录错误（如果有）
    if not tool_result["success"]:
        session["execution_state"]["errors"].append({
            "tool": tool_name,
            "error": tool_result["error"],
            "timestamp": datetime.now().isoformat()
        })

    # 6. 更新时间戳
    session["last_updated"] = datetime.now().isoformat()

    # 7. 写回 current.json
    save_json(".ccg/sessions/current.json", session)
```

**示例**：
```markdown
✅ **Coder 执行完成**

修改文件：auth.py, user.py, test_auth.py
SESSION_ID：coder-session-abc123
迭代次数：1 → 2

[会话已自动保存]

开始 Claude 验收...
```

---

### 触发点 4：质量信号更新

**时机**：
- 测试执行完成
- Codex 审核完成
- 门禁检查完成

**执行逻辑**：
```python
def on_quality_signal_update(signal_type, signal_value):
    # 1. 读取 current.json
    session = load_json(".ccg/sessions/current.json")

    # 2. 更新质量信号
    session["quality_signals"][signal_type] = signal_value
    session["last_updated"] = datetime.now().isoformat()

    # 3. 写回 current.json
    save_json(".ccg/sessions/current.json", session)
```

**示例**：
```markdown
✅ **测试执行完成**

测试结果：45 passed, 0 failed
覆盖率：82%

quality_signals.tests_passed = true

[会话已自动保存]
```

---

### 触发点 5：任务完成

**时机**：
- 任务成功完成（Codex 审核通过 + 测试通过 + Git 提交）
- 任务失败（多次迭代失败）
- 任务放弃（用户主动放弃）

**执行逻辑**：
```python
def on_task_complete(status, final_result=None):
    # 1. 读取 current.json
    session = load_json(".ccg/sessions/current.json")

    # 2. 更新最终状态
    session["status"] = status  # completed / failed / abandoned
    session["last_updated"] = datetime.now().isoformat()

    # 3. 记录最终结果
    if final_result:
        session["final_result"] = {
            "status": status,
            "summary": final_result,
            "completed_at": datetime.now().isoformat()
        }

    # 4. 归档到 history/
    task_id = session["current_task"]["id"]
    date_str = datetime.now().strftime("%Y-%m-%d")
    history_file = f".ccg/sessions/history/{date_str}-{task_id}.json"
    save_json(history_file, session)

    # 5. 重置 current.json
    template = load_json(".ccg/sessions/template.json")
    save_json(".ccg/sessions/current.json", template)

    # 6. 输出确认
    print(f"✅ 任务已归档：{history_file}")
```

**示例**：
```markdown
✅ **任务完成**

任务：实现用户认证功能
状态：completed
耗时：45 分钟
迭代次数：2
修改文件：3 个

已归档：.ccg/sessions/history/2026-01-19-task-20260119-103000.json

[会话已重置，准备开始新任务]
```

---

## Claude 实现指南

### 方式 1：内联 JSON 操作（推荐）

在 Claude 的思考过程中，直接执行 JSON 读写：

```markdown
## 执行逻辑

1. 用户描述任务："实现用户认证"
2. 路由决策：标准 CCG（评分 5 分）
3. **[自动保存]** 创建 current.json：
   ```json
   {
     "session_id": "session-20260119-103000",
     "current_task": {
       "description": "实现用户认证功能",
       "routing": "standard_ccg"
     },
     ...
   }
   ```
4. 继续执行准备阶段...
```

**Claude 使用 Edit 或 Write 工具直接更新 `.ccg/sessions/current.json`**

---

### 方式 2：使用 Bash 脚本（辅助）

创建辅助脚本简化操作：

```bash
# .ccg/scripts/session-save.sh

#!/bin/bash
# 保存会话状态的辅助脚本

SESSION_FILE=".ccg/sessions/current.json"

# 使用 jq 更新 JSON
jq ".last_updated = \"$(date -Iseconds)\" | .execution_state.iteration_count += 1" \
   "$SESSION_FILE" > "$SESSION_FILE.tmp" && \
   mv "$SESSION_FILE.tmp" "$SESSION_FILE"

echo "✅ 会话已保存"
```

**Claude 调用**：
```bash
bash .ccg/scripts/session-save.sh
```

---

## 错误处理

### 错误 1：current.json 不存在

**场景**：首次使用或文件被误删

**处理**：
```python
def ensure_current_json_exists():
    if not os.path.exists(".ccg/sessions/current.json"):
        # 复制 template.json
        shutil.copy(
            ".ccg/sessions/template.json",
            ".ccg/sessions/current.json"
        )
        print("⚠️ current.json 不存在，已从模板创建")
```

---

### 错误 2：current.json 格式错误

**场景**：JSON 损坏或格式不正确

**处理**：
```python
def load_current_json_safe():
    try:
        return load_json(".ccg/sessions/current.json")
    except JSONDecodeError:
        print("⚠️ current.json 格式错误，已重置")
        shutil.copy(
            ".ccg/sessions/template.json",
            ".ccg/sessions/current.json"
        )
        return load_json(".ccg/sessions/current.json")
```

---

### 错误 3：写入失败

**场景**：磁盘空间不足或权限问题

**处理**：
```python
def save_json_safe(file_path, data):
    try:
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
        return True
    except Exception as e:
        print(f"⚠️ 保存失败：{e}")
        print("  会话状态未保存，但不影响当前任务继续执行")
        return False
```

---

## 性能优化

### 优化 1：延迟写入

避免频繁写入磁盘：

```python
# 全局变量：待写入的更新
pending_updates = []

def queue_session_update(update_func):
    """将更新加入队列"""
    pending_updates.append(update_func)

def flush_session_updates():
    """批量执行所有更新"""
    if not pending_updates:
        return

    session = load_json(".ccg/sessions/current.json")
    for update_func in pending_updates:
        update_func(session)
    save_json(".ccg/sessions/current.json", session)
    pending_updates.clear()

# 在关键点（如工具调用完成）统一写入
```

---

### 优化 2：增量更新

只更新变化的字段：

```python
def update_session_field(field_path, value):
    """
    field_path 示例：
    - "last_updated"
    - "current_task.phase"
    - "tool_sessions.coder.call_count"
    """
    session = load_json(".ccg/sessions/current.json")

    # 使用 JSONPath 或嵌套字典更新
    set_nested_value(session, field_path, value)

    save_json(".ccg/sessions/current.json", session)
```

---

## 测试用例

### 测试 1：正常流程

```
1. 启动 Claude
2. 用户："实现用户认证"
3. ✅ current.json 创建成功
4. 调用 Coder
5. ✅ current.json 更新（SESSION_ID 已记录）
6. 调用 Codex
7. ✅ current.json 更新（审核结果已记录）
8. 任务完成
9. ✅ current.json 归档到 history/
10. ✅ current.json 重置为 template.json
```

---

### 测试 2：会话中断恢复

```
1. 用户："实现用户认证"
2. current.json 创建
3. Coder 执行中...
4. ⚠️ Claude 会话崩溃
5. 重新启动 Claude
6. ✅ 检测到 current.json 存在
7. ✅ 提示恢复会话
8. 用户选择"继续"
9. ✅ 从 current.json 恢复上下文
10. 继续执行
```

---

### 测试 3：并发保护

```
场景：多个 Claude 实例同时运行

处理：
- current.json 使用文件锁（可选）
- 或者：添加 last_updated 冲突检测
- 如果检测到冲突 → 提示用户手动解决
```

---

## 维护指南

### 手动清理历史文件

```bash
# 删除 30 天前的历史记录
find .ccg/sessions/history -name "*.json" -mtime +30 -delete

# 只保留最近 100 个文件
cd .ccg/sessions/history
ls -t *.json | tail -n +101 | xargs rm -f
```

---

### 手动重置会话

```bash
# 放弃当前任务
cp .ccg/sessions/template.json .ccg/sessions/current.json

# 或者直接删除
rm .ccg/sessions/current.json
```

---

### 查看会话历史

```bash
# 列出所有历史任务
ls -lh .ccg/sessions/history/

# 查看特定任务
cat .ccg/sessions/history/2026-01-19-task-20260119-103000.json | jq .

# 统计完成任务数
grep -l '"status": "completed"' .ccg/sessions/history/*.json | wc -l
```

---

## 附录：完整示例

### 示例：从任务开始到完成的完整 current.json 演变

**阶段 1：任务开始**
```json
{
  "session_id": "session-20260119-103000",
  "session_started": "2026-01-19T10:30:00Z",
  "last_updated": "2026-01-19T10:30:00Z",
  "status": "in_progress",
  "current_task": {
    "id": "task-20260119-103000",
    "description": "实现用户认证功能",
    "type": "feature",
    "routing": "standard_ccg",
    "phase": "preparation",
    "created_at": "2026-01-19T10:30:00Z"
  },
  "execution_state": {
    "current_step": "创建 Contract",
    "completed_steps": [],
    "pending_steps": ["Git 安全检查", "Coder 执行", "Claude 验收", "Codex 审核"],
    "iteration_count": 0,
    "errors": []
  }
}
```

**阶段 2：Contract 创建完成**
```json
{
  ...
  "last_updated": "2026-01-19T10:35:00Z",
  "current_task": {
    ...
    "phase": "execution"
  },
  "task_context": {
    "contract_file": "ai/contracts/current.md",
    ...
  },
  "execution_state": {
    "current_step": "Git 安全检查",
    "completed_steps": ["创建 Contract"],
    ...
  }
}
```

**阶段 3：Coder 执行完成**
```json
{
  ...
  "last_updated": "2026-01-19T10:50:00Z",
  "task_context": {
    ...
    "affected_files": ["auth.py", "user.py", "test_auth.py"]
  },
  "tool_sessions": {
    "coder": {
      "session_id": "coder-session-abc123",
      "last_called": "2026-01-19T10:50:00Z",
      "call_count": 1
    }
  },
  "execution_state": {
    ...
    "iteration_count": 1
  }
}
```

**阶段 4：任务完成**
```json
{
  ...
  "status": "completed",
  "last_updated": "2026-01-19T11:15:00Z",
  "current_task": {
    ...
    "phase": "delivery"
  },
  "quality_signals": {
    "tests_passed": true,
    "codex_review_status": "approved",
    "gate_passed": true,
    "scope_drift": false
  },
  "final_result": {
    "status": "completed",
    "summary": "用户认证功能已实现，包括登录、注册、密码重置",
    "completed_at": "2026-01-19T11:15:00Z"
  }
}
```

---

**文档结束**
