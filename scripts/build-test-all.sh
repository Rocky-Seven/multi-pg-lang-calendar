#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

echo -e "${YELLOW}🔨 Building All Languages...${NC}"
echo "======================================"
echo ""

# 環境変数読み込み
if [ -f "$HOME/.sdkman/bin/sdkman-init.sh" ]; then
    export SDKMAN_DIR="$HOME/.sdkman"
    source "$HOME/.sdkman/bin/sdkman-init.sh"
fi

if [ -f "$HOME/.cargo/env" ]; then
    export PATH="$HOME/.cargo/bin:$PATH"
    source "$HOME/.cargo/env"
fi

BUILD_SUCCESS=0
BUILD_FAILED=0

# C言語
echo -e "${BLUE}📦 Building C...${NC}"
cd "$PROJECT_ROOT/c"
if make clean > /dev/null 2>&1 && make; then
    echo -e "${GREEN}✅ C build successful${NC}"
    BUILD_SUCCESS=$((BUILD_SUCCESS + 1))
else
    echo -e "${RED}❌ C build failed${NC}"
    BUILD_FAILED=$((BUILD_FAILED + 1))
fi
echo ""

# Go
echo -e "${BLUE}📦 Building Go...${NC}"
cd "$PROJECT_ROOT/go"
if go build -o calendar calendar.go; then
    echo -e "${GREEN}✅ Go build successful${NC}"
    BUILD_SUCCESS=$((BUILD_SUCCESS + 1))
else
    echo -e "${RED}❌ Go build failed${NC}"
    BUILD_FAILED=$((BUILD_FAILED + 1))
fi
echo ""

# Rust
echo -e "${BLUE}📦 Building Rust...${NC}"
cd "$PROJECT_ROOT/rust"
if cargo build --release 2>&1 | tail -1 | grep -q "Finished"; then
    echo -e "${GREEN}✅ Rust build successful${NC}"
    BUILD_SUCCESS=$((BUILD_SUCCESS + 1))
else
    echo -e "${RED}❌ Rust build failed${NC}"
    BUILD_FAILED=$((BUILD_FAILED + 1))
fi
echo ""

# Kotlin
echo -e "${BLUE}📦 Building Kotlin...${NC}"
cd "$PROJECT_ROOT/kotlin"

if command -v kotlinc &> /dev/null; then
    if kotlinc calendar.kt -include-runtime -d calendar.jar 2>/dev/null; then
        echo -e "${GREEN}✅ Kotlin build successful${NC}"
        BUILD_SUCCESS=$((BUILD_SUCCESS + 1))
    else
        echo -e "${RED}❌ Kotlin build failed${NC}"
        BUILD_FAILED=$((BUILD_FAILED + 1))
    fi
else
    echo -e "${YELLOW}⚠️  kotlinc not found - skipping Kotlin build${NC}"
fi
echo ""

cd "$PROJECT_ROOT"

echo "======================================"
echo -e "${YELLOW}📊 Build Summary${NC}"
echo "======================================"
echo -e "${GREEN}Success: $BUILD_SUCCESS${NC}"
echo -e "${RED}Failed: $BUILD_FAILED${NC}"
echo ""

# テスト実行
echo "======================================"
echo -e "${YELLOW}🧪 Testing All Languages (2025年5月)${NC}"
echo "======================================"
echo ""

TEST_INPUT="2025
5"

# C
if [ -f "c/calendar" ]; then
    echo -e "${BLUE}--- C言語 ---${NC}"
    cd c
    echo "$TEST_INPUT" | ./calendar | tail -20
    cd ..
    echo ""
fi

# Go
if [ -f "go/calendar" ]; then
    echo -e "${BLUE}--- Go言語 ---${NC}"
    cd go
    echo "$TEST_INPUT" | ./calendar | tail -20
    cd ..
    echo ""
fi

# Rust
if [ -f "rust/target/release/calendar" ]; then
    echo -e "${BLUE}--- Rust ---${NC}"
    cd rust
    echo "$TEST_INPUT" | ./target/release/calendar | tail -20
    cd ..
    echo ""
fi

# Kotlin
if [ -f "kotlin/calendar.jar" ]; then
    echo -e "${BLUE}--- Kotlin ---${NC}"
    cd kotlin
    echo "$TEST_INPUT" | java -jar calendar.jar | tail -20
    cd ..
    echo ""
fi

echo "======================================"
echo -e "${GREEN}✅ All tests complete!${NC}"
echo "======================================"
