# Sensitivity Research

Updated: 2026-09-29

## Goal

Skin Aim TrainerのGodot Mouse Aimへ、VALORANTの通常Hipfire Sensitivityに対応する設定モデルを導入する。

このDocumentはResearch根拠と、実装で「確認済み」「推定 / Community measurement」「未確認」を分ける。

## Confirmed Godot Input Behavior

Godot 4.7 Documentationでは、`Input.MOUSE_MODE_CAPTURED` のMouse Aimに `InputEventMouseMotion.screen_relative` を使うことが推奨されている。

理由:

- `relative` はProjectのcontent scaleに応じてScaleされる
- Resolution / Stretch条件で見かけのSensitivityが変わる可能性がある
- `screen_relative` はscreen coordinate上のunscaled delta
- より細かいMouse Motionが必要な場合は `Input.use_accumulated_input = false` を使用できる

Sources:

- https://docs.godotengine.org/en/4.7/tutorials/inputs/mouse_and_input_coordinates.html
- https://docs.godotengine.org/en/4.7/classes/class_inputeventmousemotion.html

## VALORANT Yaw Model

複数の独立したSensitivity reference / calculatorが、VALORANTのYawを次で一致して扱っている。

`0.07 degrees / mouse count at sensitivity 1.0`

Sources checked:

- https://geargeeksgaming.com/data/game-sensitivity-constants/
- https://www.allcalcihub.com/calculator/valorant-cm360/
- https://sensconverter.org/game/valorant/

### Evidence classification

この `0.07` は今回確認できたRiot公式公開仕様ではない。

したがってRepositoryでは:

- 「VALORANT公式仕様」とは書かない
- Community measurement / widely used conversion constantとして扱う
- Actual Playtest / future calibrationで矛盾が見つかった場合は更新する

## Formulas

### Degrees per input count

```text
degrees_per_count = 0.07 × valorant_sensitivity
```

### eDPI

```text
eDPI = mouse_DPI × valorant_sensitivity
```

eDPIは比較用の数値であり、ApplicationがHardware DPIを変更するものではない。

### cm / 360

```text
cm_per_360 = 360 / (0.07 × valorant_sensitivity × DPI) × 2.54
```

Example:

```text
DPI = 1600
Sensitivity = 0.100
eDPI = 160
cm/360 ≈ 81.64 cm
```

## Implementation Decision

Phase 2では:

- Mouse Aim inputを `screen_relative` へ変更
- `Input.use_accumulated_input = false` をTraining Runtime中に使用
- SensitivityだけをCamera rotation multiplierへ使用
- DPIはeDPI / cm360計算用として保存
- Settingsは `user://settings.cfg` へ保存
- First FlowのPrimary Action「練習を開始」は維持
- SettingsはSecondary ActionとしてStart / Pauseから開く

## Remaining Verification

Automated:

- 0.1 sensitivity → 0.007 degrees/count
- 1600 DPI × 0.1 → 160 eDPI
- 1600 DPI / 0.1 → 約81.64 cm/360
- Scene settings controls存在

Windows Actual Playtest:

- Settingsを開ける
- DPI / Sensitivityを変更・保存できる
- Restart後も保存値が残る
- Sensitivityを上げるとAim rotationが増える
- Different resolution / window sizeで明らかなSensitivity scale変化がない

「VALORANTと物理的に完全一致」の最終保証には、将来360° calibrationまたはRaw input measurementを追加検討する。
