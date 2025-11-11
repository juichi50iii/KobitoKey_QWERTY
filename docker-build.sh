#!/bin/bash

# KobitoKey ファームウェア Docker ビルドスクリプト
# 左側、右側、設定リセットの3つのファームウェアを一括ビルドします

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

# ヘルパー関数: ビルド
build_target() {
    local target_name=$1
    local build_dir=$2
    local shield=$3

    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}ビルド中: ${target_name}${NC}"
    echo -e "${BLUE}========================================${NC}"

    run_docker west build -p -d "$build_dir" -b seeeduino_xiao_ble -- \
        -DSHIELD="$shield"

    echo -e "${GREEN}✓ ${target_name} のビルドが完了しました${NC}"
    echo ""
}

# メイン処理
main() {
    echo -e "${GREEN}KobitoKey ファームウェアのビルドを開始します...${NC}"
    echo ""

    # Docker イメージの確認
    echo -e "${YELLOW}Docker イメージを確認中...${NC}"
    if ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
        echo -e "${YELLOW}Docker イメージが見つかりません。ダウンロードします...${NC}"
        docker pull "$IMAGE"
    else
        echo -e "${GREEN}✓ Docker イメージが見つかりました${NC}"
    fi
    echo ""

    # ビルド開始時刻
    start_time=$(date +%s)

    # 左側のビルド
    build_target "左側キーボード" "build/left" "KobitoKey_left rgbled_adapter"

    # 右側のビルド
    build_target "右側キーボード" "build/right" "KobitoKey_right rgbled_adapter"

    # 設定リセットのビルド
    build_target "設定リセット" "build/settings_reset" "settings_reset"

    # ビルド終了時刻
    end_time=$(date +%s)
    elapsed=$((end_time - start_time))

    # 完了メッセージ
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}すべてのビルドが完了しました！${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "${BLUE}ビルド時間: ${elapsed}秒${NC}"
    echo ""
    echo -e "${YELLOW}ファームウェアファイルの場所:${NC}"
    echo -e "  左側:           ${GREEN}build/left/zephyr/zmk.uf2${NC}"
    echo -e "  右側:           ${GREEN}build/right/zephyr/zmk.uf2${NC}"
    echo -e "  設定リセット:   ${GREEN}build/settings_reset/zephyr/zmk.uf2${NC}"
    echo ""
    echo -e "${YELLOW}次のステップ:${NC}"
    echo -e "  1. キーボードをブートローダーモードで接続"
    echo -e "  2. 上記の .uf2 ファイルをキーボードにコピー"
    echo -e "  3. 詳細は DOCKER_BUILD_SETUP.md を参照"
    echo ""
}

# エラーハンドラー
error_handler() {
    echo -e "${RED}========================================${NC}"
    echo -e "${RED}エラーが発生しました${NC}"
    echo -e "${RED}========================================${NC}"
    echo ""
    echo -e "${YELLOW}トラブルシューティング:${NC}"
    echo -e "  1. Docker が起動していることを確認してください"
    echo -e "  2. ./docker-init.sh を実行してみてください"
    echo -e "  3. 詳細は DOCKER_BUILD_SETUP.md を参照してください"
    echo ""
    exit 1
}

trap error_handler ERR

# スクリプト実行
main "$@"
