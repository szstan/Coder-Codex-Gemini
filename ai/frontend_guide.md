# 前端开发规范

> 创建日期: 2026-01-17
> 适用范围: JavaScript/TypeScript/React/Vue 项目
> 基于: Airbnb Style Guide, 企业最佳实践

---

## 一、命名规范

### 1.1 JavaScript/TypeScript 命名

**强制要求**:
- 变量/函数：`camelCase`
- 类/组件：`PascalCase`
- 常量：`UPPER_SNAKE_CASE`
- 文件名：`kebab-case` 或 `PascalCase`（组件）

**示例**:
```javascript
✅ 正确
const userName = "John";
const MAX_RETRY_COUNT = 3;

class UserService { }
function getUserById(id) { }

// 文件名
user-service.js
UserProfile.jsx

❌ 错误
const UserName = "John";  // 应该用 camelCase
const max_retry_count = 3;  // 应该用 UPPER_SNAKE_CASE
class userService { }  // 应该用 PascalCase
```

### 1.2 React 组件命名

**规则**:
- 组件：`PascalCase`
- Props：`camelCase`
- 事件处理函数：`handle` 前缀

**示例**:
```jsx
✅ 正确
function UserProfile({ userId, onUserClick }) {
  const handleClick = () => {
    onUserClick(userId);
  };

  return <div onClick={handleClick}>Profile</div>;
}

❌ 错误
function userProfile({ user_id, OnUserClick }) {  // 命名不规范
  const clickHandler = () => { };  // 应该用 handle 前缀
}
```

---

## 二、代码格式化

### 2.1 缩进和空格

**强制要求**:
- 使用 2 个空格缩进
- 使用分号结尾
- 使用单引号（或配置 Prettier）

**示例**:
```javascript
✅ 正确
const user = {
  name: 'John',
  age: 30
};

function getUser(id) {
  return users.find(u => u.id === id);
}

❌ 错误
const user = {
    name: "John",  // 应该 2 空格缩进，单引号
    age: 30
}  // 缺少分号
```

### 2.2 对象和数组

**示例**:
```javascript
✅ 正确
const user = { name: 'John', age: 30 };

const users = [
  { id: 1, name: 'Alice' },
  { id: 2, name: 'Bob' }
];

❌ 错误
const user = {name:'John',age:30};  // 缺少空格
```

---

## 三、TypeScript 类型注解

### 3.1 何时使用类型注解

**建议使用**:
- 函数参数和返回值
- 公共 API
- 复杂的数据结构

**可以省略**:
- 类型推断明显的情况

**示例**:
```typescript
✅ 使用类型注解
interface User {
  id: number;
  name: string;
  email: string;
}

function getUser(id: number): User | null {
  return users.find(u => u.id === id) || null;
}

✅ 类型推断
const count = 10;  // 自动推断为 number
const names = ['Alice', 'Bob'];  // 自动推断为 string[]
```

### 3.2 常用类型

**示例**:
```typescript
// 基础类型
const name: string = 'John';
const age: number = 30;
const isActive: boolean = true;

// 数组
const ids: number[] = [1, 2, 3];
const users: User[] = [];

// 联合类型
type Status = 'pending' | 'approved' | 'rejected';
const status: Status = 'pending';

// 可选属性
interface UserProfile {
  name: string;
  email?: string;  // 可选
}

// 函数类型
type Callback = (id: number) => void;
```

---

## 四、React 最佳实践

### 4.1 组件设计

**规则**:
- 优先使用函数组件和 Hooks
- 保持组件简单单一职责
- 提取可复用逻辑为自定义 Hook

**示例**:
```jsx
✅ 函数组件 + Hooks
function UserProfile({ userId }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchUser(userId).then(data => {
      setUser(data);
      setLoading(false);
    });
  }, [userId]);

  if (loading) return <div>Loading...</div>;
  return <div>{user.name}</div>;
}
```

### 4.2 Props 解构

**示例**:
```jsx
✅ 解构 Props
function UserCard({ name, email, avatar }) {
  return (
    <div>
      <img src={avatar} alt={name} />
      <h3>{name}</h3>
      <p>{email}</p>
    </div>
  );
}

❌ 不解构
function UserCard(props) {
  return (
    <div>
      <img src={props.avatar} alt={props.name} />
      <h3>{props.name}</h3>
    </div>
  );
}
```

---

## 五、状态管理

### 5.1 useState 使用

**示例**:
```jsx
✅ 正确
const [count, setCount] = useState(0);
const [user, setUser] = useState(null);

// 基于前一个状态更新
setCount(prev => prev + 1);

❌ 错误
const [count, setCount] = useState(0);
setCount(count + 1);  // 可能导致状态不一致
```

### 5.2 useEffect 使用

**规则**:
- 明确依赖数组
- 清理副作用

**示例**:
```jsx
✅ 正确
useEffect(() => {
  const timer = setInterval(() => {
    console.log('tick');
  }, 1000);

  return () => clearInterval(timer);  // 清理
}, []);  // 空数组表示只运行一次
```

---

## 六、常见陷阱

### 6.1 避免在循环中使用索引作为 key

**示例**:
```jsx
✅ 使用唯一 ID
{users.map(user => (
  <UserCard key={user.id} user={user} />
))}

❌ 使用索引
{users.map((user, index) => (
  <UserCard key={index} user={user} />
))}
```

### 6.2 避免直接修改状态

**示例**:
```jsx
✅ 创建新对象
setUser({ ...user, name: 'New Name' });
setItems([...items, newItem]);

❌ 直接修改
user.name = 'New Name';
setUser(user);
```

---

## 七、工具和配置

### 7.1 推荐工具

**代码格式化**:
- Prettier
- ESLint

**类型检查**:
- TypeScript
- Flow

**测试**:
- Jest
- React Testing Library
- Vitest

### 7.2 配置示例

**.eslintrc.json**:
```json
{
  "extends": ["airbnb", "prettier"],
  "rules": {
    "react/prop-types": "off",
    "no-console": "warn"
  }
}
```

---

## 八、E2E 测试最佳实践

### 8.1 何时需要 E2E 测试

**必须使用 E2E 测试**：
- 关键用户流程（登录、支付、注册）
- 跨页面的复杂交互
- 涉及多个系统集成的功能

**可以省略 E2E 测试**：
- 简单的展示页面
- 纯 UI 组件（用组件测试代替）
- 内部工具或原型

### 8.2 Playwright 使用指南

**推荐使用 Playwright**：
- 跨浏览器支持（Chrome、Firefox、Safari）
- 自动等待机制
- 强大的调试工具

**基本示例**：
```javascript
import { test, expect } from '@playwright/test';

test('用户登录流程', async ({ page }) => {
  // 访问登录页
  await page.goto('https://example.com/login');

  // 填写表单
  await page.fill('input[name="email"]', 'user@example.com');
  await page.fill('input[name="password"]', 'password123');

  // 点击登录按钮
  await page.click('button[type="submit"]');

  // 验证跳转到首页
  await expect(page).toHaveURL('https://example.com/dashboard');
  await expect(page.locator('h1')).toContainText('Welcome');
});
```

---

## 九、总结

**核心要点**:
1. 使用 TypeScript 提升类型安全
2. 优先使用函数组件和 Hooks
3. 保持组件简单单一职责
4. 避免常见陷阱（key、状态修改）

**与其他规范的关系**:
- 基于 `ai/code_style_guide.md` 的通用规范
- 补充前端特定的最佳实践
- 配合 `ai/coder_quality_guide.md` 使用

---

> 本规范适用于现代前端项目（React/Vue/TypeScript）
> 更多通用规范请参考 `ai/code_style_guide.md`
