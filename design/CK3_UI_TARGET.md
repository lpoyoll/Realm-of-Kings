# Realm of Kings — CK3 UI Target (shell)

**Status:** Target vision for UI direction (not a full systems build)  
**Engine:** Godot 4 Control UI over the existing continuous 3D world  
**Principle:** Think **CK3 chrome**, not action-game hotkeys. Mouse + panels first; keys are optional shortcuts later.  
**Maps to:** v0.1 Ashford slice (strategy cam, real people/army, levy convert, dynasty/title stubs)

**Local:** `C:\Users\Jason\Documents\realm-of-kings`  
**SCM:** https://github.com/lpoyoll/Realm-of-Kings

---

## Player fantasy (UI)

You feel like you’re playing a grand-strategy court game: date and realm vitals at the top, an outliner of who/what you own, click the map or a name to open a dossier, issue Raise Levy from a button on the selected holding — then watch villagers become soldiers on the same world.

---

## Shell layout (target)

```text
┌─────────────────────────────────────────────────────────────┐
│ TOP BAR: date | gold* | prestige* | piety* | dynasty chip   │
├──────────┬──────────────────────────────────────┬───────────┤
│ OUTLINER │           3D STRATEGY MAP            │ SIDE      │
│ realm    │     (continuous world — v0.1)        │ PANEL     │
│ holdings │                                      │ (context) │
│ people   │                                      │           │
│ armies   │                                      │           │
├──────────┴──────────────────────────────────────┴───────────┤
│ BOTTOM: speed P/1x/2x | alerts tray | map mode tabs (later) │
└─────────────────────────────────────────────────────────────┘
* stub numbers OK — no real economy yet
```

Zoom to street can dim/hide outliner density; strategy zoom is the UI’s home.

---

## Panels → v0.1 wiring

| UI piece | Player-facing job | Wire to now | Fake / later |
|----------|-------------------|-------------|--------------|
| **Top bar date** | Campaign clock | Cosmic pause/speed if present; else static “1066.9.15” | Calendar events |
| **Top bar gold/prestige/piety** | Realm vitals | Stub ints on GameData | Economy / renown / faith |
| **Dynasty chip** | Who you are | Existing dynasty stub | Full dynasty tree |
| **Outliner → Holdings** | List Ashford | One row → select settlement | Multi-county |
| **Outliner → People** | Named NPCs + ruler | Existing npc/ruler entities | Traits, relations graph |
| **Outliner → Armies** | Mustered army | Army entity when count > 0 | Multiple armies |
| **Side panel — Holding** | Selected settlement | Buildings list stub; **Raise Levy** button | Buildings, tax, development |
| **Side panel — Character** | Selected person | Name, role, opinion stub | Traits, schemes, marriage |
| **Side panel — Army** | Selected army | Soldier count (= bodies); **Move** hint | Supply, commander, battles |
| **Tooltips** | Hover name/role/count | Short strings | Modifier stacks |
| **Alerts tray** | “Levy arrived at yard” | Optional one-liner | Threats, births, wars |

---

## Primary flows (must feel CK3)

### 1. Select holding → Raise Levy
1. Click Ashford on map **or** outliner Holdings row.  
2. Side panel shows holding dossier.  
3. Click **Raise Levy** (primary button) — **not** an R-key requirement.  
4. World: villagers convert → path to yard; People −N / Army +N.  
5. Optional: toast “Levy mustering (N)”.

### 2. Select army → Move
1. Click army banner/bodies **or** outliner Armies.  
2. Side panel: count, commander stub.  
3. **Right-click** map ground → move order (same bodies).  
4. Cursor / tooltip: “Move here”.

### 3. Select character
1. Click pawn or outliner People.  
2. Side panel: name, role, opinion; “Go to” pans camera.  
3. Street zoom still allowed as a dive; returning to strategy restores shell focus.

### 4. Pause / speed
- **P** pause remains OK as a shortcut.  
- On-screen speed controls in the bottom bar are the canonical UX.

---

## Input rules

| Action | Canonical | Optional shortcut (later) |
|--------|-----------|-----------------------------|
| Raise Levy | Holding panel button | R |
| Move army | RMB on map with army selected | — |
| Select | LMB | — |
| Deselect / back | Esc / empty click | — |
| Pause | Bottom bar + **P** | — |
| Zoom | Mouse wheel | — |

**Do not** ship new gameplay that only exists as a keybind with no panel/map affordance.

---

## Visual tone

- Dense but calm: CK3-like panels (dark parchment / cold stone), readable fonts, clear selected state.  
- Map stays RimWorld-readable pawns/buildings underneath.  
- Panels are opaque/translucent frames — they must not fight the 3D pick.

---

## Acceptance criteria (UI shell pass)

1. Top bar visible with date + at least one stub vital + dynasty chip.  
2. Outliner lists Holdings / People / Armies and selecting a row selects the world entity.  
3. Side panel swaps by selection type (holding / character / army).  
4. Raise Levy is issued from the holding panel (works with no key press).  
5. Army move is RMB-on-map with army selected (panel explains it).  
6. Existing v0.1 levy rules still hold (convert villagers, HUD conservation, NPCs untouched).  
7. Keyboard-only play is **not** required; shortcuts may mirror buttons but buttons win.

---

## Out of scope for this UI pass

Full CK3 systems (council, intrigue UI, war overview, religion window, culture map modes, decisions list, marriage finder, save/load screens). One shell + the three flows above is enough to aim at.

---

## Build order for Dev

1. CanvasLayer shell: top bar, outliner, side panel, bottom bar (empty frames OK).  
2. Selection bus: map click + outliner → panel.  
3. Move Raise Levy off R-only onto holding button (keep R as optional shortcut if cheap).  
4. RMB move when army selected + tooltip.  
5. Polish stubs (gold/prestige) and one toast.
