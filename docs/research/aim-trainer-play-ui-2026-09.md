# Aim Trainer Play UI Research — 2026-09-30

## Research Question

Skin Aim TrainerでTraining Modeを選択し、Difficulty / Sensitivity / Crosshairを確認して開始するまでのFlowを、どのSurfaceへまとめるべきか。

## Project Context

- Primary platform: Windows / Godot
- Current playable Training: シングルターゲット / Gridshot
- Current user feedback: 「設定とかはモードを選ぶところにあるべき」
- Priority: Training開始までの往復を減らし、選択中Modeと設定状態を見失わない
- Out of scope: Aimlabs / KovaaK'sのUI、Asset、Branding、Layoutのコピー

## Evidence

### Aimlabs — 2026 Play 2.0

Source:
- Steam official announcement, "Aimlabs 2.0 Play Screen - all of your training, all in one place", 2026-09-12
- https://steamcommunity.com/app/714010/announcements/

Observed:
- Play 2.0はTraining GridへTasks / Playlists / Guides / Benchmarks / Events / Multiplayer等を集約する。
- 発表文は、Trainingを探すためにdifferent screensをclickして回る時間を減らし、Training時間を増やすことを目的としている。
- Favorites / RecentsもPlay内のTraining discoveryとして扱う。

Applicability:
- Skin Aim Trainerはまだ2 ModeなのでAimlabsほど多いContent Surfaceは不要。
- ただし「Training discoveryと開始を分断しすぎない」という方向はCurrent User Feedbackと一致する。

### Aimlabs — Getting Started / Settings

Sources:
- https://aimlabs.com/articles/aimlabs/getting-started-in-aimlabs-four-steps-for-your-first-session/
- https://aimlabs.com/articles/aimlabs/how-to-configure-and-convert-your-sensitivity-in-aimlabs/

Observed:
- HomeからSettingsへ入り、Sensitivity / Game Profile / Crosshair等を調整できる。
- Sensitivity consistencyはTraining前の重要設定として扱われる。
- HomeにはQuick Play / Tasks discoveryがある。

Applicability:
- Sensitivity / CrosshairはTraining selectionから遠い場所へ隠さない。
- 詳細Editor自体をLibraryへ埋め込む必要はないが、選択中Trainingの近くに入口とCurrent summaryを置く価値がある。

### KovaaK's — Settings / Playlist improvements

Sources:
- https://wiki.kovaaks.com/home/KovaaK%27s/Settings
- Steam official KovaaK's 3.7.3 patch notes, 2025-01-24

Observed:
- Main SettingsはCrosshair / Mouse Sensitivity / FOVなど、Training feelへ直結する項目の中心。
- Sensitivity ScaleはGame selection / searchを使える。
- 3.7.3ではPlaylist state persistence、AddToPlaylist search、Skip Challenge Results、Session Stats clarity等が改善されている。
- SettingsからEscapeで戻る不具合も修正されており、SettingsとTraining flowのRecoveryが実際の品質対象になっている。

Applicability:
- Training selection、settings、return pathのContext continuityを重視する。
- Current 2 Modeでは大規模Scenario Searchを先回り実装しない。

## Current UI Review

### KEEP

- Data-driven Stage Catalog
- シングル / Gridshotの既存Gameplay
- Difficulty / Sensitivity / Crosshair persistence
- Result / Retry
- PauseからMain Menuへ戻る短いRecovery Path
- Dark theme / low-distraction Training HUD

### FIX

- HomeでModeを選んだ後、別Stage Setupへ遷移していたため、Mode selectionと設定が分断される。
- Trainingを切り替えるたびにHomeへ戻る必要がある。
- 選択中Mode / Difficulty / Sensitivity / Crosshair / Startの関係が1 Surfaceで見えない。

### REMOVE

- Training selectionだけのための別Stage Setup Surface
- HomeとStage Setupの往復

## Design Decision

Current Phase 3では1つのPlay / Training Library Surfaceに集約する。

```text
Left: Training Library
- シングルターゲット
- Gridshot
- 将来Stage

Right: Selected Training
- Title / Category / Description / Duration
- Current BEST
- Difficulty
- Sensitivity summary + Settings
- Crosshair Settings
- Play
```

Training Buttonを押した時は別Pageへ移動せずRight Panelだけ更新する。

Sensitivity / Crosshairの詳細設定はOverlayを維持するが、入口はSelected Training Panelへ置き、閉じると同じPlay Libraryへ戻す。

## Search / Filter Decision

Current playable Stageは2件なのでSearch / Filterは導入しない。

Stage Catalogのcategory / tagsは維持し、Stage数が増えた時だけBrowse / Searchへ拡張する。

## Validation

Automated:
- Play Library default state
- Dynamic Stage list
- Stage selection without page transition
- Selected Training detail sync
- Difficulty / Sensitivity / Crosshair entry points on same primary Surface
- Settings Overlay return to Play Library
- Single / Gridshot gameplay and records regression

Actual Windows Playtest:
- 1画面で「何を選ぶ / 何を設定する / どこから開始する」が理解できるか
- Single / Gridshot切替で不要な画面遷移が発生しないか
- Difficulty / Sensitivity / Crosshairへの到達が自然か
- 1600x900でPanelが収まり操作しやすいか
