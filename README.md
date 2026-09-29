# Skin Aim Trainer

OKIAIMXの「すぐ撃てる・FPS視点・Skinを使う楽しさ」と、Aim Trainerの本格的な練習設計を参考にしつつ、コード・Asset・UIをコピーせず独自実装するWindows向けAim Trainerです。

## 現在の状態

**Phase 1 — Core Aim Prototype**

実装済み:

- Pointer Lock
- Mouse movement based aiming
- Crosshair固定 / Camera角度更新
- Target表示
- 左クリック射撃
- Hit Detection
- Score
- ESC Pause / Pointer Lock復帰
- Restart
- Node標準機能だけで起動するLocal dev server
- Aim math / Hit detectionの自動Test

未実装（意図的）:

- VALORANT Sensitivity換算
- DPI / eDPI
- Gridshot等のTraining Mode
- Weapon / Skin / Audio / Animation
- Electron
- VALORANT Asset

Phase 1では「Mouse Aim → Targetを狙う → 撃つ → Hit判定 → Score」の安定性を先に確認します。

## 起動

Node.js 20以上で:

```bash
npm run dev
```

表示された `http://127.0.0.1:4173` をChrome / Edgeで開きます。

操作:

- 画面クリック: Pointer Lock / Aim開始
- マウス移動: Aim
- 左クリック: Shoot
- ESC: Pause
- Pause画面の「最初からやり直す」: Restart
- F2: 開発中の即時Restart

## Test

```bash
npm run validate
```

自動TestはMath / Projection / Mouse delta処理 / Hit Detectionを確認します。Pointer Lockの体感・入力遅延・高Refresh Rateでの操作感は自動Testだけでは完了扱いにしません。

## Architecture

```text
Web Core
├─ AimEngine
├─ InputController
├─ TargetSystem
├─ Renderer
└─ Game Flow

Later
├─ Training Modes
├─ Weapon System
├─ Skin System
├─ Results / Storage
└─ Electron Shell
```

Aim CoreへElectron固有処理を直接混ぜません。

## Game Dev Hub

`docs/ROADMAP.md` はGame Dev Hubのやることリストで読める形式です。

Game Dev Hub **v0.1.28以降**はWeb / Electron Project対応済みです。Project種類に **Web / Electron** を選び、このRepositoryを登録できます。

`game-dev-hub.json` はHubが開発Server起動後に開くloopback URLだけを保持します。任意Commandは持たせません。

## Asset Policy

Phase 1は外部Assetを使用しません。VALORANTの実Skin画像・3D Model・Texture・Animation・Sound等を、権利状態が不明なままRepositoryへ追加しません。
