# 代码设计原则

> 创建日期: 2026-01-17
> 适用范围: 所有编程语言的架构设计指导
> 目标: 防止过度设计，提供实用的设计决策指南

---

## 一、核心设计原则

### 1.1 SOLID 原则

#### S - 单一职责原则 (Single Responsibility Principle)

**定义**: 一个类/模块只负责一件事

**何时应用**:
- 类的职责超过一个明确的目标
- 修改一个功能需要改动多个不相关的代码

**示例**:
```python
❌ 违反 SRP：一个类做太多事
class UserManager:
    def create_user(self, data):
        # 验证数据
        # 保存到数据库
        # 发送欢迎邮件
        # 记录日志
        pass

✅ 遵循 SRP：职责分离
class UserValidator:
    def validate(self, data): pass

class UserRepository:
    def save(self, user): pass

class EmailService:
    def send_welcome_email(self, user): pass

class UserService:
    def create_user(self, data):
        self.validator.validate(data)
        user = self.repository.save(data)
        self.email_service.send_welcome_email(user)
        return user
```

**何时不应用**:
- 简单的工具函数或数据类
- 过度拆分导致代码难以理解

---

#### O - 开闭原则 (Open/Closed Principle)

**定义**: 对扩展开放，对修改关闭

**何时应用**:
- 需要支持多种变体或策略
- 预期会有新的实现方式

**示例**:
```python
❌ 违反 OCP：每次新增类型都要修改
def calculate_discount(order, customer_type):
    if customer_type == "regular":
        return order.total * 0.05
    elif customer_type == "vip":
        return order.total * 0.10
    elif customer_type == "premium":  # 新增需要修改
        return order.total * 0.15

✅ 遵循 OCP：通过策略模式扩展
class DiscountStrategy:
    def calculate(self, order): pass

class RegularDiscount(DiscountStrategy):
    def calculate(self, order):
        return order.total * 0.05

class VIPDiscount(DiscountStrategy):
    def calculate(self, order):
        return order.total * 0.10

# 新增类型无需修改现有代码
class PremiumDiscount(DiscountStrategy):
    def calculate(self, order):
        return order.total * 0.15
```

**何时不应用**:
- 只有 1-2 种情况，不会扩展
- 过度抽象导致代码复杂

---

#### L - 里氏替换原则 (Liskov Substitution Principle)

**定义**: 子类必须能替换父类而不破坏程序

**何时应用**:
- 使用继承时
- 设计接口和抽象类时

**示例**:
```python
❌ 违反 LSP：子类改变了父类行为
class Bird:
    def fly(self): pass

class Penguin(Bird):
    def fly(self):
        raise Exception("Penguins can't fly!")  # 破坏了父类契约

✅ 遵循 LSP：正确的抽象
class Bird:
    def move(self): pass

class FlyingBird(Bird):
    def move(self):
        self.fly()

class Penguin(Bird):
    def move(self):
        self.swim()
```

---

#### I - 接口隔离原则 (Interface Segregation Principle)

**定义**: 不应强迫客户端依赖它不使用的接口

**何时应用**:
- 接口有多个不相关的方法
- 不同客户端只需要部分功能

**示例**:
```python
❌ 违反 ISP：臃肿的接口
class Worker:
    def work(self): pass
    def eat(self): pass
    def sleep(self): pass

class Robot(Worker):
    def work(self): pass
    def eat(self): pass  # 机器人不需要吃饭
    def sleep(self): pass  # 机器人不需要睡觉

✅ 遵循 ISP：接口分离
class Workable:
    def work(self): pass

class Eatable:
    def eat(self): pass

class Sleepable:
    def sleep(self): pass

class Human(Workable, Eatable, Sleepable):
    pass

class Robot(Workable):
    pass
```

---

#### D - 依赖倒置原则 (Dependency Inversion Principle)

**定义**: 依赖抽象而非具体实现

**何时应用**:
- 需要替换实现（测试、切换数据库等）
- 降低模块间耦合

**示例**:
```python
❌ 违反 DIP：依赖具体实现
class UserService:
    def __init__(self):
        self.db = MySQLDatabase()  # 硬编码依赖

✅ 遵循 DIP：依赖抽象
class Database:
    def save(self, data): pass

class MySQLDatabase(Database):
    def save(self, data): pass

class UserService:
    def __init__(self, db: Database):  # 依赖抽象
        self.db = db
```

---

## 二、其他重要原则

### 2.1 DRY (Don't Repeat Yourself)

**定义**: 避免重复代码

**何时应用**:
- 相同逻辑出现 3 次以上
- 修改一处需要同步修改多处

**何时不应用**:
- 两段代码只是偶然相似，未来会独立演化
- 提取公共逻辑会导致过度抽象

**示例**:
```python
✅ 合理的 DRY
def validate_email(email):
    return re.match(r'^[\w\.-]+@[\w\.-]+\.\w+$', email)

def create_user(email):
    if not validate_email(email):
        raise ValueError("Invalid email")

def update_user(email):
    if not validate_email(email):
        raise ValueError("Invalid email")

❌ 过度的 DRY
# 两个函数只是偶然相似，未来会独立演化
def process_order(order):
    validate(order)
    save(order)

def process_refund(refund):
    validate(refund)
    save(refund)

# 不要强行提取为：
def process_entity(entity):  # 过度抽象
    validate(entity)
    save(entity)
```

---

### 2.2 KISS (Keep It Simple, Stupid)

**定义**: 保持简单

**何时应用**:
- 总是优先选择简单方案
- 复杂性必须有充分理由

**示例**:
```python
✅ 简单直接
def get_user_name(user):
    return user.name if user else "Guest"

❌ 过度复杂
def get_user_name(user):
    return UserNameResolver(
        strategy=DefaultNameStrategy(),
        fallback=GuestNameFallback()
    ).resolve(user)
```

---

### 2.3 YAGNI (You Aren't Gonna Need It)

**定义**: 不要实现当前不需要的功能

**何时应用**:
- 只实现当前需求
- 不要为"可能的未来需求"编码

**示例**:
```python
❌ 违反 YAGNI：实现未来可能需要的功能
class User:
    def __init__(self, name, email):
        self.name = name
        self.email = email
        self.phone = None  # 当前不需要
        self.address = None  # 当前不需要
        self.preferences = {}  # 当前不需要

✅ 遵循 YAGNI：只实现当前需要的
class User:
    def __init__(self, name, email):
        self.name = name
        self.email = email
```

---

## 三、常见设计模式使用指南

### 3.1 何时使用设计模式

**使用设计模式的触发条件**：
1. 有明确的变化点需要隔离
2. 代码重复且难以维护
3. 需要支持多种实现方式

**不使用设计模式的情况**：
1. 只有 1-2 种情况，不会扩展
2. 增加复杂度超过带来的收益
3. 团队不熟悉该模式

---

### 3.2 工厂模式 (Factory Pattern)

**何时使用**：
- 对象创建逻辑复杂
- 需要根据条件创建不同类型的对象

**示例**：
```python
✅ 适合使用工厂模式
class PaymentFactory:
    @staticmethod
    def create(payment_type):
        if payment_type == "credit_card":
            return CreditCardPayment()
        elif payment_type == "paypal":
            return PayPalPayment()
        elif payment_type == "wechat":
            return WeChatPayment()

❌ 不需要工厂模式
# 只有一种支付方式，直接创建即可
payment = CreditCardPayment()
```

---

### 3.3 策略模式 (Strategy Pattern)

**何时使用**：
- 有多种算法或行为可以互换
- 避免大量 if-else 或 switch-case

**示例**：
```python
✅ 适合使用策略模式
class SortStrategy:
    def sort(self, data): pass

class QuickSort(SortStrategy):
    def sort(self, data):
        # 快速排序实现
        pass

class MergeSort(SortStrategy):
    def sort(self, data):
        # 归并排序实现
        pass

class Sorter:
    def __init__(self, strategy: SortStrategy):
        self.strategy = strategy

    def sort(self, data):
        return self.strategy.sort(data)
```

---

### 3.4 观察者模式 (Observer Pattern)

**何时使用**：
- 一个对象状态变化需要通知多个对象
- 发布-订阅场景

**示例**：
```python
✅ 适合使用观察者模式
class EventManager:
    def __init__(self):
        self.listeners = []

    def subscribe(self, listener):
        self.listeners.append(listener)

    def notify(self, event):
        for listener in self.listeners:
            listener.handle(event)

# 使用
event_manager = EventManager()
event_manager.subscribe(EmailNotifier())
event_manager.subscribe(SMSNotifier())
event_manager.notify(UserCreatedEvent(user))
```

---

## 四、过度设计的识别和避免

### 4.1 过度设计的信号

**警告信号**：
1. 为"可能的未来需求"编写代码
2. 使用设计模式但只有 1-2 种实现
3. 抽象层次超过 3 层
4. 类/接口数量远超实际需求
5. 代码难以理解和维护

### 4.2 常见过度设计案例

**案例 1：过度抽象**
```python
❌ 过度设计
class AbstractUserFactory:
    def create(self): pass

class UserFactoryImpl(AbstractUserFactory):
    def create(self):
        return User()

class UserServiceFacade:
    def __init__(self, factory: AbstractUserFactory):
        self.factory = factory

# 只是为了创建一个 User 对象！

✅ 简单直接
def create_user(name, email):
    return User(name, email)
```

**案例 2：过早优化**
```python
❌ 过度设计
class CachedUserRepository:
    def __init__(self):
        self.cache = LRUCache(maxsize=1000)
        self.db = Database()

    def get(self, user_id):
        if user_id in self.cache:
            return self.cache[user_id]
        user = self.db.get(user_id)
        self.cache[user_id] = user
        return user

# 但实际上每天只有 10 个用户访问！

✅ 先简单实现
class UserRepository:
    def get(self, user_id):
        return self.db.get(user_id)

# 等真正遇到性能问题再优化
```

---

## 五、依赖管理最佳实践

### 5.1 依赖注入 (Dependency Injection)

**何时使用**：
- 需要替换实现（测试、切换数据库）
- 降低模块间耦合

**示例**：
```python
✅ 使用依赖注入
class UserService:
    def __init__(self, repository, email_service):
        self.repository = repository
        self.email_service = email_service

    def create_user(self, data):
        user = self.repository.save(data)
        self.email_service.send_welcome(user)
        return user

# 测试时可以注入 Mock
service = UserService(
    repository=MockRepository(),
    email_service=MockEmailService()
)
```

### 5.2 避免循环依赖

**问题**：
```python
❌ 循环依赖
# user_service.py
from order_service import OrderService

class UserService:
    def __init__(self):
        self.order_service = OrderService()

# order_service.py
from user_service import UserService

class OrderService:
    def __init__(self):
        self.user_service = UserService()
```

**解决方案**：
```python
✅ 引入中间层或使用事件
# 方案 1：引入中间层
class UserOrderService:
    def __init__(self, user_repo, order_repo):
        self.user_repo = user_repo
        self.order_repo = order_repo

# 方案 2：使用事件解耦
class UserService:
    def create_user(self, data):
        user = self.repository.save(data)
        event_bus.publish(UserCreatedEvent(user))
        return user

class OrderService:
    def __init__(self):
        event_bus.subscribe(UserCreatedEvent, self.on_user_created)
```

---

## 六、API 设计基本原则

### 6.1 RESTful API 设计

**基本原则**：
- 使用名词表示资源
- 使用 HTTP 方法表示操作
- 返回合适的状态码

**示例**：
```
✅ 良好的 API 设计
GET    /users          # 获取用户列表
GET    /users/123      # 获取单个用户
POST   /users          # 创建用户
PUT    /users/123      # 更新用户
DELETE /users/123      # 删除用户

❌ 不好的 API 设计
GET    /getUsers
POST   /createUser
POST   /updateUser
POST   /deleteUser
```

### 6.2 接口版本管理

**何时需要版本管理**：
- API 有破坏性变更
- 需要支持多个客户端版本

**示例**：
```
✅ URL 版本控制
/api/v1/users
/api/v2/users

✅ Header 版本控制
Accept: application/vnd.api+json; version=1
```

---

## 七、总结

### 7.1 核心要点

1. **SOLID 原则**：单一职责、开闭、里氏替换、接口隔离、依赖倒置
2. **简单性优先**：DRY、KISS、YAGNI
3. **谨慎使用设计模式**：只在有明确收益时使用
4. **避免过度设计**：识别警告信号，保持简单
5. **依赖管理**：使用依赖注入，避免循环依赖

### 7.2 决策流程

**设计决策时问自己**：
1. 这个设计解决了什么问题？
2. 有更简单的方案吗？
3. 增加的复杂度值得吗？
4. 团队能理解和维护吗？
5. 是否为未来可能不会发生的需求编码？

### 7.3 与其他规范的关系

- **engineering_codex.md**：工程执行层原则
- **coder_quality_guide.md**：质量标准和禁止行为
- **本规范**：架构设计和模式选择指导

---

> 本规范适用于所有编程语言的架构设计
> 重点：防止过度设计，提供实用的决策指南
