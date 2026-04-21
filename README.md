# ElvUI Tracking Button

A minimal tracking button replacement for ElvUI on **Project Epoch (WotLK 3.3.5)**.

ElvUI hides the default Minimap tracking button but provides no replacement. This addon restores it as a draggable, skinned button that integrates cleanly with ElvUI's profile system.

---

## Features

- Replaces the default Minimap tracking button with an ElvUI-skinned equivalent
- Draggable and lockable position, saved per profile
- Configurable size (16–40px) via `/ec` → **Tracking Button**
- Right-click to instantly reset position to default
- Excludes itself cleanly — blacklist frame name `ElvUITrackingButton` in any minimap button collector

## Requirements

- [ElvUI 6.10](https://github.com/Bennylavaa/ElvUI-Epoch) for Project Epoch
- World of Warcraft client **3.3.5** (Project Epoch)

## Installation

1. Download or clone this repository
2. Copy the `ElvUI_TrackingButton` folder into your `Interface/AddOns/` directory
3. Reload or log in — the button appears on your Minimap immediately

## Usage

| Action | Result |
|---|---|
| Left click | Opens the tracking menu |
| Right click | Resets button to default position |
| Drag | Moves the button freely |
| `/ec` → Tracking Button | Enable/disable, resize, lock position, reset |

## License

MIT
