# Requiem Trainer — RE7 (Resident Evil 7: Biohazard)

**REFramework Lua Trainer for Resident Evil 7** by namsku

> [!CAUTION]
> **Early stage — Work in Progress.** This is a developer tool, not designed to be stable by default.
> Features are actively being ported from the RE9 trainer and may be incomplete or broken.

## Status: 🚧 Active Development

Porting from the RE9 trainer. The EMV Engine core is in place, game-specific features are being adapted.

### What Works
- God Mode, Infinite Ammo, Noclip, Speed, Scale
- Enemy Insta Kill, Enemy Speed
- Items (Unlock All, Max Inventory)
- Dev Overlay (Pos, Rot, Area, NoClip status)
- Enemy Panel (HP bars, rank, distance colors)
- HUD Strip (active feature tags)
- 3D ESP (Enemies, Items, Spawners)
- Objects Browser with live 3D Overlay
- Damage Numbers

### Known Limitations
- ESP scanners use name-based fallback (exact RE7 component types still being discovered)
- No D2D support — overlays use REFramework's native `draw` API
- Object inspection may fail on some component types

## Installation

1. Install [REFramework](https://github.com/praydog/REFramework-nightly/releases) for RE7
2. Copy `re7_trainer.lua` and `re7_trainer/` into `RE7/reframework/autorun/`
3. Press **Insert** to toggle the trainer
