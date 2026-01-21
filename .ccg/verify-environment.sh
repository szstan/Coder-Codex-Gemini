#!/bin/bash
# CCG 环境依赖验证脚本
# 用途：验证项目开发环境是否完整

set -e

echo "=========================================="
echo "CCG 环境依赖验证脚本"
echo "=========================================="
echo ""

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 计数器
PASS=0
FAIL=0
WARN=0

# 检查函数
check_command() {
    local cmd=$1
    local name=$2
    local required=$3

    if command -v $cmd &> /dev/null; then
        local version=$($cmd --version 2>&1 | head -n 1)
        echo -e "${GREEN}✅ $name: $version${NC}"
        ((PASS++))
        return 0
    else
        if [ "$required" = "true" ]; then
            echo -e "${RED}❌ $name: 未安装（必需）${NC}"
            ((FAIL++))
        else
            echo -e "${YELLOW}⚠️  $name: 未安装（可选）${NC}"
            ((WARN++))
        fi
        return 1
    fi
}

echo "=== 1. 系统工具检查 ==="
check_command "git" "Git" "true"
check_command "python3" "Python" "false"
check_command "node" "Node.js" "false"
check_command "npm" "NPM" "false"
check_command "java" "Java" "false"
check_command "mvn" "Maven" "false"
check_command "go" "Go" "false"
check_command "cargo" "Rust" "false"
check_command "docker" "Docker" "false"
echo ""

echo "=== 2. 项目类型检测 ==="
PROJECT_TYPE="unknown"

if [ -f "package.json" ]; then
    echo -e "${GREEN}✅ 检测到 Node.js 项目${NC}"
    PROJECT_TYPE="nodejs"
    ((PASS++))
elif [ -f "pyproject.toml" ] || [ -f "requirements.txt" ]; then
    echo -e "${GREEN}✅ 检测到 Python 项目${NC}"
    PROJECT_TYPE="python"
    ((PASS++))
elif [ -f "pom.xml" ]; then
    echo -e "${GREEN}✅ 检测到 Java Maven 项目${NC}"
    PROJECT_TYPE="java-maven"
    ((PASS++))
elif [ -f "go.mod" ]; then
    echo -e "${GREEN}✅ 检测到 Go 项目${NC}"
    PROJECT_TYPE="go"
    ((PASS++))
else
    echo -e "${YELLOW}⚠️  无法识别项目类型${NC}"
    ((WARN++))
fi
echo ""

echo "=== 3. 项目依赖检查 ==="
if [ "$PROJECT_TYPE" = "python" ]; then
    if [ -f "requirements.txt" ]; then
        echo "检查 Python 依赖..."
        if pip check &> /dev/null; then
            echo -e "${GREEN}✅ Python 依赖完整${NC}"
            ((PASS++))
        else
            echo -e "${RED}❌ Python 依赖有问题${NC}"
            pip check
            ((FAIL++))
        fi
    fi
elif [ "$PROJECT_TYPE" = "nodejs" ]; then
    if [ -d "node_modules" ]; then
        echo -e "${GREEN}✅ Node.js 依赖已安装${NC}"
        ((PASS++))
    else
        echo -e "${YELLOW}⚠️  Node.js 依赖未安装，运行 npm install${NC}"
        ((WARN++))
    fi
fi
echo ""

echo "=== 4. 测试框架检查 ==="
if [ "$PROJECT_TYPE" = "python" ]; then
    if command -v pytest &> /dev/null; then
        echo -e "${GREEN}✅ pytest 已安装${NC}"
        pytest --collect-only &> /dev/null && echo -e "${GREEN}✅ 测试可以收集${NC}" || echo -e "${YELLOW}⚠️  测试收集失败${NC}"
        ((PASS++))
    else
        echo -e "${YELLOW}⚠️  pytest 未安装${NC}"
        ((WARN++))
    fi
elif [ "$PROJECT_TYPE" = "nodejs" ]; then
    if [ -f "package.json" ]; then
        if grep -q "\"test\"" package.json; then
            echo -e "${GREEN}✅ 测试脚本已配置${NC}"
            ((PASS++))
        else
            echo -e "${YELLOW}⚠️  未配置测试脚本${NC}"
            ((WARN++))
        fi
    fi
fi
echo ""

echo "=== 5. Git 状态检查 ==="
if git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Git 仓库已初始化${NC}"
    
    # 检查是否有未提交的改动
    if git diff-index --quiet HEAD --; then
        echo -e "${GREEN}✅ 工作区干净${NC}"
    else
        echo -e "${YELLOW}⚠️  有未提交的改动${NC}"
    fi
    ((PASS++))
else
    echo -e "${RED}❌ 不是 Git 仓库${NC}"
    ((FAIL++))
fi
echo ""

echo "=========================================="
echo "验证结果汇总"
echo "=========================================="
echo -e "${GREEN}通过: $PASS${NC}"
echo -e "${YELLOW}警告: $WARN${NC}"
echo -e "${RED}失败: $FAIL${NC}"
echo ""

if [ $FAIL -gt 0 ]; then
    echo -e "${RED}❌ 环境验证失败，请修复上述问题${NC}"
    exit 1
else
    echo -e "${GREEN}✅ 环境验证通过${NC}"
    exit 0
fi
