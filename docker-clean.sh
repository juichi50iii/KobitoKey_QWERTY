#!/bin/bash

# KobitoKey ビルド環境クリーンアップスクリプト
# West ワークスペース、依存モジュール、ビルド成果物を削除して初期状態に戻します

set -e  # エラーが発生したら即座に終了

# 色付き出力
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 削除対象のディレクトリ/ファイル
TARGETS=(
    ".west"
    "zmk"
    "modules"
    "zephyr"
    "build"
    "bootloader"
    "tools"
)

# メイン処理
main() {
    echo -e "${YELLOW}========================================${NC}"
    echo -e "${YELLOW}KobitoKey ビルド環境のクリーンアップ${NC}"
    echo -e "${YELLOW}========================================${NC}"
    echo ""

    # 削除対象の確認
    echo -e "${BLUE}以下のディレクトリ/ファイルを削除します:${NC}"
    echo ""

    local found_targets=()
    for target in "${TARGETS[@]}"; do
        if [ -e "$target" ]; then
            found_targets+=("$target")
            echo -e "  ${RED}✗${NC} $target"
        else
            echo -e "  ${GREEN}✓${NC} $target (存在しません)"
        fi
    done
    echo ""

    # 削除対象が存在しない場合
    if [ ${#found_targets[@]} -eq 0 ]; then
        echo -e "${GREEN}クリーンアップする対象がありません。${NC}"
        echo -e "${GREEN}環境は既にクリーンな状態です。${NC}"
        echo ""
        return 0
    fi

    # 確認メッセージ
    echo -e "${YELLOW}警告: この操作は取り消せません。${NC}"
    echo -e "${YELLOW}削除後は ./docker-init.sh で再初期化が必要です。${NC}"
    echo ""
    read -p "本当に削除しますか? [y/N] " -n 1 -r
    echo ""

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}中止しました${NC}"
        return 0
    fi

    echo ""
    echo -e "${RED}クリーンアップを開始します...${NC}"
    echo ""

    # 削除処理
    for target in "${found_targets[@]}"; do
        echo -e "${BLUE}削除中: $target${NC}"
        rm -rf "$target"
        echo -e "${GREEN}✓ $target を削除しました${NC}"
    done

    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}クリーンアップが完了しました！${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "${YELLOW}次のステップ:${NC}"
    echo -e "  1. 環境を再初期化: ${BLUE}./docker-init.sh${NC}"
    echo -e "  2. ファームウェアをビルド: ${BLUE}./docker-build.sh${NC}"
    echo ""
}

# エラーハンドラー
error_handler() {
    echo -e "${RED}========================================${NC}"
    echo -e "${RED}エラーが発生しました${NC}"
    echo -e "${RED}========================================${NC}"
    echo ""
    exit 1
}

trap error_handler ERR

# ヘルプ表示
show_help() {
    echo "使用法: $0 [オプション]"
    echo ""
    echo "オプション:"
    echo "  -h, --help     このヘルプを表示"
    echo "  -f, --force    確認なしで削除を実行"
    echo ""
    echo "説明:"
    echo "  このスクリプトは ZMK ビルド環境を完全にクリーンアップします。"
    echo "  以下のディレクトリ/ファイルが削除されます:"
    for target in "${TARGETS[@]}"; do
        echo "    - $target"
    done
    echo ""
    echo "例:"
    echo "  $0              # 確認メッセージ付きで実行"
    echo "  $0 -f           # 確認なしで実行"
    echo ""
}

# 引数の処理
case "${1:-}" in
    -h|--help)
        show_help
        exit 0
        ;;
    -f|--force)
        # 強制モード: 確認をスキップ
        echo -e "${YELLOW}========================================${NC}"
        echo -e "${YELLOW}強制クリーンアップモード${NC}"
        echo -e "${YELLOW}========================================${NC}"
        echo ""

        for target in "${TARGETS[@]}"; do
            if [ -e "$target" ]; then
                echo -e "${BLUE}削除中: $target${NC}"
                rm -rf "$target"
                echo -e "${GREEN}✓ $target を削除しました${NC}"
            fi
        done

        echo ""
        echo -e "${GREEN}クリーンアップが完了しました！${NC}"
        ;;
    "")
        # 通常モード
        main "$@"
        ;;
    *)
        echo -e "${RED}エラー: 不明なオプション '$1'${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac
