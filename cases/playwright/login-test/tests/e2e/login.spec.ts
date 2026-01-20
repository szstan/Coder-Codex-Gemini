// tests/e2e/login.spec.ts
// E2E tests for Login functionality

import { test, expect } from '@playwright/test';
import { LoginPage } from '../pages/LoginPage';

test.describe('Login Functionality', () => {
  let loginPage: LoginPage;

  test.beforeEach(async ({ page }) => {
    loginPage = new LoginPage(page);
    await loginPage.goto();
  });

  test('should login successfully with valid credentials', async ({ page }) => {
    // 执行登录
    await loginPage.login('test@example.com', 'password123');

    // 等待导航到首页
    await page.waitForURL('https://example.com/dashboard');

    // 验证跳转成功
    expect(page.url()).toBe('https://example.com/dashboard');

    // 验证显示用户名
    const username = page.locator('[data-testid="username"]');
    await expect(username).toBeVisible();
    await expect(username).toContainText('test@example.com');
  });

  test('should show error message with invalid password', async ({ page }) => {
    // 使用错误密码登录
    await loginPage.login('test@example.com', 'wrongpassword');

    // 验证仍在登录页面
    expect(page.url()).toContain('/login');

    // 验证显示错误信息
    const errorMessage = await loginPage.getErrorMessage();
    expect(errorMessage).toContain('Invalid email or password');
  });

  test('should show validation errors for empty fields', async ({ page }) => {
    // 不输入任何内容，直接点击登录
    await loginPage.loginButton.click();

    // 验证显示邮箱必填错误
    const hasEmailError = await loginPage.hasEmailError();
    expect(hasEmailError).toBe(true);

    // 验证显示密码必填错误
    const hasPasswordError = await loginPage.hasPasswordError();
    expect(hasPasswordError).toBe(true);

    // 验证仍在登录页面
    expect(page.url()).toContain('/login');
  });

  test('should remember user when "Remember Me" is checked', async ({ page, context }) => {
    // 勾选"记住我"并登录
    await loginPage.login('test@example.com', 'password123', true);

    // 等待导航到首页
    await page.waitForURL('https://example.com/dashboard');

    // 保存存储状态
    const cookies = await context.cookies();
    const rememberMeCookie = cookies.find(c => c.name === 'remember_me');

    // 验证设置了记住我的 cookie
    expect(rememberMeCookie).toBeDefined();
    expect(rememberMeCookie?.value).toBeTruthy();
  });
});
