# 登录功能 E2E 测试案例

> **场景**: 为 Web 应用的登录功能生成完整的 E2E 测试
> **技术栈**: React + TypeScript + Playwright

---

## 📁 文件结构

```
login-test/
├── REQUIREMENT.md              # 测试需求文档
├── CODEX_REVIEW.md            # Codex 审核报告
├── package.json               # 项目依赖
├── playwright.config.ts       # Playwright 配置
└── tests/
    ├── e2e/
    │   └── login.spec.ts      # 测试用例
    └── pages/
        └── LoginPage.ts       # Page Object
```

---

## 🎯 学习要点

### 1. Page Object Model 模式

**LoginPage.ts** 展示了如何封装页面逻辑：
- 定义页面元素（Locator）
- 封装页面操作（方法）
- 提高代码复用性

### 2. 稳定的选择器策略

优先使用 `data-testid` 属性：
```typescript
this.emailInput = page.locator('[data-testid="email-input"]');
```

### 3. 测试隔离

使用 `beforeEach` 确保每个测试独立：
```typescript
test.beforeEach(async ({ page }) => {
  loginPage = new LoginPage(page);
  await loginPage.goto();
});
```

### 4. 异步处理

使用 Playwright 的自动等待：
```typescript
await page.waitForURL('https://example.com/dashboard');
```

---

## 🚀 运行测试

### 安装依赖

```bash
npm install
```

### 运行所有测试

```bash
npm test
```

### 运行测试（有头模式）

```bash
npm run test:headed
```

### 调试模式

```bash
npm run test:debug
```

### UI 模式

```bash
npm run test:ui
```

---

## 📊 测试覆盖

| 场景 | 状态 |
|------|------|
| 正常登录流程 | ✅ |
| 错误密码处理 | ✅ |
| 空字段验证 | ✅ |
| 记住我功能 | ✅ |

---

## 📚 相关文档

- [测试需求文档](REQUIREMENT.md)
- [Codex 审核报告](CODEX_REVIEW.md)
- [Playwright 使用指南](../../../docs/PLAYWRIGHT_GUIDE.md)
- [E2E 测试生成 Skill](../../../skills/ccg-e2e-test/SKILL.md)
