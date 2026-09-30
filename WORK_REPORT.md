# WORK REPORT

## 2026-09-29 — Godot Rewrite

### User Evidence

旧Browser prototypeについて次のFeedbackを受けた。

- ChromeではなくGodotで作りたい
- ゲームが何をすればいいか分からない
- 操作しにくい

### Decision

Current Product ArchitectureをWeb / ElectronからGodotへ変更する。

- Godot 4.7.2 stable
- GDScript
- Windows-first
- BrowserをPrimary Runtimeにしない
- Electronを本ゲームShellにしない

旧Web実装はGit履歴へ残すがCurrent Runtimeから削除する。

### Usability Direction

起動後の導線を最小化。

```text
起動
→ 練習を開始
→ マウスでTargetを狙う
→ 左クリック
```

Training中に必要のないMode / Skin / SettingsはPhase 1画面へ出さない。

### Implemented

- Godot project
- 3D arena
- Mouse capture
- Mouse aim
- Center crosshair
- Single target
- Physics raycast shooting
- Score / Hit / Miss / Accuracy
- Hit / Miss feedback
- Start overlay
- Japanese 3-step instructions
- Pause overlay
- Resume / Restart
- R restart
- Godot Headless CI / Core Smoke

### Architecture Change

Before:

- Browser
- Canvas
- Pointer Lock
- Node dev server
- Later Electron

After:

- Godot 4.7.2
- Node3D / Camera3D
- Godot Mouse Capture
- Physics Raycast
- Windows Desktop target

### Validation

- Repository implementation: complete on rewrite branch
- Godot CI: PASS — GitHub Actions run 36545307524
- Windows Actual Playtest: PASS
- High Refresh Rate: NOT_RUN
- Visual / usability final confirmation: PASS — 起動導線を含むPhase 1 User verification

### Phase 1 Windows Evidence

Game Dev Hub共有Packで、Repository commit `5ac74e18` / Godot `4.7.2.stable` を対象に以下を確認。

- Godot版をGame Dev Hubから起動: PASS
- 操作が迷わないか: PASS
- Aim / Shoot: PASS
- Pause / Restart: PASS

Phase 1のCompletion Criteriaを満たしたため、RoadmapのUser確認Taskを完了へ更新した。

### Remaining

1. Phase 2 — Sensitivity / DPI / eDPIのResearchと設定
2. Crosshair設定
3. Timer / Result / Personal Best
4. Difficulty
5. Gridshot


## 2026-09-29 — Phase 2 Sensitivity / DPI / eDPI

### Research

Godot 4.7 Docsを確認し、Mouse Aimを `relative` から `screen_relative` へ変更する方針を採用した。`relative` はcontent scaleでScaleされるため、Resolution / Stretch条件でSensitivityが変わり得る。

高精度入力向けに `Input.use_accumulated_input = false` も採用。

VALORANT yawは複数の独立したSensitivity referenceで `0.07° / count at sensitivity 1.0` が一致した。ただし今回確認できたRiot公式公開仕様ではないため、Community measurementとして明示する。

### Implemented

- VALORANT Sensitivity input
- Mouse DPI input
- eDPI calculation
- cm/360 calculation
- Current sensitivity summary
- Start / Pauseから開けるSensitivity Settings
- `user://settings.cfg` persistence
- `screen_relative` Aim input
- accumulated input disabled during runtime
- Sensitivity math regression tests
- Sensitivity UI contract smoke test
- Research document

### Formulas

```text
degrees/count = 0.07 × sensitivity
eDPI = DPI × sensitivity
cm/360 = 360 / (0.07 × sensitivity × DPI) × 2.54
```

### Validation State

- Automated Godot CI: PASS — GitHub Actions run 36550215111
- Windows Settings UI / persistence: PASS — Game Dev Hub共有Pack 2026-09-29
- Windows Aim feel direction check: PASS — 感度を上げる/下げるで速度変化を確認
- Exact physical VALORANT parity calibration: NOT_RUN


## 2026-09-29 — Phase 2 Crosshair Settings

### User Requirement

VALORANTのCrosshair Codeをそのまま読み込めるようにする。

### Implemented

- Custom Godot Crosshair renderer
- Manual color / length / thickness / gap / outline / center dot
- Live preview
- VALORANT Crosshair Profile Code input
- Primary `P` section parser
- Preset / custom color
- Outline opacity / thickness
- Center dot opacity / size
- Inner lines
- Outer lines
- Independent vertical line length
- Imported code persistence
- Manual settings persistence

### Compatibility Boundary

Movement / Firing Errorによる動的なCrosshair expansionは現段階では固定形状として扱う。ADS / Sniper sectionは未対応。

Crosshair Code token mapはCommunity reverse engineering / public parser sourcesで照合したものであり、Riot公式の完全Format仕様とは扱わない。

### Deferred Product Direction

Userから、将来はAim Lab / Kovaak'sのようにHomeから複数Stageを選択できるTraining Platformへしたいという要望あり。今回は実装せずRequirements / RoadmapへFuture Directionとして記録。

### Validation State

- Parser unit/smoke coverage: PASS — GitHub Actions run 36552007274
- Godot import / cold start: PASS — GitHub Actions run 36552007274
- Windows VALORANT code import: PASS — Game Dev Hub共有Pack 2026-09-30
- Windows persistence: PASS — Game Dev Hub共有Pack 2026-09-30
- Windows manual controls: PASS — Game Dev Hub共有Pack 2026-09-30


## 2026-09-29 — Crosshair Settings Button Windows Fix

### User Evidence

Windows実機で「クロスヘアを設定」を押しても画面が変わらないと報告。

### Reproduction

既存Linux CIは事前にGodot `--import` を実行していたため再現しなかった。

Windows Direct Launch相当のCIを追加し、import cacheなしでCore Smokeを起動したところ次を再現:

```text
Parse Error: Could not find type "AimCrosshair" in the current scope.
```

### Root Cause

`aim_trainer.gd` が、新規追加した `crosshair.gd` の `class_name AimCrosshair` を型注釈として参照していた。

Godot Editor / import scan後はglobal class cacheに登録されるため正常だが、Game Dev HubからRepository更新直後にWindowsで直接起動すると、新classがcacheへ登録される前にMain Scriptをparseする場合がある。

その結果、Windows Direct LaunchでMain Script parseが失敗し、新しく追加したCrosshair UI処理が正常に初期化されない状態になった。

### Fix

- `AimCrosshair` のglobal class型注釈依存を削除
- SceneへattachされたCrosshair scriptを `Control` として参照
- Crosshair APIはattached scriptのmethodとして呼び出す
- Crosshair buttonは通常の `pressed` semanticsを維持
- Runtime Smoke Testで実マウスdown/upを通してCrosshair Settings遷移を確認
- Windows Godot 4.7.2 Direct Launch SmokeをCIへ追加
- Crosshair Settings contentが1600x900 viewport内に収まることも確認

### Validation

- Linux Godot CI: PASS
- Windows Godot 4.7.2 direct smoke: PASS
- Crosshair button GUI click transition: PASS
- Crosshair Settings layout: PASS — 620x843 within 1600x900
- User Windows actual retest: PASS — Game Dev Hub共有Pack 2026-09-30


## 2026-09-30 — Phase 2 Timer / Result / Personal Best

### Crosshair Evidence Closure

Game Dev Hub共有PackでCrosshair実機確認6/6 PASSを確認し、RoadmapのCrosshair実機確認Taskを完了へ更新した。

確認済み:

- Crosshair Settingsが開く
- VALORANT Crosshair Code import
- Preview更新
- Training反映
- 再起動後Persistence
- 手動調整

### Implemented

- 60秒Default Session
- HUD Timer
- PLAYING中のみCountdown
- Pause中Timer停止
- 0秒でResultへ自動遷移
- Result Score / Hit / Miss / Accuracy
- NEW BEST表示
- Local Personal Best
- Retry
- Startへ戻る
- Start画面BEST表示

### Persistence

`user://settings.cfg`:

```text
[training_records]
default_best_score=<int>
```

### Future Compatibility

現在はDefault Training 1種類なので固定60秒 / default_best_scoreを使用する。Home / Stage Library導入時は、DurationとRecord keyをStage metadata / Stage IDへ移行する。

### Validation State

- Godot Import / Cold Start: PASS — GitHub Actions run 36594652199
- Linux Core Smoke: PASS — GitHub Actions run 36594652199
- Windows Direct Smoke: PASS — GitHub Actions run 36594652199
- Countdown / Pause / Result / Best persistence: PASS — GitHub Actions run 36594652199
- Windows Actual Playtest: PASS — Game Dev Hub共有Pack 2026-09-30 / 8 of 8


## 2026-09-30 — Phase 2 Difficulty

### Previous Task Closure

Game Dev Hub共有PackでTimer / Result / Personal BestのWindows実機確認8/8 PASSを確認し、Roadmapの実機確認Taskを完了へ更新した。

### Design Decision

DifficultyはCurrent TrainingのAim条件だけを変える。

- かんたん: 大きいTarget / 狭いspawn range
- 標準: 既存と同じTarget / spawn range
- むずかしい: 小さいTarget / 広いspawn range

Sensitivity / Crosshair / Hit Detection rule / Score rule / 60秒SessionはDifficultyで変更しない。

### Implemented

- Start画面Difficulty selector
- 選択DifficultyのLocal persistence
- Difficulty別Target radius
- Difficulty別spawn range
- Mesh / Collisionを同じradiusへ同期
- ResultへのDifficulty表示
- Difficulty別Personal Best
- 旧default_best_scoreをNormal Bestとして読む互換処理
- Legacy keyを削除しない非破壊Migration
- Difficulty UI / geometry / records / migration regression coverage

### Validation State

- Godot Import / Cold Start: PASS — GitHub Actions run 36599258512
- Linux Core Smoke: PASS — GitHub Actions run 36599258512
- Windows Direct Smoke: PASS — GitHub Actions run 36599258512
- Legacy Best compatibility: PASS — GitHub Actions run 36599258512
- Windows Actual Playtest: PASS — Game Dev Hub共有Pack 2026-09-30 / 9 of 9
- Final visual review: PASS — Difficulty selector / ESC Main Menu flowをUser実機確認


## 2026-09-30 — Pauseからメインメニューへ戻る導線

### User Feedback

Difficulty等のWindows実機確認中、60秒Sessionの途中からStartへ戻れず、毎回の比較テストがしにくいとFeedbackを受けた。

### Implemented

- Pause画面へ「メインメニューへ戻る」を追加
- ESCでPauseした後、途中Sessionを破棄してREADY / Startへ戻れる
- 確認Dialogは出さず、繰り返しPlaytestを短い導線で行えるようにした
- 途中Session破棄ではPersonal Bestを更新しない
- Startへ戻った後の次SessionはScore / Timerを通常どおり初期化する
- Pause Menuが1600x900 viewport内へ収まるRegressionを追加
- Pause → Main Menu / unfinished score非保存をCore Smokeへ追加

### Validation State

- Linux Godot CI: PASS — GitHub Actions run 36609240253
- Windows Direct Smoke: PASS — GitHub Actions run 36609240253
- Windows Actual Playtest: PASS — Game Dev Hub共有Pack 2026-09-30


## 2026-09-30 — Phase 2 Gridshot

### Previous Task Closure

Game Dev Hub共有PackでDifficultyのWindows実機確認9/9 PASSを確認し、RoadmapのDifficulty実機確認Taskを完了へ更新した。

確認済み:

- 3段階Difficulty
- Easy / Normal / HardのTarget size / spawn range
- ESC → Main Menu
- 途中SessionでBEST非更新
- Sensitivity / Crosshair / 60秒 / Score ruleの非破壊
- Difficulty別BEST
- 再起動後Persistence

### Reference Boundary

Aimlabs公式のCurrent materialでGridshotがCore Taskとして継続していることを確認した。今回の3 Target / Respawn / Score仕様はProject固有の独自実装で、AimlabsのUI / Asset / Code / exact scoringをコピーしない。

### Implemented

- Start画面Training Mode selector
- シングル / Gridshot
- Gridshot 3 Target同時表示
- Hit TargetだけRespawn
- Target間Minimum separation
- Difficultyを3 Targetすべてへ適用
- Mode persistence
- Mode + Difficulty別Personal Best
- 既存Single BEST Keyを維持
- Gridshot専用BEST Key追加
- Mode / Target count / record separation regression coverage

### Validation State

- Godot Import / Cold Start: PASS — GitHub Actions run 36656512823
- Linux Core Smoke: PASS — GitHub Actions run 36656512823
- Windows Direct Smoke: PASS — GitHub Actions run 36656512823
- Existing Single BEST compatibility: PASS — GitHub Actions run 36656512823
- Gridshot Windows Actual Playtest: PASS — Game Dev Hub共有Pack 2026-09-30 / 8 of 8


## 2026-09-30 — Phase 3 Home / Stage Library Foundation

### Previous Task Closure

Game Dev Hub共有PackでGridshotのWindows実機確認8/8 PASSを確認し、RoadmapのGridshot実機確認Taskを完了へ更新した。

確認済み:

- Gridshot選択
- 3 Target同時表示
- HitしたTargetだけRespawn
- Miss / Accuracy
- Difficulty反映
- 60秒Result / Gridshot BEST
- Single / Gridshot BEST分離
- 再起動後Mode / BEST Persistence

### Flow / Visual Research

MeaningfulなMenu / IA変更のため、最新GuideのTask-first Structure / Domain-first Visual Researchに従ってCurrent Aim Trainerを確認した。

Representative evidence:

- AimlabsはCurrent Productで多数のTasks / PlaylistsをTrainingから選ぶ構成を維持している
- Aimlabsの2026年更新でもTraining navigation上のFeatured row / Playlist導線が使われている
- KovaaK'sはScenario Libraryを一覧・検索でき、Scenario数が大きい
- KovaaK's Playlist Browserはname / author / aim typeでBrowse / Searchし、description / scenario breakdown / timeを表示する

ProjectへのDecision:

- CurrentはPlayable Stageが2件だけなのでSearch / Filterは追加しない
- Homeは「練習を探して開始する」Primary Surfaceにする
- Stage Setupは選択済みStageのDifficulty / Sensitivity / Crosshairへ責務を限定する
- HomeとStage Setupに同じMode Selectorを重複させない
- category / tagsをStage metadataへ持たせ、Stage数が増えた時にBrowse / Searchへ拡張できるようにする
- Aimlabs / KovaaK'sのUI / Assets / Brandingはコピーしない

References:

- https://www.aimlabs.com/
- https://aimlabs.com/articles/aimlabs/big-updates-to-aimlabs-on-console/
- https://kovaaks.com/kovaaks/scenarios
- KovaaK's Steam announcement — Playlist Browser

### Implemented

- 起動直後のHome
- Home → Stage Setup → Play → Result → Retry / Home
- `data/stages.json` Stage Catalog
- `scripts/stage_catalog.gd` loader / normalization
- CatalogからPlayable Stage Buttonを動的生成
- Current Stage: シングルターゲット / Gridshot
- Stage metadata: id / mode / title / category / description / duration / playable / sort order / tags
- Stage SetupへTitle / Category / Duration / Descriptionを表示
- Stage DurationをmetadataからRuntimeへ渡す
- Stage SetupからHomeへ戻る
- Pause Main MenuをHomeへ接続
- Result BackをHomeへ接続
- 既存Single / Gridshot Save Key互換を維持
- Home / Catalog / Stage Flow Smoke Test

### Validation State

- Godot Import / Cold Start: PASS — GitHub Actions run 36658238221
- Linux Core Smoke: PASS — GitHub Actions run 36658238221
- Windows Direct Smoke: PASS — GitHub Actions run 36658238221
- Stage Catalog / Home / Result→Home routing regression: PASS — GitHub Actions run 36658238221
- Existing Single / Gridshot gameplay regression: PASS — GitHub Actions run 36658238221
- Windows Actual Playtest: NOT_RUN
- Final visual review: NOT_RUN — Home / Stage SetupはWindows実機確認Taskで確認する


## 2026-09-30 — Play Library / Quick Settings Consolidation

### User Feedback

Phase 3 Home / Stage Library Foundationを実装後、Userから「設定とかはモードを選ぶところにあるべき」「Aim LabとKovaaK'sをもっと参考にしてほしい」とFeedback。

前回のHome → Stage Setup分離はWindows Actual Playtest前だったため、未検証Flowを維持せずCurrent Product Researchから再設計した。

### Current Product Research

Aimlabs:
- 2026-09-12のPlay 2.0でTraining Gridを導入。
- Tasks / Playlists / Guides / Benchmarks / Events / Multiplayer等をPlayへ集約。
- 公式発表は、Trainingを探すために複数Screenをclickして回る時間を減らすことを目的としている。
- 2025-12 Getting StartedではHomeからQuick Play / Tasksへ入り、SettingsからSensitivity / Crosshair等を調整する。
- 2026-03 Sensitivity GuideでもTraining前のSensitivity consistencyを重要項目として扱う。

KovaaK's:
- Main SettingsはCrosshair / Mouse Sensitivity / FOV等、Training feelへ直結する設定の中心。
- Sensitivity ScaleはGame dropdown / searchを持つ。
- 2025-01 v3.7.3ではPlaylist state persistence / search / result skipping / Session Stats clarityを改善。
- SettingsからEscapeで戻れない不具合も修正されており、Training ContextへのRecoveryもProduct qualityとして扱われている。

References:
- https://steamcommunity.com/app/714010/announcements/
- https://aimlabs.com/articles/aimlabs/getting-started-in-aimlabs-four-steps-for-your-first-session/
- https://aimlabs.com/articles/aimlabs/how-to-configure-and-convert-your-sensitivity-in-aimlabs/
- https://wiki.kovaaks.com/home/KovaaK%27s/Settings
- KovaaK's 3.7.3 official Steam patch notes

Detailed Research:
- `docs/research/aim-trainer-play-ui-2026-09.md`

### Decision

Current 2-Stage規模では、Training selectionと開始前設定を別Surfaceへ分ける利益よりNavigation costが大きい。

採用:
- 左: Training Library
- 右: Selected Training / Quick Settings
- Difficulty: Right Panel内
- Sensitivity summary + Settings入口: Right Panel内
- Crosshair Settings入口: Right Panel内
- Play: Right Panel内
- Stage選択ではPage transitionしない
- Sensitivity / Crosshair詳細Overlayを閉じると同じPlay Libraryへ戻る

非採用:
- Home → 別Stage Setup
- 2 Stageだけの段階でSearch / Filterを追加
- Aimlabs / KovaaK'sのUI / Asset / Brandingコピー

### Implemented

- StartOverlay / separate Stage Setupを削除
- Play / Training Libraryを1 Surface化
- Stage LibraryとSelected Training Panelの2-column composition
- Selected Training Title / Category / Duration / Description / BEST
- Difficulty selectorをSelected Training Panelへ配置
- Sensitivity summary / settings buttonをSelected Training Panelへ配置
- Crosshair settings buttonをSelected Training Panelへ配置
- Primary Play buttonをSelected Training Panelへ配置
- Stage Buttonのselected toggle state
- Stage切替はsame-surface update
- Settings / Crosshair OverlayのREADY return先をPlay Libraryへ変更
- Existing Single / Gridshot gameplay / records / save compatibilityを維持
- Smoke Testをone-screen flowへ更新

### Validation State

- Godot Linux import / cold start / core smoke: PASS — GitHub Actions run 36667623918
- Windows Godot direct smoke: PASS — GitHub Actions run 36667623918
- Separate Stage Setup removal contract: PASS — Core Smoke
- Training selection stays on same Surface: PASS — Core Smoke
- Difficulty / Sensitivity / Crosshair entry points colocated: PASS — Core Smoke
- Existing Single / Gridshot gameplay / records: PASS — Core Smoke
- Windows Actual Playtest / final visual review: NOT_RUN


## 2026-09-30 — Aimlabs / KovaaK's UI Research Deepening

User requested that Mode selection and Settings remain together and that Aimlabs / KovaaK's be referenced more deeply.

Additional research covered:
- Aimlabs 2.0 Play Screen / Training Grid
- Aimlabs Favorites / Recents direction
- Aimlabs first-session sensitivity / crosshair setup
- KovaaK's current Scenario Browser
- KovaaK's Main Settings ownership for sensitivity / crosshair / FOV
- KovaaK's 3.7.3 playlist state persistence, search, results skipping and Settings recovery fixes

Decision:
- Current one-screen Play Library + Selected Training / Quick Settings remains the correct direction.
- Search / Favorites / Recents are intentionally deferred while only two Stages exist.
- Sensitivity / Crosshair remain global persistent settings, but their current state and entry points stay beside the selected Training.
- Settings overlays must return to the same Play Library context.
- Future library growth should first add Recents / Favorites / Search without fragmenting Training discovery across more screens.

No gameplay contract or save migration changed in this research-only update.


## 2026-09-30 — Phase 3 Hold Angle / Pre-Aim

### Research / Design Boundary

AimlabsのCurrent angle-holding解説では、Crosshair placementを維持しつつ、Target出現時に必要なmicro-adjustmentだけを行う練習が示されている。KovaaK'sにもValorant Angle Hold系Scenarioが存在する。

今回の実装はUI / Asset / exact Scenarioをコピーせず、Current Skin Aim Trainerの静止Camera / click timingへ合わせた独自の簡易Flowにした。

### Implemented

- Play LibraryへHold Angle / Pre-Aim Stageを追加
- 青いHold Pointを表示するpre-aim waiting phase
- 0.55〜1.10秒のrandom wait
- Hold Point左右へのrandom Peek
- Difficulty別Peek offset
- Target出現前のCollision無効化
- Hit後に次Cycleへ即時移行
- Mode + Difficulty別Personal Best
- Stage Catalog / persistence / state transition smoke coverage

### Validation State

- Repository implementation: COMPLETE
- Static / Godot smoke coverage: ADDED
- Godot Import / Cold Start: PASS — GitHub Actions run 36672055887
- Linux Core Smoke: PASS — GitHub Actions run 36672055887
- Windows Direct Smoke: PASS — GitHub Actions run 36672055887
- Windows Actual Playtest: NOT_RUN

### External References

- Aimlabs — How to Hold Angles in Counter-Strike 2 While Strafing (2026-02-27)
- Aimlabs — Unlocking the Secrets to Calm Aim (2026)
- KovaaK's Scenario Library — Valorant Angle Hold系Scenarioが存在


## 2026-09-30 — Stage Library clipping fix

### Symptom

Repository and Roadmap were updated to Hold Angle / Pre-Aim, but the newly added Training was not visible in the actual game UI.

### Root cause

The Training list used a fixed VBoxContainer area without scrolling. The list was designed when only two Training cards existed, so adding a third card could place the newest item outside the visible area depending on the actual window/layout size.

### Fix

- Wrap the Training list in a ScrollContainer
- Let the list expand vertically inside the available Play Library area
- Reduce each Stage card minimum height from 92px to 82px
- Keep the current selected-training panel and data-driven Stage Catalog unchanged
- Extend Godot smoke coverage to assert the ScrollContainer exists and all 3 Stage buttons are created

### Validation state

- Automated CI: PENDING
- Windows Actual Playtest: NOT_RUN


## 2026-09-30 — Ensure current 3 Training cards are visible without scrolling

### Follow-up symptom

After the first scroll-container fix, the Repository was definitely at the latest commit but the new Hold Angle / Pre-Aim item still was not obvious to the user.

### Adjustment

- Keep the ScrollContainer for future library growth
- Reduce current Training card minimum height from 82px to 68px
- Reduce vertical separation from 12px to 8px
- Ensure all current 3 cards fit in the visible 230px Training viewport without requiring wheel scrolling
- Update the helper text so scrolling is only needed from 4+ items
- Add a smoke assertion that the current StageList height fits inside the visible StageScroll area

### Validation state

- Automated CI: PENDING
- Windows Actual Playtest: NOT_RUN
