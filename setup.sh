#!/bin/bash
# CCG One-Click Setup Script for macOS/Linux
set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Helper functions
write_step() {
    echo -e "\n${CYAN}[*] $1${NC}"
}

write_success() {
    echo -e "${GREEN}[OK] $1${NC}"
}

write_error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

write_warning() {
    echo -e "${YELLOW}[WARN] $1${NC}"
}

# ==============================================================================
# Step 1: Check dependencies
# ==============================================================================
write_step "Step 1: Checking dependencies..."

# Check and install uv
if command -v uv &> /dev/null; then
    write_success "uv is installed"
else
    write_warning "uv is not installed, installing automatically..."
    if curl -LsSf https://astral.sh/uv/install.sh | sh; then
        export PATH="$HOME/.local/bin:$PATH"
        write_success "uv installed successfully"
    else
        write_error "Failed to install uv automatically"
        echo "Please install uv manually: https://github.com/astral-sh/uv"
        exit 1
    fi
fi

# Check claude CLI
if command -v claude &> /dev/null; then
    write_success "claude CLI is installed"
else
    write_error "claude CLI is not installed"
    echo "Please install Claude Code CLI first: https://docs.anthropic.com/en/docs/claude-code"
    exit 1
fi

# ==============================================================================
# Step 2: Install project dependencies
# ==============================================================================
write_step "Step 2: Installing project dependencies..."

if uv sync; then
    write_success "Project dependencies installed"
else
    write_error "Failed to install dependencies"
    exit 1
fi

# ==============================================================================
# Step 3: Register MCP server
# ==============================================================================
write_step "Step 3: Registering MCP server..."

# Try to remove existing ccg MCP server if it exists
claude mcp remove ccg -s user 2>/dev/null && write_warning "Removed existing ccg MCP server" || true

PWD=$(pwd)
if claude mcp add ccg -s user --transport stdio -- uv run --directory "$PWD" ccg-mcp; then
    write_success "MCP server registered"
else
    write_error "Failed to register MCP server"
    exit 1
fi

# ==============================================================================
# Step 4: Install Skills
# ==============================================================================
write_step "Step 4: Installing Skills..."

SKILLS_DIR="$HOME/.claude/skills"
CCG_WORKFLOW_SOURCE="skills/ccg-workflow"
GEMINI_COLLAB_SOURCE="skills/gemini-collaboration"

# Create skills directory if it doesn't exist
if [ ! -d "$SKILLS_DIR" ]; then
    mkdir -p "$SKILLS_DIR"
    write_success "Created skills directory: $SKILLS_DIR"
fi

# Copy ccg-workflow skill
if [ -d "$CCG_WORKFLOW_SOURCE" ]; then
    DEST="$SKILLS_DIR/ccg-workflow"
    rm -rf "$DEST"
    cp -r "$CCG_WORKFLOW_SOURCE" "$DEST"
    write_success "Installed ccg-workflow skill"
else
    write_warning "ccg-workflow skill not found, skipping"
fi

# Copy gemini-collaboration skill
if [ -d "$GEMINI_COLLAB_SOURCE" ]; then
    DEST="$SKILLS_DIR/gemini-collaboration"
    rm -rf "$DEST"
    cp -r "$GEMINI_COLLAB_SOURCE" "$DEST"
    write_success "Installed gemini-collaboration skill"
else
    write_warning "gemini-collaboration skill not found, skipping"
fi

# ==============================================================================
# Step 5: Configure global CLAUDE.md
# ==============================================================================
write_step "Step 5: Configuring global CLAUDE.md..."

CLAUDE_MD_PATH="$HOME/.claude/CLAUDE.md"
CCG_MARKER="# CCG Configuration"

CCG_CONFIG="

$CCG_MARKER

# 全局协议

## 强制规则

- **默认协作**：所有代码/文档改动任务，**必须**委托 Coder 执行，阶段性完成后**必须**调用 Codex 审核
- **跳过需确认**：若判断无需协作，**必须立即暂停**并报告：
  > \"这是一个简单的[描述]任务，我判断无需调用 Coder/Codex。是否同意？等待您的确认。\"
- **违规即终止**：未经确认跳过 Coder 执行或 Codex 审核 = **流程违规**
- **Skill 优先**：调用 MCP 工具前，**必须已阅读对应 Skill**（\`ccg-workflow\`、\`gemini-collaboration\`）以了解最佳实践
- **会话复用**：始终保存 \`SESSION_ID\` 保持上下文

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
"

if [ ! -f "$CLAUDE_MD_PATH" ]; then
    # Create new file
    echo "$CCG_CONFIG" > "$CLAUDE_MD_PATH"
    write_success "Created global CLAUDE.md"
else
    # Check if CCG config already exists
    if grep -qF "$CCG_MARKER" "$CLAUDE_MD_PATH"; then
        write_warning "CCG configuration already exists in CLAUDE.md, skipping"
    else
        # Append CCG config
        echo "$CCG_CONFIG" >> "$CLAUDE_MD_PATH"
        write_success "Appended CCG configuration to CLAUDE.md"
    fi
fi

# ==============================================================================
# Step 6: Configure Coder
# ==============================================================================
write_step "Step 6: Configuring Coder..."

CONFIG_DIR="$HOME/.ccg-mcp"
CONFIG_PATH="$CONFIG_DIR/config.toml"

# Create config directory if it doesn't exist
mkdir -p "$CONFIG_DIR"

# Prompt for API Token (hidden input)
read -s -p "Enter your API Token: " API_TOKEN
echo
if [ -z "$API_TOKEN" ]; then
    write_error "API Token is required"
    exit 1
fi

# Prompt for Base URL (optional)
read -p "Enter Base URL (default: https://open.bigmodel.cn/api/anthropic): " BASE_URL
if [ -z "$BASE_URL" ]; then
    BASE_URL="https://open.bigmodel.cn/api/anthropic"
fi

# Prompt for Model (optional)
read -p "Enter Model (default: glm-4.7): " MODEL
if [ -z "$MODEL" ]; then
    MODEL="glm-4.7"
fi

# Generate config.toml
cat > "$CONFIG_PATH" << EOF
[coder]
api_token = "$API_TOKEN"
base_url = "$BASE_URL"
model = "$MODEL"
EOF

# Set file permissions - only current user can read/write
chmod 600 "$CONFIG_PATH"

write_success "Coder configuration saved to $CONFIG_PATH"

# ==============================================================================
# Done!
# ==============================================================================
echo ""
echo -e "${GREEN}============================================================${NC}"
write_success "CCG setup completed successfully!"
echo -e "${GREEN}============================================================${NC}"
echo ""

echo "Next steps:"
echo "  1. Restart Claude Code CLI"
echo "  2. Verify MCP server: claude mcp list"
echo "  3. Check available skills: claude skills list"
echo ""
