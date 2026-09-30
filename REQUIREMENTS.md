# REQUIREMENTS — Skin Aim Trainer

Updated: 2026-09-30
Status: Aim foundation complete / Scenario Engine migration active

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
- Sandbox / Scenario BrowserのSCENARIO INFO Panelで変更し、Session開始後はそのSession中のDifficultyを固定する
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

## Current Product Direction — KovaaK's-style Scenario Platform

2026-09-30のUser指示により、Productの開発順を変更する。

### 開発順

1. Aim TrainerとしてのScenario再現能力を先に完成させる
2. 個別ScenarioをHardcodeするのではなく、Scenario定義DataからRuntimeを構成する
3. Clicking / Tracking / Target Switching / Reactive / Strafing / Air / Angle Hold等を同じEngineで表現できるようにする
4. Built-in Scenario Packを作り、必要なScenarioは後からData追加できるようにする
5. Weapon / VALORANT-style Skin SystemはScenario基盤完成後に統合する

### 「KovaaK'sを再現」のScope

再現対象:

- Sandbox / Scenario BrowserのScenario-centric workflow
- Challenge / Freeplayの基本Run model
- ScenarioごとのPlayer / Weapon / Bot / Spawn / Movement / Aim / Challenge / Scoring / Tagsという構成概念
- Static Clicking / Dynamic Clicking / Tracking / Target Switching / Reactive Tracking等を作れるRuntime capability
- ScenarioごとのFOV / Sensitivity / Duration / Target size / movement / health / respawn / scoring parameter
- Local Scenario / PlaylistをData-drivenに追加できる構造

そのまま複製しないもの:

- KovaaK'sのSource Code
- Proprietary Asset / Audio / Logo / Branding
- Community Scenario fileを権利確認なしでBundleすること
- Online Leaderboard / Workshop / Account infrastructureの完全複製
- UIをpixel-perfectにコピーすること

特定Scenarioを追加するときは、公開情報・User提供Data・許諾済みDataから**挙動と練習目的を再実装**する。Scenario Engine側が十分に汎用化されていれば、後続追加は原則としてScenario Data追加 + 必要最小の新Behavior Componentで行う。

## Scenario Definition v1 Contract

Scenario Engine v1のSourceは`data/scenarios/*.json`とする。

必須:

- `schema_version = 1`
- `id`
- `title`
- `aim_type`
- `duration_seconds > 0`
- `tags[]`
- `player_profile`
- `weapon_profile`
- `bot_profiles[]`
- `challenge.max_active_bots > 0`
- `challenge.respawn`
- `scoring`

Loader / Validator:

- FileごとにJSON ObjectとしてParseする
- Duplicate Scenario IDを拒否する
- 参照するPlayer / Weapon / Bot / Scoring Profile fileが存在することを確認する
- Validation ErrorがあるScenarioはplayable listへ入れない
- BrowserにError件数と要約を表示する
- Scenario directoryが存在しない旧Repository状態では`data/stages.json`へFallbackする
- Scenario directoryが存在するのに全定義がInvalidの場合はLegacyへ黙ってFallbackせず、Startを無効化する

Migration中のCurrent 5 Scenarioだけは`runtime_adapter = "legacy_mode"`と`legacy_mode`を持ち、既存Gameplayへ接続する。これは一時的互換層であり、新規Scenarioの最終Architectureではない。

## Training Mode Contract

Phase 2ではSingle / Gridshotを導入し、Phase 3でHold Angle / Pre-Aim、Microshot、Flickを追加する。ModeはHomeのStage Catalogから選択し、別のMode Selectorを重複させない。

### シングル

- 1 Targetを表示する
- Hit後にそのTargetを別位置へRespawnする
- 既存のPersonal Best保存Keyをそのまま使用する

### Gridshot

- 静止Targetを3個同時表示する
- HitしたTargetだけを別位置へRespawnする
- Target同士は極端に重ならないよう最低間隔を取る
- HitはScore +1
- MissはScoreを増やさずAccuracyへ反映する
- Sessionは60秒
- Sensitivity / DPI / Crosshair / Difficulty Contractはシングルと共有する
- GridshotのPersonal BestはDifficultyごとに別Recordとして保存する

### Hold Angle / Pre-Aim

- 青いHold Pointを先に表示し、PlayerはそこへCrosshairを置いて待つ
- 0.55〜1.10秒のランダム待機後、Hold Pointの左右どちらかへ赤いTargetを出す
- Target出現まではTarget Collisionを無効にする
- Hit後は新しいHold Point / Peek Direction / Wait Timeを作り直す
- Difficultyは既存Target radiusを共有し、Peek offsetを 1.0 / 1.4 / 1.8 とする
- Missは既存Accuracyへ反映する
- Sessionは60秒
- Personal BestはDifficultyごとに別Recordとして保存する

### Microshot

- Active Targetは1個
- 初期Targetは中央付近へ出す
- Hit後は直前位置から短距離だけ移動する
- Spawn範囲は中央寄りへ制限し、大きなFlick練習にはしない
- DifficultyでTarget radiusと最大移動距離を変更する
- Session / Accuracy / Sensitivity / Crosshairは既存Contractを再利用する
- Personal BestはDifficultyごとに専用Recordへ保存する

### Flick

- Active Targetは1個
- Targetは静止し、Hitした時だけ次位置へRespawnする
- 初回はCrosshair中央基準から一定距離以上離れた位置へ出す
- 2発目以降は直前Targetから一定距離以上離れた位置へ出す
- Minimum displacement: Easy 2.2 / Normal 3.2 / Hard 4.2
- Target radius: Easy 0.76 / Normal 0.56 / Hard 0.42
- Spawn boundsは既存Difficulty Rangeを再利用する
- Session / Accuracy / Sensitivity / Crosshairは既存Contractを再利用する
- Personal BestはDifficultyごとに専用Recordへ保存する

最後に選んだStageのModeはLocal Settingsへ保存する。既存のシングルBEST Keyは変更せず、新Modeは専用Keyを追加する。

Current record mapping:

```text
single:
  best_easy_score
  best_normal_score
  best_hard_score

gridshot:
  best_gridshot_easy_score
  best_gridshot_normal_score
  best_gridshot_hard_score

hold_angle:
  best_hold_angle_easy_score
  best_hold_angle_normal_score
  best_hold_angle_hard_score

microshot:
  best_microshot_easy_score
  best_microshot_normal_score
  best_microshot_hard_score

flick:
  best_flick_easy_score
  best_flick_normal_score
  best_flick_hard_score
```

現在のSingle / Gridshot / Hold Angle / Microshot / FlickはScenario Engine移行前のPrototype Scenarioとして保持する。

Scenario Engine v1以降は`TrainingMode enum`を新Scenario追加の中心にしない。Scenario IDから以下のProfile / Ruleを読み込み、共通Runtime Componentを組み合わせる。

- Player Profile
- Weapon Profile
- Target / Character Profile
- Bot Profile
- Spawn Profile
- Movement / Dodge Profile
- Aim Profile（必要なScenarioのみ）
- Challenge Rule
- Scoring Rule
- Tags / Aim Type

既存Mode + Difficulty BESTはMigration sourceとして読み込み、新RecordはScenario ID単位へ移行する。

## Play / Stage Library Contract

Phase 3のPrimary Surfaceは、Training選択と開始前設定を同じ場所で完了できるSandbox / Scenario Browserとする。

Current Flow:

`Scenario Browser → Training選択 + Quick Settings → Play → Result → Retry / Scenario Browser`

- Scenario Browserには実装済み / playableなStageだけを表示する
- 左側にTraining一覧、右側に選択中Trainingの詳細と開始前設定を表示する
- Training選択のためだけに別Page / Stage Setupへ遷移しない
- Current Prototypeでは`data/stages.json`を使用する
- Scenario Engine v1では`data/scenarios/`以下のScenario definitionをSource of Truthとする
- Scenario metadataは最低限 `id / title / aim_type / description / duration / tags / player_profile / weapon_profile / bot_profiles / challenge / scoring` を持つ
- 現在のplayable Stageは「シングルターゲット」「Gridshot」「Hold Angle / Pre-Aim」「Microshot」「Flick」
- Training一覧はCatalog Dataから動的に生成する
- 選択中PanelへTitle / Category / Description / Duration / Personal Bestを表示する
- Difficultyは選択中Panel内で直接変更できる
- Sensitivity / Crosshairは選択中Panel内に入口を置き、詳細Overlayを閉じると同じScenario Browserへ戻る
- Primary Actionの「練習を開始」は選択中Panel内に置く
- Training途中のPause →「メインメニューへ戻る」はScenario Browserへ戻す
- Resultの「Homeへ戻る」はScenario Browserへ戻す
- 最後に選んだMode / Difficultyは既存Local Settingsへ保存する
- Stage DurationはmetadataからRuntimeへ渡せるようにする。Current Stageはすべて60秒
- Scenario Engine移行後はScenario数増加を前提にSearch / Filter / Favorite / Recentを追加する
- Aim Type / Tags / Difficulty / SourceでBrowseできる構造にする
- 新Stage追加でSceneへ固定Buttonや巨大な条件分岐を追加しない
- KovaaK'sのScenario-centric workflow / configurable profile modelは参考にするが、Source Code / Asset / Branding / Community配布Fileはコピーしない

Current Recordは既存互換のためMode + Difficulty Keyを読み込める状態を維持する。Scenario Engine v1でScenario ID + Variant / Difficulty単位へMigrationする。

## Scenario Engine Completion Contract

Skin実装へ進む前に、最低限次を満たす。

- Static Clicking
- Dynamic Clicking
- Smooth Tracking
- Reactive Tracking
- Target Switching
- Angle Hold / Peek
- Strafe / movement target
- Multi-target spawn / despawn
- Target health / kill / respawn
- Hitscan single-shot / automatic fire
- Challenge timer / Freeplay
- Configurable scoring / accuracy
- Scenario ID別Personal Best
- Scenario Browser search / filter
- Local Playlist
- JSON定義だけで複数Scenarioを追加できる
- 新Scenario追加でMain Sceneの巨大なmode分岐を増やさない

Editor / Online Workshop / Global LeaderboardはScenario Engine v1の必須条件ではない。

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
- KovaaK'sのSource Code / Asset / Brand / Community Scenario fileを権利確認なしでコピーしない
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
