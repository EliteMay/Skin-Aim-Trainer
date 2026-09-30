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


## Deeper Current-Product Comparison — 2026-09-30

### Aimlabs 2.0 Play Screen

Official current announcement:
- https://steamcommunity.com/app/714010/announcements/
- "Aimlabs 2.0 Play Screen - all of your training, all in one place" (2026-09-12)

Observed:
- Play 2.0 introduces a consolidated Training Grid.
- Tasks / Playlists / Guides / Benchmarks / Events / Multiplayer are discoverable from the same Play destination.
- The stated goal is to reduce time spent finding training and clicking through separate screens.
- Favorites and Recents receive dedicated access so repeated training does not require rediscovery every session.

Project transfer:
- Keep Training discovery as the primary surface.
- Do not split Mode selection and pre-training settings into separate pages unless the amount of content makes that necessary.
- When the Skin Aim Trainer library grows, first add lightweight Recents / Favorites before creating more top-level navigation.

### Aimlabs First-Session / Settings Flow

Official current guides:
- https://aimlabs.com/articles/aimlabs/getting-started-in-aimlabs-four-steps-for-your-first-session/
- https://aimlabs.com/articles/aimlabs/how-to-configure-and-convert-your-sensitivity-in-aimlabs/

Observed:
- Sensitivity is treated as a setup-critical configuration before training.
- Game Profile / FOV / sensitivity are grouped under Settings.
- Crosshair, audio, graphics and visual choices are also configurable from Settings.
- Home / Play remains the training-discovery surface, while Settings is a reusable global configuration surface.

Project transfer:
- Surface the current Sensitivity / Crosshair state beside the selected Training so the user does not lose context.
- Keep detailed Sensitivity / Crosshair editors as overlays rather than permanently expanding the primary Play layout.
- Closing a Settings overlay should return to the same selected Training without losing selection.

### KovaaK's Scenario Browser

Current scenario browser:
- https://kovaaks.com/kovaaks/scenarios

Observed:
- The browser is built around a large searchable scenario collection.
- Scenario name / score-oriented information is visible in the browsing context.
- Search is useful because the content set is already large.

Project transfer:
- Search is not justified for two playable Stages.
- Preserve Stage metadata such as category / tags so Search / Filter can be added without redesigning the data model later.
- Add Search only when finding a Stage from the visible list becomes a real repeated cost.

### KovaaK's Main Settings

Reference:
- https://wiki.kovaaks.com/home/KovaaK%27s/Settings

Observed:
- Crosshair, mouse sensitivity and FOV are central Settings concerns.
- Sensitivity Scale can map to a selected game and also supports cm/360-style configuration.
- The Settings surface is reusable across scenarios rather than recreated inside each Scenario.

Project transfer:
- Keep sensitivity and crosshair as global persistent settings.
- Expose their current summary and entry points next to the selected Training.
- Do not duplicate independent copies of the same setting per Stage unless a future Stage explicitly requires an override.

### KovaaK's 3.7.3 Flow / Persistence Improvements

Official patch notes:
- https://store.steampowered.com/news/posts/?appgroupname=KovaaK+2.0%3A+The+Meta&appids=824270&enddate=1738766467&feed=steam_community_announcements

Observed:
- Playlist state is remembered across restarts.
- Search was added inside playlist selection.
- "Skip Challenge Results" was added for users who want lower interruption.
- Session Stats layout was revised for clarity.
- Escape-key recovery from sound / crosshair picker Settings was explicitly fixed.

Project transfer:
- Preserve selected Training / Difficulty across restart.
- Prioritize predictable back / Escape behavior from Sensitivity and Crosshair overlays.
- Keep Result → Replay / Play Library recovery short.
- Later, if repeated training makes Result interruption costly, add a user-controlled skip/auto-retry option instead of forcing it by default.

## Updated Direction Contract

Current primary composition remains:

```text
PLAY / TRAINING LIBRARY
├─ Left: Training list
│  ├─ シングルターゲット
│  ├─ Gridshot
│  └─ future Stages
└─ Right: Selected Training
   ├─ Title / Category / Description / Duration
   ├─ BEST
   ├─ Difficulty
   ├─ Sensitivity summary + Settings
   ├─ Crosshair Settings
   └─ Primary Play button
```

KEEP:
- One-surface Training selection + Quick Settings
- Data-driven Stage catalog
- Global persistent Sensitivity / Crosshair
- Result / Retry / Play Library recovery
- Low-distraction Training HUD

DO NOT ADD YET:
- Search
- Favorites
- Recents
- Playlist editor
- Multiple top-level tabs
- Per-Stage copies of global Sensitivity / Crosshair

ADD WHEN CONTENT / USAGE JUSTIFIES IT:
- Recents / Favorites for repeated training
- Search / category filter for a larger Stage library
- Playlist / Routine composition
- Result skip / auto-next options

The design goal is not to reproduce Aimlabs or KovaaK's visually. The transferable pattern is: training discovery is centralized, current setup is easy to inspect before Play, global aim settings remain reusable, and returning to training does not lose context.
