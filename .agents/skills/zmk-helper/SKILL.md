---
name: zmk-helper
description: ZMKファームウェアのキーマップ設定、レイヤー管理、トラックボール（PMW3610等）の感度調整、およびビルドトラブルの解決を支援する。ZMK, キーマップ, レイヤー, トラックボール, 感度, ビルドエラー, PMW3610 などのキーワードで発火。
---

# ZMK Helper — ZMK ファームウェア設定支援

## スキル読み込み通知

このスキルが読み込まれたら、必ず以下の通知をユーザーに表示してください：

> ⌨️ **ZMK Helper スキルを読み込みました**  
> ZMKファームウェアの設定変更やトラックボールの感度調整をサポートします。
> ※ビルドエラーの検証には `zmk-build-checker` を使用してください。

---

## 概要

ZMK (Zephyr Mechanical Keyboard) ファームウェアを使用するキーボードの設定作業を最適化します。
特に分割キーボードや、PMW3610 などの光学センサーを使用したトラックボール・マウス機能の設定に強みを持ちます。

---

## 使用タイミング

- キーマップ（`.keymap`）やレイヤー構成を変更したいとき
- トラックボールの感度（DPI）やスクロール挙動を調整したいとき
- マウスレイヤー（Auto Mouse Layer）の設定を最適化したいとき
- 分割キーボードの左右通信（Central/Peripheral）の役割を入れ替えたいとき

---

## 手順

### Step 1: コンテキストの把握

まず、プロジェクトのディレクトリ構成と主要な設定ファイルを確認します。

1. `config/` ディレクトリが存在するか確認する。
2. `.keymap` ファイル、`.conf` ファイル、および独自の `.dtsi` ファイルを読み込む。
3. 使用しているハードウェア（MCU, センサー, ディスプレイなど）を特定する。

### Step 2: 設定の変更・追加

ユーザーの要望に応じて、以下のファイルを編集または提案します。

- **キーマップ変更**: `behaviors` の定義や `keymap` ノードの編集。
- **トラックボール調整**: `&trackball` ノードの `sampling-rate` や `sensitivity` の変更。
- **機能フラグ**: `.conf` ファイルでの `CONFIG_ZMK_MOUSE=y` などの設定確認。

具体的な設定パターンについては、以下のリファレンスを参照してください：

📄 **[references/trackball-settings.md](references/trackball-settings.md)**

### Step 3: テンプレートの活用

新しいレイヤーや複雑なコンボを定義する場合、以下のテンプレートをベースにします：

📄 **[assets/keymap-snippet.dtsi](assets/keymap-snippet.dtsi)**

### Step 4: 検証とトラブルシューティング

- **ビルド検証**: ビルドエラーの解析や GitHub Actions の確認が必要な場合は、専用スキル `zmk-build-checker` を使用してください。
- **通信確認**: `central`/`peripheral` の役割設定ミスによる不具合の診断。

---

## 参照リソース

| ファイル | 内容 |
|---------|------|
| [references/trackball-settings.md](references/trackball-settings.md) | トラックボール感度・スクロール設定のリファレンス |
| [assets/keymap-snippet.dtsi](assets/keymap-snippet.dtsi) | キーマップ定義のテンプレート |
