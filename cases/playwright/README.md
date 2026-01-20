# Playwright 测试案例

> **目录**: cases/playwright/
> **用途**: 展示如何使用 Playwright MCP Server 和 CCG 协作生成 E2E 测试

---

## 📁 案例列表

### 1. 登录功能测试 (login-test/)

**场景**: 为 Web 应用的登录功能生成完整的 E2E 测试

**包含内容**:
- 测试需求文档
- Page Object Model 实现
- 测试用例代码
- Codex 审核报告

**技术栈**: React + TypeScript + Playwright

**学习要点**:
- 如何使用 Page Object Model
- 如何编写稳定的选择器
- 如何处理异步操作
- 如何添加断言和错误处理

---

## 🎯 使用方式

### 方式 1: 学习参考

直接阅读案例代码，了解最佳实践。

### 方式 2: 实际运行

```bash
cd cases/playwright/login-test
npm install
npx playwright test
```

### 方式 3: 使用 CCG 生成

参考案例中的需求文档，使用 `/ccg-e2e-test` Skill 生成类似的测试。

---

## 📚 相关文档

- [Playwright 使用指南](../../docs/PLAYWRIGHT_GUIDE.md)
- [E2E 测试生成 Skill](../../skills/ccg-e2e-test/SKILL.md)
- [测试策略文档](../../ai/testing_strategy.md)
