# Multi-PG-Lang Calendar - セットアップガイド（第1日目）

## 📋 概要

C言語、Go言語、Rustで祝日対応カレンダーを作成します。
内閣府の祝日CSVを利用して、実用的なカレンダーアプリを3つの言語で実装します。

## 🎯 第1日目の目標

- GitHub Codespacesで開発環境を構築
- C言語とGo言語のカレンダー実装
- Rustのカレンダー実装
- 祝日データの取得と変換

## 📦 必要な環境

- GitHubアカウント
- ブラウザ（GitHub Codespacesを利用）

---

## 🚀 ステップ1: GitHubリポジトリ作成

### 1-1. GitHubにログイン

https://github.com にアクセスしてログインします。

### 1-2. 新しいリポジトリを作成

1. 左上の **「New」** ボタンをクリック
2. 以下の情報を入力:
   - **Repository name**: `multi-pg-lang-calendar`
   - **Description**: （空欄でOK）
   - **Public / Private**: Public（推奨）
   - ✅ **「Add a README file」** をチェック
3. **「Create repository」** をクリック

---

## 💻 ステップ2: Codespacesを起動

### 2-1. Codespacesを開く

1. 作成したリポジトリページで **「<> Code」** ボタンをクリック
2. **「Codespaces」** タブを選択
3. **「Create codespace on main」** をクリック

### 2-2. 起動を待つ

- 初回は1〜2分かかります
- VSCodeエディタが開きます

---

## 🔧 ステップ3: C言語・Go言語のセットアップ

### 3-1. セットアップスクリプトを作成

ターミナルで以下を実行:

```bash
cd /workspaces/multi-pg-lang-calendar
nano setup-c-go.sh
```

### 3-2. スクリプト①の内容を貼り付け

以下のスクリプトをコピーして、nanoエディタに貼り付けます（Ctrl+Shift+V）:

```bash
#!/bin/bash
# ========================================
# Multi-PG-Lang Calendar
# C言語とGo言語 完全セットアップスクリプト
# ========================================

echo "🚀 Multi-PG-Lang Calendar - C & Go Complete Setup"
echo "=================================================="
echo ""

# ========================================
# Step 1: 基準ディレクトリ設定
# ========================================
echo "📍 Step 1: 基準ディレクトリ設定"
if [ -d "/workspaces" ]; then
    BASE_DIR="/workspaces"
else
    BASE_DIR="$HOME"
fi
PROJECT_DIR="$BASE_DIR/multi-pg-lang-calendar"
echo "プロジェクトディレクトリ: $PROJECT_DIR"
echo ""

# ========================================
# Step 2: プロジェクトディレクトリ作成
# ========================================
echo "📁 Step 2: プロジェクトディレクトリ作成"
if [ -d "$PROJECT_DIR" ]; then
    echo "⚠️ 既存ディレクトリを削除します"
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
mkdir -p c go data scripts docs bin
echo "✅ ディレクトリ構造完成"
echo ""

# ========================================
# Step 4: 祝日データダウンロード＋UTF-8変換
# ========================================
echo "📥 Step 4: 祝日データダウンロード＋UTF-8変換"
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
        echo "⚠️ 変換ツールなし、そのまま使用"
    fi
    
    rm -f data/holidays_sjis.csv
    echo "  行数: $(wc -l < data/holidays.csv)"
fi
echo ""

# ========================================
# Step 5-11: ソースコードとファイル作成
# （実際のスクリプトでは完全版を使用）
# ========================================
# ... C言語ソースコード作成 ...
# ... Go言語ソースコード作成 ...
# ... ビルドとテスト ...

echo "✨ C & Go セットアップ完了！"
```

**注意**: 上記は概要版です。完全版は、以下のブログ記事のスクリプト①を使用してください。
https://my-studies.org/lets-create-a-calendar-that-handles-holidays-using-multiple-programming-languages-c-go-rust-kotlin-day-1/


### 3-3. スクリプトを保存して実行

```bash
# 保存: Ctrl+O → Enter → Ctrl+X
chmod +x setup-c-go.sh
./setup-c-go.sh
```

### 3-4. 実行結果の確認

以下のような出力が表示されます:

```
✅ C言語ビルド成功
✅ Go言語ビルド成功

=== C言語 ===
 2025年 5月
----------------------------
 日  月  火  水  木  金  土
----------------------------
          1   2   3*
  4*  5*  6*  7   8   9  10
 11  12  13  14  15  16  17
 18  19  20  21  22  23  24
 25  26  27  28  29  30  31
----------------------------

【祝日】
 3日: 憲法記念日
 4日: みどりの日
 5日: こどもの日
 6日: 休日
```

---

## 🦀 ステップ4: Rustのセットアップ

### 4-1. Rustセットアップスクリプトを作成

```bash
cd /workspaces/multi-pg-lang-calendar
nano setup-rust.sh
```

### 4-2. スクリプト②の内容を貼り付け

以下のブログ記事の「スクリプト② Rust追加セットアップ」の完全版を貼り付けます。

https://my-studies.org/lets-create-a-calendar-that-handles-holidays-using-multiple-programming-languages-c-go-rust-kotlin-day-1/

### 4-3. スクリプトを保存して実行

```bash
# 保存: Ctrl+O → Enter → Ctrl+X
chmod +x setup-rust.sh
./setup-rust.sh
```

**注意**: Rustのビルドは5〜10分かかります。

### 4-4. 実行結果の確認

```
✅ Rustビルド成功

=== Rust ===
 2025年 5月
----------------------------
（カレンダー表示）
```

---

## 📁 完成したディレクトリ構造

```
multi-pg-lang-calendar/
├── c/
│   ├── calendar.c
│   ├── Makefile
│   └── holidays.csv -> ../data/holidays.csv
├── go/
│   ├── calendar.go
│   ├── go.mod
│   └── holidays.csv -> ../data/holidays.csv
├── rust/
│   ├── Cargo.toml
│   ├── src/
│   │   └── main.rs
│   └── holidays.csv -> ../data/holidays.csv
├── data/
│   └── holidays.csv
└── scripts/
    └── build-test.sh
```

---

## 🧪 動作確認

### 手動でテスト実行

#### C言語
```bash
cd /workspaces/multi-pg-lang-calendar/c
make
echo -e "2025\n5" | ./calendar
```

#### Go言語
```bash
cd /workspaces/multi-pg-lang-calendar/go
go run calendar.go
```

#### Rust
```bash
cd /workspaces/multi-pg-lang-calendar/rust
echo -e "2025\n5" | ./target/release/calendar
```

### 一括テスト
```bash
cd /workspaces/multi-pg-lang-calendar
./scripts/build-test.sh
```

---

## 📊 各言語の特徴比較

| 項目 | C | Go | Rust |
|------|---|----|----- |
| ビルド時間 | 数秒 | 数秒 | 5-10分（初回） |
| メモリ管理 | 手動 | GC | 所有権システム |
| 実行速度 | 非常に高速 | 高速 | 非常に高速 |
| 安全性 | 低い | 中〜高 | 非常に高い |
| 学習難易度 | 中〜高 | 低〜中 | 高 |

---

## 🎉 第1日目完了！

以下を達成しました:
- ✅ C言語でカレンダー実装
- ✅ Go言語でカレンダー実装
- ✅ Rustでカレンダー実装
- ✅ 祝日データの取得と変換

## 📝 次のステップ

**第2日目** では以下を実施します:
- Kotlinでのカレンダー実装
- GitへのCommit & Push

→ `SETUP-2DAY.md` に続く
