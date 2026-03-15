# Requiem Trainer

**REFramework Lua Trainer for Resident Evil** by namsku

> [!CAUTION]
> This project is in **early stage active development** and is designed for **developer/modding purposes only**.
> It is **not** designed to be stable by default — expect breaking changes, incomplete features, and rough edges.
> This is an on-going work in progress.

## Supported Games

| Game | Status | Folder |
|------|--------|--------|
| **Resident Evil 9** | Primary target | `re9/` |
| **Resident Evil 7** | Early WIP port | `re7/` |

## Installation

### RE9
1. Install [REFramework](https://github.com/praydog/REFramework-nightly/releases) for RE9
2. Copy `re9/requiem_trainer.lua` and `re9/requiem_trainer/` into `%STEAM_RE9%/reframework/autorun/`
3. Press **Insert** to toggle the trainer

### RE7
1. Install [REFramework](https://github.com/praydog/REFramework-nightly/releases) for RE7
2. Copy `re7/re7_trainer.lua` and `re7/re7_trainer/` into `RE7/reframework/autorun/`
3. Press **Insert** to toggle the trainer

## Features (RE9 — Primary)

- **Player**: God Mode, HP Lock, Noclip, Speed, FOV
- **Combat**: One-Hit Kill, Infinite Ammo/Grenades, No Recoil/Reload, Rapid Fire, Auto Parry
- **Enemies**: ESP, Speed control, Motion Freeze, Stealth, Damage Tracking
- **Inventory**: Weapon modification, Free Craft, Unlock Recipes
- **Items**: 3D Item ESP with category colors, distance labels
- **World**: Game Speed, Skip Cutscenes, Costume Override, Difficulty Override
- **Saves**: Unlimited Saves, Remote Storage
- **Dev Tools**: Object Explorer (RSZ type-aware), Spawn Points, Position Save/Warp
- **Overlay (D2D)**: Enemy Panel, ESP, Damage Numbers, HUD Strip, Toast Notifications

## Features (RE7 — WIP Port)

- **Player**: God Mode, Infinite Ammo, Speed, Scale, Noclip
- **Combat**: Enemy Insta Kill, Enemy Speed
- **Items**: Unlock All, Max Inventory
- **Dev Tools**: Objects Browser with 3D Overlay, Component Inspector
- **Overlay (draw API)**: Dev Panel, Enemy Panel, HUD Strip, 3D ESP, Damage Numbers

## Requirements

- [REFramework](https://github.com/praydog/REFramework-nightly/releases) (latest nightly)

## Special Thanks

- **alphaZomega** — Creator of the EMV Engine, whose work made this trainer possible
- **The RE Modding Community** — For opening the door to this world and inspiring the journey
