# V0 Vertical Slice — Realm of Kings

## Goal
A playable Godot 4.7 Forward+ slice that proves the core fantasy loop at county scale:
walk a ruler through a low-poly settlement, meet named people, zoom from regional map to street level, and muster a tiny real-unit army.

## Look
- RimWorld-like **low poly** people and buildings (flat colors, simple boxes/capsules).
- **Not** Minecraft voxel cubes / block terrain.
- Small county greens + dirt paths + wooden houses.

## In scope (this slice)
1. One small county / region with a simple settlement.
2. Continuous camera zoom: regional overview <-> street / character.
3. Controllable walkable **ruler**.
4. Named NPCs + villagers as **real entities** (nodes in the world).
5. Tiny army (8-20) as **real units** that muster and move as a group.
6. Data stubs for dynasty / title / realm.
7. README: open and run in Godot 4.7.

## Out of scope
- Full Earth globe
- Full CK3 systems (claims, succession simulation, diplomacy AI)
- Custom C++ engine
- Army disband / return-home logistics

## Controls
| Input | Action |
|-------|--------|
| WASD | Move ruler |
| Mouse wheel | Zoom regional <-> street |
| Q / E | Orbit camera |
| RMB | Order army to move to ground point |
| R | Muster army near the ruler |
| Esc | Quit (debug) |

## Architecture
```
scenes/          Main + character packed scenes
scripts/         Gameplay (camera, ruler, army, world build)
data/            Dynasty / title / realm stubs + GameData autoload
design/          This brief
meshes/          Placeholder art home (CSG/procedural for V0)
```

## Success criteria
Opening the project in Godot 4.7 and pressing Play shows:
zoomable county, settlement, walkable ruler, visible people, movable tiny army of real units.
