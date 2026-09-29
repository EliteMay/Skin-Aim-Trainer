# PROJECT_LEARNINGS

## PL-001 — Sensitivity互換をPrototype係数と混同しない

- Date: 2026-09-29
- Status: Adopted
- Context: 初期PrototypeではMouse AimのLoopだけを先に確認する。
- Decision: 固定Mouse係数はPrototype専用と明記し、VALORANT Sensitivity互換値として公開しない。
- Prevention: Sensitivity設定を追加する時は、現在の係数をそのままUser-facing Sensitivityへ昇格させない。

## PL-002 — Aim DomainとCosmeticを分離する

- Date: 2026-09-29
- Status: Adopted
- Context: 将来Weapon / Skinを追加してもAim性能は変えてはいけない。
- Decision: Mouse Aim / Hit Detection / ScoreとSkin / Weapon presentationを分離する。
- Prevention: Skin追加時にSensitivity、Hitbox、Target、Score ruleを変更しない。

## PL-003 — Engine選定はUserの実際の開発体験を優先する

- Date: 2026-09-29
- Status: Adopted
- Context: Web prototypeは技術的には起動できたが、UserはBrowserではなく通常のGameとしてGodotで開発する方を明確に希望した。
- Decision: Skin Aim TrainerをGodot 4.7.2へ切り替え、Web / Electron architectureを廃止する。
- Prevention: 初期技術選定を固定化せず、Userが実際に操作・検証しやすいRuntimeを優先する。

## PL-004 — 「機能がある」より「最初の操作が分かる」を先にする

- Date: 2026-09-29
- Status: Adopted
- Context: 旧PrototypeはAim機能があっても、Userから「何が何だかわからないくらい操作しにくい」とFeedbackがあった。
- Decision: First ViewにPrimary Actionを1つだけ置き、操作を3Stepで明示する。Training中はCrosshair / Target / Scoreへ情報量を絞る。
- Prevention: MVP前にMode / Settings / Skin Library等をFirst Flowへ詰め込まない。

## PL-005 — Foundation Shellを機械的に入れない

- Date: 2026-09-29
- Status: Adopted
- Context: 共通Foundationは有用だが、Phase 1の最優先課題はAim coreと操作の明瞭さ。
- Decision: Phase 1ではApplication Shellを入れず、必要なSave / Settings / Diagnostics / Runtime Test capabilityを後から選択導入する。
- Prevention: 共通基盤が存在すること自体を理由に、User flowを複雑化しない。


## PL-006 — Godot FPS Aimではscreen_relativeを使う

- Date: 2026-09-29
- Status: Adopted
- Context: Godotの`relative`はcontent scaleの影響を受け、Resolution / Stretch条件でMouse Sensitivityが変わり得る。
- Decision: Captured Mouse Aimは`InputEventMouseMotion.screen_relative`を使用する。
- Prevention: Aim処理へ`relative`を戻す変更ではResolution-independent sensitivityをRegression Test / Actual Playtestする。

## PL-007 — VALORANT yaw 0.07を公式仕様として表現しない

- Date: 2026-09-29
- Status: Adopted
- Context: 複数のSensitivity referenceでは0.07°/countが一致したが、今回Riot公式公開仕様としては確認できなかった。
- Decision: 0.07をCommunity measurementに基づくVALORANT-style conversion constantとして使用する。
- Prevention: UI / README / MarketingでRiot公式保証値や完全一致と断定しない。Calibration Evidenceが得られた場合はResearch Documentを更新する。

## PL-008 — DPI値とSoftware Sensitivityの責務を分ける

- Date: 2026-09-29
- Status: Adopted
- Context: DPIはMouse Hardware / Driver側の設定で、Game側Sensitivityとは別の入力要因。
- Decision: ApplicationはDPIを変更せず、eDPI / cm360計算用のUser inputとして保存する。
- Prevention: DPI inputをHardware DPI変更機能のように表示しない。
