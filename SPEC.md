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
   └─ SettingsOverlay
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
- 感度を設定
- 最初からやり直す

### Sensitivity Settings

- Mouse DPI
- VALORANT Sensitivity
- eDPI
- cm/360
- Rotation coefficient
- Save / Cancel

Start画面では「練習を開始」をPrimary Actionとして維持し、感度設定はSecondary Actionにする。

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
