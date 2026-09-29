# ROADMAP

## Phase 0 — Web → Godot Rewrite

- [x] Product RuntimeをGodotへ変更する
  - 担当: ChatGPT
  - Browser / Electron前提をCurrent仕様から外す
  - Godot 4.7.2 + GDScript + WindowsをCurrent Runtimeにする

- [x] 旧Web prototypeをGodot 3D prototypeへ置き換える
  - 担当: ChatGPT
  - project.godot / Main Scene / GDScript / Godot CIを追加
  - package.json / Browser server / Web rendererをCurrent runtimeから削除

- [x] 操作導線を作り直す
  - 担当: ChatGPT
  - 起動直後に「練習を開始」
  - 操作を3Stepで表示
  - Training中はCrosshair / Target / Score中心
  - ESC Pause / R Restartを常時Hint

## Phase 1 — Core Aim Prototype

- [x] Mouse Aimを実装する
  - 担当: ChatGPT
  - Godot Mouse Capture
  - Mouse deltaを角度へ変換
  - Frame deltaをSensitivityへ掛けない

- [x] Target / Shoot / Hit Detectionを実装する
  - 担当: ChatGPT
  - 赤いTargetを1個表示
  - Camera中央RaycastでHit判定
  - Hit後は次位置へ移動

- [x] Score / Hit / Miss / Accuracyを実装する
  - 担当: ChatGPT

- [x] Pause / Resume / Restartを実装する
  - 担当: ChatGPT

- [x] Godot Headless Smoke Testを追加する
  - 担当: ChatGPT
  - Import / Cold Start / Core SmokeをCIで確認

- [x] Godot版をGame Dev Hubから起動する
  - 担当: あなた
  - Game Dev Hubの旧Skin Aim Trainer登録を解除する
  - Fileは削除しない
  - RepositoryをGodot Projectとして再登録する
  - 「開発を開始」→「ゲームを起動」

- [x] 操作が迷わないか確認する
  - 担当: あなた
  - 起動直後に何を押すか分かる
  - 「練習を開始」を押せる
  - マウスで赤いTargetを狙える
  - 左クリックで撃てる

- [x] Aim / Shootを実機確認する
  - 担当: あなた
  - Targetを5回Hitする
  - 空振りを数回行う
  - SCORE / HIT / MISS / 命中率が正しく変わる
  - Aimが引っ掛からない

- [x] Pause / Restartを実機確認する
  - 担当: あなた
  - ESCで一時停止
  - ESCまたは「練習に戻る」で再開
  - Rまたは「最初からやり直す」でScoreが0へ戻る

完了条件: 起動 → 開始 → Aim → Shoot → Hit/Miss → Score → Pause/Resume/RestartをWindows Actual Playtestし、操作方法が分からないBlockingがない。

### Phase 1 実機確認結果 — 2026-09-29

- Game Dev HubからGodot版を起動: PASS
- 起動直後の操作導線: PASS
- Mouse Aim / Shoot / Hit / Miss / Score / 命中率: PASS
- ESC Pause / Resume / Restart: PASS
- Blockingな操作問題: なし

Phase 1はWindows実機確認まで完了。次のCurrent TaskはPhase 2のSensitivity / DPI / eDPI Researchと設定。

## Phase 2 — Training Foundation

- [x] Sensitivity / DPI / eDPIのResearchと設定
  - 担当: ChatGPT
  - Godot Mouse Aimをscreen_relativeへ変更
  - Mouse input accumulationを無効化
  - VALORANT-style yaw 0.07 modelをResearchして実装
  - DPI / Sensitivity / eDPI / cm360を設定画面へ追加
  - user://settings.cfgへ保存
  - 計算とUI ContractをGodot Smoke Testへ追加

- [x] Sensitivity / DPI / eDPIを実機確認する
  - 担当: あなた
  - Start画面の「感度を設定」を開く
  - 実際のMouse DPIとVALORANT Sensitivityを入力して保存する
  - eDPI / cm360が表示される
  - 感度を上げるとAimが速く、下げると遅くなる
  - Gameを閉じて再起動しても値が残る
  - 2026-09-29 Game Dev Hub共有Packで5/5 PASS

- [x] Crosshair設定
  - 担当: ChatGPT
  - Godot描画のCrosshair rendererへ置換
  - 色 / 長さ / 太さ / Gap / Outline / Center Dotを手動調整
  - VALORANT Crosshair Profile CodeのPrimary (P) SectionをImport
  - Inner / Outer Lines、横/縦長さ、Opacity、Outline、Center Dotを反映
  - ConfigFileへ保存
  - Parser / UI ContractをGodot Smoke Testへ追加

- [ ] Crosshair設定を実機確認する
  - 担当: あなた
  - Start画面の「クロスヘアを設定」を開く
  - VALORANTのCrosshair Codeを貼り付けて「コードを読み込む」
  - Previewが変わる
  - 「保存して戻る」後のTraining Crosshairへ反映される
  - Gameを閉じて再起動してもCrosshairが残る
  - 手動の色 / 長さ / 太さ / Gap / Outline / Center Dotも変更できる
- [ ] Timer / Result / Personal Best
- [ ] Difficulty
- [ ] Gridshot

## Phase 3 — Training Modes / Scenario Library

- [ ] Home / Stage Library基盤
  - 将来要件。現在は実装しない
  - Aim Lab / Kovaak's系の「Home → Stage選択 → Play → Result」を参考にする
  - Training Modeを追加してもMain Sceneへ条件分岐を詰め込まない
  - Stage metadata / category / difficulty / best scoreをData-driven化する

- [ ] Hold Angle / Pre-Aim
- [ ] Microshot
- [ ] Flick
- [ ] Skin Test Range

## Phase 4 — Weapon

- [ ] Primary Rifle 1種類
- [ ] Ammo
- [ ] Reload
- [ ] Equip
- [ ] Inspect
- [ ] Fire feedback

## Phase 5 — Skin System

- [ ] Data-driven Skin model
- [ ] Skin Library
- [ ] Variant
- [ ] Asset loading / Cache
- [ ] Skin選択保存

## Phase 6 — Audio / Animation

- [ ] Fire / Reload / Hit sound
- [ ] Weapon / Inspect animation

## Phase 7 — Windows Distribution

- [ ] Windows Export
- [ ] Installer
- [ ] App Icon
- [ ] Release
- [ ] Update strategy
- [ ] Logs / Diagnostics

## Phase 8 — Quality

- [ ] High Refresh / Input latency
- [ ] Long-session stability
- [ ] Actual Playtest regression
- [ ] Windows build / installer regression
