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

<<<<<<< HEAD
### Individual Build & Test(個別ビルド＆テスト)
=======
### Individual Build & Test
>>>>>>> 40b5944 (Edit Many Files)

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
