# CCG One-Click Setup Script for Windows
# This script automates the setup of Coder-Codex-Gemini MCP server

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

function Write-Step {
    param([string]$Message)
    Write-Host "`n[*] $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

# ==============================================================================
# Step 1: Check dependencies
# ==============================================================================
Write-Step "Step 1: Checking dependencies..."

# Check and install uv
$uvInstalled = $false
try {
    $null = uv --version 2>&1
    $uvInstalled = $true
    Write-Success "uv is installed"
} catch {
    Write-Warning "uv is not installed, installing automatically..."
    try {
        powershell -c "irm https://astral.sh/uv/install.ps1 | iex"
        # Refresh PATH
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        $null = uv --version 2>&1
        $uvInstalled = $true
        Write-Success "uv installed successfully"
    } catch {
        Write-Error "Failed to install uv automatically"
        Write-Host "Please install uv manually: https://github.com/astral-sh/uv" -ForegroundColor Yellow
        exit 1
    }
}

# Check claude CLI
$claudeInstalled = $false
try {
    $null = claude --version 2>&1
    $claudeInstalled = $true
    Write-Success "claude CLI is installed"
} catch {
    Write-Error "claude CLI is not installed"
    Write-Host "Please install Claude Code CLI first: https://docs.anthropic.com/en/docs/claude-code" -ForegroundColor Yellow
    exit 1
}

# ==============================================================================
# Step 2: Install project dependencies
# ==============================================================================
Write-Step "Step 2: Installing project dependencies..."

try {
    uv sync
    Write-Success "Project dependencies installed"
} catch {
    Write-Error "Failed to install dependencies"
    exit 1
}

# ==============================================================================
# Step 3: Register MCP server
# ==============================================================================
Write-Step "Step 3: Registering MCP server..."

try {
    # Try to remove existing ccg MCP server if it exists
    $null = claude mcp remove ccg -s user 2>&1
    Write-Warning "Removed existing ccg MCP server"
} catch {
    # Ignore if it doesn't exist
}

try {
    $pwd = (Get-Location).Path
    claude mcp add ccg -s user --transport stdio -- uv run --directory "$pwd" ccg-mcp
    Write-Success "MCP server registered"
} catch {
    Write-Error "Failed to register MCP server"
    exit 1
}

# ==============================================================================
# Step 4: Install Skills
# ==============================================================================
Write-Step "Step 4: Installing Skills..."

$skillsDir = "$env:USERPROFILE\.claude\skills"
$ccgWorkflowSource = "skills\ccg-workflow"
$geminiCollabSource = "skills\gemini-collaboration"

try {
    # Create skills directory if it doesn't exist
    if (!(Test-Path $skillsDir)) {
        New-Item -ItemType Directory -Path $skillsDir -Force | Out-Null
        Write-Success "Created skills directory: $skillsDir"
    }

    # Copy ccg-workflow skill
    if (Test-Path $ccgWorkflowSource) {
        $dest = "$skillsDir\ccg-workflow"
        if (Test-Path $dest) {
            Remove-Item -Recurse -Force $dest
        }
        Copy-Item -Recurse $ccgWorkflowSource $dest
        Write-Success "Installed ccg-workflow skill"
    } else {
        Write-Warning "ccg-workflow skill not found, skipping"
    }

    # Copy gemini-collaboration skill
    if (Test-Path $geminiCollabSource) {
        $dest = "$skillsDir\gemini-collaboration"
        if (Test-Path $dest) {
            Remove-Item -Recurse -Force $dest
        }
        Copy-Item -Recurse $geminiCollabSource $dest
        Write-Success "Installed gemini-collaboration skill"
    } else {
        Write-Warning "gemini-collaboration skill not found, skipping"
    }
} catch {
    Write-Error "Failed to install skills"
    exit 1
}

# ==============================================================================
# Step 5: Configure global CLAUDE.md
# ==============================================================================
Write-Step "Step 5: Configuring global CLAUDE.md..."

$claudeMdPath = "$env:USERPROFILE\.claude\CLAUDE.md"
$ccgMarker = "# CCG Configuration"

$ccgConfig = @"

$ccgMarker

# 全局协议

## 强制规则

- **默认协作**：所有代码/文档改动任务，**必须**委托 Coder 执行，阶段性完成后**必须**调用 Codex 审核
- **跳过需确认**：若判断无需协作，**必须立即暂停**并报告：
  > "这是一个简单的[描述]任务，我判断无需调用 Coder/Codex。是否同意？等待您的确认。"
- **违规即终止**：未经确认跳过 Coder 执行或 Codex 审核 = **流程违规**
- **Skill 优先**：调用 MCP 工具前，**必须已阅读对应 Skill**（`ccg-workflow`、`gemini-collaboration`）以了解最佳实践
- **会话复用**：始终保存 `SESSION_ID` 保持上下文

---

# AI 协作体系

**Claude 是最终决策者**，所有 AI 意见仅供参考，需批判性思考后做出最优决策。

## 角色分工

| 角色 | 定位 | 用途 | sandbox | 重试 |
|------|------|------|---------|------|
| **Coder** | 代码执行者 | 生成/修改代码、批量任务 | workspace-write | 默认不重试 |
| **Codex** | 代码审核者/高阶顾问 | 架构设计、质量把关、Review | read-only | 默认 1 次 |
| **Gemini** | 高阶顾问（按需） | 架构设计、第二意见、前端/UI | workspace-write (yolo) | 默认 1 次 |

## 核心流程

1. **Coder 执行**：所有改动任务委托 Coder 处理
2. **Claude 验收**：Coder 完成后快速检查，有误则 Claude 自行修复
3. **Codex 审核**：阶段性开发完成后调用 review，有误委托 Coder 修复，持续迭代直至通过

## 编码前准备（复杂任务）

1. 搜索受影响的符号/入口点
2. 列出需要修改的文件清单
3. 复杂问题可先与 Codex 或 Gemini 沟通方案

## Gemini 触发场景

- **用户明确要求**：用户指定使用 Gemini
- **Claude 自主调用**：设计前端/UI、需要第二意见或独立视角时
"@

try {
    if (!(Test-Path $claudeMdPath)) {
        # Create new file
        Set-Content -Path $claudeMdPath -Value $ccgConfig
        Write-Success "Created global CLAUDE.md"
    } else {
        # Check if CCG config already exists
        $content = Get-Content $claudeMdPath -Raw
        if ($content -match [regex]::Escape($ccgMarker)) {
            Write-Warning "CCG configuration already exists in CLAUDE.md, skipping"
        } else {
            # Append CCG config
            Add-Content -Path $claudeMdPath -Value $ccgConfig
            Write-Success "Appended CCG configuration to CLAUDE.md"
        }
    }
} catch {
    Write-Error "Failed to configure global CLAUDE.md"
    exit 1
}

# ==============================================================================
# Step 6: Configure Coder
# ==============================================================================
Write-Step "Step 6: Configuring Coder..."

$configDir = "$env:USERPROFILE\.ccg-mcp"
$configPath = "$configDir\config.toml"

try {
    # Create config directory if it doesn't exist
    if (!(Test-Path $configDir)) {
        New-Item -ItemType Directory -Path $configDir -Force | Out-Null
    }

    # Prompt for API Token (hidden input)
    $apiToken = Read-Host "Enter your API Token" -MaskInput
    if ([string]::IsNullOrWhiteSpace($apiToken)) {
        Write-Error "API Token is required"
        exit 1
    }

    # Prompt for Base URL (optional)
    $baseUrl = Read-Host "Enter Base URL (default: https://open.bigmodel.cn/api/anthropic)"
    if ([string]::IsNullOrWhiteSpace($baseUrl)) {
        $baseUrl = "https://open.bigmodel.cn/api/anthropic"
    }

    # Prompt for Model (optional)
    $model = Read-Host "Enter Model (default: glm-4.7)"
    if ([string]::IsNullOrWhiteSpace($model)) {
        $model = "glm-4.7"
    }

    # Generate config.toml
    $configContent = @"
[coder]
api_token = "$apiToken"
base_url = "$baseUrl"
model = "$model"
"@

    Set-Content -Path $configPath -Value $configContent

    # Set file permissions - only current user can read/write
    $acl = Get-Acl $configPath
    $acl.SetAccessRuleProtection($true, $false)
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($env:USERNAME, "FullControl", "Allow")
    $acl.SetAccessRule($rule)
    Set-Acl $configPath $acl

    Write-Success "Coder configuration saved to $configPath"

} catch {
    Write-Error "Failed to configure Coder"
    exit 1
}

# ==============================================================================
# Done!
# ==============================================================================
Write-Host "`n============================================================" -ForegroundColor Green
Write-Success "CCG setup completed successfully!"
Write-Host "============================================================`n" -ForegroundColor Green

Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Restart Claude Code CLI" -ForegroundColor White
Write-Host "  2. Verify MCP server: claude mcp list" -ForegroundColor White
Write-Host "  3. Check available skills: claude skills list" -ForegroundColor White
Write-Host ""
