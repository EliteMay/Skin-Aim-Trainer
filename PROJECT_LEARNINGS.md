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


## PL-009 — VALORANT Crosshair CodeはParser境界を分離する

- Date: 2026-09-29
- Status: Adopted
- Context: Crosshair Codeは短縮tokenと省略Defaultを持ち、UIコードへ直接Parse処理を混ぜると保守しにくい。
- Decision: `valorant_crosshair_code.gd`へParserを分離し、Rendererは正規化済みProfile Dictionaryだけを受け取る。
- Prevention: 新しいtoken対応をMain Scene / UI Event Handlerへ直接追加しない。

## PL-010 — Community reverse-engineered formatを公式仕様と呼ばない

- Date: 2026-09-29
- Status: Adopted
- Context: VALORANT Crosshair Codeのtoken mappingは公開ParserとCommunity analysisで一致するが、Riotの完全なFormat specificationは確認できていない。
- Decision: Import compatibilityとして実装するが、Riot公式完全互換と断定しない。
- Prevention: 未対応token / 新Formatが出た場合はParser Testを追加し、既知範囲を明示する。


## PL-011 — 新しいclass_nameをDirect Launchの必須型にしない

- Date: 2026-09-29
- Status: Adopted
- Context: 新規`class_name` scriptはGodotのglobal class cache更新前にWindows Direct Launchされると、別Scriptの型注釈から解決できない場合がある。
- Decision: Game Dev Hubから更新直後に直接起動されるMain Runtimeでは、新規custom classを必須型注釈として参照しない。必要ならexplicit preloadまたはbuilt-in base typeを使う。
- Prevention: Windows CIでは事前Editor importに依存しないDirect Launch Smokeを維持する。


## PL-012 — Session TimerはRun Stateに従わせる

- Date: 2026-09-30
- Status: Adopted
- Context: Aim TrainerのTimerがPauseや設定画面中にも減ると、Score比較と操作の公平性が崩れる。
- Decision: Countdownは`PLAYING`中だけ更新し、`PAUSED` / `RESULT` / Settings中は減らさない。
- Prevention: Timer更新をUI Timer Node任せにせず、Gameplay Run Stateと同じSource of TruthでGateする。

## PL-013 — Personal Bestは完了Sessionだけで更新する

- Date: 2026-09-30
- Status: Adopted
- Context: Restart途中やPause中のScoreをBestとして保存すると、Session比較の意味が崩れる。
- Decision: Personal BestはTimer 0でSession完了した時だけ、Current Scoreが既存Bestを超えた場合に更新する。
- Prevention: Shoot / Restart / Pause処理からBest保存を呼ばない。将来Stage化したらStage ID単位のRecord keyへ移行する。


## PL-014 — Difficultyが変わるScoreはRecordを分離する

- Date: 2026-09-30
- Status: Adopted
- Context: Target size / spawn rangeが異なるDifficultyで同じPersonal Bestを共有すると、Score比較の意味が崩れる。
- Decision: Personal BestをDifficulty keyごとに分離し、Result / Startでは選択中DifficultyのBestだけを表示する。
- Prevention: DifficultyやStage条件を追加するときは、同じScore Recordを共有して比較可能かを先に確認する。

## PL-015 — Save key分割では旧RecordをNormalへ非破壊移行する

- Date: 2026-09-30
- Status: Adopted
- Context: Difficulty追加前は`training_records/default_best_score`だけを保存していた。
- Decision: 新しい`best_normal_score`が無い場合だけ旧値をNormal Bestとして読む。旧Keyは削除しない。
- Prevention: Save構造を分割するときは旧Key fallbackとRegression Testを同じ変更に含める。


## PL-016 — 繰り返しPlaytestには途中離脱の短い導線を用意する

- Date: 2026-09-30
- Status: Adopted
- Context: Difficultyの比較確認で、60秒Sessionを最後まで待つかRestartするだけではStartへ戻れず、実機テストの反復Costが高かった。
- Decision: Pauseから確認DialogなしでMain Menuへ戻れる導線を用意し、途中SessionはRecord更新対象にしない。
- Prevention: Stage / Difficulty / Skin等を比較する機能を追加するときは、Gameplay中から安全に選択画面へ戻れるRecovery Pathも同時に確認する。


## PL-017 — Mode追加で既存Record Keyを不用意にRenameしない

- Date: 2026-09-30
- Status: Adopted
- Context: Gridshot追加前はSingle Trainingだけだったため、既存のDifficulty別BEST KeyにMode名が含まれていなかった。
- Decision: 既存KeyはSingleのRecordとして維持し、Gridshotだけ新しい`best_gridshot_*_score`を追加する。
- Prevention: Stage / Mode追加時に既存Save Keyを整理目的だけでRenameせず、互換性を先に固定する。

## PL-018 — Multi-target ModeでもHitしたTargetだけを局所更新する

- Date: 2026-09-30
- Status: Adopted
- Context: Gridshotでは3 Targetを同時表示するため、Hitごとに全Targetを再配置するとTarget switchingの連続性が崩れる。
- Decision: RaycastでHitしたColliderのIndexを特定し、そのTargetだけRespawnする。
- Prevention: Multi-target Trainingでは全体Resetと1 Target更新を分離し、通常Hitで無関係Targetを動かさない。


## PL-019 — Stage選択とStage設定を同じSurfaceへ重複させない

- Date: 2026-09-30
- Status: Adopted
- Context: Homeを追加した後もStage SetupにSingle / Gridshot Selectorを残すと、同じNavigation判断が2か所に存在してFlowが分かりにくくなる。
- Decision: StageはHomeで選び、Stage Setupは選択済みStageのDifficulty / Sensitivity / Crosshair / Startだけを扱う。
- Prevention: Home / Libraryを導入した後は、Local SetupへTop-level Stage Navigationを重複配置しない。

## PL-020 — 小さいLibraryへSearchを先回りで追加しない

- Date: 2026-09-30
- Status: Adopted
- Context: Aimlabs / KovaaK'sの大規模LibraryではSearch / Filterが重要だが、Current Skin Aim TrainerはPlayable Stageが2件だけ。
- Decision: Current Homeは一覧選択だけにし、Stage metadataへcategory / tagsを保持してStage数が増えた時にBrowse / Searchへ拡張する。
- Prevention: Reference Productの規模依存UIを機械的にコピーせず、Current content volumeとTask frequencyを確認する。

## PL-021 — Stage metadataをScene固定Nodeから分離する

- Date: 2026-09-30
- Status: Adopted
- Context: Stage追加ごとにHome SceneへButton / Title / Categoryを直書きすると、Scenario Library化でSceneとMain Scriptが肥大化する。
- Decision: Stage metadataを`data/stages.json`へ分離し、Home ButtonはCatalogから動的生成する。
- Prevention: 新Stageの表示情報をSceneへ固定追加せず、CatalogとGameplay implementationを別責務として扱う。
