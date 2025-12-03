# Multi-PG-Lang Calendar - セットアップガイド（第2日目）

## 📋 概要

第2日目では、Kotlinでのカレンダー実装とGitリポジトリへのPushを行います。

## 🎯 第2日目の目標

- Kotlinのインストールとセットアップ
- Kotlinでカレンダー実装
- 全言語の統合テスト
- GitへのCommit & Push

## 📦 前提条件

**第1日目を完了していること**
- C言語、Go言語、Rustのセットアップが完了
- プロジェクトディレクトリ: `/workspaces/multi-pg-lang-calendar`

---

## 🔧 ステップ1: Kotlinのセットアップ

### 1-1. Kotlinセットアップスクリプトを作成

GitHub Codespacesを起動後、ターミナルで以下を実行:

```bash
cd /workspaces/multi-pg-lang-calendar
nano setup-kotlin.sh
```

### 1-2. スクリプト③の内容を貼り付け

スクリプト③をコピーして貼り付けます（Ctrl+Shift+V）:
**注意**: 上記は概要版です。完全版は、以下のブログ記事のスクリプト③を使用してください:
https://my-studies.org/lets-create-a-calendar-that-handles-holidays-using-multiple-programming-languages-c-go-rust-kotlin-day-2/

```bash
#!/bin/bash
# ========================================
# Multi-PG-Lang Calendar
# スクリプト③：Kotlin完全インストール
# ========================================

echo "🚀 Multi-PG-Lang Calendar - Part 3: Kotlin Complete Setup"
echo "==========================================================="
echo ""

# ========================================
# Step 1: プロジェクトルート検出
# ========================================
echo "📍 Step 1: プロジェクトルート検出"
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
mkdir -p kotlin
echo "✅ ディレクトリ作成完了"
echo ""

# ========================================
# Step 3: SDKMAN状態確認とインストール
# ========================================
echo "🔧 Step 3: SDKMANセットアップ"
export SDKMAN_DIR="$HOME/.sdkman"

if [ ! -d "$HOME/.sdkman" ]; then
    echo "Installing SDKMAN..."
    curl -s "https://get.sdkman.io" | bash
    echo "✅ SDKMAN installed"
fi

# 環境変数設定
if [ -f "$HOME/.sdkman/bin/sdkman-init.sh" ]; then
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    echo "✅ SDKMAN environment loaded"
fi
echo ""

# ========================================
# Step 4: .bashrc に追記
# ========================================
echo "📝 Step 4: シェル設定ファイルに追記"
if [ -f "$HOME/.bashrc" ]; then
    if ! grep -q "SDKMAN_DIR.*/.sdkman" "$HOME/.bashrc"; then
        echo "" >> "$HOME/.bashrc"
        echo "# SDKMAN Configuration" >> "$HOME/.bashrc"
        echo "export SDKMAN_DIR=\"\$HOME/.sdkman\"" >> "$HOME/.bashrc"
        echo "[[ -s \"\$HOME/.sdkman/bin/sdkman-init.sh\" ]] && source \"\$HOME/.sdkman/bin/sdkman-init.sh\"" >> "$HOME/.bashrc"
        echo "✅ Added to ~/.bashrc"
    fi
fi
echo ""

# ========================================
# Step 5: Kotlinインストール
# ========================================
echo "📦 Step 5: Kotlinインストール"
source "$HOME/.sdkman/bin/sdkman-init.sh"

if ! command -v kotlin &> /dev/null; then
    echo "Installing Kotlin..."
    bash -c "export SDKMAN_DIR=$HOME/.sdkman && source $HOME/.sdkman/bin/sdkman-init.sh && sdk install kotlin" < /dev/null
    source "$HOME/.sdkman/bin/sdkman-init.sh"
fi

if command -v kotlin &> /dev/null; then
    echo "✅ Kotlin installed successfully"
    kotlin -version 2>&1 | head -1
fi
echo ""

# 以降のステップ: ソースコード作成、ビルド、テスト
# （完全版は元記事のスクリプト③を使用）

echo "✨ Kotlinセットアップ完了！"
```

### 1-3. スクリプトを保存して実行

```bash
# 保存: Ctrl+O → Enter → Ctrl+X
chmod +x setup-kotlin.sh
./setup-kotlin.sh
```

### 1-4. 実行結果の確認

以下のような出力が表示されます:

```
✅ Kotlinビルド成功
-rw-rw-rw- 1 codespace codespace 4.9M calendar.jar

🧪 Kotlinテスト実行 (2025年5月)
-----------------------------------

=== 月間カレンダー（祝日対応版）Kotlin ===

祝日データを読み込みました: 1050件

年を入力してください (例: 2025): 
月を入力してください (1-12): 

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

## 🧪 ステップ2: 統合テスト

### 2-1. 全言語を一括テスト

```bash
cd /workspaces/multi-pg-lang-calendar
./scripts/build-test-all.sh
```

### 2-2. 個別にテスト実行

#### Kotlin
```bash
cd /workspaces/multi-pg-lang-calendar/kotlin
echo -e "2025\n5" | java -jar calendar.jar
```

#### 他の言語も同様
```bash
# C言語
cd ../c
echo -e "2025\n5" | ./calendar

# Go言語
cd ../go
echo -e "2025\n5" | ./calendar

# Rust
cd ../rust
echo -e "2025\n5" | ./target/release/calendar
```

---

## 📁 完成したディレクトリ構造

```
multi-pg-lang-calendar/
├── c/
│   ├── calendar.c
│   ├── Makefile
│   ├── calendar          # 実行ファイル
│   └── holidays.csv -> ../data/holidays.csv
├── go/
│   ├── calendar.go
│   ├── go.mod
│   ├── calendar          # 実行ファイル
│   └── holidays.csv -> ../data/holidays.csv
├── kotlin/
│   ├── calendar.kt
│   ├── calendar.jar      # 実行ファイル
│   └── holidays.csv -> ../data/holidays.csv
├── rust/
│   ├── Cargo.toml
│   ├── src/
│   │   └── main.rs
│   ├── target/
│   │   └── release/
│   │       └── calendar  # 実行ファイル
│   └── holidays.csv -> ../data/holidays.csv
├── data/
│   └── holidays.csv
├── scripts/
│   ├── build-test.sh
│   └── build-test-all.sh
├── .gitignore
└── README.md
```

---

## 📤 ステップ3: Git & Push

### 3-1. サブディレクトリの.gitを削除

```bash
cd /workspaces/multi-pg-lang-calendar

# サブディレクトリの.gitディレクトリを削除
rm -rf rust/.git kotlin/.git c/.git go/.git

# 確認（プロジェクトルートの.gitのみ残っているべき）
find . -name ".git" -type d
```

**期待される出力**:
```
./.git
```

### 3-2. Git初期化（未実施の場合）

```bash
git init
git branch -M main
```

### 3-3. ステージングと状態確認

```bash
# 全ファイルをステージング
git add .

# 状態確認（重要！）
git status
```

**期待される出力例**:
```
On branch main

No commits yet

Changes to be committed:
  (use "git rm --cached <file>..." to unstage)
        new file:   .gitignore
        new file:   README.md
        new file:   c/Makefile
        new file:   c/calendar.c
        ...
```

### 3-4. コミット

```bash
git commit -m "Initial commit: Multi-PG-Lang Calendar (C, Go, Kotlin, Rust)"
```

### 3-5. リモートリポジトリの設定

**注意**: `your-username` を自分のGitHubユーザー名に置き換えてください。

```bash
git remote add origin https://github.com/your-username/multi-pg-lang-calendar.git
```

### 3-6. プッシュ

```bash
git push -u origin main --force
```

**注意**: 初回プッシュ時に認証が求められる場合があります。GitHubの指示に従ってください。

### 3-7. 最終確認

```bash
# Git状態確認
git status

# リモートリポジトリ確認
git remote -v
```

**期待される出力**:
```
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

```
origin  https://github.com/your-username/multi-pg-lang-calendar.git (fetch)
origin  https://github.com/your-username/multi-pg-lang-calendar.git (push)
```

---

## 🌐 ステップ4: GitHubでの確認

1. ブラウザでGitHubリポジトリを開く
2. 以下のファイルが表示されることを確認:
   - ✅ README.md
   - ✅ c/, go/, kotlin/, rust/ ディレクトリ
   - ✅ data/, scripts/ ディレクトリ
   - ✅ .gitignore

---

## 🎉 完成！

### 達成したこと

✅ **4つの言語でカレンダー実装**
- C言語
- Go言語
- Kotlin
- Rust

✅ **祝日対応**
- 内閣府の公式データ利用
- UTF-8変換対応

✅ **GitHubにアップロード**
- バージョン管理
- 公開リポジトリ

---

## 📊 4言語の比較

| 項目 | C | Go | Kotlin | Rust |
|------|---|----|----- |------|
| ビルド時間 | 数秒 | 数秒 | 数十秒 | 5-10分（初回） |
| 実行ファイルサイズ | 数十KB | 数MB | 数MB（JAR） | 数MB |
| メモリ管理 | 手動 | GC | JVM GC | 所有権システム |
| 実行速度 | 非常に高速 | 高速 | 中速 | 非常に高速 |
| Null安全 | なし | 中 | 高 | 最高 |
| 学習難易度 | 中〜高 | 低〜中 | 低〜中 | 高 |
| 典型的な用途 | OS、組み込み | サーバー、CLI | Android、JVMアプリ | システム、WebAssembly |

---

## 🛠️ トラブルシューティング

### Kotlinのビルドが失敗する場合

```bash
# 新しいターミナルを開く
source ~/.bashrc

# Kotlinが使えるか確認
kotlin -version

# ビルドを再試行
cd /workspaces/multi-pg-lang-calendar/kotlin
kotlinc calendar.kt -include-runtime -d calendar.jar
```

### Gitのプッシュが失敗する場合

```bash
# リモートURLを確認
git remote -v

# 認証情報を再設定
git config --global user.name "Your Name"
git config --global user.email "your-email@example.com"

# 再プッシュ
git push -u origin main --force
```

### サブディレクトリに.gitがある場合

```bash
# 全ての.gitディレクトリを検索
find . -name ".git" -type d

# プロジェクトルート以外の.gitを削除
rm -rf rust/.git kotlin/.git c/.git go/.git
```

---

## 📚 参考リンク

- **内閣府 祝日CSV**: https://www8.cao.go.jp/chosei/shukujitsu/syukujitsu.csv
- **GitHub Codespaces**: https://github.com/features/codespaces
- **SDKMAN**: https://sdkman.io/

---

## 🎊 おめでとうございます！

2日間のセットアップが完了しました。4つの言語で同じ機能を実装し、それぞれの特徴を比較できる環境が整いました。

### 次のステップ

- 各言語の実装を比較してみる
- カレンダー機能を拡張してみる
- 他の言語でも実装してみる
- パフォーマンス測定をしてみる

Happy Coding! 🚀
