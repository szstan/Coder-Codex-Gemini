# 环境准备检查清单

> **目标**：确保项目启动前所有必要的开发环境已正确配置，避免开发过程中的环境问题。

---

## 一、通用环境检查

### 1.1 必备工具

**所有项目必须安装**：

| 工具 | 用途 | 验证命令 | 安装指南 |
|------|------|---------|---------|
| **Git** | 版本控制 | `git --version` | https://git-scm.com/ |
| **代码编辑器** | VSCode / PyCharm / IntelliJ | 打开编辑器 | https://code.visualstudio.com/ |
| **Claude Code** | AI 辅助开发 | `claude --version` | https://docs.anthropic.com/claude-code |

### 1.2 CCG 工具链

**CCG 项目必须配置**：

| 工具 | 用途 | 验证命令 | 配置文件 |
|------|------|---------|---------|
| **CCG MCP Server** | Coder/Codex/Gemini 协作 | 检查 MCP 配置 | `~/.ccg-mcp/config.toml` |
| **Coder CLI** | 代码执行者 | `coder --version` | 配置 API Token |
| **Codex CLI** | 代码审核者 | `codex --version` | 配置 OpenAI API Key |
| **Gemini CLI** | 高阶顾问（可选） | `gemini --version` | 配置 Google API Key |

---

## 二、语言特定环境

### 2.1 Python 项目

**必备工具**：

| 工具 | 版本要求 | 验证命令 | 安装指南 |
|------|---------|---------|---------|
| **Python** | ≥ 3.8 | `python --version` | https://www.python.org/ |
| **pip** | 最新版 | `pip --version` | 随 Python 安装 |
| **virtualenv** | 最新版 | `virtualenv --version` | `pip install virtualenv` |

**代码质量工具**：
```bash
# 安装代码格式化和检查工具
pip install black flake8 pylint mypy

# 验证安装
black --version
flake8 --version
pylint --version
mypy --version
```

**测试工具**：
```bash
# 安装测试框架
pip install pytest pytest-cov pytest-mock

# 验证安装
pytest --version
```

**环境配置**：
```bash
# 1. 创建虚拟环境
python -m venv venv

# 2. 激活虚拟环境
# Windows
venv\Scripts\activate
# Linux/Mac
source venv/bin/activate

# 3. 安装项目依赖
pip install -r requirements.txt

# 4. 验证环境
python -c "import sys; print(sys.executable)"
```

### 2.2 Java 项目

**必备工具**：

| 工具 | 版本要求 | 验证命令 | 安装指南 |
|------|---------|---------|---------|
| **JDK** | ≥ 11 | `java -version` | https://adoptium.net/ |
| **Maven** | ≥ 3.6 | `mvn -version` | https://maven.apache.org/ |
| **Gradle** | ≥ 7.0 | `gradle -version` | https://gradle.org/ |

**代码质量工具**：
```bash
# Maven 项目
mvn dependency:resolve-plugins

# Gradle 项目
gradle dependencies
```

**测试工具**：
```bash
# 验证 JUnit 配置
mvn test -DskipTests
```

### 2.3 前端项目

**必备工具**：

| 工具 | 版本要求 | 验证命令 | 安装指南 |
|------|---------|---------|---------|
| **Node.js** | ≥ 16 | `node --version` | https://nodejs.org/ |
| **npm** | ≥ 8 | `npm --version` | 随 Node.js 安装 |
| **pnpm** | 最新版（推荐） | `pnpm --version` | `npm install -g pnpm` |

**代码质量工具**：
```bash
# 安装 ESLint 和 Prettier
npm install -g eslint prettier

# 验证安装
eslint --version
prettier --version
```

**测试工具**：
```bash
# 安装测试框架
npm install -g jest @playwright/test

# 验证安装
jest --version
playwright --version
```

**环境配置**：
```bash
# 1. 安装项目依赖
npm install
# 或使用 pnpm
pnpm install

# 2. 验证环境
npm run build
```

---

## 三、项目特定配置

### 3.1 环境变量

**创建 `.env` 文件**：
```bash
# .env.example（提交到 Git）
DATABASE_URL=postgresql://localhost:5432/mydb
API_KEY=your-api-key-here
DEBUG=false

# .env（本地使用，不提交到 Git）
DATABASE_URL=postgresql://localhost:5432/mydb_dev
API_KEY=actual-api-key
DEBUG=true
```

**验证环境变量**：
```bash
# Python
python -c "import os; print(os.getenv('DATABASE_URL'))"

# Node.js
node -e "console.log(process.env.DATABASE_URL)"
```

### 3.2 数据库配置

**PostgreSQL 示例**：
```bash
# 1. 安装 PostgreSQL
# Windows: https://www.postgresql.org/download/windows/
# Mac: brew install postgresql
# Linux: sudo apt install postgresql

# 2. 启动数据库
# Windows: 服务管理器启动
# Mac/Linux: sudo service postgresql start

# 3. 创建数据库
psql -U postgres -c "CREATE DATABASE mydb_dev;"

# 4. 验证连接
psql -U postgres -d mydb_dev -c "SELECT version();"
```

### 3.3 Docker 配置（可选）

**Docker Compose 示例**：
```yaml
# docker-compose.yml
version: '3.8'
services:
  db:
    image: postgres:15
    environment:
      POSTGRES_DB: mydb_dev
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
    ports:
      - "5432:5432"
```

**启动服务**：
```bash
# 启动所有服务
docker-compose up -d

# 验证服务
docker-compose ps
```

---

## 四、CCG 特定配置

### 4.1 CCG MCP Server 配置

**配置文件位置**：`~/.ccg-mcp/config.toml`

**配置示例**：
```toml
[coder]
api_token = "your-coder-api-token"
base_url = "https://open.bigmodel.cn/api/anthropic"
model = "glm-4.7"

[codex]
api_key = "your-openai-api-key"
model = "gpt-4"

[gemini]
api_key = "your-google-api-key"
model = "gemini-3-pro-preview"
```

**验证配置**：
```bash
# 检查配置文件是否存在
cat ~/.ccg-mcp/config.toml

# 测试 Coder 连接
# （通过 Claude Code 调用 MCP 工具验证）
```

### 4.2 Claude Code 配置

**全局配置**：`~/.claude/CLAUDE.md`
- 确保包含 CCG 协作规则
- 确保包含 Skill 前置条件

**项目配置**：`<project>/CLAUDE.md`
- 确保包含项目特定的开发规范
- 确保包含 AI 治理框架引用

---

## 五、环境验证脚本

### 5.1 Python 项目验证脚本

创建 `scripts/verify_environment.py`：
```python
#!/usr/bin/env python3
"""环境验证脚本"""

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
        sys.exit(1)
    else:
        print("✅ 环境检查通过！")
        sys.exit(0)

if __name__ == "__main__":
    main()
```

**运行验证**：
```bash
python scripts/verify_environment.py
```

### 5.2 Node.js 项目验证脚本

创建 `scripts/verify-environment.js`：
```javascript
#!/usr/bin/env node
/**
 * 环境验证脚本
 */

const { execSync } = require('child_process');

function checkCommand(cmd) {
  try {
    const version = execSync(`${cmd} --version`, { encoding: 'utf-8' }).trim();
    return { success: true, version };
  } catch (error) {
    return { success: false, version: '' };
  }
}

function main() {
  const checks = [
    ['node', 'Node.js'],
    ['npm', 'npm'],
    ['git', 'Git'],
    ['jest', 'Jest'],
    ['eslint', 'ESLint'],
    ['prettier', 'Prettier'],
  ];

  console.log('🔍 环境检查开始...\n');

  const failed = [];
  for (const [cmd, name] of checks) {
    const { success, version } = checkCommand(cmd);
    if (success) {
      console.log(`✅ ${name}: ${version.split(' ')[0]}`);
    } else {
      console.log(`❌ ${name}: 未安装`);
      failed.push(name);
    }
  }

  console.log('\n' + '='.repeat(50));
  if (failed.length > 0) {
    console.log(`❌ 环境检查失败，缺少以下工具：${failed.join(', ')}`);
    process.exit(1);
  } else {
    console.log('✅ 环境检查通过！');
    process.exit(0);
  }
}

main();
```

---

## 六、项目启动检查清单

### 6.1 首次克隆项目后

**必须执行的步骤**：

```bash
# 1. 克隆项目
git clone <repository-url>
cd <project-name>

# 2. 检查环境
python scripts/verify_environment.py  # Python 项目
node scripts/verify-environment.js    # Node.js 项目

# 3. 安装依赖
pip install -r requirements.txt       # Python
npm install                           # Node.js

# 4. 配置环境变量
cp .env.example .env
# 编辑 .env 文件，填入实际配置

# 5. 初始化数据库（如需要）
python manage.py migrate              # Django
npm run db:migrate                    # Node.js

# 6. 运行测试
pytest tests/                         # Python
npm test                              # Node.js

# 7. 启动开发服务器
python manage.py runserver            # Django
npm run dev                           # Node.js
```

### 6.2 每日开发前

**推荐执行的步骤**：

```bash
# 1. 拉取最新代码
git pull origin develop

# 2. 更新依赖（如有变化）
pip install -r requirements.txt       # Python
npm install                           # Node.js

# 3. 运行测试（确保基线正常）
pytest tests/                         # Python
npm test                              # Node.js

# 4. 启动开发服务器
python manage.py runserver            # Django
npm run dev                           # Node.js
```

---

## 七、常见问题排查

### 7.1 Python 环境问题

**问题 1：找不到模块**
```bash
# 症状
ModuleNotFoundError: No module named 'xxx'

# 解决方案
pip install xxx
# 或重新安装所有依赖
pip install -r requirements.txt
```

**问题 2：虚拟环境未激活**
```bash
# 症状
使用了系统 Python 而不是虚拟环境

# 解决方案
# Windows
venv\Scripts\activate
# Linux/Mac
source venv/bin/activate
```

### 7.2 Node.js 环境问题

**问题 1：依赖安装失败**
```bash
# 症状
npm ERR! code EACCES

# 解决方案
# 清理缓存
npm cache clean --force
# 删除 node_modules 重新安装
rm -rf node_modules package-lock.json
npm install
```

**问题 2：Node 版本不兼容**
```bash
# 症状
engine "node" is incompatible

# 解决方案
# 使用 nvm 切换 Node 版本
nvm install 16
nvm use 16
```

---

## 八、总结

### 8.1 核心要点

1. **项目启动前必须验证环境**：运行环境验证脚本
2. **配置 CCG 工具链**：Coder、Codex、Gemini
3. **安装语言特定工具**：Python/Java/Node.js + 测试框架
4. **配置环境变量**：`.env` 文件
5. **运行测试验证**：确保基线正常

### 8.2 快速参考

| 检查项 | 命令 | 预期结果 |
|--------|------|---------|
| Python 版本 | `python --version` | ≥ 3.8 |
| Node.js 版本 | `node --version` | ≥ 16 |
| Git 版本 | `git --version` | 任意版本 |
| 测试工具 | `pytest --version` / `npm test` | 正常输出 |
| CCG 配置 | `cat ~/.ccg-mcp/config.toml` | 配置文件存在 |

---

**文档版本**: v1.0
**最后更新**: 2026-01-17
**维护者**: CCG Team
