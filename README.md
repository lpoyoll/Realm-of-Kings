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

## Controls (v0.1)
- **WASD** — walk Baron Aldric Ashford (best at Street zoom)
- **Mouse wheel** — zoom **Strategy** (default/home) ↔ **Street**
- **Q / E** — orbit camera
- **LMB** — select person / army (inspector)
- **RMB** — order army to ground point
- **R** or **Raise Levy** — convert 4–8 existing villagers into soldiers (they march to the keep yard). Named NPCs are never levied.
- **P** — pause/unpause
- **Esc** — quit

## Player fantasy
You open in a **strategy overview** of Ashford. Raise levies by calling villagers to arms — population is conserved (People −N, Army +N). Zoom down to street to walk the ruler.

## What you should see
- Strategy-height camera by default (CK3 / RimWorld map feel)
- Ashford settlement with clear building footprints and pitched roofs
- Pawn silhouettes (body + head) for people
- 5 named NPCs + ~16 wandering villagers
- Raise Levy converts villagers → soldiers (no spawn-from-nowhere)
- HUD: **People** = civilians only (NPCs + villagers); **Army** = soldiers
- Dynasty / title stubs on the HUD

## Layout
```
design/     V0 brief (v0.1 design lock)
data/       Dynasty / title / realm stubs
scripts/    units, army, camera, ui, world
scenes/     main, entities, world
ui/         HUD + inspector
meshes/     art placeholders
```

## Git
Remote: https://github.com/lpoyoll/Realm-of-Kings