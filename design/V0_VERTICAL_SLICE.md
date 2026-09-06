# Voxel Realm — Vertical Slice (Godot 4)

**Status:** v0.1 design lock (Ignis corrections 2026-09-06) — supersedes settlement-as-home framing  
**Engine:** Godot 4 + GDScript  
**Art:** RimWorld-like low-poly — readable **top-down silhouettes**, flatter materials; **not** voxel cubes, **not** blocky CSG tech-demo  
**Layer:** **Strategy-first** on one continuous world (CK3-style home view). Street/walk is a zoom dive, not the default fantasy.  
**Scale:** One county-ish pocket (Ashford + countryside). No Earth globe.

**Local project folder (locked):** `C:\Users\Jason\Documents\realm-of-kings`  
**SCM:** https://github.com/lpoyoll/Realm-of-Kings

---

## Player fantasy

You open in a **strategy overview** of your holding: settlement, fields, named people and villagers as real map bodies. Zoom down to street to walk the ruler if you want. Raise levies by **calling existing villagers to arms** — they leave civilian life, march to the yard, and become the army. Nothing strategically important is a naked HUD number.

Hard rule: **anything important strategically exists as a map entity when relevant.**

---

## In scope — playable loop (v0.1)

### World & camera (strategy-first)
- Same Ashford world (keep, market, houses, farms) — one continuous scene.
- **Default / home zoom = strategy** (high, readable RimWorld/CK3 map feel: buildings + people as clear silhouettes).
- Continuous zoom down to **street** for direct ruler control; zoom back up without loading another map.
- Camera should feel like a strategy game first, village walker second.

### Ruler
- Named ruler (e.g. Aldric), dynasty + title stubs.
- At street zoom: WASD walk.
- At strategy zoom: ruler is a selected map pawn / banner (still a real entity at a location).

### People (real entities)
- **Named NPCs (3–5):** steward, captain, priest, merchant, heir — inspect (name, role, opinion stub). **Not levy fodder** in v0.1.
- **Villagers (12–20):** physical bodies; idle/wander house ↔ work. These are the levy pool.
- People HUD = **civilians only** (named NPCs + current villagers).

### Army — levy from villagers (no spawn-from-nowhere)
- **Raise Levy:** select 4–8 **existing villagers** → convert them into soldiers (same bodies or explicit swap that removes the villager entity and places a soldier at that position — no net-new population).
- They path to the keep yard and form the army group.
- **People count drops** by N; **Army count rises** by N. Totals conserve population.
- **Move:** RMB / order moves those same soldier entities as a group.
- Disband / return-to-civilian: **out of v0.1** (may stay soldiers at destination).
- Forbidden: instantiating soldiers from thin air while villagers remain untouched.

### Dynasty / titles
- Stub data + HUD only (unchanged).

### UX
- Pause on **P**; speed optional.
- HUD: People (civilians), Army (soldiers), dynasty/title, muster control, zoom layer label (Strategy / Street).

---

## Acceptance criteria (QA)

1. Strategy zoom is the comfortable default; continuous zoom to street and back on one scene.
2. Settlement readable at strategy height (keep/market/houses/farms as distinct silhouettes).
3. Named ruler exists on the map; walkable at street zoom.
4. ≥3 named NPCs as real bodies with inspect stubs.
5. ≥12 villagers as real civilian bodies before any muster.
6. Raise Levy converts existing villagers → soldiers (no spawn-from-nowhere); converted villagers leave the civilian pool.
7. After muster: People decreases by N, Army increases by N (population conserved); Army move relocates those same soldier entities.
8. Dynasty + Title stubs visible and match ruler.
9. HUD: People = civilians only; Army = soldiers only.
10. Art read is RimWorld-adjacent (flatter, silhouette-readable top-down) — not voxel cubes, not raw blocky CSG as the intended look.
11. Main scene runs (`res://scenes/main.tscn`).

---

## Out of scope (still)

- Earth / continent / globe  
- Custom engine / Unity / Unreal  
- Full CK3 systems (diplomacy, intrigue, succession, council, laws, trade, tax sim)  
- Combat / sieges / casualties  
- Voxel digging / block building  
- GIS / historical Earth data  
- Disband back to villagers  
- Multi-settlement vassal levy web  
- Production art/audio kits (placeholders OK if they read RimWorld)

---

## Art direction (v0.1 bar)

- Prefer simple low-poly kits or flattened materials over stacked CSG cubes.
- People: distinct pawn silhouettes (body + head), readable from strategy cam.
- Buildings: clear footprints/roofs from above (RimWorld colony readability).
- Flag what’s still placeholder vs intentional look.

---

## Suggested focus for Dev (this pass)

1. Levy conversion (villager → soldier) + HUD conservation.  
2. Strategy-default camera framing + RimWorld-readable materials/silhouettes.  
3. Keep existing Ashford loop otherwise.

---

## After v0.1

Multi-settlement county view; disband; light combat; one interior; opinion-gated decision.
