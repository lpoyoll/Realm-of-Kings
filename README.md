# Realm of Kings

Godot 4.7 Forward+ vertical slice (Jolt Physics). **v0.1** strategy-first county demo at **Ashford** — RimWorld-like low-poly silhouettes, not Minecraft voxels.

## Requirements
- Godot 4.7+ (tested with 4.7.2)
- Windows / macOS / Linux

## Open and run
1. Open Godot 4.7.
2. Import / open:
   `C:\Users\Jason\Documents\realm-of-kings`
3. Main scene is already `res://scenes/main.tscn`.
4. Press **F5** (Play).

## CK3 UI shell
The HUD is a CK3-like chrome frame over the continuous 3D map:

| Region | Contents |
|--------|----------|
| **Top bar** | Date `1066.9.15`, stub gold / prestige / piety, House dynasty chip, People/Army counts |
| **Left outliner** | Holdings / People / Armies — click a row to select |
| **Center** | 3D strategy map (panels do not block map picks) |
| **Right side panel** | Holding / Character / Army dossier (swaps by selection) |
| **Bottom bar** | Pause / 1x / 2x + alerts tray |

### Primary flows
1. **Raise Levy** — select Ashford (map or outliner) → side panel → **Raise Levy** button. Converts 4–8 villagers into soldiers (People −N, Army +N). Named NPCs are never levied. **R** remains an optional shortcut only.
2. **Move army** — select the army (banner/bodies or outliner) → side panel shows *Right-click map to move* → **RMB** on ground.
3. **Inspect character** — select ruler/NPC (map or outliner) → name / role / opinion → **Go to** pans/follows.

### Controls
- **WASD** — walk Baron Aldric Ashford (best at Street zoom)
- **Mouse wheel** — zoom Strategy (default/home) ↔ Street
- **Q / E** — orbit camera
- **LMB** — select holding / person / army
- **RMB** — army move (only when army selected)
- **Raise Levy** button (holding panel) or optional **R**
- **Pause / 1x / 2x** buttons (bottom) or optional **P**
- **Esc** — quit

## Player fantasy
You open in a **strategy overview** of Ashford with CK3-style panels. Raise levies from the holding dossier — population is conserved. Zoom down to street to walk the ruler; outliner dims at street zoom.

## What you should see
- Strategy-height camera by default
- Ashford settlement with clear building footprints and pitched roofs
- Pawn silhouettes for people
- 5 named NPCs + ~16 wandering villagers
- Raise Levy converts villagers → soldiers (no spawn-from-nowhere)
- People = civilians only (NPCs + villagers); Army = soldiers
- Dynasty / title / vitals stubs on the top bar

## Layout
```
design/     V0 brief + CK3_UI_TARGET.md
data/       Dynasty / title / realm + vitals stubs
scripts/    units, army, camera, ui (ck3_shell), world
scenes/     main, entities, world
ui/         ck3_shell.tscn (+ legacy hud/inspector)
meshes/     art placeholders
```

## Git
Remote: https://github.com/lpoyoll/Realm-of-Kings