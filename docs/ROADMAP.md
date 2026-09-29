# ROADMAP

## Phase 1 — Core Aim Prototype

- [x] Web Coreの最小構造を作成する
  - 担当: ChatGPT
  - Aim / Input / Target / Rendererを分離する
  - 外部AssetとElectronをまだ入れない

- [x] Pointer LockとMouse Aimを実装する
  - 担当: ChatGPT
  - Mouse movementX / movementYでCamera角度を更新する
  - Frame deltaでSensitivityを変えない

- [x] Target / Shoot / Hit Detection / Scoreを実装する
  - 担当: ChatGPT
  - TargetにCrosshairが合った時だけScoreが増える
  - Hit後は次Targetへ切り替わる

- [x] Pause / Restartを実装する
  - 担当: ChatGPT
  - ESCでPointer Lock解除時にPauseを表示する
  - RestartでScore / Camera / Targetを初期化する

- [x] Static Validationを実装する
  - 担当: ChatGPT
  - Projection / Mouse delta / Hit DetectionをNode Testで確認する

- [ ] Aim Test — マウス操作を実機確認する
  - 担当: あなた
  - ゲーム画面をクリックしてMouseを左右・上下へ動かす
  - Crosshairは中央のままTarget / 視界が相対移動する
  - Cursorが画面外へ出ない
  - ESCで一時停止し、Aimへ安全に戻れる

- [ ] Shooting Test — Hit / Missを実機確認する
  - 担当: あなた
  - TargetへCrosshairを合わせて5回撃つ
  - Hitした時だけScoreが1ずつ増える
  - Target外を撃ってScoreが増えないことを確認する

- [ ] Restart Test — 初期化を実機確認する
  - 担当: あなた
  - Scoreを増やした後Pause画面から「最初からやり直す」を押す
  - Scoreが0へ戻る
  - Aim方向とTargetが初期状態へ戻る

完了条件: Mouse Aim → Targetを狙う → 撃つ → Hit判定 → Score のLoopをActual Playtestし、Blockingな入力問題がない。

## Phase 2 — Training Foundation

- [ ] Timer / Accuracy / Miss / Result / Personal Bestを実装する
- [ ] Difficulty / Settings / Sensitivity / Crosshairを実装する
- [ ] Gridshotを完成させる

## Phase 3 — Training Modes

- [ ] Hold Angle / Microshot / Flick / Skin Test Rangeを実装する

## Phase 4 — Weapon

- [ ] Primary Rifle 1種類のWeapon Rendering / Ammo / Reload / Equip / Inspect / Fire feedbackを実装する

## Phase 5 — Skin System

- [ ] Data-driven Skin model / Library / Variant / Asset loading / Cacheを実装する

## Phase 6 — Audio / Animation

- [ ] Fire / Reload / Hit soundとInspect / Skin-specific animationを実装する

## Phase 7 — Electron

- [ ] Aim Core安定後にElectron shell / Installer / Auto Update / Icon / Releases / Logs / Diagnosticsを実装する

## Phase 8 — Quality

- [ ] Performance / High Refresh / Input / Playtest / Regression / Installer / Updateを検証する
