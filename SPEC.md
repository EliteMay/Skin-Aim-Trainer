# SPEC — Phase 1 Core Aim Prototype

## Runtime

- Browser: Chromium系Desktopを代表Runtimeとする
- Rendering: Canvas 2D
- Input: Pointer Lock + MouseEvent movementX / movementY
- Build dependency: none
- Dev server: Node.js built-in HTTP server

Phase 1で外部3D Engineを導入しない理由は、Mouse Aim / Hit Detection / Pointer LockのCore Contractを最小構成で検証するため。Weapon Rendering / Skin 3D要件が確定したPhase 4以降でRenderer技術を再評価できるよう、Aim / Target logicをRendererから分離する。

## Aim Engine

State:

- yaw
- pitch

Mouse inputは`movementX / movementY`を直接角度へ変換する。描画frame deltaを掛けない。

Phase 1の固定係数はPrototype tuning値であり、VALORANT Sensitivity互換を意味しない。

## Target System

Targetはworld angular coordinateとして保持する。

- target yaw
- target pitch
- angular radius

RendererはCameraとの差分角をscreen coordinateへprojectionする。

Hit Detectionは射撃時点に再計算し、Crosshair centerがTarget projected circle内にある場合だけHitとする。

## Renderer Boundary

Rendererはstateを描画するだけでScoreやHit ruleを所有しない。

## Pause / Pointer Lock

- Canvas click / Resume button → requestPointerLock
- Pointer Lock acquired → Pause UIを隠す
- ESC等でPointer Lock解除 → Pause UI表示
- Pointer Lockなしの最初のClickはShootとして数えない

## Restart

- Score = 0
- Camera yaw/pitch = 0
- Target respawn

## Performance Contract

- Aim角度更新はMouse event driven
- RenderはrequestAnimationFrame
- Training中Network Requestなし
- Training中大量Logなし
- DevicePixelRatioは描画負荷を抑えるため最大2へ制限

## Phase 1 Verification

Automated:

- angle normalization
- target projection center
- mouse delta mapping
- target hit / miss
- required file validation

Manual Actual Playtest:

- Pointer Lock / cursor confinement
- fast mouse movement tracking
- repeated Hit / Miss
- ESC pause → resume
- resize / 60Hz / 120Hz+環境で体感変化がないか

Actual Playtestが未実施ならPhase 1 Completeにはしない。
