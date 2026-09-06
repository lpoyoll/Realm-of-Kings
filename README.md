# Realm of Kings

Godot 4.7 Forward+ vertical slice (Jolt Physics). RimWorld-like low-poly county demo at **Ashford** — not Minecraft voxels.

## Requirements
- Godot 4.7+ (tested with 4.7.2)
- Windows / macOS / Linux

## Open and run
1. Open Godot 4.7.
2. Import / open:
   `C:\Users\Jason\Documents\realm-of-kings`
3. Main scene is already `res://scenes/main.tscn`.
4. Press **F5** (Play).

## Controls
- **WASD** — walk Baron Aldric Ashford
- **Mouse wheel** — zoom street <-> regional
- **Q / E** — orbit camera
- **LMB** — select person / army (inspector)
- **RMB** — order army to ground point
- **R** or **Raise Levy** — muster 4-8 real soldiers
- **Space** — pause/unpause
- **Esc** — quit

## What you should see
- Ashford settlement (keep, market, houses, farms)
- Named NPCs + wandering villagers as real entities
- Controllable ruler
- Tiny army of real units that muster and march
- HUD counts from live group membership

## Layout
```
design/     V0 brief
data/       Dynasty / title / realm stubs
scripts/    units, army, camera, ui, world
scenes/     main, entities, world
ui/         HUD + inspector
meshes/     art placeholders
```

## Git
Remote: https://github.com/lpoyoll/Realm-of-Kings