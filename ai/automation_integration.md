# 自动化检查集成指南

> **目标**：定义如何在 CCG 工作流中集成自动化检查工具，提高代码质量和开发效率。

---

## 一、自动化检查的价值

### 1.1 为什么需要自动化检查？

**自动化检查的优势**：
- ✅ **快速反馈**：秒级发现问题，而不是等待人工审查
- ✅ **一致性**：标准统一，不受人为因素影响
- ✅ **节省时间**：自动化处理重复性检查
- ✅ **提前发现问题**：在提交前发现问题，成本最低

### 1.2 自动化检查的类型

| 检查类型 | 工具示例 | 检查内容 | 执行时机 |
|---------|---------|---------|---------|
| **代码格式化** | Black, Prettier | 代码格式、缩进、空行 | Coder 执行后 |
| **代码风格检查** | Flake8, ESLint | 命名规范、代码复杂度 | Coder 执行后 |
| **类型检查** | mypy, TypeScript | 类型错误、类型不匹配 | Coder 执行后 |
| **测试运行** | pytest, Jest | 功能正确性、覆盖率 | Claude 验收后 |
| **安全扫描** | Bandit, npm audit | 安全漏洞、依赖风险 | 测试通过后 |

---

## 二、集成点设计

### 2.1 在 CCG 工作流中的集成点

```
Coder 执行
    ↓
【自动化检查 1：代码格式化】← 自动修复
    ↓
【自动化检查 2：代码风格检查】← 报告问题
    ↓
【自动化检查 3：类型检查】← 报告问题
    ↓
Claude 验收
    ↓
【自动化检查 4：测试运行】← 必须通过
    ↓
【自动化检查 5：覆盖率检查】← 必须达标
    ↓
Codex 审核
    ↓
【自动化检查 6：安全扫描】← 报告风险
    ↓
Git 提交
```

### 2.2 集成策略

| 集成点 | 策略 | 失败处理 |
|--------|------|---------|
| **Coder 执行后** | 自动运行格式化和风格检查 | 自动修复或报告给 Claude |
| **Claude 验收后** | 自动运行测试和覆盖率检查 | 测试失败则 Claude 修复 |
| **Codex 审核后** | 自动运行安全扫描 | 报告风险，由 Claude 决策 |

---

## 三、Python 项目自动化检查

### 3.1 工具配置

**安装工具**：
```bash
pip install black flake8 mypy pytest pytest-cov bandit
```

**配置文件**：

`pyproject.toml`:
```toml
[tool.black]
line-length = 100
target-version = ['py311']

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py"]
python_classes = ["Test*"]
python_functions = ["test_*"]
addopts = "--cov=src --cov-report=term-missing --cov-fail-under=80"

[tool.mypy]
python_version = "3.11"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true
```

`.flake8`:
```ini
[flake8]
max-line-length = 100
exclude = .git,__pycache__,venv
ignore = E203,W503
```

### 3.2 自动化脚本

创建 `scripts/auto_check.sh`:
```bash
#!/bin/bash
set -e

echo "🔍 开始自动化检查..."

# 1. 代码格式化
echo "📝 运行代码格式化..."
black src/ tests/
echo "✅ 代码格式化完成"

# 2. 代码风格检查
echo "🎨 运行代码风格检查..."
flake8 src/ tests/
echo "✅ 代码风格检查通过"

# 3. 类型检查
echo "🔤 运行类型检查..."
mypy src/
echo "✅ 类型检查通过"

# 4. 运行测试
echo "🧪 运行测试..."
pytest tests/ --cov=src --cov-report=term-missing
echo "✅ 测试通过"

# 5. 安全扫描
echo "🔒 运行安全扫描..."
bandit -r src/ -f json -o bandit-report.json || true
echo "✅ 安全扫描完成"

echo "✅ 所有检查通过！"
```

### 3.3 集成到 CCG 工作流

**在 Coder 执行后自动运行**：
```python
# 伪代码
def after_coder_execution():
    # 1. 自动格式化
    run_command("black src/ tests/")

    # 2. 检查代码风格
    result = run_command("flake8 src/ tests/")
    if result.failed:
        report_to_claude(result.errors)

    # 3. 检查类型
    result = run_command("mypy src/")
    if result.failed:
        report_to_claude(result.errors)
```

---

## 四、Node.js 项目自动化检查

### 4.1 工具配置

**安装工具**：
```bash
npm install -D prettier eslint @typescript-eslint/parser jest @playwright/test
```

**配置文件**：

`.prettierrc`:
```json
{
  "semi": true,
  "singleQuote": true,
  "tabWidth": 2,
  "printWidth": 100
}
```

`.eslintrc.json`:
```json
{
  "extends": ["eslint:recommended", "plugin:@typescript-eslint/recommended"],
  "parser": "@typescript-eslint/parser",
  "rules": {
    "no-console": "warn",
    "no-unused-vars": "error"
  }
}
```

`jest.config.js`:
```javascript
module.exports = {
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80
    }
  }
};
```

### 4.2 自动化脚本

创建 `scripts/auto-check.sh`:
```bash
#!/bin/bash
set -e

echo "🔍 开始自动化检查..."

# 1. 代码格式化
echo "📝 运行代码格式化..."
npx prettier --write src/ tests/
echo "✅ 代码格式化完成"

# 2. 代码风格检查
echo "🎨 运行代码风格检查..."
npx eslint src/ tests/
echo "✅ 代码风格检查通过"

# 3. 运行测试
echo "🧪 运行测试..."
npm test -- --coverage
echo "✅ 测试通过"

# 4. 安全扫描
echo "🔒 运行安全扫描..."
npm audit --json > audit-report.json || true
echo "✅ 安全扫描完成"

echo "✅ 所有检查通过！"
```

---

## 五、Java 项目自动化检查

### 5.1 工具配置

**Maven 配置** (`pom.xml`):
```xml
<build>
  <plugins>
    <!-- Google Java Format -->
    <plugin>
      <groupId>com.spotify.fmt</groupId>
      <artifactId>fmt-maven-plugin</artifactId>
      <version>2.19</version>
      <executions>
        <execution>
          <goals>
            <goal>format</goal>
          </goals>
        </execution>
      </executions>
    </plugin>

    <!-- SpotBugs -->
    <plugin>
      <groupId>com.github.spotbugs</groupId>
      <artifactId>spotbugs-maven-plugin</artifactId>
      <version>4.7.3.0</version>
    </plugin>

    <!-- JaCoCo Coverage -->
    <plugin>
      <groupId>org.jacoco</groupId>
      <artifactId>jacoco-maven-plugin</artifactId>
      <version>0.8.10</version>
      <configuration>
        <rules>
          <rule>
            <element>BUNDLE</element>
            <limits>
              <limit>
                <counter>LINE</counter>
                <value>COVEREDRATIO</value>
                <minimum>0.80</minimum>
              </limit>
            </limits>
          </rule>
        </rules>
      </configuration>
    </plugin>
  </plugins>
</build>
```

### 5.2 自动化脚本

创建 `scripts/auto-check.sh`:
```bash
#!/bin/bash
set -e

echo "🔍 开始自动化检查..."

# 1. 代码格式化
echo "📝 运行代码格式化..."
mvn fmt:format
echo "✅ 代码格式化完成"

# 2. 代码风格检查
echo "🎨 运行代码风格检查..."
mvn spotbugs:check
echo "✅ 代码风格检查通过"

# 3. 运行测试
echo "🧪 运行测试..."
mvn test jacoco:report jacoco:check
echo "✅ 测试通过"

echo "✅ 所有检查通过！"
```

---

## 六、环境准备强制执行

### 6.1 项目启动时自动检查

创建 `scripts/verify_environment.py`:
```python
#!/usr/bin/env python3
"""环境验证脚本 - 在项目启动时自动运行"""

import sys
import subprocess
from typing import List, Tuple

def check_command(cmd: str, min_version: str = None) -> Tuple[bool, str]:
    """检查命令是否可用"""
    try:
        result = subprocess.run(
            [cmd, "--version"],
            capture_output=True,
            text=True,
            timeout=5
        )
        version = result.stdout.strip() or result.stderr.strip()
        return True, version
    except (FileNotFoundError, subprocess.TimeoutExpired):
        return False, ""

def main():
    """主函数"""
    checks = [
        ("python", "Python 3.8+"),
        ("pip", "pip"),
        ("git", "Git"),
        ("pytest", "pytest"),
        ("black", "black"),
        ("flake8", "flake8"),
    ]

    print("🔍 环境检查开始...\n")

    failed = []
    for cmd, name in checks:
        success, version = check_command(cmd)
        if success:
            print(f"✅ {name}: {version.split()[0]}")
        else:
            print(f"❌ {name}: 未安装")
            failed.append(name)

    print("\n" + "="*50)
    if failed:
        print(f"❌ 环境检查失败，缺少以下工具：{', '.join(failed)}")
        print("\n请运行以下命令安装：")
        print(f"pip install {' '.join(failed)}")
        sys.exit(1)
    else:
        print("✅ 环境检查通过！")
        sys.exit(0)

if __name__ == "__main__":
    main()
```

### 6.2 在 CCG 工作流中强制执行

**在项目启动时自动运行**：
```python
# 伪代码
def ccg_workflow_start():
    # 第一步：强制环境检查
    result = run_command("python scripts/verify_environment.py")

    if result.failed:
        return {
            "status": "环境检查失败",
            "missing": result.missing_tools,
            "install_command": result.install_command
        }

    # 第二步：继续正常流程
    # ...
```

---

## 七、总结

### 7.1 核心要点

1. **自动化检查提高效率**：快速反馈，一致性标准
2. **多个集成点**：Coder 执行后、Claude 验收后、Codex 审核后
3. **语言特定工具**：Python (Black, Flake8), Node.js (Prettier, ESLint), Java (Google Java Format, SpotBugs)
4. **环境准备强制执行**：项目启动时自动检查环境

### 7.2 快速参考

| 检查类型 | Python | Node.js | Java |
|---------|--------|---------|------|
| 格式化 | Black | Prettier | Google Java Format |
| 风格检查 | Flake8 | ESLint | SpotBugs |
| 类型检查 | mypy | TypeScript | - |
| 测试 | pytest | Jest | JUnit |
| 覆盖率 | pytest-cov | Jest | JaCoCo |

---

**文档版本**: v1.0
**最后更新**: 2026-01-17
**维护者**: CCG Team
