# ROADMAP

## Phase 0 — Web → Godot Rewrite

- [x] Product RuntimeをGodotへ変更する
  - 担当: ChatGPT
  - Browser / Electron前提をCurrent仕様から外す
  - Godot 4.7.2 + GDScript + WindowsをCurrent Runtimeにする

- [x] 旧Web prototypeをGodot 3D prototypeへ置き換える
  - 担当: ChatGPT
  - project.godot / Main Scene / GDScript / Godot CIを追加
  - package.json / Browser server / Web rendererをCurrent runtimeから削除

- [x] 操作導線を作り直す
  - 担当: ChatGPT
  - 起動直後に「練習を開始」
  - 操作を3Stepで表示
  - Training中はCrosshair / Target / Score中心
  - ESC Pause / R Restartを常時Hint

## Phase 1 — Core Aim Prototype

- [x] Mouse Aimを実装する
  - 担当: ChatGPT
  - Godot Mouse Capture
  - Mouse deltaを角度へ変換
  - Frame deltaをSensitivityへ掛けない

- [x] Target / Shoot / Hit Detectionを実装する
  - 担当: ChatGPT
  - 赤いTargetを1個表示
  - Camera中央RaycastでHit判定
  - Hit後は次位置へ移動

- [x] Score / Hit / Miss / Accuracyを実装する
  - 担当: ChatGPT

- [x] Pause / Resume / Restartを実装する
  - 担当: ChatGPT

- [x] Godot Headless Smoke Testを追加する
  - 担当: ChatGPT
  - Import / Cold Start / Core SmokeをCIで確認

- [x] Godot版をGame Dev Hubから起動する
  - 担当: あなた
  - Game Dev Hubの旧Skin Aim Trainer登録を解除する
  - Fileは削除しない
  - RepositoryをGodot Projectとして再登録する
  - 「開発を開始」→「ゲームを起動」

- [x] 操作が迷わないか確認する
  - 担当: あなた
  - 起動直後に何を押すか分かる
  - 「練習を開始」を押せる
  - マウスで赤いTargetを狙える
  - 左クリックで撃てる

- [x] Aim / Shootを実機確認する
  - 担当: あなた
  - Targetを5回Hitする
  - 空振りを数回行う
  - SCORE / HIT / MISS / 命中率が正しく変わる
  - Aimが引っ掛からない

- [x] Pause / Restartを実機確認する
  - 担当: あなた
  - ESCで一時停止
  - ESCまたは「練習に戻る」で再開
  - Rまたは「最初からやり直す」でScoreが0へ戻る

完了条件: 起動 → 開始 → Aim → Shoot → Hit/Miss → Score → Pause/Resume/RestartをWindows Actual Playtestし、操作方法が分からないBlockingがない。

### Phase 1 実機確認結果 — 2026-09-29

- Game Dev HubからGodot版を起動: PASS
- 起動直後の操作導線: PASS
- Mouse Aim / Shoot / Hit / Miss / Score / 命中率: PASS
- ESC Pause / Resume / Restart: PASS
- Blockingな操作問題: なし

Phase 1はWindows実機確認まで完了。次のCurrent TaskはPhase 2のSensitivity / DPI / eDPI Researchと設定。

## Phase 2 — Training Foundation

- [x] Sensitivity / DPI / eDPIのResearchと設定
  - 担当: ChatGPT
  - Godot Mouse Aimをscreen_relativeへ変更
  - Mouse input accumulationを無効化
  - VALORANT-style yaw 0.07 modelをResearchして実装
  - DPI / Sensitivity / eDPI / cm360を設定画面へ追加
  - user://settings.cfgへ保存
  - 計算とUI ContractをGodot Smoke Testへ追加

- [x] Sensitivity / DPI / eDPIを実機確認する
  - 担当: あなた
  - Start画面の「感度を設定」を開く
  - 実際のMouse DPIとVALORANT Sensitivityを入力して保存する
  - eDPI / cm360が表示される
  - 感度を上げるとAimが速く、下げると遅くなる
  - Gameを閉じて再起動しても値が残る
  - 2026-09-29 Game Dev Hub共有Packで5/5 PASS

- [x] Crosshair設定
  - 担当: ChatGPT
  - Godot描画のCrosshair rendererへ置換
  - 色 / 長さ / 太さ / Gap / Outline / Center Dotを手動調整
  - VALORANT Crosshair Profile CodeのPrimary (P) SectionをImport
  - Inner / Outer Lines、横/縦長さ、Opacity、Outline、Center Dotを反映
  - ConfigFileへ保存
  - Parser / UI ContractをGodot Smoke Testへ追加

- [x] Crosshair設定を実機確認する
  - 担当: あなた
  - Start画面の「クロスヘアを設定」を開く
  - VALORANTのCrosshair Codeを貼り付けて「コードを読み込む」
  - Previewが変わる
  - 「保存して戻る」後のTraining Crosshairへ反映される
  - Gameを閉じて再起動してもCrosshairが残る
  - 手動の色 / 長さ / 太さ / Gap / Outline / Center Dotも変更できる
  - 2026-09-30 Game Dev Hub共有Packで6/6 PASS

- [x] Timer / Result / Personal Best
  - 担当: ChatGPT
  - Default Sessionを60秒にする
  - Training中だけCountdownする
  - Pause中はCountdownを止める
  - 0秒で自動的にResultへ遷移する
  - ResultにScore / Hit / Miss / Accuracy / Bestを表示する
  - Best Scoreをuser://settings.cfgへ保存する
  - Retry / 開始画面へ戻るを追加する
  - Godot Smoke TestでCountdown / Pause / Result / Best保存を確認する

- [x] Timer / Result / Personal Bestを実機確認する
  - 担当: あなた
  - 「60秒の練習を開始」でTimerが01:00から減る
  - ESCでPause中はTimerが止まる
  - 0秒でResult画面へ移動する
  - Score / Hit / Miss / 命中率がResultへ表示される
  - Best Scoreが更新される
  - Gameを閉じて再起動してもBESTが残る
  - 「もう一度」で新しい60秒Sessionを開始できる
  - 「開始画面へ戻る」でStartへ戻れる
  - 2026-09-30 Game Dev Hub共有Packで8/8 PASS

- [x] Difficulty
  - 担当: ChatGPT
  - Start画面へ「かんたん / 標準 / むずかしい」の3段階を追加
  - DifficultyでTarget sizeとspawn rangeだけを変更
  - Sensitivity / Crosshair / Score rule / 60秒Sessionは変更しない
  - 選択したDifficultyをuser://settings.cfgへ保存
  - Personal BestをDifficulty別に保存
  - 旧default_best_scoreはNormalのBestとして読み込み互換を維持
  - Difficulty / migration / Best分離をGodot Smoke Testへ追加

- [x] Difficultyを実機確認する
  - 担当: あなた
  - Start画面で3段階の難易度を選べる
  - 「かんたん」はTargetが大きく、出現範囲が狭い
  - 「標準」はこれまでと同じTarget size / 出現範囲
  - 「むずかしい」はTargetが小さく、出現範囲が広い
  - 練習途中でESC →「メインメニューへ戻る」でStartへすぐ戻れる
  - 途中Sessionを破棄してもBESTは更新されない
  - 難易度を変えてもSensitivity / Crosshair / 60秒 / Score ruleは変わらない
  - BESTが難易度ごとに別々に保存される
  - Gameを閉じて再起動しても選択DifficultyとBESTが残る
  - 2026-09-30 Game Dev Hub共有Packで9/9 PASS

- [x] Gridshot
  - 担当: ChatGPT
  - Start画面へ「シングル / Gridshot」の練習モード選択を追加
  - Gridshotは静止Targetを3個同時表示
  - HitしたTargetだけを別位置へRespawn
  - MissはScoreを増やさずAccuracyへ反映
  - Difficulty / Sensitivity / Crosshair / 60秒Sessionは既存Contractを再利用
  - 選択Modeをuser://settings.cfgへ保存
  - GridshotのPersonal BestをDifficulty別に保存
  - 既存シングルBESTの保存Keyは維持
  - Mode / Target数 / Record分離をGodot Smoke Testへ追加

- [x] Gridshotを実機確認する
  - 担当: あなた
  - Start画面で「Gridshot」を選べる
  - 開始すると赤いTargetが3個同時に表示される
  - 1個Hitすると、そのTargetだけ別位置へ移動する
  - MissではScoreが増えず、命中率へ反映される
  - Difficultyを変えるとGridshot Targetの大きさ / 出現範囲も変わる
  - 60秒後にResultへ移動し、GridshotのBESTが保存される
  - シングルへ戻してもシングルのBESTがGridshotと混ざらない
  - Gameを閉じて再起動しても選択ModeとGridshot BESTが残る
  - 2026-09-30 Game Dev Hub共有Packで8/8 PASS

## Phase 3 — Training Modes / Scenario Library

- [x] Home / Stage Library基盤
  - 担当: ChatGPT
  - 起動直後をHomeに変更
  - Homeから実装済みStageを選んでStage Setupへ進む
  - Stage定義をdata/stages.jsonへ分離
  - category / description / duration / mode / tagsをData-driven化
  - シングル / GridshotをCatalogから動的にHomeへ表示
  - Stage SetupではDifficulty / Sensitivity / Crosshairだけを設定
  - ESC Pauseの「メインメニューへ戻る」とResultの「Homeへ戻る」はHomeへ戻す
  - 既存Single / Gridshot gameplayとSave Keyは維持
  - Home / Stage Catalog / Stage FlowをGodot Smoke Testへ追加

- [ ] Home / Stage Libraryを実機確認する
  - 担当: あなた
  - 起動すると最初にHomeが表示される
  - Homeに「シングルターゲット」と「Gridshot」が表示される
  - シングルターゲットを押すと専用のStage Setupへ進める
  - Gridshotを押すと専用のStage Setupへ進める
  - Stage SetupからDifficulty / 感度 / Crosshairを設定して開始できる
  - Training途中でESC →「メインメニューへ戻る」でHomeへ戻れる
  - Resultの「Homeへ戻る」でHomeへ戻れる
  - Gameを再起動しても前回Stage / Difficulty表示と既存BESTが壊れない

- [ ] Hold Angle / Pre-Aim
- [ ] Microshot
- [ ] Flick
- [ ] Skin Test Range

## Phase 4 — Weapon

- [ ] Primary Rifle 1種類
- [ ] Ammo
- [ ] Reload
- [ ] Equip
- [ ] Inspect
- [ ] Fire feedback

## Phase 5 — Skin System

- [ ] Data-driven Skin model
- [ ] Skin Library
- [ ] Variant
- [ ] Asset loading / Cache
- [ ] Skin選択保存

## Phase 6 — Audio / Animation

- [ ] Fire / Reload / Hit sound
- [ ] Weapon / Inspect animation

## Phase 7 — Windows Distribution

- [ ] Windows Export
- [ ] Installer
- [ ] App Icon
- [ ] Release
- [ ] Update strategy
- [ ] Logs / Diagnostics

## Phase 8 — Quality

- [ ] High Refresh / Input latency
- [ ] Long-session stability
- [ ] Actual Playtest regression
- [ ] Windows build / installer regression
