# CCG 会话恢复逻辑

> 本文档定义 Claude 会话启动时自动检测和恢复上下文的详细逻辑。

---

## 会话启动流程

### 完整流程图

```
Claude 会话启动
  ↓
步骤 1：加载项目配置
  ├─ 读取 .ccg/project-context.json
  ├─ 显示项目基本信息
  └─ 继续
  ↓
步骤 2：检测会话状态
  ├─ 检查 .ccg/sessions/current.json 是否存在
  ├─ 检查 status != "idle"
  └─ 分支：
      ├─ 有未完成任务 → 步骤 3
      └─ 无任务 → 步骤 4
  ↓
步骤 3：提示恢复会话
  ├─ 显示任务信息和进度
  ├─ 询问用户操作
  └─ 分支：
      ├─ 继续任务 → 步骤 5
      ├─ 保存并开始新任务 → 归档 + 步骤 4
      └─ 放弃任务 → 清空 + 步骤 4
  ↓
步骤 4：准备新任务
  └─ 等待用户输入
  ↓
步骤 5：恢复任务上下文
  ├─ 加载任务描述和目标
  ├─ 恢复 SESSION_ID（Coder/Codex/Gemini）
  ├─ 加载 Contract / OpenSpec（如有）
  ├─ 加载受影响的文件清单
  └─ 从当前步骤继续执行
```

---

## 步骤 1：加载项目配置

### 执行逻辑

```python
def load_project_context():
    """会话启动时自动执行"""

    # 1. 检查文件是否存在
    if not os.path.exists(".ccg/project-context.json"):
        print("⚠️ 项目配置文件不存在：.ccg/project-context.json")
        print("  请先创建配置文件（可参考模板）")
        return None

    # 2. 读取配置
    try:
        config = load_json(".ccg/project-context.json")
    except Exception as e:
        print(f"❌ 配置文件加载失败：{e}")
        return None

    # 3. 显示项目信息
    print_project_info(config)

    return config

def print_project_info(config):
    """格式化显示项目信息"""
    print(f"""
📋 **项目上下文已加载**

**项目名称**：{config['project_name']}
**描述**：{config['description']}
**技术栈**：{config['tech_stack']['language']} + {config['tech_stack']['framework']}
**当前阶段**：{config['current_phase']}

**关键模块**：
""")
    for module in config['key_modules']:
        status_icon = "✅" if module['status'] == "已完成" else "🔄"
        print(f"  {status_icon} {module['name']} - {module['status']}")

    print(f"""
**最近决策**（最近 3 条）：
""")
    for decision in config['recent_decisions'][:3]:
        print(f"  - {decision['date']}: {decision['decision']}")

    if config.get('known_issues'):
        print(f"""
⚠️ **已知问题**：
""")
        for issue in config['known_issues']:
            print(f"  - [{issue['severity']}] {issue['description']}")

    print("\n" + "="*60 + "\n")
```

### 输出示例

```markdown
📋 **项目上下文已加载**

**项目名称**：Coder-Codex-Gemini
**描述**：多模型协作 MCP 服务器
**技术栈**：Python + FastMCP
**当前阶段**：v1.0 已发布，持续优化中

**关键模块**：
  ✅ Skills 系统 - 已完成
  ✅ 模块化文档 - 刚完成
  🔄 会话管理 - 开发中

**最近决策**（最近 3 条）：
  - 2026-01-19: 模块化拆分 CCG Workflow 文档
  - 2026-01-18: 新增架构不变性（8 条硬约束）
  - 2026-01-03: 项目重命名为 CCG

============================================================
```

---

## 步骤 2：检测会话状态

### 执行逻辑

```python
def detect_session_state():
    """检测是否有未完成的会话"""

    # 1. 检查 current.json 是否存在
    if not os.path.exists(".ccg/sessions/current.json"):
        return None

    # 2. 读取会话状态
    try:
        session = load_json(".ccg/sessions/current.json")
    except Exception as e:
        print(f"⚠️ 会话文件损坏：{e}")
        print("  已重置会话状态")
        reset_session()
        return None

    # 3. 检查是否有活动任务
    if session.get("status") == "idle" or not session.get("current_task"):
        return None

    # 4. 返回会话信息
    return session
```

---

## 步骤 3：提示恢复会话

### 执行逻辑

```python
def prompt_session_recovery(session):
    """提示用户恢复会话"""

    # 1. 提取任务信息
    task = session["current_task"]
    exec_state = session["execution_state"]

    # 2. 计算时间差
    last_updated = datetime.fromisoformat(session["last_updated"])
    time_ago = human_time_diff(datetime.now() - last_updated)

    # 3. 显示任务信息
    print(f"""
⚠️ **检测到未完成任务**

**任务**：{task['description']}
**类型**：{task['type']} | **路由**：{task['routing']}
**阶段**：{task['phase']}
**上次更新**：{session['last_updated']} ({time_ago}前)

**进度**：
""")

    # 4. 显示已完成步骤
    if exec_state['completed_steps']:
        print("  ✅ 已完成：")
        for step in exec_state['completed_steps']:
            if isinstance(step, dict):
                print(f"    - {step['step']} ({step['completed_at']})")
            else:
                print(f"    - {step}")

    # 5. 显示当前步骤
    if exec_state['current_step']:
        print(f"  🔄 进行中：{exec_state['current_step']}")

    # 6. 显示待执行步骤
    if exec_state['pending_steps']:
        print("  ⏳ 待执行：")
        for step in exec_state['pending_steps']:
            print(f"    - {step}")

    # 7. 显示工具会话信息
    if any(s['session_id'] for s in session['tool_sessions'].values()):
        print("\n  📡 工具会话：")
        for tool, info in session['tool_sessions'].items():
            if info['session_id']:
                print(f"    - {tool.capitalize()}: {info['session_id']} (调用 {info['call_count']} 次)")

    # 8. 显示受影响的文件
    affected_files = session['task_context']['affected_files']
    if affected_files:
        print(f"\n  📂 受影响的文件 ({len(affected_files)} 个):")
        for file in affected_files[:5]:  # 最多显示 5 个
            print(f"    - {file}")
        if len(affected_files) > 5:
            print(f"    ... 还有 {len(affected_files) - 5} 个文件")

    # 9. 显示错误（如果有）
    if exec_state['errors']:
        print(f"\n  ❌ 错误记录 ({len(exec_state['errors'])} 个):")
        for error in exec_state['errors'][-3:]:  # 最多显示最近 3 个
            print(f"    - [{error['tool']}] {error['error']}")

    # 10. 提供操作选项
    print("""
**操作选项**：
1. ✅ 继续此任务（推荐）
2. 💾 保存并开始新任务
3. ❌ 放弃此任务并清空会话

请选择（1/2/3）：""")

    return await_user_choice()

def human_time_diff(timedelta):
    """将时间差转换为易读格式"""
    seconds = timedelta.total_seconds()
    if seconds < 60:
        return f"{int(seconds)} 秒"
    elif seconds < 3600:
        return f"{int(seconds / 60)} 分钟"
    elif seconds < 86400:
        return f"{int(seconds / 3600)} 小时"
    else:
        return f"{int(seconds / 86400)} 天"
```

### 输出示例

```markdown
⚠️ **检测到未完成任务**

**任务**：实现用户认证功能
**类型**：feature | **路由**：standard_ccg
**阶段**：execution
**上次更新**：2026-01-19T10:50:00Z (30 分钟前)

**进度**：
  ✅ 已完成：
    - 创建 Contract (2026-01-19T10:35:00Z)
    - Git 安全检查 (2026-01-19T10:40:00Z)
  🔄 进行中：Coder 执行代码改动
  ⏳ 待执行：
    - Claude 验收
    - Codex 审核
    - Git 提交推送

  📡 工具会话：
    - Coder: coder-session-abc123 (调用 1 次)

  📂 受影响的文件 (3 个):
    - auth.py
    - user.py
    - test_auth.py

**操作选项**：
1. ✅ 继续此任务（推荐）
2. 💾 保存并开始新任务
3. ❌ 放弃此任务并清空会话

请选择（1/2/3）：
```

---

## 步骤 4：准备新任务

### 执行逻辑

```python
def prepare_new_task():
    """准备开始新任务"""

    print("""
🆕 **准备开始新任务**

项目配置已加载，您可以开始描述新任务。

**提示**：
- 尽量详细描述任务目标
- 说明预计影响的模块或文件
- 明确是新功能、Bug 修复还是重构

请描述您的任务：
""")
```

---

## 步骤 5：恢复任务上下文

### 执行逻辑

```python
def resume_task_context(session):
    """恢复任务上下文并继续执行"""

    task = session["current_task"]
    exec_state = session["execution_state"]
    task_context = session["task_context"]

    print(f"""
✅ **会话已恢复**

**任务**：{task['description']}
**路由**：{task['routing']}
**当前阶段**：{task['phase']}
**当前步骤**：{exec_state['current_step']}

**上下文信息**：
""")

    # 1. 恢复 Contract / OpenSpec
    if task_context['contract_file']:
        print(f"  📄 Contract: {task_context['contract_file']}")
        contract_content = load_file(task_context['contract_file'])
        print(f"     （已加载，{len(contract_content)} 字符）")

    if task_context['openspec_file']:
        print(f"  📄 OpenSpec: {task_context['openspec_file']}")
        spec_content = load_file(task_context['openspec_file'])
        print(f"     （已加载，{len(spec_content)} 字符）")

    # 2. 恢复 SESSION_ID
    tool_sessions = session['tool_sessions']
    for tool, info in tool_sessions.items():
        if info['session_id']:
            print(f"  🔗 {tool.capitalize()} SESSION_ID: {info['session_id']}（已恢复）")

    # 3. 显示受影响的文件
    affected_files = task_context['affected_files']
    if affected_files:
        print(f"  📂 受影响的文件：{', '.join(affected_files)}")

    # 4. 恢复质量信号
    quality = session['quality_signals']
    if quality['codex_review_status']:
        print(f"  ✅ 上次 Codex 审核：{quality['codex_review_status']}")

    # 5. 显示待执行步骤
    if exec_state['pending_steps']:
        print(f"\n**待执行步骤**：")
        for i, step in enumerate(exec_state['pending_steps'], 1):
            print(f"  {i}. {step}")

    print(f"\n**继续执行**：{exec_state['current_step']}\n")

    # 6. 返回恢复的上下文
    return {
        "task": task,
        "execution_state": exec_state,
        "task_context": task_context,
        "tool_sessions": tool_sessions,
        "quality_signals": quality
    }
```

### 输出示例

```markdown
✅ **会话已恢复**

**任务**：实现用户认证功能
**路由**：standard_ccg
**当前阶段**：execution
**当前步骤**：Claude 验收

**上下文信息**：
  📄 Contract: ai/contracts/current.md
     （已加载，1523 字符）
  🔗 Coder SESSION_ID: coder-session-abc123（已恢复）
  📂 受影响的文件：auth.py, user.py, test_auth.py

**待执行步骤**：
  1. Claude 验收
  2. Codex 审核
  3. Git 提交推送

**继续执行**：Claude 验收

开始验收 Coder 的执行结果...
```

---

## 用户操作处理

### 操作 1：继续任务

```python
def handle_continue_task(session):
    """用户选择继续任务"""

    # 1. 恢复上下文
    context = resume_task_context(session)

    # 2. 根据当前阶段决定下一步
    phase = session["current_task"]["phase"]
    current_step = session["execution_state"]["current_step"]

    if phase == "preparation":
        # 继续准备阶段（如创建 Contract）
        continue_preparation(context)
    elif phase == "execution":
        # 继续执行阶段（如 Coder 执行或 Claude 验收）
        continue_execution(context)
    elif phase == "review":
        # 继续审核阶段（如 Codex 审核）
        continue_review(context)
    elif phase == "delivery":
        # 继续交付阶段（如 Git 提交）
        continue_delivery(context)
```

---

### 操作 2：保存并开始新任务

```python
def handle_save_and_new_task(session):
    """用户选择保存当前任务并开始新任务"""

    # 1. 归档当前任务
    task_id = session["current_task"]["id"]
    date_str = datetime.now().strftime("%Y-%m-%d")
    archive_file = f".ccg/sessions/history/{date_str}-{task_id}-paused.json"

    # 2. 添加暂停标记
    session["status"] = "paused"
    session["paused_at"] = datetime.now().isoformat()

    # 3. 保存到 history/
    save_json(archive_file, session)

    # 4. 重置 current.json
    reset_session()

    # 5. 提示用户
    print(f"""
💾 **任务已保存**

归档文件：{archive_file}

您可以随时恢复此任务（从 history/ 目录手动复制回 current.json）

现在可以开始新任务...
""")

    # 6. 准备新任务
    prepare_new_task()
```

---

### 操作 3：放弃任务

```python
def handle_abandon_task(session):
    """用户选择放弃任务"""

    # 1. 确认操作
    print("⚠️ 确认放弃任务？此操作不可恢复。（y/N）：")
    confirmation = await_user_input()

    if confirmation.lower() != 'y':
        print("  已取消操作")
        return prompt_session_recovery(session)  # 重新显示选项

    # 2. 可选：归档到 history/ (标记为 abandoned)
    task_id = session["current_task"]["id"]
    date_str = datetime.now().strftime("%Y-%m-%d")
    archive_file = f".ccg/sessions/history/{date_str}-{task_id}-abandoned.json"

    session["status"] = "abandoned"
    session["abandoned_at"] = datetime.now().isoformat()
    save_json(archive_file, session)

    # 3. 清空 current.json
    reset_session()

    # 4. 提示用户
    print(f"""
❌ **任务已放弃**

会话已清空，准备开始新任务...
""")

    # 5. 准备新任务
    prepare_new_task()
```

---

## 辅助函数

### 重置会话

```python
def reset_session():
    """重置会话状态"""
    template = load_json(".ccg/sessions/template.json")
    save_json(".ccg/sessions/current.json", template)
```

---

### 安全加载文件

```python
def load_file(file_path):
    """安全加载文件内容"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            return f.read()
    except FileNotFoundError:
        print(f"⚠️ 文件不存在：{file_path}")
        return None
    except Exception as e:
        print(f"⚠️ 文件加载失败：{file_path} - {e}")
        return None
```

---

## Claude 实现示例

### 会话启动时的完整流程

```markdown
## Claude 内部逻辑（会话启动）

1. **加载项目配置**
   ```python
   config = load_project_context()
   # 显示项目信息
   ```

2. **检测会话状态**
   ```python
   session = detect_session_state()
   ```

3. **分支处理**
   ```python
   if session:
       # 有未完成任务
       choice = prompt_session_recovery(session)
       if choice == 1:
           # 继续任务
           context = resume_task_context(session)
           handle_continue_task(session)
       elif choice == 2:
           # 保存并开始新任务
           handle_save_and_new_task(session)
       elif choice == 3:
           # 放弃任务
           handle_abandon_task(session)
   else:
       # 无任务，准备新任务
       prepare_new_task()
   ```

4. **等待用户输入**
```

---

## 测试场景

### 测试 1：首次启动（无会话）

```
输入：Claude 会话启动
输出：
  - 显示项目配置
  - 提示"准备开始新任务"
  - 等待用户输入
```

---

### 测试 2：恢复未完成任务

```
输入：Claude 会话启动（current.json 存在）
输出：
  - 显示项目配置
  - 显示未完成任务信息
  - 提供 3 个操作选项
用户选择：1（继续）
输出：
  - 恢复任务上下文
  - 继续执行当前步骤
```

---

### 测试 3：保存并开始新任务

```
输入：Claude 会话启动（current.json 存在）
输出：显示未完成任务信息
用户选择：2（保存并开始新）
输出：
  - 任务归档到 history/
  - current.json 重置
  - 提示"准备开始新任务"
```

---

### 测试 4：current.json 损坏

```
输入：Claude 会话启动（current.json 格式错误）
输出：
  - ⚠️ 会话文件损坏
  - 自动重置会话
  - 提示"准备开始新任务"
```

---

**文档结束**
