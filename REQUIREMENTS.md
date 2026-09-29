# REQUIREMENTS — Skin Aim Trainer

Updated: 2026-09-29
Status: Phase 1 implementation-ready / actual playtest pending

## Product Core

好きな武器Skinを使用した状態で、Aim Labのような本格的なAim Trainingを行えるWindows向けAim Trainerを作る。

中心体験:

`Skinを選ぶ → 武器を持つ → 撃つ → Aim Training → Result`

## Priority

1. Mouse操作の正確さ
2. Input latencyの少なさ
3. Aim Training品質
4. 分かりやすさ
5. 安定性
6. Skin体験
7. 見た目

## Platform / Architecture

- Primary: Windows PC
- Final distribution: Electron Windows Application
- Aim Trainer CoreはWeb技術側へ分離する
- Electron固有処理をAim Engineへ直接混ぜない
- 将来Web版へ展開可能な構造を維持する

## Phase 1 Scope

実装対象:

- Training View
- Pointer Lock
- Mouse Aim
- Target
- Left Click Shoot
- Hit Detection
- Score
- Restart
- ESC Pause / safe resume

Phase 1ではWeapon Skinを実装しない。

### Phase 1 Completion

- Mouse movementでAimが安定して動く
- CursorがAim中に画面外へ出ない
- FPSの描画deltaをSensitivity計算に掛けない
- TargetへCrosshairを合わせて撃つとScoreが増える
- Target外を撃ってもScoreは増えない
- ESC Pause後、安全にPointer Lockへ復帰できる
- RestartでScore / Aim / Target stateが初期化される
- Static Testが通る
- Actual PlaytestでCore Loopを確認する

## Phase 2+ Summary

Phase 2: Timer / Accuracy / Miss / Result / Personal Best / Difficulty / Settings / Sensitivity / Crosshair / Gridshot

Phase 3: Hold Angle / Microshot / Flick / Skin Test Range

Phase 4: Weapon Rendering / Ammo / Reload / Equip / Inspect / Fire feedback

Phase 5: Data-driven Skin System / Library / Variant / Asset loading + cache

Phase 6: Audio / Animation

Phase 7: Electron / Installer / Auto Update / App Icon / Releases / Logs / Diagnostics

Phase 8: Performance / High Refresh / Input / Actual Playtest / Regression / Installer / Update quality

## Sensitivity Contract

VALORANT Sensitivity換算はPhase 2で方式をResearch / Verificationしてから実装する。Phase 1の固定Mouse係数をVALORANT換算値として扱わない。

## Skin Contract

SkinはWeapon performanceと分離し、Skin変更でAccuracy / Sensitivity / Hit Detection / Target behavior / Scoreを変更しない。

## Asset / Branding Contract

- OKIAIMXのコード・画像・音声・Asset・UIをコピーしない
- Aim Labをコピーしない
- VALORANT Assetの権利状態を無視しない
- Riot公式Productと誤認するBrandingをしない
- 初期はPlaceholder / Original / Permission確認済みAssetだけを使う

## Storage

Accountは必須にしない。Phase 2以降、Sensitivity / DPI / Crosshair / Controls / Graphics / Sound / Selected Skin / Variant / Last Mode / Personal Best / Recent Resultsを保存する。

## Non-breakable Requirements

1. Mouse Aim最優先
2. FPSでSensitivityを変化させない
3. Skin変更でAim性能を変えない
4. Training中のInput latencyを増やさない
5. Loginなしで主要Trainingを利用可能
6. Skin選択を保存
7. Sensitivityを保存
8. Crosshairを保存
9. Aim画面をUIで邪魔しない
10. Skin追加でGame Logicを書き換えない
11. VALORANT Assetの権利状態を無視しない
12. OKIAIMXをコピーしない
13. Aim Labをコピーしない
14. MVP前に不要機能を増やさない
15. Game Dev HubでActual Playtest可能な状態を最終的に維持する

## Current Blocking Integration Issue

2026-09-29のGame Dev Hub v0.1.27はProject modelで`engine !== "godot"`を拒否するため、本ProjectのWeb/Electron architectureを直接登録できない。

Project architectureをGodotへ変える回避はしない。Hub側にWeb/Electron Project supportを追加するか、対応完了まで本Repository単体でWeb Coreを検証する。
