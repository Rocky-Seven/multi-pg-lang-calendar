#!/bin/bash

# ========================================
# Multi-PG-Lang Calendar
# スクリプト②：Rust専用セットアップ
# このスクリプト1つでRustが完全に動作します
# ========================================

echo "🚀 Multi-PG-Lang Calendar - Part 2: Rust Setup"
echo "================================================"
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
    echo "   Part 1 (C & Go) のセットアップを先に実行してください"
    exit 1
fi

cd "$PROJECT_ROOT"
echo "✅ プロジェクトルート: $(pwd)"
echo ""

# ========================================
# Step 2: Rustディレクトリ作成
# ========================================

echo "📁 Step 2: Rustディレクトリ作成"
echo "-----------------------------------"

mkdir -p rust

echo "✅ ディレクトリ作成完了"
echo ""

# ========================================
# Step 3: Rustインストール確認
# ========================================

echo "🔧 Step 3: Rustインストール確認"
echo "-----------------------------------"

if command -v cargo &> /dev/null; then
    echo "✅ Rust already installed"
    rustc --version
    cargo --version
else
    echo "Installing Rust..."
    
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    
    # 環境変数を読み込み
    export PATH="$HOME/.cargo/bin:$PATH"
    if [ -f "$HOME/.cargo/env" ]; then
        source "$HOME/.cargo/env"
    fi
    
    if command -v cargo &> /dev/null; then
        echo "✅ Rust installed successfully"
        rustc --version
        cargo --version
    else
        echo "❌ Rust installation failed"
        exit 1
    fi
fi

echo ""

# ========================================
# Step 4: Rustソースコード作成
# ========================================

echo "📝 Step 4: Rustソースコード作成"
echo "-----------------------------------"

cd rust

# 環境変数を確実に読み込み
export PATH="$HOME/.cargo/bin:$PATH"
if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
fi

# Cargo プロジェクト初期化
if [ ! -f "Cargo.toml" ]; then
    cargo init --name calendar 2>/dev/null
    echo "✅ Rust project initialized"
fi

# Cargo.toml 作成
cat > Cargo.toml << 'TOML_EOF'
[package]
name = "calendar"
version = "0.1.0"
edition = "2021"

[dependencies]
reqwest = { version = "0.11", features = ["blocking"] }
encoding_rs = "0.8"
TOML_EOF

echo "✅ Cargo.toml 作成完了"

# main.rs 作成
cat > src/main.rs << 'RUST_SOURCE_EOF'
use std::fs::File;
use std::io::{self, BufRead, BufReader, Write};

#[derive(Debug, Clone)]
struct Holiday {
    year: i32,
    month: i32,
    day: i32,
    name: String,
}

const WEEKDAYS: [&str; 7] = ["日", "月", "火", "水", "木", "金", "土"];
const HOLIDAY_URL: &str = "https://www8.cao.go.jp/chosei/shukujitsu/syukujitsu.csv";
const HOLIDAY_FILE: &str = "holidays.csv";

fn download_and_convert_holiday_file() -> Result<(), Box<dyn std::error::Error>> {
    println!("内閣府から祝日データをダウンロード中...");
    
    let response = reqwest::blocking::get(HOLIDAY_URL)?;
    let bytes = response.bytes()?;
    
    let (decoded, _, _) = encoding_rs::SHIFT_JIS.decode(&bytes);
    
    let mut file = File::create(HOLIDAY_FILE)?;
    file.write_all(decoded.as_bytes())?;
    
    println!("祝日データを保存しました: {}", HOLIDAY_FILE);
    println!("✅ UTF-8に変換しました");
    Ok(())
}

fn load_holidays_from_file(filename: &str) -> Result<Vec<Holiday>, Box<dyn std::error::Error>> {
    let file = File::open(filename)?;
    let reader = BufReader::new(file);
    let mut holidays = Vec::new();
    let mut line_num = 0;

    for line in reader.lines() {
        line_num += 1;
        let line = line?;
        
        if line_num == 1 {
            continue;
        }
        
        let trimmed_line = line.trim();
        if trimmed_line.is_empty() {
            continue;
        }

        let parts: Vec<&str> = trimmed_line.split(',').collect();
        if parts.len() < 2 {
            continue;
        }

        let date_str = parts[0].trim().replace('/', "-");
        let name = parts[1].trim().to_string();

        let date_parts: Vec<&str> = date_str.split('-').collect();
        if date_parts.len() != 3 {
            continue;
        }

        match (
            date_parts[0].parse::<i32>(),
            date_parts[1].parse::<i32>(),
            date_parts[2].parse::<i32>(),
        ) {
            (Ok(year), Ok(month), Ok(day)) => {
                if year >= 1900 && year <= 2100 && month >= 1 && month <= 12 && day >= 1 && day <= 31 {
                    holidays.push(Holiday { year, month, day, name });
                }
            }
            _ => {}
        }
    }

    Ok(holidays)
}

fn is_holiday(holidays: &[Holiday], year: i32, month: i32, day: i32) -> Option<String> {
    holidays
        .iter()
        .find(|h| h.year == year && h.month == month && h.day == day)
        .map(|h| h.name.clone())
}

fn is_leap_year(year: i32) -> bool {
    (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
}

fn get_days_in_month(year: i32, month: i32) -> i32 {
    match month {
        1 | 3 | 5 | 7 | 8 | 10 | 12 => 31,
        4 | 6 | 9 | 11 => 30,
        2 => if is_leap_year(year) { 29 } else { 28 },
        _ => 0,
    }
}

fn get_weekday(year: i32, month: i32, day: i32) -> i32 {
    let mut y = year;
    let mut m = month;
    
    if m < 3 {
        y -= 1;
        m += 12;
    }
    
    let h = (day + (13 * (m + 1)) / 5 + y + y / 4 - y / 100 + y / 400) % 7;
    (h + 6) % 7
}

fn print_calendar(holidays: &[Holiday], year: i32, month: i32) {
    println!("\n        {}年 {}月", year, month);
    println!("----------------------------");

    for wd in WEEKDAYS.iter() {
        print!(" {} ", wd);
    }
    println!();
    println!("----------------------------");

    let first_weekday = get_weekday(year, month, 1);
    let days_in_month = get_days_in_month(year, month);

    for _ in 0..first_weekday {
        print!("    ");
    }

    let mut current_weekday = first_weekday;
    for day in 1..=days_in_month {
        let is_hol = is_holiday(holidays, year, month, day).is_some();
        
        if is_hol {
            print!("{:3}*", day);
        } else {
            print!("{:3} ", day);
        }

        current_weekday += 1;
        if current_weekday == 7 {
            println!();
            current_weekday = 0;
        }
    }

    if current_weekday != 0 {
        println!();
    }
    println!("----------------------------");

    println!("\n【祝日】");
    let mut month_holidays: Vec<_> = holidays
        .iter()
        .filter(|h| h.year == year && h.month == month)
        .collect();
    
    month_holidays.sort_by_key(|h| h.day);
    
    if month_holidays.is_empty() {
        println!("  なし");
    } else {
        for h in month_holidays {
            println!("  {:2}日: {}", h.day, h.name);
        }
    }
    println!();
}

fn read_line() -> String {
    let mut input = String::new();
    io::stdin().read_line(&mut input).unwrap();
    input.trim().to_string()
}

fn main() {
    println!("=== 月間カレンダー（祝日対応版）Rust ===\n");

    let mut holidays = Vec::new();
    
    match load_holidays_from_file(HOLIDAY_FILE) {
        Ok(data) => {
            holidays = data;
            println!("祝日データを読み込みました: {}件", holidays.len());
        }
        Err(_) => {
            println!("ローカルファイル '{}' が見つかりません。", HOLIDAY_FILE);
            print!("内閣府から祝日データをダウンロードしますか？ (y/n): ");
            io::stdout().flush().unwrap();
            
            let response = read_line();
            
            if response.to_lowercase() == "y" {
                match download_and_convert_holiday_file() {
                    Ok(_) => {
                        match load_holidays_from_file(HOLIDAY_FILE) {
                            Ok(data) => {
                                holidays = data;
                                println!("祝日データを読み込みました: {}件", holidays.len());
                            }
                            Err(e) => {
                                println!("読み込みエラー: {}", e);
                            }
                        }
                    }
                    Err(e) => {
                        println!("ダウンロードエラー: {}", e);
                        println!("祝日データなしで続行します。");
                    }
                }
            } else {
                println!("祝日データなしで続行します。");
            }
        }
    }

    print!("\n年を入力してください (例: 2025): ");
    io::stdout().flush().unwrap();
    let year: i32 = read_line().parse().unwrap_or(2025);

    print!("月を入力してください (1-12): ");
    io::stdout().flush().unwrap();
    let month: i32 = read_line().parse().unwrap_or(1);

    if !(1..=12).contains(&month) {
        println!("月は1から12の間で入力してください。");
        return;
    }

    print_calendar(&holidays, year, month);
}
RUST_SOURCE_EOF

echo "✅ rust/src/main.rs 作成完了"
echo ""

cd "$PROJECT_ROOT"

# ========================================
# Step 5: シンボリックリンク作成
# ========================================

echo "🔗 Step 5: シンボリックリンク作成"
echo "-----------------------------------"

cd rust
ln -sf ../data/holidays.csv holidays.csv
echo "✅ rust/holidays.csv -> ../data/holidays.csv"
cd "$PROJECT_ROOT"

echo ""

# ========================================
# Step 6: Rustビルド
# ========================================

echo "🔨 Step 6: Rustビルド（5-10分かかります）"
echo "-----------------------------------"

cd rust

# 環境変数を再確認
export PATH="$HOME/.cargo/bin:$PATH"
if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
fi

echo "Rustをビルド中..."
echo "（初回は依存関係のダウンロードに時間がかかります）"
echo ""

if cargo build --release; then
    echo ""
    echo "✅ Rustビルド成功"
    ls -lh target/release/calendar
else
    echo ""
    echo "❌ Rustビルド失敗"
    cd "$PROJECT_ROOT"
    exit 1
fi

cd "$PROJECT_ROOT"
echo ""

# ========================================
# Step 7: Rustテスト実行
# ========================================

echo "🧪 Step 7: Rustテスト実行 (2025年5月)"
echo "-----------------------------------"
echo ""

cd rust
echo -e "2025\n5" | ./target/release/calendar
cd "$PROJECT_ROOT"

echo ""

# ========================================
# Step 8: .gitignore 更新
# ========================================

echo "📝 Step 8: .gitignore 更新"
echo "-----------------------------------"

cat > .gitignore << 'GIT_EOF'
# Compiled binaries
c/calendar
go/calendar
kotlin/calendar.jar
rust/target/

# Build artifacts
*.o
*.class

# Go
go.sum

# Rust
Cargo.lock

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

echo "✅ .gitignore 更新完了"
echo ""

# ========================================
# 完了メッセージ
# ========================================

echo "=========================================="
echo "✨ Rustセットアップ完了！"
echo "=========================================="
echo ""
echo "📁 プロジェクト: $PROJECT_ROOT"
echo ""
echo "✅ Rust: ビルド成功"
echo ""
echo "📝 次のステップ:"
echo "-----------------------------------"
echo "  1. Rustを手動実行:"
echo "     cd $PROJECT_ROOT/rust"
echo "     echo -e '2025\n5' | ./target/release/calendar"
echo ""
echo "  2. Kotlinをセットアップ:"
echo "     ./setup-kotlin.sh"
echo ""
echo "  3. 全言語を一括テスト (Kotlin完了後):"
echo "     cd $PROJECT_ROOT"
echo "     ./scripts/build-test-all.sh"
echo ""
echo "=========================================="
echo ""
