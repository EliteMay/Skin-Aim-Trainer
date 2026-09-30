# Skin Aim Trainer

OKIAIMXの「すぐ練習を始められる短い導線」を参考にしつつ、コード・Asset・UIをコピーせず独自実装するWindows向けAim Trainerです。

## 現在の方針

**Browser / Electron版は終了し、Godot 4.7.2 + GDScriptでWindowsゲームとして開発します。**

Phase 1のCore Aim PrototypeはWindows実機確認まで完了しました。現在はPhase 2 — Training Foundationへ進みます。引き続き最優先は「マウスAimが素直に動く」「操作が一目で分かる」ことです。

## 起動後にやること

1. **練習モードと難易度を選ぶ**
2. **60秒の練習を開始** を押す
3. マウスで赤いTargetを狙って左クリックで撃つ

操作:

- マウス移動: Aim
- 左クリック: Shoot
- ESC: 一時停止 / 再開
- Pause中の「メインメニューへ戻る」: 途中Sessionを破棄して開始画面へ戻る
- R: 最初からやり直す

移動、武器モデル、Skinはまだ入れていません。Phase 2では感度・Crosshair・Difficultyに加え、シングル / Gridshotを切り替えられます。

## Phase 1 完了

- Godot 3D Training Scene
- 起動直後の大きい開始画面
- 日本語の操作説明
- Mouse Capture
- Mouse Aim
- 中央Crosshair
- 赤いTarget
- 左クリック射撃
- Raycast Hit Detection
- Score / Hit / Miss / 命中率
- HIT / MISS Feedback
- ESC Pause / Resume
- R Restart
- Godot Headless Smoke Test
- GitHub Actions CI
- Game Dev HubからのGodot起動 実機確認
- 起動導線 / Aim / Shoot / Hit-Miss / Pause / Restart 実機確認

## Phase 2で追加済み

- VALORANT-style Sensitivity設定
- DPI入力
- eDPI / cm/360表示
- Sensitivity保存
- Resolution scaleの影響を避けるGodot `screen_relative` Mouse Aim
- Mouse input accumulation無効化
- Crosshair設定
- VALORANT Crosshair Profile Code Import
- Inner / Outer Lines対応Crosshair renderer
- 60秒Session Timer
- Result画面
- Local Personal Best保存
- 3段階Difficulty（かんたん / 標準 / むずかしい）
- Difficulty別Personal Best
- 既存BESTを失わないNormal互換読み込み
- Pause中からメインメニューへ即時復帰
- シングル / Gridshotの練習モード選択
- Gridshotの3 Target同時表示 / Hit TargetだけRespawn
- GridshotのDifficulty別Personal Best

## 将来のUI方向

現在はCore Trainingの検証を優先していますが、将来は **Home → Stage選択 → Play → Result** のAim Lab / Kovaak's系Training Platform構成へ拡張します。

## まだ入れていないもの
- Home / Stage Library
- Microshot / Hold Angle / Flick / Tracking
- 武器モデル
- Skin
- Reload / Inspect
- Audio / Animation
- Windows Installer

## 開発環境

- Engine: Godot 4.7.2 stable
- Language: GDScript
- Primary target: Windows
- Main Scene: `res://scenes/main.tscn`

## Game Dev Hub

このRepositoryはGodot Projectです。

以前Web / Electronとして登録したSkin Aim TrainerがGame Dev Hubに残っている場合は、**登録だけ解除してGodot Projectとして再登録**します。PC上のRepository Fileを削除する必要はありません。

HubからはGodot Editor起動 / Game起動 / Roadmap確認を使います。

## Asset Policy

実VALORANT Skin、3D Model、Texture、Animation、Sound等は、利用条件を確認せずRepositoryへ追加しません。初期はOriginal / Placeholder / 利用許可を確認できるAssetだけを使用します。
