# PROJECT_LEARNINGS

## PL-001 — Sensitivity互換をPrototype係数と混同しない

- Date: 2026-09-29
- Status: Adopted
- Context: Phase 1ではMouse AimのLoopだけを最小実装する。
- Decision: 固定Mouse係数はPrototype専用と明記し、VALORANT Sensitivity互換値として公開しない。Phase 2で方式をResearch / Verificationする。
- Prevention: Sensitivity設定を追加する時は、現在のPrototype係数をそのままUser-facing Sensitivityへ昇格させない。

## PL-002 — Aim logicをRenderer / Electronから分離する

- Date: 2026-09-29
- Status: Adopted
- Context: 最終的にはWeapon / Skin / Electronへ拡張するが、Core Aimの入力品質を先に確認する必要がある。
- Decision: AimEngine / TargetSystem / InputController / Rendererを分離する。
- Prevention: Skin / Electron追加時にHit DetectionやSensitivity計算へCosmetic / shell責務を混ぜない。
