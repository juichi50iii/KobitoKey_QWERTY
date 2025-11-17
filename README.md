# KobitoKey_QWERTY

本家の小人キーファームウェアに加え、プログラミング時によく使う記号を加えたファームウェアです。

## ファームウェアの主な機能
* ZMK Dongle 対応
* Prospector 対応
* ZMK Studio 対応
* Keymap Editor 対応

## ファームウェアの書き込み対応表

### ドングルモード（完全ワイヤレス）

| ハードウェア | ファームウェアファイル | 役割 |
|------------|-------------------|------|
| ドングル用Xiao BLE | `KobitoKey_dongle_xiao.uf2` | セントラル（USB接続） |
| 左側キーボード | `KobitoKey_left_peripheral.uf2` | ペリフェラル（BLE接続） |
| 右側キーボード | `KobitoKey_right_peripheral.uf2` | ペリフェラル（BLE接続） |

### Prospectorモード（完全ワイヤレス）

| ハードウェア | ファームウェアファイル | 役割 |
|------------|-------------------|------|
| Prospector | `KobitoKey_dongle_prospector.uf2` | セントラル（USB接続） |
| 左側キーボード | `KobitoKey_left_peripheral.uf2` | ペリフェラル（BLE接続） |
| 右側キーボード | `KobitoKey_right_peripheral.uf2` | ペリフェラル（BLE接続） |

### ドングルなしモード（左側USB接続）

| ハードウェア | ファームウェアファイル | 役割 |
|------------|-------------------|------|
| 左側キーボード | `KobitoKey_left_dongleless.uf2` | セントラル（USB接続） |
| 右側キーボード | `KobitoKey_right_dongleless.uf2` | ペリフェラル（BLE接続） |

### 設定リセット用

| ハードウェア | ファームウェアファイル | 用途 |
|------------|-------------------|------|
| 任意のXiao BLE | `settings_reset-seeeduino_xiao_ble-zmk.uf2` | Bluetooth設定のリセット |

## 使い方

[リリースページ](https://github.com/happy-ryo/KobitoKey_QWERTY/releases)から必要なファームウェアをダウンロードしてください。

### 初回セットアップ
1. 各Xiao BLEに `settings_reset-seeeduino_xiao_ble-zmk.uf2` を書き込む
2. 上記の対応表に従って、各ハードウェアに対応するファームウェアを書き込む



本ファームウェアで発生した問題を小人キー作者である、五十川さんに問い合わせないでください。


![my_keymap](https://github.com/user-attachments/assets/b9f95f79-436f-46e1-8173-e2fcd53f9481)

