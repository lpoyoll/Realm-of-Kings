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
3. **Inspect character** — select ruler/NPC (map or outliner) → name / role / opinion / traits / education / skills → **Go to** pans/follows.
4. **Council** — top-bar **Council** → panel lists five jobs with live appointees; click a councillor to update the character dossier (panel stays open).
5. **Military** — top-bar **Military** → Levies live count (map soldiers) + MaA regiment slots (Bowmen / Spearmen / Light Horse at size 0; Recruit Coming/disabled). No MaA bodies on the map.
6. **Decisions** — top-bar **Decisions** → panel lists Hold Court / Host Feast (live stubs) and Invite Knights / Send Gift (Coming). Hold Court bumps councillor opinions; Host Feast deducts a small gold stub. No new map bodies.
7. **Court** — top-bar **Court** → panel lists existing ruler + named NPCs as courtiers (portrait initials + name + role); click a row to open the character dossier. Court Physician / Court Tutor stay Vacant / Coming. No new map bodies.
8. **Intrigue** — top-bar **Intrigue** → Schemes: Sway (NPC target dropdown + Start toast/opinion bump; View opens dossier), Fabricate Hook / Murder Coming. Hooks / Secrets: None. Spymaster line = Elowen. No new map bodies.

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
- Character dossier shows traits / education / skills stubs (per person)
- **Council** top-bar icon opens a Council window stub: Chancellor / Steward / Marshal / Spymaster / Court Chaplain assigned to existing NPCs (Mira Goods, Steward Corvin, Captain Rhea, Elowen Ashford, Father Alden). Click a row to select that person in the side dossier (traits still work).
- **Military** top-bar icon opens a Military window: live levy count from army on the map, plus Men-at-Arms slots (Bowmen / Spearmen / Light Horse) at size 0 with Recruit Coming/disabled. MaA do not spawn map entities; levies remain the only raised troops.
- **Decisions** top-bar icon opens a Decisions window stub: Hold Court (toast + councillor opinion +2), Host Feast (toast + small gold cost), Invite Knights / Send Gift Coming/disabled. Panel-only — no street/RTS and no new entities.
- **Court** top-bar icon opens a Court window stub: Court of Ashford / House Ashford header, courtiers from existing ruler + named NPCs (click opens dossier), Court Physician / Court Tutor Vacant Coming.
- **Intrigue** top-bar icon opens an Intrigue window stub: Spymaster Elowen, Sway scheme (target picker from existing NPCs; Start toast + opinion +5; View selects dossier), Fabricate Hook / Murder Coming/disabled, Hooks / Secrets None. Realm stays Coming stub.

## Layout
```
design/     V0 brief + CK3_UI_TARGET.md
data/       Dynasty / title / realm / council + vitals stubs
scripts/    units, army, camera, ui (ck3_shell), world
scenes/     main, entities, world
ui/         ck3_shell.tscn (+ legacy hud/inspector)
meshes/     art placeholders
```

## Git
Remote: https://github.com/lpoyoll/Realm-of-Kings