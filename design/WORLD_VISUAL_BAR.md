# Realm of Kings — World Visual Bar

**Status:** LOCKED (Ignis via Paul, 2026-09-06) — chrome may pass; **map must not look like a school demo**  
**Priority:** Hold Horizon B stubs until a first Ashford world pass clears this bar  
**Partners:** @Gary IA/acceptance · @Marissa density/taste · @Sean implement · @Danielle smoke  

**Local:** `C:\\Users\\Jason\\Documents\\realm-of-kings`  
**Feeds:** `V0_VERTICAL_SLICE.md` (physicalisation) · `CK3_UI_TARGET.md` (chrome already cleared on `7e32c28`)

---

## Problem (from Ignis shot)

HUD can look like CK3 while the **world** is still: flat green slab, toy gable boxes, capsule “jelly” pawns. That is **not** the destination. Destination = **CK3 with a living visual world** — readable strategy map first.

---

## What we are / are not (world)

| We **are** | We are **not** |
|------------|----------------|
| A living strategy map you read like CK3/RimWorld from above | An RTS sandbox or village walker playground |
| Distinct holdings, roofs, fields, roads, banners | A bright flat green plane with toy houses |
| Readable people at strategy zoom (pawn silhouettes with head/body/color role) | Featureless capsules / jelly cylinders |
| Same world when you peek to street | A second “pretty” map that doesn’t match play |

---

## Strategy zoom (default — this is the bar that matters)

At ~strategy height the player must instantly read:

1. **Ground** — muted terrain (grass/dirt variation or tiled low-poly), **not** a single untextured green slab; soft horizon / fog OK.  
2. **Holdings** — keep/manor distinct from houses; pitched roofs; footprint readable; banner/CoA on keep.  
3. **Roads / yards** — paths with value separation from fields (not one tan rectangle soup).  
4. **Fields** — 2–3 farm plots with crop tint or furrow suggestion.  
5. **Trees / clutter** — sparse but real silhouettes (not random Lego blobs only).  
6. **People** — **no jelly capsules**. Minimum: RimWorld-like pawn (body + head), role colors (ruler accent, soldiers steel, villagers muted, named NPCs unique). Named NPCs readable as “someone” at strategy distance.  
7. **Army** — soldiers visually distinct from villagers when mustered (shield/spear stub or helmet color).  
8. **Light** — directional sun + gentle ambient; avoid clinic-bright ortho blast.

### Strategy glance test (Marissa + Ignis)

“Would I believe this is a medieval holding on a strategy map for 2 seconds?”  
If no → fail, even if systems work.

---

## Street peek (optional dive — lower priority)

- Same meshes, closer camera — no new art set required for pass 1.  
- Ground detail can stay simple; **do not** spend the first pass on interiors.  
- WASD walk may exist but must not drive art priority.

---

## Explicit fails (block “looks like the game”)

- Flat single-color ground plane as the whole map  
- Capsule/cylinder/sphere people as the final pawn language  
- Buildings that are only unbevelled boxes with primary-color roofs  
- Neon debug materials, hot pink, default SpatialMaterial chrome look  
- UI polished while world stays demo (HUD ≠ game)

---

## Pass 1 scope (Sean — first world pass)

Do these only:

1. Replace ground with muted multi-shade terrain (mesh or textured plane + slight noise).  
2. Rebuild Ashford kit: keep (banner), 8–12 houses with varied roofs, market stub, roads, 2–3 fields. Low-poly OK if **readable**.  
3. Replace all people with pawn prefab (body+head); role palette.  
4. Soldier variant for levies.  
5. Basic sun + environment ambient/fog.  

**Out of pass 1:** animations polish, interiors, water sim, foliage density, unique hero meshes, CK3 2D portraits on map.

---

## Acceptance criteria (Danielle + Marissa)

1. No flat green slab as dominant ground read.  
2. No capsule jelly pawns remain in Ashford.  
3. Keep vs house vs field vs road distinguishable at strategy default cam.  
4. Ruler / NPC / villager / soldier distinguishable by silhouette or color at strategy zoom.  
5. Banner or clear keep landmark present.  
6. Lighting no longer “blank ortho demo.”  
7. Chrome from `7e32c28` still works (no regress).  
8. Marissa glance: strategy map reads medieval holding, not student scene.  

---

## Art flags (need later)

- Low-poly medieval kit (or Kenney-like CC0) for houses/keep  
- Pawn atlas / simple mesh kit  
- Ground grass/dirt textures  
- Optional: map-mode friendly albedo (flat colors that still read)

Until then: authored low-poly placeholders that **pass the glance test** beat rushed feature stubs.
