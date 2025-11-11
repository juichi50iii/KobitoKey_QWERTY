# Docker を使った KobitoKey ファームウェアのビルド

このガイドでは、Docker を使用して KobitoKey のファームウェアを簡単にビルドする方法を説明します。

## なぜ Docker を使うのか？

### メリット

- **セットアップが簡単**: 複雑な依存関係のインストールが不要
- **環境の一貫性**: GitHub Actions と同じ環境でビルド
- **クリーンな環境**: ローカルシステムを汚さない
- **クロスプラットフォーム**: Windows、macOS、Linux で同じ手順
- **メンテナンスが容易**: `docker pull` だけで最新環境に更新

### ネイティブビルドとの比較

| 項目 | Docker | ネイティブ |
|------|--------|------------|
| 初回セットアップ時間 | 5分 | 30-60分 |
| 必要なディスク容量 | 2-3GB | 10GB以上 |
| ビルド速度 | やや遅い（5-15%） | 速い |
| メンテナンス | 簡単 | 複雑 |
| IDE統合 | 制限あり | フル機能 |

**推奨**: キーマップの変更など日常的なビルドには Docker を、高度な開発にはネイティブ環境を使用。

## 前提条件

使用しているプラットフォームに応じて、Docker をインストールしてください。

### Windows (WSL2)

- **Docker Desktop for Windows** (WSL2 バックエンド)
  - インストール: https://www.docker.com/products/docker-desktop
  - WSL2 統合を有効にする必要があります

### macOS

- **Docker Desktop for Mac**
  - インストール: https://www.docker.com/products/docker-desktop
  - Apple Silicon (M1/M2) でも問題なく動作します

### Linux (Ubuntu/Debian など)

- **Docker Engine** または **Docker Desktop for Linux**
  - Docker Engine: `sudo apt-get install docker.io` (Ubuntu/Debian)
  - 詳細: https://docs.docker.com/engine/install/
  - ユーザーを docker グループに追加: `sudo usermod -aG docker $USER`

### Docker の動作確認

インストール後、Docker が正常に動作していることを確認してください：
```bash
docker --version
docker run hello-world
```

## クイックスタート

### 1. 初回セットアップ

プロジェクトディレクトリで以下を実行：

```bash
./docker-init.sh
```

このスクリプトは以下を実行します：
- Docker イメージのダウンロード
- West ワークスペースの初期化
- 依存モジュールの更新

### 2. ファームウェアのビルド

```bash
./docker-build.sh
```

このスクリプトは以下の3つのファームウェアをビルドします：
- 左側キーボード (`build/left/zephyr/zmk.uf2`)
- 右側キーボード (`build/right/zephyr/zmk.uf2`)
- 設定リセット (`build/settings_reset/zephyr/zmk.uf2`)

### 3. ファームウェアの書き込み

ビルドが完了したら、以下の手順でファームウェアを書き込んでください：

1. キーボードをブートローダーモードで接続
   - リセットボタンをダブルクリック、または
   - 既存のファームウェアでブートローダーに入るキーコンボを使用
2. キーボードがUSBストレージデバイスとしてマウントされる
3. 生成された `.uf2` ファイルをキーボードにコピー
4. コピーが完了すると自動的に再起動してファームウェアが適用される

## 手動ビルド（個別のターゲット）

スクリプトを使わず、個別にビルドする場合：

### 左側のみビルド

```bash
docker run --rm -it \
  -v "$PWD:/workspace" \
  -w /workspace \
  zmkfirmware/zmk-build-arm:stable \
  west build -p -d build/left -b seeeduino_xiao_ble -- \
    -DSHIELD="KobitoKey_left rgbled_adapter"
```

### 右側のみビルド

```bash
docker run --rm -it \
  -v "$PWD:/workspace" \
  -w /workspace \
  zmkfirmware/zmk-build-arm:stable \
  west build -p -d build/right -b seeeduino_xiao_ble -- \
    -DSHIELD="KobitoKey_right rgbled_adapter"
```

### 設定リセットのみビルド

```bash
docker run --rm -it \
  -v "$PWD:/workspace" \
  -w /workspace \
  zmkfirmware/zmk-build-arm:stable \
  west build -p -d build/settings_reset -b seeeduino_xiao_ble -- \
    -DSHIELD=settings_reset
```

## 依存関係の更新

`config/west.yml` を変更した場合や、ZMK のバージョンを更新した場合：

```bash
docker run --rm -it \
  -v "$PWD:/workspace" \
  -w /workspace \
  zmkfirmware/zmk-build-arm:stable \
  west update
```

または、`docker-init.sh` を再実行してください。

## Docker イメージの更新

ZMK の Docker イメージを最新版に更新する場合：

```bash
docker pull zmkfirmware/zmk-build-arm:stable
```

特定のバージョンを使用する場合：

```bash
docker pull zmkfirmware/zmk-build-arm:2.5
```

## トラブルシューティング

### ビルドエラー: "west: command not found"

**原因**: West ワークスペースが初期化されていない

**解決策**:
```bash
./docker-init.sh
```

### パーミッションエラー

**原因**: Docker がファイルを root として作成する場合がある

**解決策**:
```bash
sudo chown -R $USER:$USER build/
```

または、ビルドコマンドに `--user $(id -u):$(id -g)` を追加：
```bash
docker run --rm -it \
  --user $(id -u):$(id -g) \
  -v "$PWD:/workspace" \
  -w /workspace \
  zmkfirmware/zmk-build-arm:stable \
  west build ...
```

### Docker が遅い

**原因**: Docker のファイルシステムオーバーヘッド

**対策**:

#### WSL2 (Windows) の場合
プロジェクトを WSL2 ファイルシステム上に配置してください（`/mnt/c` ではなく `/home` 配下）。

Windowsファイルシステム (`/mnt/c/Users/...`) からのアクセスは非常に遅いため、必ず WSL2 のネイティブファイルシステムを使用してください：
```bash
# 良い例 (速い)
/home/username/work/KobitoKey_QWERTY

# 悪い例 (遅い)
/mnt/c/Users/username/Documents/KobitoKey_QWERTY
```

#### すべてのプラットフォーム共通
ccache を使用してビルドキャッシュを永続化：
```bash
docker run --rm -it \
  -v "$PWD:/workspace" \
  -v "$HOME/.ccache:/root/.ccache" \
  -w /workspace \
  zmkfirmware/zmk-build-arm:stable \
  west build ...
```

### ビルドキャッシュをクリア

ビルドキャッシュが破損した場合：

```bash
rm -rf build/
```

その後、再度ビルドを実行してください。

### Docker が起動しない・接続できない

#### Windows (WSL2) の場合

Docker Desktop が起動しない、または WSL2 から接続できない場合：

1. Windows で Docker Desktop を起動
2. Settings → Resources → WSL Integration で、使用している WSL ディストリビューションが有効になっていることを確認
3. WSL を再起動：`wsl --shutdown` してから WSL を起動

#### macOS の場合

Docker Desktop が起動しない場合：

1. Docker Desktop を完全に終了して再起動
2. macOS を再起動
3. Rosetta 2 がインストールされているか確認 (Intel Mac用アプリの場合)

#### Linux の場合

Docker Engine が起動しない場合：

```bash
# Docker サービスの状態を確認
sudo systemctl status docker

# Docker サービスを起動
sudo systemctl start docker

# 自動起動を有効化
sudo systemctl enable docker
```

権限エラーが出る場合：
```bash
# ユーザーを docker グループに追加
sudo usermod -aG docker $USER

# ログアウトして再ログイン、またはシェルを再起動
newgrp docker
```

## 高度な使用方法

### VS Code Dev Container

より統合された開発環境が必要な場合、VS Code Dev Container を使用できます。

1. VS Code に「Remote - Containers」拡張機能をインストール
2. ZMK リポジトリの devcontainer 設定を参照
3. プロジェクトを container 内で開く

詳細は ZMK の公式ドキュメントを参照してください。

### Docker Compose

複数のビルドターゲットを効率的に管理したい場合、`docker-compose.yml` を作成することもできます。

### カスタム Docker イメージ

独自のツールや設定を追加したい場合、ZMK のイメージをベースにカスタムイメージを作成できます：

```dockerfile
FROM zmkfirmware/zmk-build-arm:stable

# カスタマイズをここに追加
RUN apt-get update && apt-get install -y your-tool

# ...
```

## 参考リンク

### ZMK 関連
- [ZMK 公式 Docker リポジトリ](https://github.com/zmkfirmware/zmk-docker)
- [ZMK ドキュメント](https://zmk.dev/)

### Docker 関連
- [Docker 公式ドキュメント](https://docs.docker.com/)
- [Docker Desktop for Windows (WSL2)](https://docs.docker.com/desktop/windows/wsl/)
- [Docker Desktop for Mac](https://docs.docker.com/desktop/mac/)
- [Docker Engine (Linux)](https://docs.docker.com/engine/install/)

## よくある質問

### Docker と GitHub Actions の違いは？

GitHub Actions も同じ Docker イメージを使用しているため、ローカルで Docker を使えば CI と同じ結果が得られます。

### ネイティブ環境と Docker を併用できますか？

はい、両方とも同じプロジェクト構造を使用するため、問題なく併用できます。

### ビルド時間はどれくらいですか？

初回ビルド：5-10分程度
2回目以降：1-3分程度（キャッシュによる）

### オフラインでビルドできますか？

一度 Docker イメージをダウンロードし、`west update` を実行した後は、オフラインでもビルドできます。

## ライセンス

ZMK Docker イメージは MIT ライセンスです。
