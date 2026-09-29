# REQUIREMENTS â€” Skin Aim Trainer

Updated: 2026-09-29
Status: Phase 1 implementation-ready / actual playtest pending

## Product Core

å¥½ããªæ­¦å™¨Skinã‚’ä½¿ç”¨ã—ãŸçŠ¶æ…‹ã§ã€Aim Labã®ã‚ˆã†ãªæœ¬æ ¼çš„ãªAim Trainingã‚’è¡Œãˆã‚‹Windowså‘ã‘Aim Trainerã‚’ä½œã‚‹ã€‚

ä¸­å¿ƒä½“é¨“:

`Skinã‚’é¸ã¶ â†’ æ­¦å™¨ã‚’æŒã¤ â†’ æ’ƒã¤ â†’ Aim Training â†’ Result`

## Priority

1. Mouseæ“ä½œã®æ­£ç¢ºã•
2. Input latencyã®å°‘ãªã•
3. Aim Trainingå“è³ª
4. åˆ†ã‹ã‚Šã‚„ã™ã•
5. å®‰å®šæ€§
6. Skinä½“é¨“
7. è¦‹ãŸç›®

## Platform / Architecture

- Primary: Windows PC
- Final distribution: Electron Windows Application
- Aim Trainer Coreã¯WebæŠ€è¡“å´ã¸åˆ†é›¢ã™ã‚‹
- Electronå›ºæœ‰å‡¦ç†ã‚’Aim Engineã¸ç›´æ¥æ··ãœãªã„
- å°†æ¥Webç‰ˆã¸å±•é–‹å¯èƒ½ãªæ§‹é€ ã‚’ç¶­æŒã™ã‚‹

## Phase 1 Scope

å®Ÿè£…å¯¾è±¡:

- Training View
- Pointer Lock
- Mouse Aim
- Target
- Left Click Shoot
- Hit Detection
- Score
- Restart
- ESC Pause / safe resume

Phase 1ã§ã¯Weapon Skinã‚’å®Ÿè£…ã—ãªã„ã€‚

### Phase 1 Completion

- Mouse movementã§AimãŒå®‰å®šã—ã¦å‹•ã
- CursorãŒAimä¸­ã«ç”»é¢å¤–ã¸å‡ºãªã„
- FPSã®æç”»deltaã‚’Sensitivityè¨ˆç®—ã«æ›ã‘ãªã„
- Targetã¸Crosshairã‚’åˆã‚ã›ã¦æ’ƒã¤ã¨ScoreãŒå¢—ãˆã‚‹
- Targetå¤–ã‚’æ’ƒã£ã¦ã‚‚Scoreã¯å¢—ãˆãªã„
- ESC Pauseå¾Œã€å®‰å…¨ã«Pointer Lockã¸å¾©å¸°ã§ãã‚‹
- Restartã§Score / Aim / Target stateãŒåˆæœŸåŒ–ã•ã‚Œã‚‹
- Static TestãŒé€šã‚‹
- Actual Playtestã§Core Loopã‚’ç¢ºèªã™ã‚‹

## Phase 2+ Summary

Phase 2: Timer / Accuracy / Miss / Result / Personal Best / Difficulty / Settings / Sensitivity / Crosshair / Gridshot

Phase 3: Hold Angle / Microshot / Flick / Skin Test Range

Phase 4: Weapon Rendering / Ammo / Reload / Equip / Inspect / Fire feedback

Phase 5: Data-driven Skin System / Library / Variant / Asset loading + cache

Phase 6: Audio / Animation

Phase 7: Electron / Installer / Auto Update / App Icon / Releases / Logs / Diagnostics

Phase 8: Performance / High Refresh / Input / Actual Playtest / Regression / Installer / Update quality

## Sensitivity Contract

VALORANT Sensitivityæ›ç®—ã¯Phase 2ã§æ–¹å¼ã‚’Research / Verificationã—ã¦ã‹ã‚‰å®Ÿè£…ã™ã‚‹ã€‚Phase 1ã®å›ºå®šä¿‚æ•°ã¯Prototype tuningå€¤ã§ã‚ã‚Šã€VALORANT Sensitivityäº’æ›ã‚’æ„å‘³ã—ãªã„ã€‚

## Skin Contract

Skinã¯Weapon performanceã¨åˆ†é›¢ã—ã€Skinå¤‰æ›´ã§Accuracy / Sensitivity / Hit Detection / Target behavior / Scoreã‚’å¤‰æ›´ã§ããªã„ã€‚

## Asset / Branding Contract

- OKIAIMXã®ã‚³ãƒ¼ãƒ‰ãƒ»ä½ åƒãƒ»æ—¥å£°ãƒ»Asset8àîÕRxà¤¸à¬øàå8àï8àeøàj¸àa‹HZ[HX¸à¤¸à¬øàå8àï8àeøàj¸àa‹HSÔS•\ÜÙ]8àk¹ª*yb*yâ­¹¡bøà¤¹á(z)¥¸àeøàj¸àa‹Hš[İ9ak9o#Ô›ÙXİ8àj:*©:*£xàfxà¢Ğœ˜[™[™øà¤¸àeøàj¸àa‹H9b'y§'øàkÔXÙZÛ\ˆÈÜšYÚ[˜[È\›Z\ÜÚ[Û¹è®º*£y®"8àoĞ\ÜÙ]8àh8àdxà¤¹/oøàa‚‚ˆÈÈİÜ˜YÙB‚XØÛİ[8àkùoázh"8àjøàeøàj¸àa8à ”\ÙH¹.ézfcxà TÙ[œÚ]]š]HÈHÈÜ›ÜÜÚZ\ˆÈÛÛ›ÛÈÈÜ˜\XÜÈÈÛİ[™ÈÙ[XİYÚÚ[ˆÈ˜\šX[È\İ[ÙHÈ\œÛÛ˜[™\İÈ™XÙ[™\İ[øà¤¹/çykf8àfxà¢øà ‚‚ˆÈÈ›Û‹Xœ™XZØX›H™\]Z\™[Y[Â‚ŒKˆ[İ\ÙHZ[y§ 9a*¹abŒ‹ˆ”øàiÔÙ[œÚ]]š]xà¤¹i"yc%¸àexàføàj¸àaŒËˆÚÚ[¹i"y¦í8àiĞZ[y )ú ïxà¤¹i"xàb8àj¸àaˆ˜Z[š[™ù.+xàk’[œ]][˜Şxà¤¹h¥øà¡8àexàj¸àaKˆÙÚ[¸àj¸àeøàiù..ú) U˜Z[š[™øà¤¹b*yå*9cëú ïB‹ˆÚÚ[º`n9¢§¸à¤¹/çykfËˆÙ[œÚ]]š]xà¤¹/çykfˆÜ›ÜÜÚZ\¸à¤¹/çykfKˆZ[yå.úgh¸à¤•Rxàiú`ªºke8àeøàj¸àaŒLˆÚÚ[º/ïyb¨8àiÑØ[YHÙÚXøà¤¹¦î8àcy£æøàb8àj¸àaŒLKˆSÔS•\ÜÙ]8àk¹ª*yb*yâ­¹¡bøà¤¹á(z)¥¸àeøàj¸àaŒL‹ˆÒÒPRSV8à¤¸à¬øàå8àï8àeøàj¸àaŒLËˆZ[HX¸à¤¸à¬øàå8àï8àeøàj¸àaŒMˆU”9bcxàjù.#z) yªgú ïxà¤¹h¥øà¡8àexàj¸àaŒMKˆØ[YH]ˆX¸àiĞXİX[^]\İ9cëú ïxàj¹â­¹¡bøà¤¹§ 9í`¹æ¡8àjùí«y£ xàfxà¢Â‚ˆÈÈİ\œ™[›ØÚÚ[™È[YÜ˜][Ûˆ\ÜİYB‚ŒŒ‹LKLxàk‘Ø[YH]ˆXˆŒŒKŒøàkÔ›Ú™Xİ[Ù[8àiØ[™Ú[™HOOH™ÛÙİ˜8à¤¹¢ä¹d)¸àfxà¢øàgøà xà y§+›Ú™Xİ8àk•ÙX‹Ñ[Xİ›Ûˆ\˜Ú]Xİ\™xà¤¹æí9£©yænúc,¸àiøàcxàj¸àa8à ‚‚”›Ú™Xİ\˜Ú]Xİ\™xà¤‘ÛÙİ8àn9i"xàb8à¢ùfçº`oøàkøàeøàj¸àa8à ’X¹`m8àjÕÙX‹Ñ[Xİ›Ûˆ›Ú™Xİİ\Ü8à¤º/ïyb¨8àfxà¢øàbøà ykï¹oç9k£9.¡¸ào¸àiù§+™\ÜÚ]Üycf9/døàiÕÙXˆÛÜ™xà¤¹©':*/8àfxà¢øà ‚