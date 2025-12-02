#!/bin/bash

# ========================================
# Multi-PG-Lang Calendar
# スクリプト③：Kotlin完全インストール
# SDKMANの問題を回避して確実にインストール
# ========================================

echo "🚀 Multi-PG-Lang Calendar - Part 3: Kotlin Complete Setup"
echo "==========================================================="
echo ""

# ========================================
# Step 1: プロジェクトルート検出
# ========================================

echo "📍 Step 1: プロジェクトルート検出"
echo "-----------------------------------"

if [ -d "/workspaces/multi-pg-lang-calendar" ]; then
    PROJECT_ROOT="/workspaces/multi-pg-lang-calendar"
elif [ -d "$HOME/multi-pg-lang-calendar" ]; then
    PROJECT_ROOT="$HOME/multi-pg-lang-calendar"
else
    echo "❌ プロジェクトディレクトリが見つかりません"
    exit 1
fi

cd "$PROJECT_ROOT"
echo "✅ プロジェクトルート: $(pwd)"
echo ""

# ========================================
# Step 2: Kotlinディレクトリ作成
# ========================================

echo "📁 Step 2: Kotlinディレクトリ作成"
echo "-----------------------------------"

mkdir -p kotlin

echo "✅ ディレクトリ作成完了"
echo ""

# ========================================
# Step 3: SDKMAN状態確認
# ========================================

echo "🔍 Step 3: SDKMAN状態確認"
echo "-----------------------------------"

# システムワイドのSDKMANを確認
if [ -d "/usr/local/sdkman" ]; then
    echo "⚠️  システムワイドのSDKMANが検出されました: /usr/local/sdkman"
    echo "   このSDKMANは使用せず、ユーザーディレクトリにインストールします"
    SDKMAN_SYSTEM=1
fi

# ユーザーディレクトリのSDKMAN
if [ -d "$HOME/.sdkman" ]; then
    echo "✅ ユーザーSDKMAN検出: $HOME/.sdkman"
    SDKMAN_USER=1
else
    SDKMAN_USER=0
fi

echo ""

# ========================================
# Step 4: ユーザーSDKMANインストール
# ========================================

echo "🔧 Step 4: ユーザーSDKMANセットアップ"
echo "-----------------------------------"

if [ "$SDKMAN_USER" -eq 0 ]; then
    echo "Installing SDKMAN to user directory..."
    
    # ユーザーディレクトリにインストール
    export SDKMAN_DIR="$HOME/.sdkman"
    curl -s "https://get.sdkman.io" | bash
    
    if [ $? -eq 0 ]; then
        echo "✅ SDKMAN installed to $HOME/.sdkman"
    else
        echo "❌ SDKMAN installation failed"
        exit 1
    fi
else
    echo "✅ SDKMAN already installed"
fi

# 環境変数設定
export SDKMAN_DIR="$HOME/.sdkman"

# sdkman-init.shを読み込み
if [ -f "$HOME/.sdkman/bin/sdkman-init.sh" ]; then
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    echo "✅ SDKMAN environment loaded"
else
    echo "❌ sdkman-init.sh not found"
    exit 1
fi

echo ""

# ========================================
# Step 5: .bashrc / .zshrc に追記
# ========================================

echo "📝 Step 5: シェル設定ファイルに追記"
echo "-----------------------------------"

# .bashrc に追記
if [ -f "$HOME/.bashrc" ]; then
    if ! grep -q "SDKMAN_DIR.*/.sdkman" "$HOME/.bashrc"; then
        echo "" >> "$HOME/.bashrc"
        echo "# SDKMAN Configuration" >> "$HOME/.bashrc"
        echo "export SDKMAN_DIR=\"\$HOME/.sdkman\"" >> "$HOME/.bashrc"
        echo "[[ -s \"\$HOME/.sdkman/bin/sdkman-init.sh\" ]] && source \"\$HOME/.sdkman/bin/sdkman-init.sh\"" >> "$HOME/.bashrc"
        echo "✅ Added to ~/.bashrc"
    else
        echo "✅ Already in ~/.bashrc"
    fi
fi

# .zshrc に追記（存在する場合）
if [ -f "$HOME/.zshrc" ]; then
    if ! grep -q "SDKMAN_DIR.*/.sdkman" "$HOME/.zshrc"; then
        echo "" >> "$HOME/.zshrc"
        echo "# SDKMAN Configuration" >> "$HOME/.zshrc"
        echo "export SDKMAN_DIR=\"\$HOME/.sdkman\"" >> "$HOME/.zshrc"
        echo "[[ -s \"\$HOME/.sdkman/bin/sdkman-init.sh\" ]] && source \"\$HOME/.sdkman/bin/sdkman-init.sh\"" >> "$HOME/.zshrc"
        echo "✅ Added to ~/.zshrc"
    else
        echo "✅ Already in ~/.zshrc"
    fi
fi

echo ""

# ========================================
# Step 6: Kotlinインストール
# ========================================

echo "📦 Step 6: Kotlinインストール"
echo "-----------------------------------"

# 環境変数を再読み込み
export SDKMAN_DIR="$HOME/.sdkman"
source "$HOME/.sdkman/bin/sdkman-init.sh"

# Kotlinがインストールされているか確認
if command -v kotlin &> /dev/null; then
    echo "✅ Kotlin already installed"
    kotlin -version 2>&1 | head -1
else
    echo "Installing Kotlin..."
    
    # 明示的にユーザーSDKMANを使用してインストール
    bash -c "export SDKMAN_DIR=$HOME/.sdkman && source $HOME/.sdkman/bin/sdkman-init.sh && sdk install kotlin" < /dev/null
    
    # 環境変数を再読み込み
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    
    # 確認
    if command -v kotlin &> /dev/null; then
        echo "✅ Kotlin installed successfully"
        kotlin -version 2>&1 | head -1
    else
        echo "❌ Kotlin installation failed"
        echo ""
        echo "手動インストールを試してください:"
        echo "  source ~/.bashrc"
        echo "  sdk install kotlin"
        exit 1
    fi
fi

echo ""

# ========================================
# Step 7: Kotlinソースコード作成
# ========================================

echo "📝 Step 7: Kotlinソースコード作成"
echo "-----------------------------------"

cat > kotlin/calendar.kt << 'KOTLIN_SOURCE_EOF'
import java.io.File
import java.net.URL
import java.time.LocalDate

data class Holiday(
    val year: Int,
    val month: Int,
    val day: Int,
    val name: String
)

val weekdays = arrayOf("日", "月", "火", "水", "木", "金", "土")
val holidays = mutableListOf<Holiday>()

const val HOLIDAY_URL = "https://www8.cao.go.jp/chosei/shukujitsu/syukujitsu.csv"
const val HOLIDAY_FILE = "holidays.csv"

fun downloadAndConvertHolidayFile(): Boolean {
    return try {
        println("内閣府から祝日データをダウンロード中...")
        
        val content = URL(HOLIDAY_URL).readBytes()
        
        val text = try {
            String(content, charset("Shift_JIS"))
        } catch (e: Exception) {
            String(content, Charsets.UTF_8)
        }
        
        File(HOLIDAY_FILE).writeText(text, Charsets.UTF_8)
        println("祝日データを保存しました: $HOLIDAY_FILE")
        true
    } catch (e: Exception) {
        println("ダウンロードエラー: ${e.message}")
        false
    }
}

fun loadHolidaysFromFile(filename: String): Boolean {
    val file = File(filename)
    if (!file.exists()) {
        return false
    }

    try {
        val lines = file.readLines(Charsets.UTF_8)
        var lineNum = 0

        for (line in lines) {
            lineNum++
            if (lineNum == 1) continue
            
            val trimmedLine = line.trim()
            if (trimmedLine.isEmpty()) continue

            val parts = trimmedLine.split(",")
            if (parts.size < 2) continue

            val dateStr = parts[0].trim().replace("/", "-")
            val name = parts[1].trim()

            try {
                val dateParts = dateStr.split("-")
                if (dateParts.size != 3) continue

                val year = dateParts[0].toInt()
                val month = dateParts[1].toInt()
                val day = dateParts[2].toInt()

                holidays.add(Holiday(year, month, day, name))
            } catch (e: NumberFormatException) {
                // Skip invalid lines
            }
        }
        return true
    } catch (e: Exception) {
        println("ファイル読み込みエラー: ${e.message}")
        return false
    }
}

fun isHoliday(year: Int, month: Int, day: Int): Pair<Boolean, String> {
    val holiday = holidays.find { it.year == year && it.month == month && it.day == day }
    return if (holiday != null) {
        Pair(true, holiday.name)
    } else {
        Pair(false, "")
    }
}

fun printCalendar(year: Int, month: Int) {
    println("\n        ${year}年 ${month}月")
    println("----------------------------")

    weekdays.forEach { print(" $it ") }
    println()
    println("----------------------------")

    val firstDay = LocalDate.of(year, month, 1)
    val firstWeekday = firstDay.dayOfWeek.value % 7
    val daysInMonth = firstDay.lengthOfMonth()

    repeat(firstWeekday) {
        print("    ")
    }

    var currentWeekday = firstWeekday
    for (day in 1..daysInMonth) {
        val (isHol, _) = isHoliday(year, month, day)
        
        if (isHol) {
            print("%3d*".format(day))
        } else {
            print("%3d ".format(day))
        }

        currentWeekday++
        if (currentWeekday == 7) {
            println()
            currentWeekday = 0
        }
    }

    if (currentWeekday != 0) {
        println()
    }
    println("----------------------------")

    println("\n【祝日】")
    val monthHolidays = holidays.filter { it.year == year && it.month == month }
    if (monthHolidays.isEmpty()) {
        println("  なし")
    } else {
        monthHolidays.sortedBy { it.day }.forEach {
            println("  %2d日: %s".format(it.day, it.name))
        }
    }
    println()
}

fun main() {
    println("=== 月間カレンダー（祝日対応版）Kotlin ===\n")

    if (!loadHolidaysFromFile(HOLIDAY_FILE)) {
        println("ローカルファイル '$HOLIDAY_FILE' が見つかりません。")
        print("内閣府から祝日データをダウンロードしますか？ (y/n): ")
        
        val response = readLine()?.trim()?.lowercase()
        
        if (response == "y") {
            if (downloadAndConvertHolidayFile()) {
                if (loadHolidaysFromFile(HOLIDAY_FILE)) {
                    println("祝日データを読み込みました: ${holidays.size}件")
                } else {
                    println("読み込みエラーが発生しました")
                }
            } else {
                println("祝日データなしで続行します。")
            }
        } else {
            println("祝日データなしで続行します。")
        }
    } else {
        println("祝日データを読み込みました: ${holidays.size}件")
    }

    print("\n年を入力してください (例: 2025): ")
    val year = readLine()?.toIntOrNull() ?: 2025

    print("月を入力してください (1-12): ")
    val month = readLine()?.toIntOrNull() ?: 1

    if (month !in 1..12) {
        println("月は1から12の間で入力してください。")
        return
    }

    printCalendar(year, month)
}
KOTLIN_SOURCE_EOF

echo "✅ kotlin/calendar.kt 作成完了"
echo ""

# ========================================
# Step 8: シンボリックリンク作成
# ========================================

echo "🔗 Step 8: シンボリックリンク作成"
echo "-----------------------------------"

cd kotlin
ln -sf ../data/holidays.csv holidays.csv
echo "✅ kotlin/holidays.csv -> ../data/holidays.csv"
cd "$PROJECT_ROOT"

echo ""

# ========================================
# Step 9: Kotlinビルド
# ========================================

echo "🔨 Step 9: Kotlinビルド"
echo "-----------------------------------"

cd kotlin

# 環境変数を再読み込み
export SDKMAN_DIR="$HOME/.sdkman"
source "$HOME/.sdkman/bin/sdkman-init.sh"

echo "Kotlinをビルド中..."
echo ""

if kotlinc calendar.kt -include-runtime -d calendar.jar 2>&1 | tee /tmp/kotlin_build.log; then
    if [ -f "calendar.jar" ]; then
        echo ""
        echo "✅ Kotlinビルド成功"
        ls -lh calendar.jar
        BUILD_SUCCESS=1
    else
        echo ""
        echo "❌ Kotlinビルド失敗（JARファイルが作成されませんでした）"
        BUILD_SUCCESS=0
    fi
else
    echo ""
    echo "❌ Kotlinビルド失敗"
    BUILD_SUCCESS=0
fi

cd "$PROJECT_ROOT"
echo ""

# ========================================
# Step 10: Kotlinテスト実行
# ========================================

if [ "$BUILD_SUCCESS" -eq 1 ]; then
    echo "🧪 Step 10: Kotlinテスト実行 (2025年5月)"
    echo "-----------------------------------"
    echo ""
    
    cd kotlin
    echo -e "2025\n5" | java -jar calendar.jar
    cd "$PROJECT_ROOT"
    
    echo ""
fi

# ========================================
# Step 11: README更新
# ========================================

echo "📝 Step 11: README更新"
echo "-----------------------------------"

cat > README.md << 'README_EOF'
# 🗓️ Multi-PG-Lang Calendar

Calendar App implemented in C, Go, Kotlin & Rust  
C言語、Go、Kotlin、Rustで実装した祝日対応カレンダー

## ✨ Features

- 🌐 4つのプログラミング言語で同じ機能を実装
- 📥 内閣府の祝日データ自動取得（UTF-8変換対応）
- 🚀 GitHub Codespaces で即座に試せる
- 📊 言語間のパフォーマンス比較が可能

## 🚀 Quick Start

### All Languages (自動ビルド＆テスト)
```bash
./scripts/build-test-all.sh
```

### Individual Build & Test

#### C
```bash
cd c && make
echo -e "2025\n5" | ./calendar
```

#### Go
```bash
cd go
go build -o calendar calendar.go
echo -e "2025\n5" | ./calendar
```

#### Kotlin
```bash
cd kotlin
kotlinc calendar.kt -include-runtime -d calendar.jar
echo -e "2025\n5" | java -jar calendar.jar
```

#### Rust
```bash
cd rust
cargo build --release
echo -e "2025\n5" | ./target/release/calendar
```

## 📁 Directory Structure
```
multi-pg-lang-calendar/
├── c/              # C言語実装
├── go/             # Go実装
├── kotlin/         # Kotlin実装
├── rust/           # Rust実装
├── data/           # 共通データ（祝日CSV・UTF-8）
└── scripts/        # ビルド・テストスクリプト
```

## 📄 License

MIT License
README_EOF

echo "✅ README.md 更新完了"
echo ""

# ========================================
# Step 12: 統合テストスクリプト作成
# ========================================

echo "📝 Step 12: 統合テストスクリプト更新"
echo "-----------------------------------"

cat > scripts/build-test-all.sh << 'BUILD_ALL_EOF'
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
BUILD_ALL_EOF

chmod +x scripts/build-test-all.sh
echo "✅ scripts/build-test-all.sh 更新完了"
echo ""

# ========================================
# 完了メッセージ
# ========================================

echo "=========================================="
echo "✨ Kotlinセットアップ完了！"
echo "=========================================="
echo ""
echo "📁 プロジェクト: $PROJECT_ROOT"
echo ""

if [ "$BUILD_SUCCESS" -eq 1 ]; then
    echo "✅ Kotlin: ビルド成功"
    echo ""
    echo "📝 次のステップ:"
    echo "-----------------------------------"
    echo "  1. Kotlinを手動実行:"
    echo "     cd $PROJECT_ROOT/kotlin"
    echo "     echo -e '2025\n5' | java -jar calendar.jar"
    echo ""
    echo "  2. 全言語を一括テスト:"
    echo "     cd $PROJECT_ROOT"
    echo "     ./scripts/build-test-all.sh"
    echo ""
    echo "  3. 新しいターミナルで常にKotlinを使用可能にする:"
    echo "     source ~/.bashrc"
    echo ""
else
    echo "⚠️  Kotlin: ビルド失敗"
    echo ""
    echo "【トラブルシューティング】"
    echo "-----------------------------------"
    echo "1. 新しいターミナルを開く"
    echo ""
    echo "2. 環境変数を読み込む:"
    echo "   source ~/.bashrc"
    echo ""
    echo "3. Kotlinが使えるか確認:"
    echo "   kotlin -version"
    echo ""
    echo "4. ビルドを再試行:"
    echo "   cd $PROJECT_ROOT/kotlin"
    echo "   kotlinc calendar.kt -include-runtime -d calendar.jar"
    echo ""
    echo "5. 実行:"
    echo "   echo -e '2025\n5' | java -jar calendar.jar"
    echo ""
fi

echo "=========================================="
echo ""
