# Java 开发规范

> 创建日期: 2026-01-17
> 适用范围: Java 项目
> 基于: Google Java Style Guide, 企业最佳实践

---

## 一、命名规范

### 1.1 Java 特定命名

**强制要求**:
- 类/接口：`PascalCase`
- 方法/变量：`camelCase`
- 常量：`UPPER_SNAKE_CASE`
- 包名：`lowercase.with.dots`

**示例**:
```java
✅ 正确
package com.example.userservice;

public class UserService {
    private static final int MAX_RETRY_COUNT = 3;
    private UserRepository userRepository;

    public User getUserById(int userId) {
        return userRepository.findById(userId);
    }
}

❌ 错误
package com.Example.UserService;  // 包名应该全小写

public class userService {  // 类名应该 PascalCase
    private static final int maxRetryCount = 3;  // 常量应该 UPPER_SNAKE_CASE

    public User GetUserById(int user_id) {  // 方法应该 camelCase
        return null;
    }
}
```

### 1.2 接口和实现类命名

**规则**:
- 接口：描述性名词，不使用 I 前缀
- 实现类：接口名 + Impl 或具体实现描述

**示例**:
```java
✅ 正确
public interface UserRepository { }
public class UserRepositoryImpl implements UserRepository { }
// 或
public class JdbcUserRepository implements UserRepository { }

❌ 错误
public interface IUserRepository { }  // 不要使用 I 前缀
```

---

## 二、代码格式化

### 2.1 缩进和空格

**强制要求**:
- 使用 4 个空格缩进
- 大括号使用 K&R 风格（左括号不换行）
- 运算符两侧加空格

**示例**:
```java
✅ 正确
public class Example {
    public void method() {
        if (condition) {
            doSomething();
        } else {
            doOtherwi();
        }
    }
}

❌ 错误
public class Example
{  // 左括号应该不换行
    public void method()
    {
        if(condition){  // 缺少空格
            doSomething();
        }
    }
}
```

### 2.2 行长度

**建议**:
- 每行不超过 100-120 字符
- 长语句合理换行

**示例**:
```java
✅ 正确换行
User user = userService.createUser(
    userName,
    email,
    phoneNumber
);

❌ 过长不换行
User user = userService.createUser(userName, email, phoneNumber, address, city, country);
```

---

## 三、类和接口设计

### 3.1 类成员顺序

**推荐顺序**:
1. 静态常量
2. 静态变量
3. 实例变量
4. 构造函数
5. 静态方法
6. 实例方法
7. 内部类

**示例**:
```java
public class UserService {
    // 1. 静态常量
    private static final int MAX_RETRY = 3;

    // 2. 静态变量
    private static UserService instance;

    // 3. 实例变量
    private UserRepository repository;
    private Logger logger;

    // 4. 构造函数
    public UserService(UserRepository repository) {
        this.repository = repository;
        this.logger = LoggerFactory.getLogger(UserService.class);
    }

    // 5. 静态方法
    public static UserService getInstance() {
        return instance;
    }

    // 6. 实例方法
    public User getUser(int id) {
        return repository.findById(id);
    }
}
```

### 3.2 访问修饰符

**规则**:
- 默认使用最小可见性
- 优先使用 private，必要时才扩大
- 避免使用 public 字段

**示例**:
```java
✅ 正确
public class User {
    private int id;
    private String name;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }
}

❌ 错误
public class User {
    public int id;  // 不要暴露字段
    public String name;
}
```

---

## 四、异常处理

### 4.1 异常处理原则

**规则**:
- 捕获具体异常，避免捕获 Exception
- 不要吞掉异常
- 使用 try-with-resources 管理资源

**示例**:
```java
✅ 正确
try (BufferedReader reader = new BufferedReader(new FileReader("file.txt"))) {
    String line = reader.readLine();
} catch (IOException e) {
    logger.error("Failed to read file", e);
    throw new ServiceException("File read error", e);
}

❌ 错误
try {
    BufferedReader reader = new BufferedReader(new FileReader("file.txt"));
    String line = reader.readLine();
} catch (Exception e) {  // 不要捕获 Exception
    // 不要吞掉异常
}
```

### 4.2 自定义异常

**规则**:
- 继承合适的异常类
- 提供有意义的错误信息
- 包含原始异常（cause）

**示例**:
```java
✅ 正确
public class UserNotFoundException extends RuntimeException {
    public UserNotFoundException(int userId) {
        super("User not found: " + userId);
    }

    public UserNotFoundException(int userId, Throwable cause) {
        super("User not found: " + userId, cause);
    }
}
```

---

## 五、集合和泛型

### 5.1 使用泛型

**规则**:
- 始终使用泛型，避免原始类型
- 使用接口类型声明变量

**示例**:
```java
✅ 正确
List<String> names = new ArrayList<>();
Map<Integer, User> userMap = new HashMap<>();

❌ 错误
List names = new ArrayList();  // 缺少泛型
ArrayList<String> names = new ArrayList<>();  // 应该用接口类型
```

### 5.2 集合初始化

**示例**:
```java
✅ Java 9+ 使用工厂方法
List<String> names = List.of("Alice", "Bob", "Charlie");
Set<Integer> numbers = Set.of(1, 2, 3);
Map<String, Integer> map = Map.of("a", 1, "b", 2);

✅ 传统方式
List<String> names = Arrays.asList("Alice", "Bob", "Charlie");
```

---

## 六、Lambda 和 Stream

### 6.1 使用 Lambda 表达式

**规则**:
- 简单情况使用 Lambda
- 复杂逻辑提取为方法

**示例**:
```java
✅ 简单 Lambda
list.forEach(item -> System.out.println(item));
list.sort((a, b) -> a.compareTo(b));

✅ 方法引用
list.forEach(System.out::println);
list.sort(String::compareTo);

❌ 过度复杂的 Lambda
list.forEach(item -> {
    if (item.isValid()) {
        item.process();
        item.save();
        logger.info("Processed: " + item);
    }
});
```

### 6.2 使用 Stream API

**示例**:
```java
✅ 正确使用 Stream
List<String> activeUserNames = users.stream()
    .filter(User::isActive)
    .map(User::getName)
    .collect(Collectors.toList());

// 查找第一个
Optional<User> admin = users.stream()
    .filter(u -> u.getRole() == Role.ADMIN)
    .findFirst();
```

---

## 七、注解使用

### 7.1 常用注解

**示例**:
```java
✅ 正确使用注解
@Override
public String toString() {
    return "User{id=" + id + ", name=" + name + "}";
}

@Deprecated(since = "2.0", forRemoval = true)
public void oldMethod() {
    // 旧方法
}

@SuppressWarnings("unchecked")
private List<String> getList() {
    return (List<String>) rawList;
}
```

---

## 八、常见陷阱

### 8.1 字符串比较

**问题**:
```java
❌ 错误：使用 == 比较字符串
if (str == "hello") {  // 比较引用而非内容
    // ...
}

✅ 正确：使用 equals
if ("hello".equals(str)) {  // 避免 NullPointerException
    // ...
}
```

### 8.2 空指针检查

**示例**:
```java
✅ 使用 Optional
public Optional<User> findUser(int id) {
    return Optional.ofNullable(repository.find(id));
}

// 使用
findUser(123).ifPresent(user -> {
    System.out.println(user.getName());
});
```

---

## 九、工具和配置

### 9.1 推荐工具

**代码格式化**:
- Google Java Format
- Checkstyle

**代码检查**:
- SpotBugs
- PMD
- SonarLint

**测试**:
- JUnit 5
- Mockito
- AssertJ

---

## 十、总结

**核心要点**:
1. 遵循 Java 命名规范（PascalCase, camelCase）
2. 使用泛型和 Stream API
3. 优先使用 try-with-resources
4. 避免常见陷阱（字符串比较、空指针）

**与其他规范的关系**:
- 基于 `ai/code_style_guide.md` 的通用规范
- 补充 Java 特定的最佳实践
- 配合 `ai/coder_quality_guide.md` 使用

---

> 本规范适用于 Java 8+ 项目
> 更多通用规范请参考 `ai/code_style_guide.md`
