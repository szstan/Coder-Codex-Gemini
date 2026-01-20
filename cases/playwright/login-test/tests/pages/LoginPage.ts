// tests/pages/LoginPage.ts
// Page Object for Login Page

import { Page, Locator } from '@playwright/test';

export class LoginPage {
  readonly page: Page;
  readonly emailInput: Locator;
  readonly passwordInput: Locator;
  readonly rememberMeCheckbox: Locator;
  readonly loginButton: Locator;
  readonly errorMessage: Locator;
  readonly emailError: Locator;
  readonly passwordError: Locator;

  constructor(page: Page) {
    this.page = page;

    // 使用 data-testid 选择器（最稳定）
    this.emailInput = page.locator('[data-testid="email-input"]');
    this.passwordInput = page.locator('[data-testid="password-input"]');
    this.rememberMeCheckbox = page.locator('[data-testid="remember-me-checkbox"]');
    this.loginButton = page.locator('[data-testid="login-button"]');
    this.errorMessage = page.locator('[data-testid="error-message"]');
    this.emailError = page.locator('[data-testid="email-error"]');
    this.passwordError = page.locator('[data-testid="password-error"]');
  }

  /**
   * 导航到登录页面
   */
  async goto() {
    await this.page.goto('https://example.com/login');
  }

  /**
   * 执行登录操作
   * @param email 邮箱地址
   * @param password 密码
   * @param rememberMe 是否记住我
   */
  async login(email: string, password: string, rememberMe: boolean = false) {
    await this.emailInput.fill(email);
    await this.passwordInput.fill(password);

    if (rememberMe) {
      await this.rememberMeCheckbox.check();
    }

    await this.loginButton.click();
  }

  /**
   * 获取错误提示信息
   */
  async getErrorMessage(): Promise<string> {
    return await this.errorMessage.textContent() || '';
  }

  /**
   * 检查是否显示邮箱错误
   */
  async hasEmailError(): Promise<boolean> {
    return await this.emailError.isVisible();
  }

  /**
   * 检查是否显示密码错误
   */
  async hasPasswordError(): Promise<boolean> {
    return await this.passwordError.isVisible();
  }
}
