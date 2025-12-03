# 🗓️ Multi-PG-Lang Calendar

Calendar App implemented in C, Go, Kotlin & Rust  
C言語、Go、Kotlin、Rustで実装した祝日対応カレンダー

## ✨ Features

- 🌐 **4つのプログラミング言語で同じ機能を実装**
  - C言語、Go、Kotlin、Rust
- 📥 **内閣府の祝日データ対応**
  - 公式CSVを自動取得
  - Shift_JIS → UTF-8変換対応
- 🚀 **GitHub Codespaces で即座に試せる**
  - ブラウザだけで開発環境を構築
  - 環境構築の手間なし
- 📊 **言語間の比較が可能**
  - パフォーマンス
  - コードの書きやすさ
  - 実行ファイルサイズ

---

## 🚀 Quick Start

### GitHub Codespacesで始める

1. このリポジトリで **「<> Code」** ボタンをクリック
2. **「Codespaces」** タブを選択
3. **「Create codespace on main」** をクリック

詳しくは **[セットアップガイド](#-セットアップガイド)** を参照してください。

### All Languages (自動ビルド＆テスト)

```bash
./scripts/build-test-all.sh
```

---

## 🔨 Individual Build & Test（個別ビルド＆テスト）

### C言語

```bash
cd c
make
echo -e "2025\n5" | ./calendar
```

または手動入力:

```bash
./calendar
# 年を入力: 2025
# 月を入力: 5
```

### Go言語

```bash
cd go
go build -o calendar calendar.go
echo -e "2025\n5" | ./calendar
```

または:

```bash
go run calendar.go
```

### Kotlin

```bash
cd kotlin
kotlinc calendar.kt -include-runtime -d calendar.jar
echo -e "2025\n5" | java -jar calendar.jar
```

### Rust

```bash
cd rust
cargo build --release
echo -e "2025\n5" | ./target/release/calendar
```

---

## 📁 Directory Structure

```
multi-pg-lang-calendar/
├── c/                          # C言語実装
│   ├── calendar.c              # ソースコード
│   ├── Makefile                # ビルド設定
│   └── holidays.csv -> ../data/holidays.csv
├── go/                         # Go実装
│   ├── calendar.go             # ソースコード
│   ├── go.mod                  # Go module設定
│   └── holidays.csv -> ../data/holidays.csv
├── kotlin/                     # Kotlin実装
│   ├── calendar.kt             # ソースコード
│   └── holidays.csv -> ../data/holidays.csv
├── rust/                       # Rust実装
│   ├── Cargo.toml              # ビルド設定
│   ├── src/
│   │   └── main.rs             # ソースコード
│   └── holidays.csv -> ../data/holidays.csv
├── data/                       # 共通データ
│   └── holidays.csv            # 祝日データ（UTF-8）
├── scripts/                    # スクリプト
│   ├── build-test.sh           # C & Go テスト
│   └── build-test-all.sh       # 全言語テスト
├── .gitignore                  # Git除外設定
├── README.md                   # このファイル
├── SETUP-1DAY.md              # セットアップガイド（第1日目）
└── SETUP-2DAY.md              # セットアップガイド（第2日目）
└── git-setup.sh               # Git初期化 & Push スクリプト

```

---

## 📚 セットアップガイド

### 🗓️ 2日間で完成！

#### 第1日目：C、Go、Rustのセットアップ
**所要時間**: 約20-30分（Rustビルド含む）

- GitHub Codespacesの起動
- C言語とGo言語の環境構築
- Rustの環境構築とビルド

👉 **[SETUP-1DAY.md](./SETUP-1DAY.md)** を参照

#### 第2日目：Kotlin、Git & Push
**所要時間**: 約15-20分

- Kotlinの環境構築
- 4言語の統合テスト
- GitへのCommit & Push

👉 **[SETUP-2DAY.md](./SETUP-2DAY.md)** を参照

---

## 📊 言語比較

| 項目 | C | Go | Kotlin | Rust |
|------|---|----|----- |------|
| **ビルド時間** | 数秒 | 数秒 | 数十秒 | 5-10分（初回） |
| **実行速度** | ⚡️ 非常に高速 | ⚡️ 高速 | 🐢 中速 | ⚡️ 非常に高速 |
| **メモリ管理** | 手動 | GC | JVM GC | 所有権システム |
| **Null安全** | ❌ なし | 🟡 中 | ✅ 高 | ✅✅ 最高 |
| **学習難易度** | 🟡 中〜高 | 🟢 低〜中 | 🟢 低〜中 | 🔴 高 |
| **典型的な用途** | OS、組み込み | サーバー、CLI | Android、JVM | システム、WebAssembly |
| **実行ファイルサイズ** | 数十KB | 数MB | 数MB（JAR） | 数MB |

---

## 🎯 実行例

```bash
$ cd c && ./calendar

=== 月間カレンダー（祝日対応版）C言語 ===

祝日データを読み込みました: 1050件

年を入力してください (例: 2025): 2025
月を入力してください (1-12): 5

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

**注意**: `*` は祝日を示します

---

## 🔧 技術詳細

### 祝日データの取得

内閣府が公開している公式の祝日CSVを使用:
- **URL**: https://www8.cao.go.jp/chosei/shukujitsu/syukujitsu.csv
- **フォーマット**: Shift_JIS → UTF-8に自動変換
- **データ範囲**: 昭和30年（1955年）以降の全祝日

### 各言語の実装特徴

#### C言語
- **特徴**: 最小限のランタイム、高速実行
- **ライブラリ**: 標準ライブラリのみ
- **ビルドツール**: Makefile + gcc

#### Go言語
- **特徴**: シンプルで読みやすいコード
- **ライブラリ**: 標準ライブラリ + HTTP client
- **ビルドツール**: go modules

#### Kotlin
- **特徴**: null安全、Java互換
- **ライブラリ**: Kotlin標準ライブラリ
- **ビルドツール**: kotlinc
- **実行**: JVM上で動作

#### Rust
- **特徴**: メモリ安全、高性能
- **ライブラリ**: 
  - `reqwest`: HTTP通信
  - `encoding_rs`: 文字コード変換
- **ビルドツール**: Cargo

---

## 🛠️ トラブルシューティング

### ビルドエラーが発生した場合

```bash
# 依存関係の確認
cd <言語ディレクトリ>

# C言語
make clean && make

# Go
go mod tidy
go build

# Kotlin
source ~/.bashrc  # SDKMANの再読み込み
kotlinc -version  # バージョン確認

# Rust
cargo clean
cargo build --release
```

### 祝日データが読み込めない場合

```bash
# データファイルの確認
ls -l data/holidays.csv

# シンボリックリンクの確認
ls -l c/holidays.csv go/holidays.csv kotlin/holidays.csv rust/holidays.csv

# 再ダウンロード
curl -o data/holidays_sjis.csv https://www8.cao.go.jp/chosei/shukujitsu/syukujitsu.csv
iconv -f SHIFT_JIS -t UTF-8 data/holidays_sjis.csv > data/holidays.csv
```

詳しくは **[SETUP-2DAY.md](./SETUP-2DAY.md)** のトラブルシューティングセクションを参照してください。

---

## 🤝 Contributing

プルリクエストを歓迎します！以下のような改善を募集しています:

- 他の言語での実装（Python、Java、C#など）
- パフォーマンス測定機能の追加
- UI/UXの改善
- バグ修正

---

## 📄 License

MIT License

---

## 🔗 参考リンク

- **内閣府 祝日データ**: https://www8.cao.go.jp/chosei/shukujitsu/syukujitsu.csv
- **GitHub Codespaces**: https://github.com/features/codespaces
- **プロジェクトブログ記事**:
  - [第1日目: C、Go、Rust](https://my-studies.org/lets-create-a-calendar-that-handles-holidays-using-multiple-programming-languages-c-go-rust-kotlin-day-1/)
  - [第2日目: Kotlin、Git & Push](https://my-studies.org/lets-create-a-calendar-that-handles-holidays-using-multiple-programming-languages-c-go-rust-kotlin-day-2/)

---

## 📮 Contact

質問や提案がある場合は、[Issues](../../issues)を作成してください。

---

**Made with ❤️ by developers learning multiple programming languages**
