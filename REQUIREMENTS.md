# REQUIREMENTS — Skin Aim Trainer

Updated: 2026-09-30
Status: Phase 1 complete / Phase 2 active

## Product Core

好きな武器Skinを使用した状態で、本格的なAim Trainingを行えるWindows向けAim Trainerを作る。

中心体験:

`起動 → すぐ練習開始 → 狙う → 撃つ → 結果を見る → Skinを変えて再練習`

## Priority

1. Mouse操作の正確さ
2. Input latencyの少なさ
3. 操作の分かりやすさ
4. Aim Training品質
5. 安定性
6. Skin体験
7. 見た目

## Platform / Architecture

- Primary: Windows PC
- Engine: Godot 4.7.2 stable
- Language: GDScript
- Final game runtime: Godot Windows Desktop Application
- BrowserをPrimary Runtimeにしない
- Electronを本ゲームのShellにしない
- Game Dev HubからGodot Projectとして管理・起動する

## Phase 1 UX Contract

起動直後から迷わせない。

- First Viewに大きい「練習を開始」を1つ置く
- First Viewに操作を3Stepで表示する
- Training開始後はCrosshair / Target / Score系だけを主表示にする
- 常時表示する操作Hintは `ESC メニュー / R やり直し` だけ
- ESCでPause画面を表示
- Pause画面では「練習に戻る」をPrimary Actionとして維持する
- Pause画面から「最初からやり直す」「メインメニューへ戻る」を選べる
- 「メインメニューへ戻る」は途中Sessionを完了扱いにせず破棄し、Personal Bestを更新しない
- 感度 / Crosshair設定はPause内のSecondary Actionとして維持する
- Phase 1ではモード選択、Skin選択、詳細設定を開始前導線へ混ぜない
- User-facing UIは日本語だけで意味が分かる状態にする

## Phase 1 Gameplay Scope

実装対象:

- 3D Training View
- Godot Mouse Capture
- Mouse Aim
- Center Crosshair
- 1 Target at a time
- Left Click Shoot
- Physics Raycast Hit Detection
- Score
- Hit / Miss / Accuracy
- Restart
- ESC Pause / Resume

Phase 1では移動を入れない。まずAimとShootの品質だけを確認する。

### Phase 1 Completion

2026-09-29にWindows実機で以下を確認し、Phase 1を完了した。

- 開始方法が説明なしでも見つけられる
- Mouse movementでAimが安定して動く
- Aim中にOS cursorがTrainingを邪魔しない
- Mouse deltaへframe deltaを掛けない
- TargetへCrosshairを合わせて撃つとHitになる
- Target外を撃つとMissになる
- Hit後にTargetが別位置へ移動する
- Score / Hit / Miss / Accuracyが更新される
- ESC Pause後に安全にAimへ戻れる
- R RestartでScore / Aim / Targetが初期化される
- Godot Import / Cold Start / Core Smokeが通る
- Windows Actual PlaytestでCore Loopを確認する

## Sensitivity Contract

Phase 2でSensitivity Researchを実施し、次をCurrent Contractとする。

- Godot Mouse Aimは `InputEventMouseMotion.screen_relative` を使用する
- Mouse AimへFrame deltaを掛けない
- Training中は `Input.use_accumulated_input = false` を使用する
- VALORANT-style rotation modelはCommunityで広く使用されている yaw `0.07°/count at sensitivity 1.0` を採用する
- `degrees_per_count = 0.07 × sensitivity`
- `eDPI = DPI × sensitivity`
- `cm/360 = 360 / (0.07 × sensitivity × DPI) × 2.54`
- DPIはApplicationが変更せず、Mouse Hardware / Driver側の実値をUserが入力する
- Sensitivity / DPIはLocal Settingsへ保存する

0.07は今回確認できたRiot公式公開仕様ではないため、「Riot公式保証値」とは扱わない。Research根拠と残るVerificationは `docs/SENSITIVITY_RESEARCH.md` をSource of Truthとする。

## Crosshair Contract

Phase 2ではCrosshairをTrainingの表示設定として扱う。

- Start / PauseからCrosshair Settingsを開ける
- 色 / 長さ / 太さ / Gap / Outline / Center Dotを手動調整できる
- VALORANTのCrosshair Profile Codeを貼り付けてPrimary Crosshair (P)を読み込める
- Inner / Outer Lines、horizontal / vertical length、opacity、outline、center dotを静的形状として反映する
- Movement Error / Firing Errorによる動的Crosshair変形は現段階では再現しない
- ADS (A) / Sniper (S) Sectionは現段階では読み込まない
- 読み込んだCodeまたは手動設定はLocal Settingsへ保存する
- Crosshair設定はSensitivity / Hit Detection / Scoreへ影響させない

VALORANT Crosshair Codeのtoken構造は公開Parser / Community reverse engineeringを根拠にする。Riot公式の完全Format仕様として断定しない。

## Session / Result / Personal Best Contract

Phase 2のCurrent Trainingは、結果比較ができる固定Sessionとして扱う。

- Default Session Durationは60秒
- Countdownは`PLAYING`中だけ進める
- Pause / Settings表示中はSession Timeを消費しない
- 0秒で射撃を停止し、Mouse Captureを解除してResultへ遷移する
- ResultにScore / Hit / Miss / Accuracy / Personal Bestを表示する
- Personal BestはDefault TrainingのBest ScoreとしてLocalへ保存する
- Personal BestはSession終了時にCurrent Scoreが既存Bestを上回った場合だけ更新する
- RetryはScore / Hit / Miss / Aim / Timerを初期化して新しいSessionを開始する
- ResultからStartへ戻れる
- Account / Cloud Saveを必須にしない

現在の60秒値はTraining FoundationのDefault。将来Home / Stage Libraryを導入したら、DurationとBest Record keyをStage metadata側へ移行できる構造を維持する。

## Difficulty Contract

Phase 2のCurrent Trainingでは、DifficultyをAim課題のTarget presentationだけに限定する。

- `かんたん / 標準 / むずかしい` の3段階
- DifficultyはTarget radiusとspawn rangeだけを変更する
- Sensitivity / DPI / Crosshair / Hit Detection rule / Score rule / Session durationは変更しない
- Start画面で選択し、Session開始後はそのSession中のDifficultyを固定する
- 選択DifficultyはLocal Settingsへ保存する
- Personal BestはDifficultyごとに別Recordとして保存する
- 旧`training_records/default_best_score`は`標準`のBestとして読み込み、既存User Dataを捨てない
- 旧KeyはMigration時に削除しない
- Balance値はProject parameterとして保持し、Windows Actual Playtestで必要なら調整する

Current balance:

| Difficulty | Target radius | X range | Y range |
|---|---:|---:|---:|
| かんたん | 0.82 | -4.2〜4.2 | 0.6〜4.2 |
| 標準 | 0.62 | -5.2〜5.2 | 0.2〜4.6 |
| むずかしい | 0.46 | -6.2〜6.2 | -0.1〜5.0 |

## Future Home / Stage Library Direction

現在は実装しないが、最終的にAim Lab / Kovaak's系のTraining Platform構成へ拡張する。

想定Flow:

`Home → Stage / Training選択 → Play → Result → 再挑戦 / 次のStage`

- Homeを追加する
- Gridshot / Flick / Micro / Tracking / Hold Angle等を複数Stageとして管理する
- StageはData-drivenに追加できる構成にする
- Stageごとに説明 / 難易度 / Score / Personal Bestを持てるようにする
- 現在の単一Training画面を巨大な条件分岐へ育てない

## Skin Contract

SkinはWeapon performanceと分離する。

Skin変更で以下を変更しない:

- Sensitivity
- Hit Detection
- Target behavior
- Score rule
- Training difficulty

## Asset / Branding Contract

- OKIAIMXのコード・画像・音声・Asset・UIをコピーしない
- Aim Labをコピーしない
- VALORANT Assetの権利状態を無視しない
- Riot公式Productと誤認するBrandingをしない
- 初期はPlaceholder / Original / Permission確認済みAssetだけを使う

## Storage

Accountは必須にしない。

後続Phaseで保存候補:

- Sensitivity
- DPI
- Crosshair
- Controls
- Graphics
- Sound
- Selected Skin / Variant
- Last Mode
- Personal Best
- Recent Results

## Non-breakable Requirements

1. Mouse Aim最優先
2. FPSでSensitivityを変化させない
3. Skin変更でAim性能を変えない
4. Training中のInput latencyを増やさない
5. Loginなしで主要Trainingを利用可能
6. Aim画面をUIで邪魔しない
7. 最初の操作を明確にする
8. User-facing操作説明は日本語で理解できる
9. Skin追加でGame Logicを書き換えない
10. VALORANT Assetの権利状態を無視しない
11. OKIAIMXをコピーしない
12. Aim Labをコピーしない
13. MVP前に不要機能を増やさない
14. Game Dev HubでActual Playtest可能な状態を維持する

## Superseded Architecture

2026-09-29のUser指示により、旧Web Core / Browser / Electron前提は廃止する。Git履歴は残すがCurrent Product Architectureとして扱わない。
