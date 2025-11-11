#!/bin/bash

# KobitoKey ファームウェア Docker 初期化スクリプト
# Docker イメージのダウンロードと West ワークスペースの初期化を行います

set -e  # エラーが発生したら即座に終了

# 設定
IMAGE="zmkfirmware/zmk-build-arm:stable"
WORKSPACE="/workspace"

# 色付き出力
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# ヘルパー関数: Docker を実行
run_docker() {
    docker run --rm -it \
        --user $(id -u):$(id -g) \
        -v "$PWD:$WORKSPACE" \
        -w "$WORKSPACE" \
        "$IMAGE" \
        "$@"
}

# メイン処理
main() {
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}KobitoKey ビルド環境の初期化${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""

    # ステップ 1: Docker イメージのダウンロード
    echo -e "${BLUE}[1/4] Docker イメージをダウンロード中...${NC}"
    if docker image inspect "$IMAGE" >/dev/null 2>&1; then
        echo -e "${YELLOW}既に Docker イメージが存在します。最新版を確認中...${NC}"
        docker pull "$IMAGE"
    else
        docker pull "$IMAGE"
    fi
    echo -e "${GREEN}✓ Docker イメージの準備が完了しました${NC}"
    echo ""

    # ステップ 2: West ワークスペースの初期化
    echo -e "${BLUE}[2/4] West ワークスペースを初期化中...${NC}"
    if [ -d ".west" ]; then
        echo -e "${YELLOW}.west ディレクトリが既に存在します。スキップします。${NC}"
    else
        run_docker west init -l config
        echo -e "${GREEN}✓ West ワークスペースの初期化が完了しました${NC}"
    fi
    echo ""

    # ステップ 3: 依存モジュールの更新
    echo -e "${BLUE}[3/4] 依存モジュールを更新中...${NC}"
    echo -e "${YELLOW}この処理には数分かかる場合があります${NC}"
    run_docker west update
    echo -e "${GREEN}✓ 依存モジュールの更新が完了しました${NC}"
    echo ""

    # ステップ 4: Zephyr のエクスポート
    echo -e "${BLUE}[4/4] Zephyr をエクスポート中...${NC}"
    run_docker west zephyr-export
    echo -e "${GREEN}✓ Zephyr のエクスポートが完了しました${NC}"
    echo ""

    # 完了メッセージ
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}初期化が完了しました！${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "${YELLOW}次のステップ:${NC}"
    echo -e "  1. キーマップを編集: ${BLUE}boards/shields/KobitoKey/KobitoKey.keymap${NC}"
    echo -e "  2. ファームウェアをビルド: ${BLUE}./docker-build.sh${NC}"
    echo ""
    echo -e "${YELLOW}参考ドキュメント:${NC}"
    echo -e "  - Docker ビルドガイド: ${BLUE}DOCKER_BUILD_SETUP.md${NC}"
    echo ""
}

# エラーハンドラー
error_handler() {
    echo -e "${RED}========================================${NC}"
    echo -e "${RED}エラーが発生しました${NC}"
    echo -e "${RED}========================================${NC}"
    echo ""
    echo -e "${YELLOW}トラブルシューティング:${NC}"
    echo -e "  1. Docker Desktop が起動していることを確認してください"
    echo -e "     コマンド: ${BLUE}docker --version${NC}"
    echo ""
    echo -e "  2. インターネット接続を確認してください"
    echo ""
    echo -e "  3. .west ディレクトリがある場合は削除して再試行してください"
    echo -e "     コマンド: ${BLUE}rm -rf .west zmk modules${NC}"
    echo ""
    echo -e "  4. 詳細は DOCKER_BUILD_SETUP.md を参照してください"
    echo ""
    exit 1
}

trap error_handler ERR

# 確認メッセージ
if [ -d ".west" ] || [ -d "zmk" ]; then
    echo -e "${YELLOW}警告: .west または zmk ディレクトリが既に存在します。${NC}"
    echo -e "${YELLOW}既存の設定を保持したまま、必要な更新のみを行います。${NC}"
    echo ""
    read -p "続行しますか? [Y/n] " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]] && [[ ! -z $REPLY ]]; then
        echo -e "${YELLOW}中止しました${NC}"
        exit 0
    fi
fi

# スクリプト実行
main "$@"
