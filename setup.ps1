# CCG One-Click Setup Script for Windows
# This script automates the setup of Coder-Codex-Gemini MCP server

param(
    [switch]$WhatIf,
    [switch]$Help
)

# Show help
if ($Help) {
    Write-Host @"
CCG One-Click Setup Script for Windows

Usage: .\setup.ps1 [-WhatIf] [-Help]

Options:
  -WhatIf    Dry-run mode. Show what would be done without making changes.
  -Help      Show this help message.

Examples:
  .\setup.ps1           # Run the setup
  .\setup.ps1 -WhatIf   # Preview what would be done
"@
    exit 0
}

$DryRun = $WhatIf.IsPresent

# Force UTF-8 encoding for file operations
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$PSDefaultParameterValues['Set-Content:Encoding'] = 'utf8'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

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

function Write-ErrorMsg {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Write-WarningMsg {
    param([string]$Message)
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Write-DryRun {
    param([string]$Message)
    Write-Host "[DRY-RUN] $Message" -ForegroundColor Magenta
}

# ==============================================================================
# Dry-run mode banner
# ==============================================================================
if ($DryRun) {
    Write-Host "`n============================================================" -ForegroundColor Magenta
    Write-Host "  DRY-RUN MODE - No changes will be made" -ForegroundColor Magenta
    Write-Host "============================================================`n" -ForegroundColor Magenta
}

# ==============================================================================
# Step 1: Check dependencies
# ==============================================================================
Write-Step "Step 1: Checking dependencies..."

# Helper function to refresh PATH by merging registry PATH with current session PATH
function Refresh-PathFromRegistry {
    $registryPath = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    $currentPath = $env:Path
    # Merge: add registry paths that are not already in current PATH
    $currentPaths = $currentPath -split ';' | Where-Object { $_ -ne '' }
    $registryPaths = $registryPath -split ';' | Where-Object { $_ -ne '' }
    $newPaths = $registryPaths | Where-Object { $_ -notin $currentPaths }
    if ($newPaths) {
        $env:Path = $currentPath + ";" + ($newPaths -join ';')
    }
}

# Check uv
$uvInstalled = $false
try {
    $null = uv --version 2>&1
    $uvInstalled = $true
    Write-Success "uv is installed"
} catch {
    # Try refreshing PATH from registry (may help find tools installed by npm, scoop, etc.)
    Refresh-PathFromRegistry
    try {
        $null = uv --version 2>&1
        $uvInstalled = $true
        Write-Success "uv is installed"
    } catch {
        if ($DryRun) {
            Write-WarningMsg "uv is not installed"
            Write-DryRun "Would install uv automatically"
        } else {
            Write-WarningMsg "uv is not installed, installing automatically..."
            try {
                powershell -c "irm https://astral.sh/uv/install.ps1 | iex"
                # Refresh PATH again after installation
                Refresh-PathFromRegistry
                $null = uv --version 2>&1
                $uvInstalled = $true
                Write-Success "uv installed successfully"
            } catch {
                Write-ErrorMsg "Failed to install uv automatically"
                Write-Host "Please install uv manually: https://github.com/astral-sh/uv" -ForegroundColor Yellow
                exit 1
            }
        }
    }
}

# Check claude CLI
$claudeInstalled = $false
try {
    $null = claude --version 2>&1
    $claudeInstalled = $true
    Write-Success "claude CLI is installed"
} catch {
    # Try refreshing PATH from registry (may help find tools installed by npm, scoop, etc.)
    Refresh-PathFromRegistry
    try {
        $null = claude --version 2>&1
        $claudeInstalled = $true
        Write-Success "claude CLI is installed"
    } catch {
        if ($DryRun) {
            Write-WarningMsg "claude CLI is not installed"
            Write-DryRun "Would require claude CLI to be installed before running"
        } else {
            Write-ErrorMsg "claude CLI is not installed"
            Write-Host "Please install Claude Code CLI first: https://docs.anthropic.com/en/docs/claude-code" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "If you have already installed claude CLI, please check:" -ForegroundColor Yellow
            Write-Host "  1. Restart your terminal to refresh PATH" -ForegroundColor White
            Write-Host "  2. Ensure claude is in your PATH: where.exe claude" -ForegroundColor White
            Write-Host "  3. For npm install: npm install -g @anthropic-ai/claude-code" -ForegroundColor White
            exit 1
        }
    }
}

# ==============================================================================
# Step 2: Install project dependencies
# ==============================================================================
Write-Step "Step 2: Installing project dependencies..."

if ($DryRun) {
    Write-DryRun "Would run: uv sync"
    Write-Success "Project dependencies would be installed"
} else {
    uv sync
    if ($LASTEXITCODE -ne 0) {
        Write-ErrorMsg "Failed to install dependencies"
        exit 1
    }
    Write-Success "Project dependencies installed"
}

# ==============================================================================
# Step 3: Register MCP server
# ==============================================================================
Write-Step "Step 3: Registering MCP server..."

# Check for Git Bash (required by Claude Code on Windows)
$gitBashPath = $env:CLAUDE_CODE_GIT_BASH_PATH
if (-not $gitBashPath) {
    # Try common installation paths
    $commonPaths = @(
        "C:\Program Files\Git\bin\bash.exe",
        "C:\Program Files (x86)\Git\bin\bash.exe",
        "$env:LOCALAPPDATA\Programs\Git\bin\bash.exe"
    )
    foreach ($path in $commonPaths) {
        if (Test-Path $path) {
            $gitBashPath = $path
            break
        }
    }
}

if (-not $gitBashPath -or -not (Test-Path $gitBashPath)) {
    Write-WarningMsg "Git Bash not found. Claude Code on Windows requires Git Bash for MCP server registration."
    Write-Host ""
    Write-Host "Please install Git for Windows:" -ForegroundColor Yellow
    Write-Host "  1. Download from: https://git-scm.com/downloads/win" -ForegroundColor White
    Write-Host "  2. Install with default options" -ForegroundColor White
    Write-Host "  3. Restart PowerShell and run this script again" -ForegroundColor White
    Write-Host ""
    Write-Host "Or, if Git Bash is already installed, set the environment variable:" -ForegroundColor Yellow
    Write-Host "  `$env:CLAUDE_CODE_GIT_BASH_PATH = 'C:\Program Files\Git\bin\bash.exe'" -ForegroundColor White
    Write-Host ""
    Write-WarningMsg "Skipping MCP server registration. You can register manually later."
    Write-Host ""
} elseif ($DryRun) {
    Write-DryRun "Would run: claude mcp remove ccg --scope user"

    # Check uv version
    $useRefresh = $false
    try {
        $uvVersionOutput = uv --version 2>&1
        if ($uvVersionOutput -match "uv (\d+)\.(\d+)\.(\d+)") {
            $major = [int]$Matches[1]
            $minor = [int]$Matches[2]
            if ($major -gt 0 -or ($major -eq 0 -and $minor -ge 4)) {
                $useRefresh = $true
            }
        }
    } catch {}

    if ($useRefresh) {
        Write-DryRun "Would run: claude mcp add ccg --scope user --transport stdio -- uvx --refresh --from git+https://github.com/szstan/Coder-Codex-Gemini.git ccg-mcp"
    } else {
        Write-DryRun "Would run: claude mcp add ccg --scope user --transport stdio -- uvx --from git+https://github.com/szstan/Coder-Codex-Gemini.git ccg-mcp"
    }
    Write-Success "MCP server would be registered"
} else {
    # Temporarily relax error handling for native commands in Step 3
    $oldErrorActionPreference = $ErrorActionPreference
    $oldNativeCommandEap = $null
    $ErrorActionPreference = "Continue"
    if ($PSVersionTable.PSVersion.Major -ge 7) {
        $oldNativeCommandEap = $PSNativeCommandUseErrorActionPreference
        $PSNativeCommandUseErrorActionPreference = $false
    }

    try {
        # Try to remove existing ccg MCP server if it exists
        $null = & claude @("mcp","remove","ccg","--scope","user") 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-WarningMsg "Removed existing ccg MCP server"
        }

        # Check uv version to determine if --refresh is supported
        $mcpRegistered = $false
        $lastError = ""
        $useRefresh = $false
        $uvVersionKnown = $false

        try {
            $uvVersionOutput = uv --version 2>&1
            if ($uvVersionOutput -match "uv (\d+)\.(\d+)\.(\d+)") {
                $uvVersionKnown = $true
                $major = [int]$Matches[1]
                $minor = [int]$Matches[2]
                # --refresh requires uv >= 0.4.0
                if ($major -gt 0 -or ($major -eq 0 -and $minor -ge 4)) {
                    $useRefresh = $true
                }
            }
        } catch {
            # If we can't determine version, don't use --refresh
        }

        if ($useRefresh) {
            # Try with --refresh first
            $refreshSucceeded = $false
            try {
                $refreshOutput = & claude @("mcp","add","ccg","--scope","user","--transport","stdio","--","uvx","--refresh","--from","git+https://github.com/szstan/Coder-Codex-Gemini.git","ccg-mcp") 2>&1
                if ($LASTEXITCODE -eq 0) {
                    $refreshSucceeded = $true
                }
            } catch {
                $refreshOutput = $_.Exception.Message
                $refreshSucceeded = $false
            }

            if ($refreshSucceeded) {
                $mcpRegistered = $true
                Write-Success "MCP server registered (with --refresh)"
            } else {
                # Check if error is about --refresh option (covers various CLI error message formats)
                # Use -replace to normalize whitespace for reliable matching
                $refreshOutputStr = ($refreshOutput | Out-String) -replace '\s+', ' '
                if ($refreshOutputStr -match "(?i)(unknown|unrecognized|unexpected|invalid|no such|unsupported|found argument).*--refresh|--refresh.*(unknown|unrecognized|unexpected|invalid|no such|unsupported|found argument)|unknown option.*--refresh") {
                    # Fallback: --refresh was rejected, try without it
                    Write-WarningMsg "--refresh option was rejected, falling back to installation without --refresh..."
                    $fallbackSucceeded = $false
                    try {
                        $fallbackOutput = & claude @("mcp","add","ccg","--scope","user","--transport","stdio","--","uvx","--from","git+https://github.com/szstan/Coder-Codex-Gemini.git","ccg-mcp") 2>&1
                        if ($LASTEXITCODE -eq 0) {
                            $fallbackSucceeded = $true
                        }
                    } catch {
                        $fallbackOutput = $_.Exception.Message
                        $fallbackSucceeded = $false
                    }
                    if ($fallbackSucceeded) {
                        $mcpRegistered = $true
                        Write-Success "MCP server registered (without --refresh)"
                    } else {
                        $lastError = $fallbackOutput
                    }
                } else {
                    $lastError = $refreshOutput
                }
            }
        } else {
            # uv version too old or unknown, skip --refresh
            if ($uvVersionKnown) {
                Write-WarningMsg "Your uv version does not support --refresh option (requires uv >= 0.4.0)"
            } else {
                Write-WarningMsg "Could not determine uv version, skipping --refresh option"
            }
            Write-WarningMsg "Installing without --refresh..."
            Write-WarningMsg "Consider upgrading uv: powershell -c `"irm https://astral.sh/uv/install.ps1 | iex`""

            $fallbackSucceeded = $false
            try {
                $fallbackOutput = & claude @("mcp","add","ccg","--scope","user","--transport","stdio","--","uvx","--from","git+https://github.com/szstan/Coder-Codex-Gemini.git","ccg-mcp") 2>&1
                if ($LASTEXITCODE -eq 0) {
                    $fallbackSucceeded = $true
                }
            } catch {
                $fallbackOutput = $_.Exception.Message
                $fallbackSucceeded = $false
            }
            if ($fallbackSucceeded) {
                $mcpRegistered = $true
                Write-Success "MCP server registered (without --refresh)"
            } else {
                $lastError = $fallbackOutput
            }
        }

        if (-not $mcpRegistered) {
            Write-ErrorMsg "Failed to register MCP server"
            Write-Host "Error details: $lastError" -ForegroundColor Red
            exit 1
        }
    } finally {
        $ErrorActionPreference = $oldErrorActionPreference
        if ($PSVersionTable.PSVersion.Major -ge 7) {
            $PSNativeCommandUseErrorActionPreference = $oldNativeCommandEap
        }
    }
}

# ==============================================================================
# Step 4: Install additional MCP servers
# ==============================================================================
Write-Step "Step 4: Installing additional MCP servers..."

# Check if npm is installed
$npmInstalled = $false
try {
    $null = npm --version 2>&1
    $npmInstalled = $true
    Write-Success "npm is installed"
} catch {
    Write-WarningMsg "npm is not installed, skipping additional MCP servers"
    Write-WarningMsg "To install npm: https://nodejs.org/"
}

if ($npmInstalled -and -not $DryRun) {
    # Install Ace MCP (semantic search)
    Write-Step "Installing Ace MCP for semantic search..."
    try {
        $null = npm list -g acemcp-node 2>&1
        Write-Success "acemcp-node is already installed"
    } catch {
        try {
            npm install -g acemcp-node
            Write-Success "acemcp-node installed successfully"
        } catch {
            Write-WarningMsg "Failed to install acemcp-node, you can install it manually later"
        }
    }

    # Register Ace MCP server
    Write-Step "Registering Ace MCP server..."
    $null = & claude @("mcp","remove","acemcp","--scope","user") 2>&1
    try {
        $null = & claude @("mcp","add","acemcp","--scope","user","--transport","stdio","--","npx","acemcp-node") 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Ace MCP server registered"
        } else {
            Write-WarningMsg "Failed to register Ace MCP server, you can register it manually later"
        }
    } catch {
        Write-WarningMsg "Failed to register Ace MCP server, you can register it manually later"
    }

    # Register Playwright MCP server (for testing)
    Write-Step "Registering Playwright MCP server for testing..."
    try {
        $null = & claude @("mcp","remove","playwright","--scope","user") 2>&1
        $playwrightOutput = & claude @("mcp","add","playwright","--scope","user","--transport","stdio","-e","SYSTEMROOT=C:\Windows","--","cmd","/c","npx","-y","@executeautomation/playwright-mcp-server") 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Playwright MCP server registered"
        } else {
            Write-WarningMsg "Failed to register Playwright MCP server"
            Write-WarningMsg "You can register it manually later"
        }
    } catch {
        Write-WarningMsg "Failed to register Playwright MCP server: $_"
        Write-WarningMsg "You can register it manually later"
    }
} elseif ($DryRun) {
    Write-DryRun "Would check for npm installation"
    Write-DryRun "Would install acemcp-node globally"
    Write-DryRun "Would register Ace MCP server"
    Write-DryRun "Would register Playwright MCP server"
}

# ==============================================================================
# Step 5: Install Skills
# ==============================================================================
Write-Step "Step 5: Installing Skills..."

$skillsDir = "$env:USERPROFILE\.claude\skills"
$skillsSourceDir = Join-Path $PSScriptRoot "skills"

if ($DryRun) {
    if (!(Test-Path $skillsDir)) {
        Write-DryRun "Would create directory: $skillsDir"
    }
    if (Test-Path $skillsSourceDir) {
        $skillDirs = Get-ChildItem -Path $skillsSourceDir -Directory
        foreach ($skillDir in $skillDirs) {
            Write-DryRun "Would copy: $($skillDir.FullName) -> $skillsDir\$($skillDir.Name)"
            Write-Success "$($skillDir.Name) skill would be installed"
        }
    } else {
        Write-WarningMsg "Skills directory not found, would skip"
    }
} else {
    try {
        # Create skills directory if it doesn't exist
        if (!(Test-Path $skillsDir)) {
            New-Item -ItemType Directory -Path $skillsDir -Force | Out-Null
            Write-Success "Created skills directory: $skillsDir"
        }

        # Install all skills from skills directory
        $installedCount = 0
        if (Test-Path $skillsSourceDir) {
            $skillDirs = Get-ChildItem -Path $skillsSourceDir -Directory
            foreach ($skillDir in $skillDirs) {
                $dest = Join-Path $skillsDir $skillDir.Name
                if (Test-Path $dest) {
                    Remove-Item -Recurse -Force $dest
                }
                Copy-Item -Recurse $skillDir.FullName $dest
                Write-Success "Installed $($skillDir.Name) skill"
                $installedCount++
            }
            Write-Success "Installed $installedCount skills"
        } else {
            Write-WarningMsg "Skills directory not found, skipping"
        }
    } catch {
        Write-ErrorMsg "Failed to install skills: $_"
        exit 1
    }
}

# ==============================================================================
# Step 6: Configure global CLAUDE.md
# ==============================================================================
Write-Step "Step 6: Configuring global CLAUDE.md..."

$claudeMdPath = "$env:USERPROFILE\.claude\CLAUDE.md"
$ccgMarker = "# CCG Configuration"

# Read CCG config from external file to avoid encoding issues
$ccgConfigPath = Join-Path $PSScriptRoot "templates\ccg-global-prompt.md"

if ($DryRun) {
    if (!(Test-Path $claudeMdPath)) {
        if (Test-Path $ccgConfigPath) {
            Write-DryRun "Would create: $claudeMdPath (from template)"
            Write-Success "Global CLAUDE.md would be created"
        } else {
            Write-WarningMsg "CCG global prompt template not found at $ccgConfigPath"
        }
    } else {
        $content = Get-Content $claudeMdPath -Raw -Encoding UTF8
        if ($content -match [regex]::Escape($ccgMarker)) {
            Write-WarningMsg "CCG configuration already exists in CLAUDE.md, would skip"
        } else {
            if (Test-Path $ccgConfigPath) {
                Write-DryRun "Would append CCG configuration to: $claudeMdPath"
                Write-Success "CCG configuration would be appended to CLAUDE.md"
            } else {
                Write-WarningMsg "CCG global prompt template not found at $ccgConfigPath"
            }
        }
    }
} else {
    try {
        if (!(Test-Path $claudeMdPath)) {
            # File doesn't exist - create new file with CCG config
            if (Test-Path $ccgConfigPath) {
                Copy-Item $ccgConfigPath $claudeMdPath
                Write-Success "Created global CLAUDE.md"
            } else {
                Write-WarningMsg "CCG global prompt template not found at $ccgConfigPath"
                Write-WarningMsg "Please manually copy the CCG configuration to $claudeMdPath"
            }
        } else {
            # File exists - ask user what to do
            Write-Host ""
            Write-Host "CLAUDE.md already exists at: $claudeMdPath" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "Choose an option:" -ForegroundColor Cyan
            Write-Host "  1. Overwrite (replace entire file with CCG configuration)" -ForegroundColor White
            Write-Host "  2. Append (add CCG configuration to end of file)" -ForegroundColor White
            Write-Host "  3. Skip (keep existing file unchanged)" -ForegroundColor White
            Write-Host ""

            $choice = Read-Host "Enter your choice [1/2/3] (default: 3)"

            if ([string]::IsNullOrWhiteSpace($choice)) {
                $choice = "3"
            }

            switch ($choice) {
                "1" {
                    # Overwrite
                    if (Test-Path $ccgConfigPath) {
                        Copy-Item $ccgConfigPath $claudeMdPath -Force
                        Write-Success "Overwritten CLAUDE.md with CCG configuration"
                    } else {
                        Write-WarningMsg "CCG global prompt template not found at $ccgConfigPath"
                    }
                }
                "2" {
                    # Append
                    $content = Get-Content $claudeMdPath -Raw -Encoding UTF8
                    if ($content -match [regex]::Escape($ccgMarker)) {
                        Write-WarningMsg "CCG configuration already exists in CLAUDE.md, skipping"
                    } else {
                        if (Test-Path $ccgConfigPath) {
                            $ccgContent = Get-Content $ccgConfigPath -Raw -Encoding UTF8
                            Add-Content -Path $claudeMdPath -Value "`n$ccgContent" -Encoding UTF8
                            Write-Success "Appended CCG configuration to CLAUDE.md"
                        } else {
                            Write-WarningMsg "CCG global prompt template not found at $ccgConfigPath"
                        }
                    }
                }
                "3" {
                    # Skip
                    Write-WarningMsg "Skipped CLAUDE.md configuration"
                }
                default {
                    Write-WarningMsg "Invalid choice, skipping CLAUDE.md configuration"
                }
            }
        }
    } catch {
        Write-ErrorMsg "Failed to configure global CLAUDE.md: $_"
        exit 1
    }
}

# ==============================================================================
# Step 7: Configure Coder
# ==============================================================================
Write-Step "Step 7: Configuring Coder..."

$configDir = "$env:USERPROFILE\.ccg-mcp"
$configPath = "$configDir\config.toml"

if ($DryRun) {
    if (!(Test-Path $configDir)) {
        Write-DryRun "Would create directory: $configDir"
    }
    if (Test-Path $configPath) {
        Write-WarningMsg "Config file already exists at $configPath"
        Write-DryRun "Would prompt: Overwrite? (y/N)"
    }
    Write-DryRun "Would prompt for: API Token, Base URL, Model"
    Write-DryRun "Would create config file: $configPath"
    Write-DryRun "Would set file permissions (current user only)"
    Write-Success "Coder configuration would be saved"
} else {
    $skipCoderConfig = $false

    try {
        # Create config directory if it doesn't exist
        if (!(Test-Path $configDir)) {
            New-Item -ItemType Directory -Path $configDir -Force | Out-Null
        }

        # Check if config already exists
        if (Test-Path $configPath) {
            Write-WarningMsg "Config file already exists at $configPath"
            $overwrite = Read-Host "Overwrite? (y/N)"
            if ($overwrite -ne "y" -and $overwrite -ne "Y") {
                Write-WarningMsg "Skipping Coder configuration"
                $skipCoderConfig = $true
            }
        }

        if (-not $skipCoderConfig) {
            # Display API Token instructions
            Write-Host ""
            Write-Host "==================================================================" -ForegroundColor Cyan
            Write-Host "  Coder Configuration - API Token Required" -ForegroundColor Cyan
            Write-Host "==================================================================" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "To get your API Token:" -ForegroundColor Yellow
            Write-Host "  1. Visit: https://open.bigmodel.cn" -ForegroundColor White
            Write-Host "  2. Sign up / Login to your account" -ForegroundColor White
            Write-Host "  3. Navigate to 'API Keys' section" -ForegroundColor White
            Write-Host "  4. Create a new API key and copy it" -ForegroundColor White
            Write-Host ""
            Write-Host "Default Configuration:" -ForegroundColor Yellow
            Write-Host "  Base URL: https://open.bigmodel.cn/api/anthropic" -ForegroundColor White
            Write-Host "  Model:    glm-4.7" -ForegroundColor White
            Write-Host ""
            Write-Host "==================================================================" -ForegroundColor Cyan
            Write-Host ""

            # Prompt for API Token
            $apiToken = Read-Host "Enter your API Token (required)"
            if ([string]::IsNullOrWhiteSpace($apiToken)) {
                Write-ErrorMsg "API Token is required"
                exit 1
            }

            # Prompt for Base URL (optional)
            $baseUrl = Read-Host "Enter Base URL (press Enter for default: https://open.bigmodel.cn/api/anthropic)"
            if ([string]::IsNullOrWhiteSpace($baseUrl)) {
                $baseUrl = "https://open.bigmodel.cn/api/anthropic"
            }

            # Prompt for Model (optional)
            $model = Read-Host "Enter Model (press Enter for default: glm-4.7)"
            if ([string]::IsNullOrWhiteSpace($model)) {
                $model = "glm-4.7"
            }

            # Escape special characters for TOML string values (backslash and double quote)
            $safeApiToken = $apiToken -replace '\\', '\\' -replace '"', '\"'
            $safeBaseUrl = $baseUrl -replace '\\', '\\' -replace '"', '\"'
            $safeModel = $model -replace '\\', '\\' -replace '"', '\"'

            # Generate config.toml
            $configContent = @"
[coder]
api_token = "$safeApiToken"
base_url = "$safeBaseUrl"
model = "$safeModel"

[coder.env]
CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1"
"@

            # Use UTF8 without BOM - critical for TOML parsers
            # PowerShell 5.x's "Set-Content -Encoding UTF8" writes BOM (EF BB BF) which breaks TOML parsing
            [System.IO.File]::WriteAllText($configPath, $configContent, [System.Text.UTF8Encoding]::new($false))

            # Set file permissions - only current user can read/write
            $acl = Get-Acl $configPath
            $acl.SetAccessRuleProtection($true, $false)
            $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($env:USERNAME, "FullControl", "Allow")
            $acl.SetAccessRule($rule)
            Set-Acl $configPath $acl

            Write-Success "Coder configuration saved to $configPath"
        }

    } catch {
        Write-ErrorMsg "Failed to configure Coder: $_"
        exit 1
    }
}
# ==============================================================================
# Done!
# ==============================================================================
if ($DryRun) {
    Write-Host "`n============================================================" -ForegroundColor Magenta
    Write-Host "  DRY-RUN COMPLETED - No changes were made" -ForegroundColor Magenta
    Write-Host "============================================================`n" -ForegroundColor Magenta
    Write-Host "Run without -WhatIf to apply changes:" -ForegroundColor Cyan
    Write-Host "  .\setup.ps1" -ForegroundColor White
} else {
    Write-Host "`n============================================================" -ForegroundColor Green
    Write-Success "CCG setup completed successfully!"
    Write-Host "============================================================`n" -ForegroundColor Green

    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Restart Claude Code CLI" -ForegroundColor White
    Write-Host "  2. Verify MCP server: claude mcp list" -ForegroundColor White
    Write-Host "  3. Check available skills: /ccg-workflow" -ForegroundColor White
}
Write-Host ""
