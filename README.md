# Skin Aim Trainer

OKIAIMXの「すぐ練習を始められる短い導線」を参考にしつつ、コード・Asset・UIをコピーせず独自実装するWindows向けAim Trainerです。

## 現在の方針

**Browser / Electron版は終了し、Godot 4.7.2 + GDScriptでWindowsゲームとして開発します。**

Phase 1 / Phase 2はWindows実機確認まで完了し、Phase 3 — Training Modes / Scenario Libraryへ進んでいます。Play / Training LibraryとQuick SettingsもWindows実機確認済みです。引き続き最優先は「マウスAimが素直に動く」「操作が一目で分かる」ことです。

## 起動後にやること

1. **Play画面でトレーニングを選ぶ**
2. 同じ画面の右側で**難易度 / 感度 / クロスヘア**を確認する
3. **60秒の練習を開始** を押して、赤いTargetを狙って左クリックで撃つ

操作:

- マウス移動: Aim
- 左クリック: Shoot
- ESC: 一時停止 / 再開
- Pause中の「メインメニューへ戻る」: 途中Sessionを破棄して開始画面へ戻る
- R: 最初からやり直す

移動、武器モデル、Skinはまだ入れていません。Homeから現在実装済みのシングルターゲット / Gridshot / Hold Angle / Pre-Aim / Microshotを選べます。

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

## Phase 3で追加済み

- 起動直後のPlay / Training Library
- Data-driven Stage Library
- 左側のTraining一覧 + 右側の選択中Training / Quick Settings
- 別Stage Setup画面を挟まず、選択と設定を1画面へ集約
- シングルターゲット / Gridshot / Hold Angle / Pre-Aim / MicroshotをStage Catalogから動的表示
- 難易度を選択中Trainingの横で変更
- 感度 / Crosshair設定を選択中Trainingの横から開く
- Stage metadataを`data/stages.json`へ分離
- Stage category / description / duration / mode / tags
- ESC / ResultからPlay画面へ戻る導線
- Hold Point待機 → ランダム左右Peek → micro-adjustして撃つHold Angle / Pre-Aim
- 中央付近の小Targetを短距離で追うMicroshot

現在は4 Stageだけなので検索 / Filterは入れていません。Stage数が増えた段階で、category / tagsを使ったBrowse / Searchを追加できる構造にしています。Aimlabs / KovaaK'sのUIやAssetはコピーせず、「Trainingを探す・設定する・開始する」の往復を減らす構造だけを参考にしています。

## まだ入れていないもの
- Flick / Tracking
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
