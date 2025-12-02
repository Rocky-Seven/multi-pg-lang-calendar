#!/bin/bash

# ========================================
# Multi-PG-Lang Calendar
# C言語とGo言語 完全セットアップスクリプト
# このスクリプト1つで全て完了します
# ========================================

echo "🚀 Multi-PG-Lang Calendar - C & Go Complete Setup"
echo "=================================================="
echo ""

# ========================================
# Step 1: 基準ディレクトリ設定
# ========================================

echo "📍 Step 1: 基準ディレクトリ設定"
echo "-----------------------------------"

if [ -d "/workspaces" ]; then
    BASE_DIR="/workspaces"
    echo "✅ GitHub Codespaces環境"
else
    BASE_DIR="$HOME"
    echo "✅ ローカル環境"
fi

PROJECT_DIR="$BASE_DIR/multi-pg-lang-calendar"
echo "プロジェクトディレクトリ: $PROJECT_DIR"
echo ""

# ========================================
# Step 2: プロジェクトディレクトリ作成
# ========================================

echo "📁 Step 2: プロジェクトディレクトリ作成"
echo "-----------------------------------"

if [ -d "$PROJECT_DIR" ]; then
    echo "⚠️  既存ディレクトリを削除します: $PROJECT_DIR"
    rm -rf "$PROJECT_DIR"
fi

mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"
echo "✅ 作成完了: $(pwd)"
echo ""

# ========================================
# Step 3: ディレクトリ構造作成
# ========================================

echo "📁 Step 3: ディレクトリ構造作成"
echo "-----------------------------------"

mkdir -p c go data scripts docs bin

echo "✅ ディレクトリ構造:"
ls -la
echo ""

# ========================================
# Step 4: 祝日データダウンロード＋UTF-8変換
# ========================================

echo "📥 Step 4: 祝日データダウンロード＋UTF-8変換"
echo "-----------------------------------"

if curl -o data/holidays_sjis.csv https://www8.cao.go.jp/chosei/shukujitsu/syukujitsu.csv 2>/dev/null; then
    echo "✅ ダウンロード成功"
    
    # UTF-8変換
    if command -v iconv &> /dev/null; then
        iconv -f SHIFT_JIS -t UTF-8 data/holidays_sjis.csv > data/holidays.csv 2>/dev/null
        echo "✅ UTF-8変換成功 (iconv)"
    elif command -v nkf &> /dev/null; then
        nkf -w data/holidays_sjis.csv > data/holidays.csv
        echo "✅ UTF-8変換成功 (nkf)"
    else
        mv data/holidays_sjis.csv data/holidays.csv
        echo "⚠️  変換ツールなし、そのまま使用"
    fi
    
    rm -f data/holidays_sjis.csv
    
    echo "   ファイル: data/holidays.csv"
    echo "   行数: $(wc -l < data/holidays.csv)"
    echo "   サイズ: $(ls -lh data/holidays.csv | awk '{print $5}')"
else
    echo "❌ ダウンロード失敗"
fi

echo ""

# ========================================
# Step 5: C言語ソースコード作成
# ========================================

echo "📝 Step 5: C言語ソースコード作成"
echo "-----------------------------------"

cat > c/calendar.c << 'C_SOURCE_EOF'
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define MAX_HOLIDAYS 1100

typedef struct {
    int year;
    int month;
    int day;
    char name[100];
} Holiday;

Holiday holidays[MAX_HOLIDAYS];
int holiday_count = 0;

const char* weekdays[] = {"日", "月", "火", "水", "木", "金", "土"};

char* trim(char* str) {
    char* end;
    while(isspace((unsigned char)*str)) str++;
    if(*str == 0) return str;
    end = str + strlen(str) - 1;
    while(end > str && isspace((unsigned char)*end)) end--;
    end[1] = '\0';
    return str;
}

int load_holidays_from_file(const char* filename) {
    FILE *fp = fopen(filename, "r");
    if (fp == NULL) {
        return 0;
    }

    char line[512];
    int line_num = 0;
    
    if (fgets(line, sizeof(line), fp) != NULL) {
        line_num++;
    }

    while (fgets(line, sizeof(line), fp) != NULL && holiday_count < MAX_HOLIDAYS) {
        line_num++;
        
        line[strcspn(line, "\n")] = 0;
        line[strcspn(line, "\r")] = 0;
        
        char* trimmed_line = trim(line);
        if (strlen(trimmed_line) == 0) continue;

        char date_str[50] = "";
        char name[100] = "";
        
        char *comma = strchr(trimmed_line, ',');
        if (comma == NULL) continue;
        
        int date_len = comma - trimmed_line;
        if (date_len >= sizeof(date_str) || date_len == 0) continue;
        
        strncpy(date_str, trimmed_line, date_len);
        date_str[date_len] = '\0';
        strcpy(name, comma + 1);
        
        char* clean_date = trim(date_str);
        char* clean_name = trim(name);
        
        if (strlen(clean_date) == 0 || strlen(clean_name) == 0) continue;
        
        int year = 0, month = 0, day = 0;
        int parsed = 0;
        
        if (sscanf(clean_date, "%d/%d/%d", &year, &month, &day) == 3) {
            parsed = 1;
        } else if (sscanf(clean_date, "%d-%d-%d", &year, &month, &day) == 3) {
            parsed = 1;
        }
        
        if (parsed && year >= 1900 && year <= 2100 && 
            month >= 1 && month <= 12 && day >= 1 && day <= 31) {
            
            holidays[holiday_count].year = year;
            holidays[holiday_count].month = month;
            holidays[holiday_count].day = day;
            strncpy(holidays[holiday_count].name, clean_name, sizeof(holidays[holiday_count].name) - 1);
            holidays[holiday_count].name[sizeof(holidays[holiday_count].name) - 1] = '\0';
            
            holiday_count++;
        }
    }

    fclose(fp);
    printf("祝日データを読み込みました: %d件\n", holiday_count);
    return 1;
}

int is_holiday(int year, int month, int day, char* holiday_name) {
    for (int i = 0; i < holiday_count; i++) {
        if (holidays[i].year == year && 
            holidays[i].month == month && 
            holidays[i].day == day) {
            if (holiday_name != NULL) {
                strcpy(holiday_name, holidays[i].name);
            }
            return 1;
        }
    }
    return 0;
}

int get_days_in_month(int year, int month) {
    int days[] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
    if (month == 2) {
        if ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)) {
            return 29;
        }
    }
    return days[month - 1];
}

int get_weekday(int year, int month, int day) {
    if (month < 3) {
        year--;
        month += 12;
    }
    int h = (day + (13 * (month + 1)) / 5 + year + year / 4 - year / 100 + year / 400) % 7;
    return (h + 6) % 7;
}

void print_calendar(int year, int month) {
    printf("\n        %d年 %d月\n", year, month);
    printf("----------------------------\n");
    
    for (int i = 0; i < 7; i++) {
        printf(" %s ", weekdays[i]);
    }
    printf("\n");
    printf("----------------------------\n");
    
    int first_day = get_weekday(year, month, 1);
    int days_in_month = get_days_in_month(year, month);
    
    for (int i = 0; i < first_day; i++) {
        printf("    ");
    }
    
    int current_weekday = first_day;
    for (int day = 1; day <= days_in_month; day++) {
        int is_hol = is_holiday(year, month, day, NULL);
        
        if (is_hol) {
            printf("%3d*", day);
        } else {
            printf("%3d ", day);
        }
        
        current_weekday++;
        if (current_weekday == 7) {
            printf("\n");
            current_weekday = 0;
        }
    }
    
    if (current_weekday != 0) {
        printf("\n");
    }
    printf("----------------------------\n");
    
    printf("\n【祝日】\n");
    int found = 0;
    for (int i = 0; i < holiday_count; i++) {
        if (holidays[i].year == year && holidays[i].month == month) {
            printf("  %2d日: %s\n", holidays[i].day, holidays[i].name);
            found = 1;
        }
    }
    if (!found) {
        printf("  なし\n");
    }
    printf("\n");
}

int main() {
    int year, month;
    
    printf("=== 月間カレンダー（祝日対応版）C言語 ===\n\n");
    
    const char* filenames[] = {
        "holidays.csv",
        "../data/holidays.csv",
        "data/holidays.csv"
    };
    
    int loaded = 0;
    for (int i = 0; i < 3 && !loaded; i++) {
        loaded = load_holidays_from_file(filenames[i]);
        if (loaded) break;
    }
    
    if (!loaded) {
        printf("祝日データなしで続行します。\n");
    }
    
    printf("\n年を入力してください (例: 2025): ");
    if (scanf("%d", &year) != 1) {
        printf("入力エラー\n");
        return 1;
    }
    
    printf("月を入力してください (1-12): ");
    if (scanf("%d", &month) != 1) {
        printf("入力エラー\n");
        return 1;
    }
    
    if (month < 1 || month > 12) {
        printf("月は1から12の間で入力してください。\n");
        return 1;
    }
    
    print_calendar(year, month);
    
    return 0;
}
C_SOURCE_EOF

echo "✅ c/calendar.c 作成完了"
echo ""

# ========================================
# Step 6: C言語 Makefile 作成
# ========================================

echo "📝 Step 6: C言語 Makefile 作成"
echo "-----------------------------------"

cat > c/Makefile << 'MAKE_EOF'
CC = gcc
CFLAGS = -Wall -O2
TARGET = calendar

all: $(TARGET)

$(TARGET): calendar.c
	$(CC) $(CFLAGS) -o $(TARGET) calendar.c

clean:
	rm -f $(TARGET)

run: $(TARGET)
	./$(TARGET)
MAKE_EOF

echo "✅ c/Makefile 作成完了"
echo ""

# ========================================
# Step 7: Go言語ソースコード作成
# ========================================

echo "📝 Step 7: Go言語ソースコード作成"
echo "-----------------------------------"

cat > go/calendar.go << 'GO_SOURCE_EOF'
package main

import (
	"bufio"
	"fmt"
	"io"
	"net/http"
	"os"
	"os/exec"
	"strconv"
	"strings"
	"time"
)

type Holiday struct {
	Year  int
	Month int
	Day   int
	Name  string
}

var holidays []Holiday
var weekdays = []string{"日", "月", "火", "水", "木", "金", "土"}

const holidayURL = "https://www8.cao.go.jp/chosei/shukujitsu/syukujitsu.csv"
const holidayFile = "holidays.csv"

func downloadAndConvertHolidayFile() error {
	fmt.Println("内閣府から祝日データをダウンロード中...")
	
	resp, err := http.Get(holidayURL)
	if err != nil {
		return fmt.Errorf("ダウンロードエラー: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("HTTPエラー: %d", resp.StatusCode)
	}

	tmpFile := "holidays_sjis.csv"
	out, err := os.Create(tmpFile)
	if err != nil {
		return fmt.Errorf("ファイル作成エラー: %v", err)
	}

	_, err = io.Copy(out, resp.Body)
	out.Close()
	if err != nil {
		return fmt.Errorf("保存エラー: %v", err)
	}

	cmd := exec.Command("iconv", "-f", "SHIFT_JIS", "-t", "UTF-8", tmpFile)
	output, err := cmd.Output()
	if err != nil {
		os.Rename(tmpFile, holidayFile)
		fmt.Println("⚠️  UTF-8変換をスキップしました")
	} else {
		err = os.WriteFile(holidayFile, output, 0644)
		if err != nil {
			return fmt.Errorf("UTF-8ファイル作成エラー: %v", err)
		}
		os.Remove(tmpFile)
		fmt.Println("✅ UTF-8に変換しました")
	}

	fmt.Printf("祝日データを保存しました: %s\n", holidayFile)
	return nil
}

func loadHolidaysFromFile(filename string) error {
	file, err := os.Open(filename)
	if err != nil {
		return err
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	lineNum := 0
	
	if scanner.Scan() {
		lineNum++
	}

	for scanner.Scan() {
		lineNum++
		line := strings.TrimSpace(scanner.Text())
		
		if line == "" {
			continue
		}

		parts := strings.Split(line, ",")
		if len(parts) < 2 {
			continue
		}

		dateStr := strings.TrimSpace(parts[0])
		name := strings.TrimSpace(parts[1])

		dateStr = strings.ReplaceAll(dateStr, "/", "-")
		dateParts := strings.Split(dateStr, "-")
		
		if len(dateParts) != 3 {
			continue
		}

		year, err1 := strconv.Atoi(dateParts[0])
		month, err2 := strconv.Atoi(dateParts[1])
		day, err3 := strconv.Atoi(dateParts[2])

		if err1 != nil || err2 != nil || err3 != nil {
			continue
		}

		holidays = append(holidays, Holiday{
			Year:  year,
			Month: month,
			Day:   day,
			Name:  name,
		})
	}

	return scanner.Err()
}

func isHoliday(year, month, day int) (bool, string) {
	for _, h := range holidays {
		if h.Year == year && h.Month == month && h.Day == day {
			return true, h.Name
		}
	}
	return false, ""
}

func printCalendar(year, month int) {
	fmt.Printf("\n        %d年 %d月\n", year, month)
	fmt.Println("----------------------------")

	for _, wd := range weekdays {
		fmt.Printf(" %s ", wd)
	}
	fmt.Println()
	fmt.Println("----------------------------")

	firstDay := time.Date(year, time.Month(month), 1, 0, 0, 0, 0, time.Local)
	firstWeekday := int(firstDay.Weekday())
	
	lastDay := firstDay.AddDate(0, 1, -1)
	daysInMonth := lastDay.Day()

	for i := 0; i < firstWeekday; i++ {
		fmt.Print("    ")
	}

	currentWeekday := firstWeekday
	for day := 1; day <= daysInMonth; day++ {
		isHol, _ := isHoliday(year, month, day)
		
		if isHol {
			fmt.Printf("%3d*", day)
		} else {
			fmt.Printf("%3d ", day)
		}

		currentWeekday++
		if currentWeekday == 7 {
			fmt.Println()
			currentWeekday = 0
		}
	}

	if currentWeekday != 0 {
		fmt.Println()
	}
	fmt.Println("----------------------------")

	fmt.Println("\n【祝日】")
	found := false
	for _, h := range holidays {
		if h.Year == year && h.Month == month {
			fmt.Printf("  %2d日: %s\n", h.Day, h.Name)
			found = true
		}
	}
	if !found {
		fmt.Println("  なし")
	}
	fmt.Println()
}

func main() {
	fmt.Println("=== 月間カレンダー（祝日対応版）Go言語 ===\n")

	err := loadHolidaysFromFile(holidayFile)
	if err != nil {
		fmt.Printf("ローカルファイル '%s' が見つかりません。\n", holidayFile)
		fmt.Print("内閣府から祝日データをダウンロードしますか？ (y/n): ")
		
		var response string
		fmt.Scan(&response)
		
		if strings.ToLower(response) == "y" {
			if err := downloadAndConvertHolidayFile(); err != nil {
				fmt.Printf("ダウンロード失敗: %v\n", err)
				fmt.Println("祝日データなしで続行します。")
			} else {
				if err := loadHolidaysFromFile(holidayFile); err != nil {
					fmt.Printf("読み込みエラー: %v\n", err)
				} else {
					fmt.Printf("祝日データを読み込みました: %d件\n", len(holidays))
				}
			}
		} else {
			fmt.Println("祝日データなしで続行します。")
		}
	} else {
		fmt.Printf("祝日データを読み込みました: %d件\n", len(holidays))
	}

	var year, month int
	fmt.Print("\n年を入力してください (例: 2025): ")
	fmt.Scan(&year)

	fmt.Print("月を入力してください (1-12): ")
	fmt.Scan(&month)

	if month < 1 || month > 12 {
		fmt.Println("月は1から12の間で入力してください。")
		return
	}

	printCalendar(year, month)
}
GO_SOURCE_EOF

echo "✅ go/calendar.go 作成完了"
echo ""

# ========================================
# Step 8: Go module 初期化
# ========================================

echo "📝 Step 8: Go module 初期化"
echo "-----------------------------------"

cd go
go mod init calendar 2>/dev/null
echo "✅ Go module 初期化完了"
cd ..
echo ""

# ========================================
# Step 9: シンボリックリンク作成
# ========================================

echo "🔗 Step 9: シンボリックリンク作成"
echo "-----------------------------------"

cd c
ln -sf ../data/holidays.csv holidays.csv
echo "✅ c/holidays.csv -> ../data/holidays.csv"
cd ..

cd go
ln -sf ../data/holidays.csv holidays.csv
echo "✅ go/holidays.csv -> ../data/holidays.csv"
cd ..

echo ""

# ========================================
# Step 10: .gitignore 作成
# ========================================

echo "📝 Step 10: .gitignore 作成"
echo "-----------------------------------"

cat > .gitignore << 'GIT_EOF'
# Compiled binaries
c/calendar
go/calendar
*.o

# Go
go.sum

# Data
data/holidays_sjis.csv

# OS
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/
*.swp
GIT_EOF

echo "✅ .gitignore 作成完了"
echo ""

# ========================================
# Step 11: README.md 作成
# ========================================

echo "📝 Step 11: README.md 作成"
echo "-----------------------------------"

cat > README.md << 'README_EOF'
# 🗓️ Multi-PG-Lang Calendar - C & Go

Calendar App implemented in C and Go  
C言語とGoで実装した祝日対応カレンダー

## ✨ Features

- 🌐 C言語とGo言語で同じ機能を実装
- 📥 内閣府の祝日データ対応（UTF-8変換済み）
- 🚀 GitHub Codespaces で即座に試せる
- 📊 2言語の比較が可能

## 🚀 Quick Start

### Build & Test (自動)
```bash
./scripts/build-test.sh
```

### Individual Usage

#### C
```bash
cd c
make
echo -e "2025\n5" | ./calendar
```

#### Go
```bash
cd go
go run calendar.go
# または
go build -o calendar calendar.go
echo -e "2025\n5" | ./calendar
```

## 📁 Directory Structure
```
multi-pg-lang-calendar/
├── c/              # C言語実装
│   ├── calendar.c
│   ├── Makefile
│   └── holidays.csv -> ../data/holidays.csv
├── go/             # Go実装
│   ├── calendar.go
│   ├── go.mod
│   └── holidays.csv -> ../data/holidays.csv
├── data/           # 共通データ（祝日CSV）
│   └── holidays.csv
└── scripts/        # スクリプト
    └── build-test.sh
```

## 📄 License

MIT License
README_EOF

echo "✅ README.md 作成完了"
echo ""

# ========================================
# Step 12: ビルド・テストスクリプト作成
# ========================================

echo "📝 Step 12: ビルド・テストスクリプト作成"
echo "-----------------------------------"

cat > scripts/build-test.sh << 'BUILD_TEST_EOF'
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
BUILD_TEST_EOF

chmod +x scripts/build-test.sh
echo "✅ scripts/build-test.sh 作成完了"
echo ""

# ========================================
# Step 13: ビルド実行
# ========================================

echo "🔨 Step 13: ビルド実行"
echo "-----------------------------------"

# C言語ビルド
echo "C言語をビルド中..."
cd c
make clean > /dev/null 2>&1
make

if [ $? -eq 0 ]; then
    echo "✅ C言語ビルド成功"
else
    echo "❌ C言語ビルド失敗"
fi

cd ..

# Goビルド
echo "Go言語をビルド中..."
cd go
go build -o calendar calendar.go

if [ $? -eq 0 ]; then
    echo "✅ Go言語ビルド成功"
else
    echo "❌ Go言語ビルド失敗"
fi

cd ..

echo ""

# ========================================
# Step 14: テスト実行
# ========================================

echo "🧪 Step 14: テスト実行 (2025年5月)"
echo "-----------------------------------"
echo ""

TEST_INPUT="2025
5"

# Cテスト
echo "=== C言語 ==="
cd c
echo "$TEST_INPUT" | ./calendar
cd ..
echo ""

# Goテスト
echo "=== Go言語 ==="
cd go
echo "$TEST_INPUT" | ./calendar
cd ..

echo ""

# ========================================
# 完了メッセージ
# ========================================

echo "=========================================="
echo "✨ セットアップ完了！"
echo "=========================================="
echo ""
echo "📁 プロジェクト: $PROJECT_DIR"
echo ""
echo "📝 次のステップ:"
echo "-----------------------------------"
echo "  1. プロジェクトディレクトリに移動:"
echo "     cd $PROJECT_DIR"
echo ""
echo "  2. 再ビルド・テスト:"
echo "     ./scripts/build-test.sh"
echo ""
echo "  3. C言語を手動実行:"
echo "     cd c"
echo "     make"
echo "     echo -e '2025\n5' | ./calendar"
echo ""
echo "  4. Go言語を手動実行:"
echo "     cd go"
echo "     go run calendar.go"
echo ""
echo "=========================================="
echo ""
