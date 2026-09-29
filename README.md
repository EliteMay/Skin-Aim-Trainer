# Skin Aim Trainer

OKIAIMXの「すぐ練習を始められる短い導線」を参考にしつつ、コード・Asset・UIをコピーせず独自実装するWindows向けAim Trainerです。

## 現在の方針

**Browser / Electron版は終了し、Godot 4.7.2 + GDScriptでWindowsゲームとして開発します。**

今はPhase 1の操作確認版です。最優先は「何をすればいいか一目で分かる」「マウスAimが素直に動く」ことです。

## 起動後にやること

1. **練習を開始** を押す
2. マウスで赤いTargetを狙う
3. 左クリックで撃つ

操作:

- マウス移動: Aim
- 左クリック: Shoot
- ESC: 一時停止 / 再開
- R: 最初からやり直す

Phase 1では移動、武器モデル、Skin、モード選択、細かい設定はまだ入れません。

## Phase 1で実装済み

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

## まだ入れていないもの

- VALORANT Sensitivity換算
- DPI / eDPI
- Gridshot / Microshot / Hold Angle / Flick
- 武器モデル
- Skin
- Reload / Inspect
- Audio / Animation
- Result / Personal Best
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
