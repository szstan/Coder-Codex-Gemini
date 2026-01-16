# Python 开发规范

> 创建日期: 2026-01-17
> 适用范围: Python 项目
> 基于: PEP 8, PEP 257, 企业最佳实践

---

## 一、命名规范

### 1.1 Python 特定命名

**强制要求**:
- 变量/函数：`snake_case`
- 类：`PascalCase`
- 常量：`UPPER_SNAKE_CASE`
- 私有成员：`_leading_underscore`
- 特殊方法：`__dunder__`

**示例**:
```python
✅ 正确
user_name = "John"
MAX_RETRY_COUNT = 3

class UserService:
    def get_user_by_id(self, user_id):
        return self._fetch_from_db(user_id)

    def _fetch_from_db(self, user_id):  # 私有方法
        pass

❌ 错误
userName = "John"  # 应该用 snake_case
class userService:  # 应该用 PascalCase
    def GetUserById(self):  # 应该用 snake_case
        pass
```

---

## 二、代码格式化

### 2.1 缩进和空格

**强制要求**:
- 使用 4 个空格缩进（不使用 Tab）
- 运算符两侧加空格
- 逗号后加空格

**示例**:
```python
✅ 正确
def calculate_total(items, tax_rate=0.1):
    total = sum(item.price for item in items)
    return total * (1 + tax_rate)

❌ 错误
def calculate_total(items,tax_rate=0.1):
    total=sum(item.price for item in items)
    return total*(1+tax_rate)
```

### 2.2 行长度

**建议**:
- 每行不超过 100 字符（PEP 8 建议 79，企业实践 100）
- 长表达式使用括号换行

**示例**:
```python
✅ 正确换行
result = some_function(
    argument1,
    argument2,
    argument3
)

# 或
result = (
    some_long_expression
    + another_expression
    + yet_another_expression
)

❌ 过长不换行
result = some_function(argument1, argument2, argument3, argument4, argument5, argument6)
```

---

## 三、导入规范

### 3.1 导入顺序

**强制要求**:
1. 标准库
2. 第三方库
3. 本地模块
4. 组之间空一行

**示例**:
```python
✅ 正确
import os
import sys
from typing import List, Dict

import requests
import numpy as np

from .models import User
from .utils import validate_email
```

### 3.2 导入风格

**规则**:
- 每个导入单独一行
- 避免 `from module import *`
- 使用绝对导入优于相对导入

**示例**:
```python
✅ 正确
import os
import sys
from typing import List

❌ 错误
import os, sys  # 不要在一行导入多个
from typing import *  # 不要使用 *
```

---

## 四、类型注解

### 4.1 何时使用类型注解

**建议使用**:
- 公共 API 函数
- 复杂的函数签名
- 容易混淆的参数类型

**可以省略**:
- 简单的内部函数
- 类型显而易见的情况

**示例**:
```python
✅ 公共 API 使用类型注解
from typing import List, Optional

def get_users(
    user_ids: List[int],
    include_inactive: bool = False
) -> List[User]:
    """获取用户列表"""
    pass

def calculate_total(items: List[Item]) -> float:
    """计算总价"""
    return sum(item.price for item in items)

✅ 简单函数可省略
def _is_valid(value):
    return value is not None
```

### 4.2 常用类型注解

**示例**:
```python
from typing import List, Dict, Optional, Union, Tuple, Any

# 基础类型
name: str = "John"
age: int = 30
price: float = 99.99
is_active: bool = True

# 集合类型
user_ids: List[int] = [1, 2, 3]
user_map: Dict[int, str] = {1: "John", 2: "Jane"}

# 可选类型
email: Optional[str] = None  # 等同于 Union[str, None]

# 联合类型
result: Union[int, str] = 42

# 元组
coordinates: Tuple[float, float] = (10.0, 20.0)

# 函数类型
from typing import Callable
callback: Callable[[int], str] = lambda x: str(x)
```

---

## 五、文档字符串（Docstring）

### 5.1 何时写 Docstring

**必须写**:
- 所有公共模块、类、函数
- 复杂的内部函数

**可以省略**:
- 简单的私有方法
- 显而易见的 getter/setter

### 5.2 Docstring 格式

**推荐使用 Google 风格**:

```python
✅ 完整的 Docstring
def calculate_discount(
    price: float,
    discount_rate: float,
    max_discount: Optional[float] = None
) -> float:
    """计算折扣后的价格。

    Args:
        price: 原价
        discount_rate: 折扣率（0-1 之间）
        max_discount: 最大折扣金额，None 表示无限制

    Returns:
        折扣后的价格

    Raises:
        ValueError: 当 discount_rate 不在 0-1 之间时

    Examples:
        >>> calculate_discount(100, 0.2)
        80.0
        >>> calculate_discount(100, 0.5, max_discount=30)
        70.0
    """
    if not 0 <= discount_rate <= 1:
        raise ValueError("discount_rate must be between 0 and 1")

    discount = price * discount_rate
    if max_discount is not None:
        discount = min(discount, max_discount)

    return price - discount
```

---

## 六、异常处理

### 6.1 异常处理原则

**规则**:
- 捕获具体的异常，避免裸 `except`
- 不要吞掉异常
- 使用 `finally` 清理资源（或使用上下文管理器）

**示例**:
```python
✅ 正确
try:
    result = risky_operation()
except ValueError as e:
    logger.error(f"Invalid value: {e}")
    raise
except IOError as e:
    logger.error(f"IO error: {e}")
    return None

❌ 错误
try:
    result = risky_operation()
except:  # 不要使用裸 except
    pass  # 不要吞掉异常
```

### 6.2 上下文管理器

**优先使用 `with` 语句**:

```python
✅ 使用 with
with open("file.txt", "r") as f:
    content = f.read()

# 数据库连接
with get_db_connection() as conn:
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM users")

❌ 手动管理资源
f = open("file.txt", "r")
content = f.read()
f.close()  # 容易忘记或异常时不执行
```

---

## 七、常见模式

### 7.1 列表推导式

**规则**:
- 简单情况使用列表推导式
- 复杂情况使用普通循环

**示例**:
```python
✅ 简单推导式
squares = [x**2 for x in range(10)]
even_numbers = [x for x in numbers if x % 2 == 0]

✅ 复杂情况用循环
result = []
for item in items:
    if item.is_valid():
        processed = item.process()
        if processed:
            result.append(processed)

❌ 过度复杂的推导式
result = [item.process() for item in items if item.is_valid() and item.process()]
```

### 7.2 字典和集合

**示例**:
```python
✅ 字典推导式
user_map = {user.id: user.name for user in users}

✅ 集合推导式
unique_ids = {item.id for item in items}

✅ 使用 get 方法
value = my_dict.get("key", default_value)

❌ 不要这样
if "key" in my_dict:
    value = my_dict["key"]
else:
    value = default_value
```

### 7.3 字符串格式化

**推荐使用 f-string（Python 3.6+）**:

```python
✅ f-string（推荐）
name = "John"
age = 30
message = f"User {name} is {age} years old"

✅ format 方法（兼容性）
message = "User {} is {} years old".format(name, age)

❌ 旧式格式化（避免）
message = "User %s is %d years old" % (name, age)
```

---

## 八、Python 特定最佳实践

### 8.1 使用生成器节省内存

**规则**:
- 处理大数据集时使用生成器
- 使用 `yield` 而非返回完整列表

**示例**:
```python
✅ 使用生成器
def read_large_file(file_path):
    with open(file_path, "r") as f:
        for line in f:
            yield line.strip()

# 使用
for line in read_large_file("large.txt"):
    process(line)

❌ 一次性加载全部
def read_large_file(file_path):
    with open(file_path, "r") as f:
        return [line.strip() for line in f]  # 内存占用大
```

### 8.2 使用 dataclass 简化数据类

**Python 3.7+ 推荐使用 dataclass**:

```python
✅ 使用 dataclass
from dataclasses import dataclass

@dataclass
class User:
    id: int
    name: str
    email: str
    is_active: bool = True

user = User(1, "John", "john@example.com")

❌ 手动实现
class User:
    def __init__(self, id, name, email, is_active=True):
        self.id = id
        self.name = name
        self.email = email
        self.is_active = is_active

    def __repr__(self):
        return f"User(id={self.id}, name={self.name}...)"
```

### 8.3 使用 Enum 定义常量集合

**示例**:
```python
✅ 使用 Enum
from enum import Enum

class Status(Enum):
    PENDING = "pending"
    APPROVED = "approved"
    REJECTED = "rejected"

# 使用
order.status = Status.PENDING

❌ 使用字符串常量
STATUS_PENDING = "pending"
STATUS_APPROVED = "approved"
STATUS_REJECTED = "rejected"
```

### 8.4 使用 pathlib 处理路径

**Python 3.4+ 推荐使用 pathlib**:

```python
✅ 使用 pathlib
from pathlib import Path

config_path = Path("config") / "settings.json"
if config_path.exists():
    content = config_path.read_text()

❌ 使用 os.path
import os

config_path = os.path.join("config", "settings.json")
if os.path.exists(config_path):
    with open(config_path, "r") as f:
        content = f.read()
```

---

## 九、常见陷阱

### 9.1 可变默认参数

**问题**:
```python
❌ 错误：可变默认参数
def add_item(item, items=[]):
    items.append(item)
    return items

# 问题：默认列表在所有调用间共享
add_item(1)  # [1]
add_item(2)  # [1, 2] 而非 [2]

✅ 正确：使用 None
def add_item(item, items=None):
    if items is None:
        items = []
    items.append(item)
    return items
```

### 9.2 循环中的闭包

**问题**:
```python
❌ 错误：闭包捕获循环变量
funcs = []
for i in range(3):
    funcs.append(lambda: i)

# 问题：所有函数都返回 2
[f() for f in funcs]  # [2, 2, 2]

✅ 正确：使用默认参数
funcs = []
for i in range(3):
    funcs.append(lambda x=i: x)

[f() for f in funcs]  # [0, 1, 2]
```

---

## 十、工具和配置

### 10.1 推荐工具

**代码格式化**:
- Black: 无配置的代码格式化工具
- autopep8: 自动修复 PEP 8 违规

**代码检查**:
- Pylint: 全面的代码检查
- Flake8: 轻量级检查工具
- mypy: 静态类型检查

**测试**:
- pytest: 推荐的测试框架
- pytest-cov: 覆盖率报告

### 10.2 配置示例

**pyproject.toml**:
```toml
[tool.black]
line-length = 100
target-version = ['py38']

[tool.pylint.messages_control]
max-line-length = 100
disable = ["C0111"]  # missing-docstring

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py"]
```

---

## 十一、总结

**核心要点**:
1. 遵循 PEP 8 命名规范（snake_case, PascalCase）
2. 使用类型注解提升代码可读性
3. 优先使用现代 Python 特性（f-string, dataclass, pathlib）
4. 避免常见陷阱（可变默认参数、闭包）
5. 使用工具自动化格式化和检查

**与其他规范的关系**:
- 基于 `ai/code_style_guide.md` 的通用规范
- 补充 Python 特定的最佳实践
- 配合 `ai/coder_quality_guide.md` 使用

---

> 本规范适用于 Python 3.7+ 项目
> 更多通用规范请参考 `ai/code_style_guide.md`
