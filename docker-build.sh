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
    # TTYが利用可能かチェック
    if [ -t 0 ]; then
        local TTY_FLAG="-it"
    else
        local TTY_FLAG="-i"
    fi

    docker run --rm $TTY_FLAG \
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
    local cmake_args=$4
    local snippet=$5

    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}ビルド中: ${target_name}${NC}"
    echo -e "${BLUE}========================================${NC}"

    # west buildコマンドの構築
    # snippetは -S オプションとして -- の前に配置する必要がある
    local build_cmd=(west build -s zmk/app -p -d "$build_dir" -b seeeduino_xiao_ble)

    # snippetがある場合は --の前に追加
    if [ -n "$snippet" ]; then
        build_cmd+=(-S "$snippet")
    fi

    # -- 以降にCMake引数を追加
    build_cmd+=(--)
    build_cmd+=(-DZMK_CONFIG="$WORKSPACE/config")
    build_cmd+=(-DZephyr_DIR="$WORKSPACE/zephyr/share/zephyr-package/cmake")
    build_cmd+=(-DSHIELD="$shield")

    # 追加のCMake引数
    if [ -n "$cmake_args" ]; then
        build_cmd+=("$cmake_args")
    fi

    run_docker "${build_cmd[@]}"

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

    # Zephyr のエクスポート
    echo -e "${YELLOW}Zephyr をエクスポート中...${NC}"
    run_docker west zephyr-export
    echo -e "${GREEN}✓ Zephyr のエクスポートが完了しました${NC}"
    echo ""

    # ビルド開始時刻
    start_time=$(date +%s)

    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}ドングルなし構成のビルド${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""

    # 左側のビルド（ドングルなし）
    build_target "左側キーボード（ドングルなし）" \
        "build/left_dongleless" \
        "KobitoKey_left rgbled_adapter"

    # 右側のビルド（ドングルなし）
    build_target "右側キーボード（ドングルなし）" \
        "build/right_dongleless" \
        "KobitoKey_right rgbled_adapter"

    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}ドングルあり構成のビルド${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""

    # ドングルのビルド（XIAO BLE版）
    build_target "ドングル（XIAO BLE版）" \
        "build/dongle" \
        "KobitoKey_dongle_xiao" \
        "-DCONFIG_ZMK_STUDIO=y" \
        "studio-rpc-usb-uart"

    # ドングルのビルド（Prospector版）
    build_target "ドングル（Prospector版）" \
        "build/dongle_prospector" \
        "KobitoKey_dongle_xiao prospector_adapter" \
        "-DCONFIG_ZMK_STUDIO=y" \
        "studio-rpc-usb-uart"

    # 左側ペリフェラルのビルド
    build_target "左側ペリフェラル" \
        "build/left_peripheral" \
        "KobitoKey_left_peripheral rgbled_adapter"

    # 右側ペリフェラルのビルド
    build_target "右側ペリフェラル" \
        "build/right_peripheral" \
        "KobitoKey_right_peripheral rgbled_adapter"

    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}共通ファームウェアのビルド${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""

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
    echo ""
    echo -e "${BLUE}【ドングルなし構成】${NC}"
    echo -e "  左側:           ${GREEN}build/left_dongleless/zephyr/zmk.uf2${NC}"
    echo -e "  右側:           ${GREEN}build/right_dongleless/zephyr/zmk.uf2${NC}"
    echo ""
    echo -e "${BLUE}【ドングルあり構成】${NC}"
    echo -e "  ドングル（XIAO BLE版）:  ${GREEN}build/dongle/zephyr/zmk.uf2${NC}"
    echo -e "  ドングル（Prospector版）: ${GREEN}build/dongle_prospector/zephyr/zmk.uf2${NC}"
    echo -e "  左ペリフェラル:          ${GREEN}build/left_peripheral/zephyr/zmk.uf2${NC}"
    echo -e "  右ペリフェラル:          ${GREEN}build/right_peripheral/zephyr/zmk.uf2${NC}"
    echo ""
    echo -e "${BLUE}【共通】${NC}"
    echo -e "  設定リセット:   ${GREEN}build/settings_reset/zephyr/zmk.uf2${NC}"
    echo ""
    echo -e "${YELLOW}次のステップ:${NC}"
    echo -e "  1. 使用する構成を選択（ドングルあり/なし）"
    echo -e "  2. キーボードをブートローダーモードで接続"
    echo -e "  3. 対応する .uf2 ファイルをキーボードにコピー"
    echo -e "  4. 詳細は DONGLE_IMPLEMENTATION_PLAN.md を参照"
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
