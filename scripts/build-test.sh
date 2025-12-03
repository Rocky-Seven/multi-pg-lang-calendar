#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

echo -e "${YELLOW}🔨 Building C and Go...${NC}"
echo "======================================"
echo ""

# C言語ビルド
echo -e "${BLUE}📦 Building C...${NC}"
echo "-----------------------------------"
cd "$PROJECT_ROOT/c"
if make clean && make; then
    echo -e "${GREEN}✅ C build successful${NC}"
    ls -lh calendar
else
    echo -e "${RED}❌ C build failed${NC}"
    exit 1
fi
echo ""

# Goビルド
echo -e "${BLUE}📦 Building Go...${NC}"
echo "-----------------------------------"
cd "$PROJECT_ROOT/go"
if go build -o calendar calendar.go; then
    echo -e "${GREEN}✅ Go build successful${NC}"
    ls -lh calendar
else
    echo -e "${RED}❌ Go build failed${NC}"
    exit 1
fi
echo ""

cd "$PROJECT_ROOT"

# テスト実行
echo "======================================"
echo -e "${YELLOW}🧪 Testing (2025年5月)${NC}"
echo "======================================"
echo ""

TEST_INPUT="2025
5"

# Cテスト
echo -e "${BLUE}--- C言語 ---${NC}"
cd "$PROJECT_ROOT/c"
echo "$TEST_INPUT" | ./calendar
echo ""

# Goテスト
echo -e "${BLUE}--- Go言語 ---${NC}"
cd "$PROJECT_ROOT/go"
echo "$TEST_INPUT" | ./calendar
echo ""

cd "$PROJECT_ROOT"

echo "======================================"
echo -e "${GREEN}✅ All tests complete!${NC}"
echo "======================================"
