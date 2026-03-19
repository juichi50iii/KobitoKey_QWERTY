---
name: zmk-build-checker
description: GitHub Actions の ZMK ビルド結果を解析し、エラー修正を支援する。GitHub Actions, ビルドエラー, workflow, log, gh コマンドなどのキーワードで発火。
---

# ZMK Build Checker — GitHub Actions ビルド検証支援

## スキル読み込み通知

このスキルが読み込まれたら、必ず以下の通知をユーザーに表示してください：

> 🔍 **ZMK Build Checker スキルを読み込みました**  
> GitHub Actions のビルド・テストログを解析し、エラーの原因特定と修正をサポートします。
> ※ユニットテスト自体の詳細は `zmk-test-helper` を併用してください。

---

## 概要

GitHub Actions で実行される ZMK ファームウェアのビルドプロセスを監視・解析します。
失敗したビルド（紅いバツ印）の原因を特定し、コードの修正案を提示することに特化しています。

---

## 使用タイミング

- GitHub にプッシュした後、Actions が失敗（Failure）したとき
- ローカルでのビルドエラーが解決できず、クラウドでの詳細ログを確認したいとき
- 過去のビルド成功/失敗の履歴を比較したいとき

---

## 手順

### Step 1: ワークフロー状態の確認

GitHub CLI (`gh`) を使用して、現在のリポジトリのワークフロー実行状況を確認します。

1. `gh run list` を実行して、直近の実行 ID を取得する。
2. 失敗しているステップ（通常は `Build` ステップ）を特定する。

### Step 2: ログの取得と解析

以下の補助スクリプトを使用して、エラーログの要約を取得します：

📄 **[scripts/check-workflow.mjs](scripts/check-workflow.mjs)**

```bash
node scripts/check-workflow.mjs
```

解析の重点ポイント：
- **Devicetree エラー**: シンタックスエラー、未定義のノード参照。
- **Kconfig エラー**: 存在しない設定フラグの使用。
- **C コンパイルエラー**: 欠落しているヘッダー、型不一致。

### Step 3: 修正案の提示

ログの解析結果に基づき、以下のファイルを修正します。
- `.keymap`, `.dtsi`, `.conf` など。

### Step 4: 修正の適用と PR 作成 (再検証)

1. **ブランチ作成**: 修正用の新しいブランチを作成します（例: `fix/build-error-<ID>`）。
2. **修正のコミット**: 解析に基づいた修正をコミットします。
3. **プルリクエストの作成**: GitHub にプッシュし、PR を作成して GitHub Actions の再ビルドを待ちます。

> [!IMPORTANT]
> メインブランチへの直接コミットは避け、必ず PR を通じて Actions の結果を確認するようにしてください。これにより、壊れたコードがメインに残るのを防げます。

---

## 補助ツール

| ファイル | 内容 |
|---------|------|
| [scripts/check-workflow.mjs](scripts/check-workflow.mjs) | GitHub Actions の失敗ログを自動取得・要約するスクリプト |
