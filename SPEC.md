# SPEC — Godot Phase 1 Core Aim Prototype

## Runtime

- Engine: Godot 4.7.2 stable
- Language: GDScript
- Rendering: Godot 3D / Compatibility renderer
- Input: `InputEventMouseMotion.relative` + `Input.MOUSE_MODE_CAPTURED`
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
   └─ PauseOverlay
```

## Run State

3状態だけを持つ。

- `READY` — 開始画面。Cursor visible。
- `PLAYING` — Mouse captured。Aim / Shoot受付。
- `PAUSED` — Pause画面。Cursor visible。

遷移:

```text
READY --開始--> PLAYING
PLAYING --ESC--> PAUSED
PAUSED --ESC / 練習に戻る--> PLAYING
PLAYING / PAUSED --R / やり直す--> PLAYING(reset)
```

## Aim

State:

- yaw degrees
- pitch degrees

Mouse motionのrelative値を固定係数で角度へ変換する。

`frame delta`はSensitivity計算へ掛けない。

Pitchは上下72度へClampする。

Phase 1係数は操作確認用でありVALORANT Sensitivity互換を意味しない。

## Target

- 1個だけ表示する
- Camera前方の固定距離Plane上へRandom spawn
- X / Y範囲を限定し、極端な画面端へ出さない
- Hit後だけ次位置へ移動する

Targetは`StaticBody3D + SphereShape3D`でPhysics collisionを持つ。

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
- 大きい「練習を開始」

未実装のMode / Skin / SettingsはMain flowへ出さない。

### Training

Training中のPrimary Visual:

- Target
- Crosshair

補助表示:

- Score / Hit / Miss / 命中率
- `ESC メニュー / R やり直し`

### Pause

- 練習に戻る
- 最初からやり直す

選択肢を増やさない。

## Performance

- AimはMouse Event driven
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
