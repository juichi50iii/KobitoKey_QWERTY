# KobitoKey Keymap Improvements for Windows Programming

## 現在の問題点

Windowsプログラミングで重要な記号が不足しています：

### 🔴 不足している重要なキー
| キー | 記号 | 用途 | 重要度 |
|-----|------|------|---------|
| Backtick | `` ` `` | テンプレートリテラル、Markdown、シェルコマンド | 高 |
| Tilde | `~` | ホームディレクトリ、ビット演算NOT | 高 |
| Backslash | `\` | エスケープ、Windowsパス、正規表現 | 高 |
| Pipe | `|` | コマンドパイプ、OR演算子 | 高 |
| Left Brace | `{` | コードブロック、オブジェクトリテラル | 高 |
| Right Brace | `}` | コードブロック、オブジェクトリテラル | 高 |
| Home | - | 行頭移動 | 中 |
| End | - | 行末移動 | 中 |
| Page Up | - | ページスクロール | 低 |
| Page Down | - | ページスクロール | 低 |

## 改善計画

### Layer 1 (NUMBER) の改善

現在の配置：
```
Layer 1:
 0    1   2   3      trans          -   trans    ↑     trans   trans
 =    4   5   6      trans          +   ←        ↓     →       trans
trans 7   8   9      trans          *   /        [     ]       trans
trans trans trans LSHFT trans       trans trans  trans trans   trans
```

改善後の配置：
```
Layer 1:
 0    1   2   3      `              -   trans    ↑     \       |
 =    4   5   6      trans          +   ←        ↓     →       trans
 {    7   8   9      }              *   /        [     ]       trans
trans trans trans LSHFT trans       trans trans  trans trans   trans
```

### Layer 2 (FUNCTION) の改善

改善後の配置：
```
Layer 2:
HOME END PG_UP PG_DN BT_SEL4       F1   F2   F3   F4   F5
trans trans trans trans BT_CLR     F6   F7   F8   F9   F10
trans trans trans trans BT_CLR_ALL F11  F12  trans trans trans
trans trans trans trans trans      DEL  trans trans trans trans
```

## 実装手順

### 1. KobitoKey.keymap の Layer 1 更新

`boards/shields/KobitoKey/KobitoKey.keymap` の50-58行目を以下に変更：

```c
        layer1 {
            label = "NUMBER";
            bindings = <
                &kp N0    &kp N1   &kp N2   &kp N3      &kp GRAVE       &kp MINUS   &trans       &kp UP         &kp BSLH     &kp PIPE
                &kp EQUAL &kp N4   &kp N5   &kp N6      &trans          &kp PLUS    &kp LEFT     &kp DOWN       &kp RIGHT    &trans
                &kp LBRC  &kp N7   &kp N8   &kp N9      &kp RBRC        &kp ASTRK   &kp SLASH    &kp LBKT       &kp RBKT     &trans
                &trans    &trans   &trans   &kp LSHFT   &trans          &trans      &trans       &trans         &trans       &trans
            >;
        };
```

### 2. KobitoKey.keymap の Layer 2 更新

`boards/shields/KobitoKey/KobitoKey.keymap` の60-68行目を以下に変更：

```c
        layer2 {
            label = "FUNCTION";
            bindings = <
                &kp HOME       &kp END        &kp PG_UP      &kp PG_DN      &bt BT_SEL 4          &kp F1        &kp F2       &kp F3      &kp F4     &kp F5
                &trans         &trans         &trans         &trans         &bt BT_CLR            &kp F6        &kp F7       &kp F8      &kp F9     &kp F10
                &trans         &trans         &trans         &trans         &bt BT_CLR_ALL        &kp F11       &kp F12      &trans      &trans     &trans
                &trans         &trans         &trans         &trans         &trans                &kp DEL       &trans       &trans      &trans     &trans
            >;
        };
```

## 変更前後の比較

### Layer 1 変更点
| 位置 | 変更前 | 変更後 | 理由 |
|------|--------|--------|------|
| (0,4) | `&trans` | `&kp GRAVE` | バッククォート・チルダアクセス |
| (0,8) | `&trans` | `&kp BSLH` | バックスラッシュアクセス |
| (0,9) | `&trans` | `&kp PIPE` | パイプアクセス |
| (2,0) | `&trans` | `&kp LBRC` | 左中括弧アクセス |
| (2,4) | `&trans` | `&kp RBRC` | 右中括弧アクセス |

### Layer 2 変更点
| 位置 | 変更前 | 変更後 | 理由 |
|------|--------|--------|------|
| (0,0) | `&bt BT_SEL 0` | `&kp HOME` | ナビゲーション向上 |
| (0,1) | `&bt BT_SEL 1` | `&kp END` | ナビゲーション向上 |
| (0,2) | `&bt BT_SEL 2` | `&kp PG_UP` | ナビゲーション向上 |
| (0,3) | `&bt BT_SEL 3` | `&kp PG_DN` | ナビゲーション向上 |

## テスト方法

1. 変更後、GitHub Actions でビルドが成功することを確認
2. 各レイヤーで新しい記号が正しく入力できることをテスト
3. 既存のキー配置に影響がないことを確認

## 期待される効果

- VSCode、Git、npm/yarn、Docker等の開発ツールで必要なキーが全て利用可能
- プログラミング時の効率向上
- Windowsプログラミング環境での快適性向上