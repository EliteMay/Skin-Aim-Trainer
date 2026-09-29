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
- Windows Actual Playtest: NOT_RUN
- Final visual review: NOT_RUN — Start画面の追加Selectorは実機確認Taskで確認する


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

- Linux Godot CI: pending
- Windows Direct Smoke: pending
- Windows Actual Playtest: NOT_RUN
