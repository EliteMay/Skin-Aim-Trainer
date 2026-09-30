# SPEC — Godot Aim Trainer Core

## Runtime

- Engine: Godot 4.7.2 stable
- Language: GDScript
- Rendering: Godot 3D / Compatibility renderer
- Input: `InputEventMouseMotion.screen_relative` + `Input.MOUSE_MODE_CAPTURED`
- Primary target: Windows
- Main Scene: `res://scenes/main.tscn`

Browser / Pointer Lock / Canvas / ElectronはCurrent Runtime Contractではない。

## Scene Structure

```text
Main (Node3D)
├─ Camera3D
├─ DirectionalLight3D
├─ Arena
│  ├─ Floor
│  ├─ BackWall
│  ├─ LeftWall
│  └─ RightWall
├─ TargetRoot
├─ FeedbackTimer
└─ UI (CanvasLayer)
   ├─ HUD
   ├─ Crosshair
   ├─ ControlsHint
   ├─ Feedback
   ├─ StartOverlay
   ├─ PauseOverlay
   ├─ SettingsOverlay
   ├─ CrosshairSettingsOverlay
   └─ ResultOverlay
```

## Run State

4状態を持つ。

- `READY` — 開始画面。Cursor visible。
- `PLAYING` — Mouse captured。Aim / Shoot / Countdown受付。
- `PAUSED` — Pause画面。Cursor visible。Countdown停止。
- `RESULT` — Session終了結果。Cursor visible。Shoot停止。

遷移:

```text
READY --開始--> PLAYING
PLAYING --ESC--> PAUSED
PAUSED --ESC / 練習に戻る--> PLAYING
PAUSED --メインメニューへ戻る--> READY
PLAYING --Timer 0--> RESULT
RESULT --もう一度 / R--> PLAYING(reset)
RESULT --開始画面へ戻る / ESC--> READY
PLAYING / PAUSED --R / やり直す--> PLAYING(reset)
```

## Aim

State:

- yaw degrees
- pitch degrees

Mouse motionは `screen_relative` を使用する。Godotのcontent scaleによるSensitivity変化を避ける。

Training Runtime中は `Input.use_accumulated_input = false` とし、Mouse Motionを描画FrameごとにまとめるDefault動作を使わない。

`frame delta`はSensitivity計算へ掛けない。

Pitchは上下72度へClampする。

Phase 2のSensitivity model:

```text
degrees_per_count = 0.07 × valorant_sensitivity
eDPI = DPI × valorant_sensitivity
cm/360 = 360 / (0.07 × valorant_sensitivity × DPI) × 2.54
```

DPIは計算・表示・保存に使用する。ApplicationからMouse Hardware DPIは変更しない。

0.07 yawはCommunity measurementとして扱い、Riot公式公開仕様とは表現しない。

## Target

- 1個だけ表示する
- Camera前方の固定距離Plane上へRandom spawn
- X / Y範囲をDifficulty Profileから取得する
- Hit後だけ次位置へ移動する

Targetは`StaticBody3D + SphereShape3D`でPhysics collisionを持つ。Mesh radiusとCollision radiusは同じDifficulty valueを使用し、VisualとHit判定を一致させる。

Difficulty Profile:

| Difficulty | Radius | X range | Y range |
|---|---:|---:|---:|
| かんたん | 0.82 | -4.2〜4.2 | 0.6〜4.2 |
| 標準 | 0.62 | -5.2〜5.2 | 0.2〜4.6 |
| むずかしい | 0.46 | -6.2〜6.2 | -0.1〜5.0 |

## Training Modes

### Single

- Active Target Count: 1
- HitしたTargetをRespawn
- 既存のDifficulty別Best Keyを使用

### Gridshot

- Active Target Count: 3
- 3 Targetは同じDistance Plane上へ配置
- HitしたTargetだけをRespawn
- Respawn時は他のActive Targetと最低間隔を取る
- Score ruleはHit +1 / Miss +0
- Accuracyは既存のHit / Shots計算を再利用
- Difficulty Profileは3 Targetすべてへ同じRadius / Spawn Rangeを適用

Mode切替はREADY Stateでのみ受け付ける。Training開始後はSession中のModeを固定する。

## Shooting / Hit Detection

射撃時にCamera中央からCamera forwardへPhysics Rayを飛ばす。

- colliderが`aim_target` group → Hit
- それ以外 / collisionなし → Miss

Hit:

- score +1
- hits +1
- Target respawn
- `HIT +1` Feedback

Miss:

- misses +1
- `MISS` Feedback

Accuracy:

`hits / shots * 100`

## UI / Usability

### Start

First Viewで以下だけを強く見せる。

- Product名
- 「やることは3つだけ」
- 3Step操作説明
- 小さいTraining Mode selector
- 小さいDifficulty selector
- 大きい「60秒の練習を開始」

未実装のMode / SkinはMain flowへ出さない。

### Training

Training中のPrimary Visual:

- Target
- Crosshair

補助表示:

- Score / Hit / Miss / 命中率
- 60秒Countdown Timer
- `ESC メニュー / R やり直し`

### Pause

- 練習に戻る
- 感度を設定
- クロスヘアを設定
- 最初からやり直す
- メインメニューへ戻る

「メインメニューへ戻る」は現在の途中Sessionを破棄してREADYへ戻す。途中ScoreはPersonal Bestへ保存しない。確認Dialogは出さず、Difficulty等を繰り返し検証しやすい短い導線を優先する。

### Sensitivity Settings

- Mouse DPI
- VALORANT Sensitivity
- eDPI
- cm/360
- Rotation coefficient
- Save / Cancel

Start画面では「練習を開始」をPrimary Actionとして維持し、感度設定はSecondary Actionにする。

### Crosshair Settings

- Custom ControlでCrosshairを描画する
- 色
- Inner line length / thickness / offset
- Outline
- Center Dot
- Preview
- Save / Cancel
- VALORANT Crosshair Profile Code Import

VALORANT Code ImportはPrimary `P` Sectionを対象にする。

対応する静的項目:

- preset / custom color (`c`, `u`)
- outline (`h`, `o`, `t`)
- center dot (`d`, `a`, `z`)
- inner lines (`0b/0a/0l/0v/0g/0t/0o`)
- outer lines (`1b/1a/1l/1v/1g/1t/1o`)

Movement / Firing Error関連tokenはParse時に検出するが、動的変形は再現しない。ADS `A` / Sniper `S` Sectionも現在は対象外。

ImportしたProfileは元Codeも保存する。Import後に手動調整した場合は、現在の簡易Crosshair設定へ切り替える。

### Session / Result / Personal Best

Current default Sessionは60秒。

- `_process(delta)`で`PLAYING`中だけ残り時間を減らす
- `PAUSED` / Settings / Result中はCountdownしない
- HUD中央上に`MM:SS`で表示
- 0秒到達時にRESULTへ遷移
- Target / Crosshair / HUDを隠し、MouseをVisibleへ戻す

Result表示:

- Score
- Accuracy
- Hit / Miss
- Personal Best
- New Best表示
- Retry
- Startへ戻る

Personal BestはDifficulty別に`user://settings.cfg`へ保存する。

```text
[training]
mode="single|gridshot"
difficulty="easy|normal|hard"

[training_records]
best_easy_score=<int>
best_normal_score=<int>
best_hard_score=<int>
best_gridshot_easy_score=<int>
best_gridshot_normal_score=<int>
best_gridshot_hard_score=<int>
```

旧`training_records/default_best_score`があり、`best_normal_score`が無い場合は旧値をNormal Bestとして読み込む。旧Keyは削除しない。

Stage Library導入時はStage ID + Difficulty単位のRecordへ拡張する。

### Difficulty

- Start画面のOptionButtonで3段階から選択
- 変更はREADY Stateでのみ受け付ける
- 選択時にTarget Mesh / Collision / spawn rangeを同じProfileから更新する
- Difficulty変更はSensitivity / Crosshair / Session duration / Score ruleへ影響させない
- ResultへDifficulty名を表示する
- Start画面のBESTは選択DifficultyのRecordだけを表示する

### Future Home / Stage Library

将来は単一Start画面から、Home / Scenario Library中心の構造へ移行する。

```text
Home
→ Stage Library
→ Training
→ Result
→ Retry / Next
```

Stage定義はData-driven化し、Mode追加でMain Sceneへ巨大な分岐を追加しない。

## Performance

- AimはMouse Event driven
- `screen_relative` を使用
- `Input.use_accumulated_input = false`
- Aim角度へframe deltaを掛けない
- Training中Network Requestなし
- Training中大量Logなし
- Phase 1では重いAssetを読み込まない
- 外部3D Assetなし

## Testing

Automated:

- Godot project import
- Main Scene cold start
- Mouse delta math
- Pitch clamp
- Accuracy calculation
- Scene contract
- Start UI default state
- Timer countdown
- Pause中Timer停止
- Pause → メインメニュー遷移
- 途中Session破棄時にPersonal Bestを更新しない
- Timer 0 → Result transition
- Result statistics
- Personal Best persistence
- Difficulty selector contract
- Difficulty target radius / spawn range
- Difficulty別Best分離
- Legacy default_best_score → Normal Best compatibility
- Training Mode selector contract
- Single 1 Target / Gridshot 3 Target activation
- Gridshot Target respawn isolation
- Mode別Personal Best分離

Actual Playtest:

- Start flowの理解
- Mouse capture
- fast mouse movement
- repeated Hit / Miss
- ESC pause / resume
- R restart
- 60Hz / 120Hz / 144Hz以上のAim体感

Static / Headless TestだけでAim体感をComplete扱いにしない。

## Game Dev Hub

Current Repositoryに`project.godot`が存在するためGodot Projectとして扱う。

旧Web登録Recordは自動変換を前提にしない。User側では一度登録解除し、Godotとして再登録する。

## Foundation

Phase 1では操作導線を最小化するためGodot Game FoundationのApplication Shellを導入しない。

Save / Settings / Runtime Test Bridge / Diagnostics等が必要になったPhaseで、必要なFoundation capabilityだけを再評価する。
