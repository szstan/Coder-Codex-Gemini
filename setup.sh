#!/bin/bash
# CCG One-Click Setup Script for macOS/Linux
set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

cd "$SCRIPT_DIR"
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
claude mcp remove ccg --scope user 2>/dev/null && write_warning "Removed existing ccg MCP server" || true

# Check uv version to determine if --refresh is supported
MCP_REGISTERED=false
LAST_ERROR=""
USE_REFRESH=false
UV_VERSION_KNOWN=false

UV_VERSION_OUTPUT=$(uv --version 2>&1) || true
if [[ "$UV_VERSION_OUTPUT" =~ uv\ ([0-9]+)\.([0-9]+)\.([0-9]+) ]]; then
    UV_VERSION_KNOWN=true
    MAJOR="${BASH_REMATCH[1]}"
    MINOR="${BASH_REMATCH[2]}"
    # --refresh requires uv >= 0.4.0
    if [ "$MAJOR" -gt 0 ] || ([ "$MAJOR" -eq 0 ] && [ "$MINOR" -ge 4 ]); then
        USE_REFRESH=true
    fi
fi

if [ "$USE_REFRESH" = true ]; then
    # Try with --refresh first (disable set -e for this block)
    set +e
    REFRESH_OUTPUT=$(claude mcp add ccg --scope user --transport stdio -- uvx --refresh --from git+https://github.com/FredericMN/Coder-Codex-Gemini.git ccg-mcp 2>&1)
    REFRESH_EXIT_CODE=$?
    set -e

    if [ $REFRESH_EXIT_CODE -eq 0 ]; then
        MCP_REGISTERED=true
        write_success "MCP server registered (with --refresh)"
    elif echo "$REFRESH_OUTPUT" | grep -qiE "(unknown|unrecognized|unexpected|invalid).*(option|flag|argument).*--refresh|--refresh.*(unknown|unrecognized|unexpected|invalid)"; then
        # Fallback: --refresh was rejected (covers various CLI error message formats), try without it
        write_warning "--refresh option was rejected, falling back to installation without --refresh..."
        set +e
        FALLBACK_OUTPUT=$(claude mcp add ccg --scope user --transport stdio -- uvx --from git+https://github.com/FredericMN/Coder-Codex-Gemini.git ccg-mcp 2>&1)
        FALLBACK_EXIT_CODE=$?
        set -e
        if [ $FALLBACK_EXIT_CODE -eq 0 ]; then
            MCP_REGISTERED=true
            write_success "MCP server registered (without --refresh)"
        else
            LAST_ERROR="$FALLBACK_OUTPUT"
        fi
    else
        LAST_ERROR="$REFRESH_OUTPUT"
    fi
else
    # uv version too old or unknown, skip --refresh
    if [ "$UV_VERSION_KNOWN" = true ]; then
        write_warning "Your uv version does not support --refresh option (requires uv >= 0.4.0)"
    else
        write_warning "Could not determine uv version, skipping --refresh option"
    fi
    write_warning "Installing without --refresh..."
    write_warning "Consider upgrading uv: curl -LsSf https://astral.sh/uv/install.sh | sh"

    set +e
    FALLBACK_OUTPUT=$(claude mcp add ccg --scope user --transport stdio -- uvx --from git+https://github.com/FredericMN/Coder-Codex-Gemini.git ccg-mcp 2>&1)
    FALLBACK_EXIT_CODE=$?
    set -e
    if [ $FALLBACK_EXIT_CODE -eq 0 ]; then
        MCP_REGISTERED=true
        write_success "MCP server registered (without --refresh)"
    else
        LAST_ERROR="$FALLBACK_OUTPUT"
    fi
fi

if [ "$MCP_REGISTERED" = false ]; then
    write_error "Failed to register MCP server"
    echo "Error details: $LAST_ERROR"
    exit 1
fi

# ==============================================================================
# Step 4: Install additional MCP servers
# ==============================================================================
write_step "Step 4: Installing additional MCP servers..."

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    write_warning "npm is not installed, skipping additional MCP servers"
    write_warning "To install npm: https://nodejs.org/"
else
    write_success "npm is installed"

    # Install Ace MCP (semantic search)
    write_step "Installing Ace MCP for semantic search..."
    if npm list -g acemcp-node &> /dev/null; then
        write_success "acemcp-node is already installed"
    else
        if npm install -g acemcp-node; then
            write_success "acemcp-node installed successfully"
        else
            write_warning "Failed to install acemcp-node, you can install it manually later"
        fi
    fi

    # Register Ace MCP server
    write_step "Registering Ace MCP server..."
    claude mcp remove acemcp --scope user 2>/dev/null || true
    if claude mcp add acemcp --scope user --transport stdio -- npx acemcp-node 2>&1; then
        write_success "Ace MCP server registered"
    else
        write_warning "Failed to register Ace MCP server, you can register it manually later"
    fi

    # Register Playwright MCP server (for testing) - using config file method
    write_step "Registering Playwright MCP server for testing..."

    MCP_CONFIG_PATH="$HOME/.claude/mcp.json"

    # Create a Python script to update mcp.json with standard formatting
    python3 -c "
import json
import os

config_path = '$MCP_CONFIG_PATH'

# Read existing config or create new one
if os.path.exists(config_path):
    with open(config_path, 'r', encoding='utf-8') as f:
        config = json.load(f)
else:
    config = {'mcpServers': {}}

# Ensure mcpServers exists
if 'mcpServers' not in config:
    config['mcpServers'] = {}

# Add or update Playwright MCP server
config['mcpServers']['playwright'] = {
    'command': 'npx',
    'args': ['-y', '@executeautomation/playwright-mcp-server']
}

# Save with standard 2-space indentation
with open(config_path, 'w', encoding='utf-8') as f:
    json.dump(config, f, indent=2, ensure_ascii=False)
    f.write('\n')

print('Success')
" && write_success "Playwright MCP server registered" || write_warning "Failed to register Playwright MCP server"
fi

# ==============================================================================
# Step 5: Install Skills
# ==============================================================================
write_step "Step 5: Installing Skills..."

SKILLS_DIR="$HOME/.claude/skills"
CCG_WORKFLOW_SOURCE="$SCRIPT_DIR/skills/ccg-workflow"
GEMINI_COLLAB_SOURCE="$SCRIPT_DIR/skills/gemini-collaboration"

# Create skills directory if it doesn't exist
if [ ! -d "$SKILLS_DIR" ]; then
    mkdir -p "$SKILLS_DIR"
    write_success "Created skills directory: $SKILLS_DIR"
fi

# Install all skills from skills directory
SKILLS_SOURCE_DIR="$SCRIPT_DIR/skills"
INSTALLED_COUNT=0
SKIPPED_COUNT=0

if [ -d "$SKILLS_SOURCE_DIR" ]; then
    for skill_dir in "$SKILLS_SOURCE_DIR"/*; do
        if [ -d "$skill_dir" ]; then
            skill_name=$(basename "$skill_dir")
            DEST="$SKILLS_DIR/$skill_name"
            rm -rf "$DEST"
            cp -r "$skill_dir" "$DEST"
            write_success "Installed $skill_name skill"
            INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
        fi
    done
    write_success "Installed $INSTALLED_COUNT skills"
else
    write_warning "Skills directory not found, skipping"
fi

# ==============================================================================
# Step 6: Configure global CLAUDE.md
# ==============================================================================
write_step "Step 6: Configuring global CLAUDE.md..."

CLAUDE_MD_PATH="$HOME/.claude/CLAUDE.md"
CCG_MARKER="# CCG Configuration"
CCG_CONFIG_PATH="$SCRIPT_DIR/templates/ccg-global-prompt.md"

# Create .claude directory if it doesn't exist
mkdir -p "$HOME/.claude"

if [ ! -f "$CLAUDE_MD_PATH" ]; then
    # File doesn't exist - create new file with CCG config
    if [ -f "$CCG_CONFIG_PATH" ]; then
        cp "$CCG_CONFIG_PATH" "$CLAUDE_MD_PATH"
        write_success "Created global CLAUDE.md"
    else
        write_warning "CCG global prompt template not found at $CCG_CONFIG_PATH"
        write_warning "Please manually copy the CCG configuration to $CLAUDE_MD_PATH"
    fi
else
    # File exists - ask user what to do
    echo ""
    echo -e "${YELLOW}CLAUDE.md already exists at: $CLAUDE_MD_PATH${NC}"
    echo ""
    echo -e "${CYAN}Choose an option:${NC}"
    echo "  1. Overwrite (replace entire file with CCG configuration)"
    echo "  2. Append (add CCG configuration to end of file)"
    echo "  3. Skip (keep existing file unchanged)"
    echo ""
    read -p "Enter your choice [1/2/3] (default: 3): " choice

    if [ -z "$choice" ]; then
        choice="3"
    fi

    case "$choice" in
        1)
            # Overwrite
            if [ -f "$CCG_CONFIG_PATH" ]; then
                cp -f "$CCG_CONFIG_PATH" "$CLAUDE_MD_PATH"
                write_success "Overwritten CLAUDE.md with CCG configuration"
            else
                write_warning "CCG global prompt template not found at $CCG_CONFIG_PATH"
            fi
            ;;
        2)
            # Append
            if grep -qF "$CCG_MARKER" "$CLAUDE_MD_PATH"; then
                write_warning "CCG configuration already exists in CLAUDE.md, skipping"
            else
                if [ -f "$CCG_CONFIG_PATH" ]; then
                    echo "" >> "$CLAUDE_MD_PATH"
                    cat "$CCG_CONFIG_PATH" >> "$CLAUDE_MD_PATH"
                    write_success "Appended CCG configuration to CLAUDE.md"
                else
                    write_warning "CCG global prompt template not found at $CCG_CONFIG_PATH"
                fi
            fi
            ;;
        3)
            # Skip
            write_warning "Skipped CLAUDE.md configuration"
            ;;
        *)
            write_warning "Invalid choice, skipping CLAUDE.md configuration"
            ;;
    esac
fi

# ==============================================================================
# Step 7: Configure Coder
# ==============================================================================
write_step "Step 7: Configuring Coder..."

CONFIG_DIR="$HOME/.ccg-mcp"
CONFIG_PATH="$CONFIG_DIR/config.toml"

# Create config directory if it doesn't exist
mkdir -p "$CONFIG_DIR"

# Check if config already exists
if [ -f "$CONFIG_PATH" ]; then
    write_warning "Config file already exists at $CONFIG_PATH"
    read -p "Overwrite? (y/N): " OVERWRITE
    if [ "$OVERWRITE" != "y" ] && [ "$OVERWRITE" != "Y" ]; then
        write_warning "Skipping Coder configuration"
        # Jump to Done
        echo ""
        echo -e "${GREEN}============================================================${NC}"
        write_success "CCG setup completed successfully!"
        echo -e "${GREEN}============================================================${NC}"
        echo ""
        echo "Next steps:"
        echo "  1. Restart Claude Code CLI"
        echo "  2. Verify MCP server: claude mcp list"
        echo "  3. Check available skills: /ccg-workflow"
        echo ""
        exit 0
    fi
fi

# Display API Token instructions
echo ""
echo -e "${CYAN}==================================================================${NC}"
echo -e "${CYAN}  Coder Configuration - API Token Required${NC}"
echo -e "${CYAN}==================================================================${NC}"
echo ""
echo -e "${YELLOW}To get your API Token:${NC}"
echo "  1. Visit: https://open.bigmodel.cn"
echo "  2. Sign up / Login to your account"
echo "  3. Navigate to 'API Keys' section"
echo "  4. Create a new API key and copy it"
echo ""
echo -e "${YELLOW}Default Configuration:${NC}"
echo "  Base URL: https://open.bigmodel.cn/api/anthropic"
echo "  Model:    glm-4.7"
echo ""
echo -e "${CYAN}==================================================================${NC}"
echo ""

# Prompt for API Token (hidden input)
read -s -p "Enter your API Token (required): " API_TOKEN
echo
if [ -z "$API_TOKEN" ]; then
    write_error "API Token is required"
    exit 1
fi

# Prompt for Base URL (optional)
read -p "Enter Base URL (press Enter for default: https://open.bigmodel.cn/api/anthropic): " BASE_URL
if [ -z "$BASE_URL" ]; then
    BASE_URL="https://open.bigmodel.cn/api/anthropic"
fi

# Prompt for Model (optional)
read -p "Enter Model (press Enter for default: glm-4.7): " MODEL
if [ -z "$MODEL" ]; then
    MODEL="glm-4.7"
fi

# Escape special characters for TOML string values (backslash and double quote)
SAFE_API_TOKEN=$(printf '%s' "$API_TOKEN" | sed 's/\\/\\\\/g; s/"/\\"/g')
SAFE_BASE_URL=$(printf '%s' "$BASE_URL" | sed 's/\\/\\\\/g; s/"/\\"/g')
SAFE_MODEL=$(printf '%s' "$MODEL" | sed 's/\\/\\\\/g; s/"/\\"/g')

# Generate config.toml
cat > "$CONFIG_PATH" << EOF
[coder]
api_token = "$SAFE_API_TOKEN"
base_url = "$SAFE_BASE_URL"
model = "$SAFE_MODEL"

[coder.env]
CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1"
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
echo "  3. Check available skills: /ccg-workflow"
echo ""
