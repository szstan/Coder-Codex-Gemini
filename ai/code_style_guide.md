# 通用代码风格规范

> 创建日期: 2026-01-17
> 适用范围: 所有编程语言的通用规范
> 目标: 确保代码一致性、可读性和可维护性

---

## 一、命名规范

### 1.1 通用原则

**强制要求**:
- 名称必须清晰表达意图，避免缩写（除非是广泛认可的缩写）
- 使用英文命名，避免拼音或中英混合
- 避免使用单字母变量名（除了循环计数器 i, j, k）
- 避免使用无意义的名称（如 data, info, temp, foo, bar）

**好的命名**:
```
✅ userCount, calculateTotalPrice, isAuthenticated
✅ MAX_RETRY_COUNT, API_TIMEOUT_MS
✅ UserRepository, OrderService
```

**不好的命名**:
```
❌ cnt, calc, auth
❌ data1, temp, foo
❌ yonghuShuLiang (拼音)
```

### 1.2 变量命名

**规则**:
- 使用名词或名词短语
- 布尔变量使用 is/has/can/should 前缀
- 集合类型使用复数形式

**示例**:
```
✅ userName, orderList, isActive, hasPermission
❌ user_name_string, orders_array, active, permission
```

### 1.3 函数/方法命名

**规则**:
- 使用动词或动词短语
- 表达清晰的动作意图
- 返回布尔值的函数使用 is/has/can/should 前缀

**示例**:
```
✅ getUserById, calculateTotal, validateInput, isValid
❌ user, total, input, valid
```

### 1.4 类/接口命名

**规则**:
- 使用名词或名词短语
- 使用 PascalCase（大驼峰）
- 接口名可以使用 I 前缀或描述性名词

**示例**:
```
✅ UserService, OrderRepository, PaymentProcessor
✅ IUserService 或 UserServiceInterface
❌ userservice, User_Service, process
```

### 1.5 常量命名

**规则**:
- 使用全大写字母
- 单词之间用下划线分隔
- 表达清晰的含义

**示例**:
```
✅ MAX_RETRY_COUNT, API_TIMEOUT_MS, DEFAULT_PAGE_SIZE
❌ MAX, TIMEOUT, SIZE
```

---

## 二、代码格式化

### 2.1 缩进

**强制要求**:
- 使用空格而非 Tab（除非项目明确使用 Tab）
- 缩进层级：2 空格（JavaScript/TypeScript）或 4 空格（Python/Java）
- 保持一致性，不混用

### 2.2 行长度

**建议**:
- 每行不超过 100-120 字符
- 超长行应合理换行
- 优先在运算符、逗号后换行

**示例**:
```
✅ 合理换行
const result = calculateTotalPrice(
  items,
  discountRate,
  taxRate
);

❌ 过长不换行
const result = calculateTotalPrice(items, discountRate, taxRate, shippingFee, insuranceFee, handlingFee);
```

### 2.3 空行使用

**规则**:
- 函数之间空一行
- 逻辑块之间空一行
- 文件末尾保留一个空行
- 不要有多余的连续空行

### 2.4 空格使用

**规则**:
- 运算符两侧加空格：`a + b` 而非 `a+b`
- 逗号后加空格：`func(a, b)` 而非 `func(a,b)`
- 关键字后加空格：`if (condition)` 而非 `if(condition)`
- 括号内侧不加空格：`(a + b)` 而非 `( a + b )`

---

## 三、注释规范

### 3.1 何时写注释

**必须写注释**:
- 复杂的业务逻辑
- 非显而易见的算法
- 重要的假设或约束
- 临时解决方案（TODO/FIXME）
- 公共 API 和接口

**不需要写注释**:
- 显而易见的代码
- 重复代码本身的信息
- 过时或错误的注释（应删除）

### 3.2 注释风格

**规则**:
- 使用清晰、简洁的语言
- 解释"为什么"而非"是什么"
- 保持注释与代码同步更新

**好的注释**:
```
✅ 解释原因
// 使用指数退避避免 API 限流
await retryWithBackoff(apiCall);

// 临时方案：等待上游修复 Bug #1234
const workaround = ...;
```

**不好的注释**:
```
❌ 重复代码
// 设置用户名为 John
userName = "John";

❌ 过时注释
// TODO: 重构这个函数（已经重构完成但注释未删除）
```

### 3.3 TODO/FIXME 标记

**规则**:
- TODO: 计划中的改进
- FIXME: 已知问题需要修复
- 包含日期和负责人（可选）

**示例**:
```
// TODO(2026-01-17): 添加缓存机制提升性能
// FIXME: 处理并发情况下的竞态条件
```

---

## 四、文件组织

### 4.1 文件命名

**规则**:
- 使用小写字母和连字符：`user-service.js`
- 或使用 camelCase：`userService.js`
- 或使用 PascalCase（类文件）：`UserService.java`
- 保持项目内一致

### 4.2 文件结构

**推荐顺序**:
1. 文件头注释（可选）
2. 导入/引用语句
3. 常量定义
4. 类型定义
5. 主要代码
6. 导出语句

### 4.3 导入组织

**规则**:
- 按类型分组：标准库 → 第三方库 → 本地模块
- 组内按字母顺序排序
- 组之间空一行

**示例**:
```
// 标准库
import os
import sys

// 第三方库
import requests
import numpy as np

// 本地模块
from .models import User
from .utils import validate
```

---

## 五、代码结构

### 5.1 函数长度

**建议**:
- 单个函数不超过 50 行
- 超过则考虑拆分为多个小函数
- 每个函数只做一件事

### 5.2 函数参数

**建议**:
- 参数数量不超过 3-4 个
- 超过则考虑使用对象/字典封装
- 必需参数在前，可选参数在后

**示例**:
```
✅ 参数合理
function createUser(name, email, options = {}) { ... }

❌ 参数过多
function createUser(name, email, age, phone, address, city, country) { ... }

✅ 使用对象封装
function createUser(userData) { ... }
```

### 5.3 嵌套深度

**建议**:
- 嵌套层级不超过 3 层
- 使用 early return 减少嵌套
- 提取复杂条件为函数

**示例**:
```
✅ Early return
function processUser(user) {
  if (!user) return null;
  if (!user.isActive) return null;

  return doProcess(user);
}

❌ 深层嵌套
function processUser(user) {
  if (user) {
    if (user.isActive) {
      return doProcess(user);
    }
  }
  return null;
}
```

---

## 六、最佳实践

### 6.1 DRY 原则（Don't Repeat Yourself）

**规则**:
- 避免重复代码
- 提取公共逻辑为函数
- 但不要过度抽象

### 6.2 KISS 原则（Keep It Simple, Stupid）

**规则**:
- 优先选择简单直接的实现
- 避免过度设计
- 复杂性必须有充分理由

### 6.3 单一职责原则

**规则**:
- 每个函数/类只负责一件事
- 职责清晰，边界明确
- 便于测试和维护

### 6.4 避免魔法数字

**规则**:
- 使用命名常量替代硬编码数字
- 提升代码可读性

**示例**:
```
✅ 使用常量
const MAX_RETRY_COUNT = 3;
for (let i = 0; i < MAX_RETRY_COUNT; i++) { ... }

❌ 魔法数字
for (let i = 0; i < 3; i++) { ... }
```

---

## 七、与现有规范的关系

本规范是 `ai/coder_quality_guide.md` 的补充：
- **质量指南**：定义质量标准和禁止行为
- **本规范**：定义具体的代码风格和格式

**使用方式**:
1. 优先遵守 `coder_quality_guide.md` 的质量原则
2. 在此基础上应用本规范的风格要求
3. 语言特定规范（Python/Java/前端）进一步细化

---

## 八、工具支持

### 8.1 推荐工具

**代码格式化**:
- Python: Black, autopep8
- JavaScript/TypeScript: Prettier, ESLint
- Java: Google Java Format, Checkstyle

**代码检查**:
- Python: Pylint, Flake8
- JavaScript/TypeScript: ESLint, TSLint
- Java: SpotBugs, PMD

### 8.2 编辑器配置

**推荐配置**:
- 启用自动格式化（保存时）
- 显示空白字符
- 设置行长度标尺（100 或 120）
- 启用 Linter 实时检查

---

## 九、总结

**核心要点**:
1. 命名清晰表达意图
2. 保持代码格式一致
3. 注释解释"为什么"
4. 函数简短单一职责
5. 避免过度复杂

**记住**:
- 代码是写给人看的，其次才是给机器执行的
- 一致性比个人偏好更重要
- 简单清晰优于复杂巧妙

---

> 本规范适用于所有编程语言
> 语言特定规范请参考：
> - Python: `ai/python_guide.md`
> - Java: `ai/java_guide.md`
> - 前端: `ai/frontend_guide.md`
