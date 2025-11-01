#!/bin/bash

# ========================================
# Multi-PG-Lang Calendar
# Git初期化 & Push スクリプト（エラー時手動対応版）
# エラー発生時は詳細な手動手順を表示
# ========================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "📦 Git Repository Setup & Push"
echo "=========================================="
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
    echo -e "${RED}❌ プロジェクトディレクトリが見つかりません${NC}"
    exit 1
fi

cd "$PROJECT_ROOT"
echo -e "${GREEN}✅ プロジェクトルート: $(pwd)${NC}"
echo ""

# ========================================
# Step 2: Git設定確認
# ========================================

echo "🔧 Step 2: Git設定確認"
echo "-----------------------------------"

if ! command -v git &> /dev/null; then
    echo -e "${RED}❌ Git がインストールされていません${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Git version: $(git --version)${NC}"
echo ""

# Gitユーザー設定確認
GIT_USER_NAME=$(git config --global user.name 2>/dev/null)
GIT_USER_EMAIL=$(git config --global user.email 2>/dev/null)

if [ -z "$GIT_USER_NAME" ] || [ -z "$GIT_USER_EMAIL" ]; then
    echo -e "${YELLOW}⚠️  Git ユーザー情報が設定されていません${NC}"
    echo ""
    echo "以下のコマンドで設定してください:"
    echo -e "${BLUE}  git config --global user.name \"Your Name\"${NC}"
    echo -e "${BLUE}  git config --global user.email \"your.email@example.com\"${NC}"
    echo ""
    read -p "今すぐ設定しますか？ (y/n): " SETUP_NOW
    
    if [ "$SETUP_NOW" = "y" ]; then
        read -p "Git ユーザー名: " INPUT_NAME
        read -p "Git メールアドレス: " INPUT_EMAIL
        
        git config --global user.name "$INPUT_NAME"
        git config --global user.email "$INPUT_EMAIL"
        
        echo -e "${GREEN}✅ Git ユーザー情報を設定しました${NC}"
    else
        echo -e "${RED}❌ Git設定が必要です。スクリプトを終了します。${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✅ Git ユーザー情報:${NC}"
    echo "   Name: $GIT_USER_NAME"
    echo "   Email: $GIT_USER_EMAIL"
fi

echo ""

# ========================================
# Step 3: Git初期化
# ========================================

echo "📝 Step 3: Git初期化"
echo "-----------------------------------"

if [ -d ".git" ]; then
    echo -e "${YELLOW}⚠️  既にGitリポジトリが存在します${NC}"
    echo ""
    git log --oneline -5 2>/dev/null
    echo ""
    read -p "再初期化しますか？（既存の履歴は削除されます） (y/n): " REINIT
    
    if [ "$REINIT" = "y" ]; then
        rm -rf .git
        git init
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ Gitリポジトリを再初期化しました${NC}"
        else
            echo -e "${RED}❌ 初期化失敗${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}既存のリポジトリを使用します${NC}"
    fi
else
    git init
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Gitリポジトリを初期化しました${NC}"
    else
        echo -e "${RED}❌ 初期化失敗${NC}"
        exit 1
    fi
fi

echo ""

# ========================================
# Step 4: デフォルトブランチ設定
# ========================================

echo "🌿 Step 4: デフォルトブランチ設定"
echo "-----------------------------------"

git branch -M main
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ デフォルトブランチ: main${NC}"
else
    echo -e "${RED}❌ ブランチ設定失敗${NC}"
    exit 1
fi

echo ""

# ========================================
# Step 5: ファイルをステージング
# ========================================

echo "📋 Step 5: ファイルをステージング"
echo "-----------------------------------"

echo "現在の状態:"
git status --short

echo ""
read -p "全てのファイルをステージングしますか？ (y/n): " DO_ADD

if [ "$DO_ADD" != "y" ]; then
    echo -e "${YELLOW}⚠️  ステージングをスキップしました${NC}"
    echo ""
    echo "手動でステージングするには:"
    echo -e "${BLUE}  git add .${NC}"
    echo ""
    exit 0
fi

git add .

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ ステージング完了${NC}"
    echo ""
    echo "ステージングされたファイル:"
    git status --short
else
    echo -e "${RED}❌ ステージング失敗${NC}"
    echo ""
    echo "手動で実行してください:"
    echo -e "${BLUE}  git add .${NC}"
    exit 1
fi

echo ""

# ========================================
# Step 6: コミット
# ========================================

echo "💾 Step 6: コミット"
echo "-----------------------------------"

if git diff --cached --quiet; then
    echo -e "${YELLOW}⚠️  コミットする変更がありません${NC}"
else
    COMMIT_MESSAGE="Initial commit: Multi-PG-Lang Calendar (C, Go, Kotlin, Rust)"
    
    echo "コミットメッセージ:"
    echo "  $COMMIT_MESSAGE"
    echo ""
    read -p "このメッセージでコミットしますか？ (y/n): " DO_COMMIT
    
    if [ "$DO_COMMIT" = "y" ]; then
        git commit -m "$COMMIT_MESSAGE"
        
        if [ $? -eq 0 ]; then
            echo ""
            echo -e "${GREEN}✅ コミット成功${NC}"
            git log --oneline -1
        else
            echo -e "${RED}❌ コミット失敗${NC}"
            echo ""
            echo "手動でコミットしてください:"
            echo -e "${BLUE}  git commit -m \"Initial commit: Multi-PG-Lang Calendar\"${NC}"
            exit 1
        fi
    else
        echo -e "${YELLOW}⚠️  コミットをスキップしました${NC}"
        echo ""
        echo "手動でコミットするには:"
        echo -e "${BLUE}  git commit -m \"Your message here\"${NC}"
        exit 0
    fi
fi

echo ""

# ========================================
# Step 7: リモートリポジトリ設定
# ========================================

echo "🌐 Step 7: リモートリポジトリ設定"
echo "-----------------------------------"

# 既存のリモートを確認
EXISTING_REMOTE=$(git remote get-url origin 2>/dev/null)

if [ -n "$EXISTING_REMOTE" ]; then
    echo -e "${GREEN}既存のリモートリポジトリ:${NC}"
    echo "  $EXISTING_REMOTE"
    echo ""
    read -p "リモートを変更しますか？ (y/n): " CHANGE_REMOTE
    
    if [ "$CHANGE_REMOTE" = "y" ]; then
        git remote remove origin
        echo -e "${GREEN}既存のリモートを削除しました${NC}"
        REMOTE_SET=0
    else
        echo -e "${GREEN}既存のリモートを使用します${NC}"
        REMOTE_SET=1
    fi
else
    REMOTE_SET=0
fi

if [ "$REMOTE_SET" -eq 0 ]; then
    echo ""
    echo -e "${YELLOW}GitHubリポジトリのURLを入力してください${NC}"
    echo "例: https://github.com/username/multi-pg-lang-calendar.git"
    echo "または: git@github.com:username/multi-pg-lang-calendar.git"
    echo ""
    echo "（空Enter でスキップ）"
    read -p "リモートURL: " REMOTE_URL
    
    if [ -n "$REMOTE_URL" ]; then
        git remote add origin "$REMOTE_URL"
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ リモートリポジトリを設定しました${NC}"
        else
            echo -e "${RED}❌ リモート設定失敗${NC}"
            echo ""
            echo "手動で設定してください:"
            echo -e "${BLUE}  git remote add origin <URL>${NC}"
            exit 1
        fi
    else
        echo -e "${YELLOW}⚠️  リモートURLが入力されませんでした${NC}"
        echo ""
        echo "後で手動で設定してください:"
        echo -e "${BLUE}  git remote add origin <URL>${NC}"
        echo -e "${BLUE}  git push -u origin main${NC}"
        exit 0
    fi
fi

echo ""

# ========================================
# Step 8: プッシュ
# ========================================

echo "🚀 Step 8: プッシュ"
echo "-----------------------------------"

CURRENT_REMOTE=$(git remote get-url origin 2>/dev/null)

if [ -z "$CURRENT_REMOTE" ]; then
    echo -e "${YELLOW}⚠️  リモートリポジトリが設定されていません${NC}"
    echo ""
    echo "手動でプッシュするには:"
    echo -e "${BLUE}  1. GitHubでリポジトリを作成${NC}"
    echo -e "${BLUE}  2. git remote add origin <URL>${NC}"
    echo -e "${BLUE}  3. git push -u origin main${NC}"
    exit 0
fi

echo "リモートリポジトリ: $CURRENT_REMOTE"
echo ""
read -p "プッシュを実行しますか？ (y/n): " DO_PUSH

if [ "$DO_PUSH" != "y" ]; then
    echo -e "${YELLOW}⚠️  プッシュをスキップしました${NC}"
    echo ""
    echo "後で手動でプッシュするには:"
    echo -e "${BLUE}  git push -u origin main${NC}"
    exit 0
fi

echo ""
echo "プッシュ中..."
echo ""

git push -u origin main

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅✅✅ プッシュ成功！ ✅✅✅${NC}"
    echo ""
    echo "リポジトリURL: $CURRENT_REMOTE"
else
    echo ""
    echo -e "${RED}❌ プッシュ失敗${NC}"
    echo ""
    echo -e "${YELLOW}=========================================="
    echo "⚠️  プッシュエラー - 手動対応が必要です"
    echo "==========================================${NC}"
    echo ""
    echo -e "${BLUE}【よくあるエラーと対処法】${NC}"
    echo "-----------------------------------"
    echo ""
    echo "1️⃣  認証エラー (Authentication failed)"
    echo "   → Personal Access Token を使用してください"
    echo "   → https://github.com/settings/tokens"
    echo ""
    echo "2️⃣  リポジトリが存在しない (repository not found)"
    echo "   → GitHubで先にリポジトリを作成してください"
    echo "   → https://github.com/new"
    echo ""
    echo "3️⃣  既存のリポジトリと競合"
    echo "   → 以下のコマンドを実行:"
    echo -e "${BLUE}     git pull origin main --allow-unrelated-histories${NC}"
    echo -e "${BLUE}     git push -u origin main${NC}"
    echo ""
    echo "4️⃣  ブランチ名が違う"
    echo "   → リモートが master の場合:"
    echo -e "${BLUE}     git push -u origin main:master${NC}"
    echo ""
    echo -e "${YELLOW}【手動でプッシュを再試行】${NC}"
    echo "-----------------------------------"
    echo -e "${BLUE}  git push -u origin main${NC}"
    echo ""
    echo "または、強制プッシュ（注意！）:"
    echo -e "${BLUE}  git push -u origin main --force${NC}"
    echo ""
    exit 1
fi

echo ""

# ========================================
# Step 9: 追加コミット用スクリプト作成
# ========================================

echo "📝 Step 9: 追加コミット用スクリプト作成"
echo "-----------------------------------"

cat > scripts/git-commit-push.sh << 'GIT_COMMIT_EOF'
#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "📦 Git Commit & Push"
echo "=========================================="
echo ""

# プロジェクトルート検出
if [ -d "/workspaces/multi-pg-lang-calendar" ]; then
    PROJECT_ROOT="/workspaces/multi-pg-lang-calendar"
elif [ -d "$HOME/multi-pg-lang-calendar" ]; then
    PROJECT_ROOT="$HOME/multi-pg-lang-calendar"
else
    echo -e "${RED}❌ プロジェクトディレクトリが見つかりません${NC}"
    exit 1
fi

cd "$PROJECT_ROOT"

# ステータス確認
echo "📋 変更されたファイル:"
echo "-----------------------------------"
git status --short

if git diff --quiet && git diff --cached --quiet; then
    echo ""
    echo -e "${YELLOW}⚠️  コミットする変更がありません${NC}"
    exit 0
fi

echo ""

# コミットメッセージ入力
read -p "コミットメッセージを入力してください: " COMMIT_MSG

if [ -z "$COMMIT_MSG" ]; then
    echo -e "${RED}❌ コミットメッセージが空です${NC}"
    exit 1
fi

# ステージングとコミット
echo ""
read -p "全てのファイルをステージングしますか？ (y/n): " DO_ADD

if [ "$DO_ADD" = "y" ]; then
    git add .
    echo -e "${GREEN}✅ ステージング完了${NC}"
fi

git commit -m "$COMMIT_MSG"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ コミット成功${NC}"
else
    echo -e "${RED}❌ コミット失敗${NC}"
    exit 1
fi

# プッシュ
echo ""
read -p "プッシュしますか？ (y/n): " DO_PUSH

if [ "$DO_PUSH" = "y" ]; then
    git push
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ プッシュ成功${NC}"
    else
        echo -e "${RED}❌ プッシュ失敗${NC}"
        echo ""
        echo "手動で再試行してください:"
        echo -e "${BLUE}  git push${NC}"
    fi
else
    echo -e "${YELLOW}プッシュをスキップしました${NC}"
    echo ""
    echo "後でプッシュするには:"
    echo -e "${BLUE}  git push${NC}"
fi

echo ""
echo "完了！"
GIT_COMMIT_EOF

chmod +x scripts/git-commit-push.sh
echo -e "${GREEN}✅ scripts/git-commit-push.sh 作成完了${NC}"

echo ""

# ========================================
# 完了メッセージ
# ========================================

echo "=========================================="
echo -e "${GREEN}✨ Git セットアップ完了！${NC}"
echo "=========================================="
echo ""
echo "📁 プロジェクト: $PROJECT_ROOT"
echo "🌿 ブランチ: main"
echo "🌐 リモート: $CURRENT_REMOTE"
echo ""
echo -e "${BLUE}📝 便利なコマンド:${NC}"
echo "-----------------------------------"
echo "  状態確認:"
echo "    git status"
echo ""
echo "  変更を追加・コミット・プッシュ:"
echo "    ./scripts/git-commit-push.sh"
echo ""
echo "  手動でコミット:"
echo "    git add ."
echo "    git commit -m 'メッセージ'"
echo "    git push"
echo ""
echo "  履歴確認:"
echo "    git log --oneline"
echo ""
echo "  ブランチ確認:"
echo "    git branch -a"
echo ""
echo "=========================================="
echo ""
