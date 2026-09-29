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

- Automated Godot CI: pending
- Windows Settings UI / persistence: NOT_RUN
- Windows Aim feel: NOT_RUN
- Exact physical VALORANT parity calibration: NOT_RUN
