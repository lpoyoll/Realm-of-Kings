# Realm of Kings — CK3 UI & Feature Target

**Status:** PRODUCT LOCK (Ignis via Paul, 2026-09-06) — **CK3 with a living visual world**; not RTS, not village-walker  
**Engine:** Godot 4 Control shell over continuous world  
**Art under map:** RimWorld-readable low-poly (v0.1)  
**Reference:** Crusader Kings III UI/IA (screenshots welcome; no ripped Paradox assets in-game)

**Local:** `C:\Users\Jason\Documents\realm-of-kings`  
**SCM:** https://github.com/lpoyoll/Realm-of-Kings  
**Feeds:** `design/V0_VERTICAL_SLICE.md` (simulation truths already locked)

---

## North star

Build **more or less a CK3 clone in systems and chrome**, with one hard difference: strategy map and physical world are the **same** continuous space, and levies/people are **real entities**.

### The UI is the piece that brings it all together

The shell is not decoration. It is the **player computer** for the whole game:

- **CK3-shaped windows** (Realm, Military, Council, Court, Intrigue, Factions, Decisions, Character, Holding) are how you *think* and *issue orders*.
- **The living map** is how those orders *manifest* (villagers become soldiers, armies march as bodies, people exist at places).
- Every important number in a panel must resolve to something you can select, pan to, and see on the map when it matters.
- Hotkeys never replace a panel; panels never lie about abstract counts.

So: systems land *into* the UI first (stub window OK), then gain simulation depth — the chrome stays the spine.

---

## What we are / are not (product lock)

| We **are** | We are **not** |
|------------|----------------|
| CK3-class grand strategy with CK3 chrome as the primary play surface | An RTS (no battalion micro fantasy) |
| A continuous living map where people/armies are real selectable bodies | A village walker with UI bolted on |
| Panel + map-RMB order flows (Raise Levy, move army, select dossiers) | WASD/hotkey-first command |
| RimWorld-readable silhouettes proving physicalisation under strategy cam | Street-level control as the default fantasy |

**Hard rules**
1. Primary play surface = grand-strategy chrome (top bar, outliner, character/holding/army panels, decisions). Map clicks **serve the UI**.
2. No RTS feel — if a feature makes it feel like commanding an RTS battalion, cut or redesign.
3. Visual world proves physicalisation (levies from real villagers, people exist). Camera/default UX stays strategy/CK3.
4. Next build priority after shell green: **deepen CK3 shell** (character panel, holding panel, outliner selection) — **not** more street-level control.

QA judges future smokes on **CK3-feel**, not RTS completeness.

---

## Two horizons

### Horizon A — UI shell (Dev now)
Shell smoke **PASS** on `4c128fe` / `c7d330a`. **Next:** deepen character / holding / outliner selection + stub icon windows — **not** street control.

### Horizon B — CK3 feature parity (roadmap)
Fill the same windows with real systems over time. Empty/stub panels are OK early; **do not** invent alternate IA — mirror CK3 information architecture so we know what we are building toward.

---

## Horizon A — Shell layout (implement now)

```text
┌──────────────────────────────────────────────────────────────────┐
│ TOP BAR: Date │ Gold* │ Prestige* │ Piety* │ Lifestyle* │ Dynasty │
│          + icon row stubs: Realm / Council / Court / Intrigue…     │
├────────────┬─────────────────────────────────────┬───────────────┤
│ OUTLINER   │         3D STRATEGY MAP             │ SIDE / DOSSIER│
│ Holdings   │                                     │               │
│ Vassals*   │                                     │               │
│ People     │                                     │               │
│ Armies     │                                     │               │
│ Factions*  │                                     │               │
├────────────┴─────────────────────────────────────┴───────────────┤
│ BOTTOM: Pause / 1x / 2x / 3x* │ alert toasts │ map-mode tabs*    │
└──────────────────────────────────────────────────────────────────┘
* stub or disabled-with-tooltip ("Coming") until that system exists
```

**Selection:** `none | holding | character | title* | army`  
LMB select, Esc/empty clear, outliner ↔ map sync.  
**Raise Levy:** Holding dossier button (mouse-only required).  
**Army move:** RMB on map with army selected.  
**Keys:** optional mirrors only.

Street zoom may collapse gutters; strategy zoom is home.

Retire floating debug People/Army counters once shell shows them.

### Shell panel fields (A)

| Panel | Must show now | Stub OK |
|-------|---------------|---------|
| Top vitals | Date + gold/prestige/piety ints | Lifestyle, stress |
| Top icons | Visible row | Open real windows later |
| Outliner Holdings | Ashford | Multi-county |
| Outliner People | Ruler + named NPCs | Villager browse |
| Outliner Armies | Levy when raised | Multiple armies |
| Outliner Vassals/Factions | Header + "None" | Real lists |
| Dossier Holding | Name, buildings stub, **Raise Levy**, available levies | Dev/tax/faith |
| Dossier Character | Name, role, opinion | Traits, rivals, hooks |
| Dossier Army | Count (= bodies), RMB hint | Supply, knights |
| Realm (no sel.) | Title, dynasty, People/Army totals | Realm laws |
| Bottom | Pause/speeds + toast | Map modes |

### Shell ACs (QA)

1. Top bar: date + ≥1 vital + dynasty chip + icon row (stubs fine).  
2. Outliner sections exist; Holdings/People/Armies select world entities.  
3. Dossier switches Realm / Holding / Character / Army.  
4. Raise Levy from Holding panel (no key required); villagers convert; People −N / Army +N.  
5. Army selected → RMB moves same bodies.  
6. Bottom pause/speed works; P may mirror pause.  
7. Shell counts match entity rules (civilians vs soldiers).  
8. Empty levy disables button with reason.  
9. Strategy default; street dive doesn’t break selection bus.

---

## Horizon B — CK3 feature map (build toward)

Use this as the checklist of **windows/systems** to fill. Each gets a dossier or dedicated window in the shell’s icon row. Simulation still obeys: important things exist on the map when relevant.

### Character & dynasty
- Character view: traits, skills, lifestyle, stress, dread, prestige, piety  
- Relationships: friends, rivals, soulmate, hooks  
- Dynasty tree, houses, renown, legacies  
- Succession, heirs, claims  
- Education / childhood (later)

### Realm & government
- Titles hierarchy (barony → county → duchy → kingdom → empire) — start with barony/county stubs  
- Vassals, feudal contracts (stub → real)  
- Council jobs + councillor characters  
- Laws, crown authority  
- Court / grandees / court positions (later)

### Intrigue & diplomacy
- Schemes (murder, sway, fabricate claim…)  
- Hooks & secrets  
- Personal & realm diplomacy: alliances, marriages, betrothals, wars, tributaries  
- Factions & civil wars

### War & military
- Raise levies / men-at-arms / knights (levies already entity-based)  
- Army orders, gather, raid, supply (extend RMB model)  
- Battles & sieges as physicalised events on the same map (differentiator)  
- War overview / CB / warscore UI

### Faith, culture, learning
- Faith window, conversion, tenets (stub → real)  
- Culture & hybridisation (later)  
- Innovations / tech clock

### Economy & holdings
- Holding buildings & upgrades  
- Domain limit, taxes, men-at-arms recruitment  
- Development, control, popular opinion  
- Trade later if we want; not required for CK3-feel MVP

### Map modes & alerts
- Political, dynasty, faith, culture, opinion, development map modes  
- Feed / important alerts (birth, death, war, faction threshold)

### Meta
- Pause speeds, decisions list, finders (character/title), save/load, settings, encyclopedia stubs

**Parity rule:** When adding a system, add its **CK3-shaped entry point** in the shell first (icon + empty window), then fill data — so the clone shape stays visible.

---

## Differentiator (never drop)

| CK3-like | Our twist |
|----------|-----------|
| Levy number in UI | UI number = bodies on map; raise **converts** villagers |
| Abstract armies | Armies march as entities you can zoom to |
| Separate tactical map | Same continuous world; street dive optional |
| 2D map art | RimWorld-like 3D readable from strategy cam |

---

## Reference shots

Public guide refs pulled for IA (GamePressure interface guide, military/levy guides). Drop your own CK3 shots anytime to refine density.

## Screenshot wishlist (optional extras)

If you can drop refs (your shots or web grabs), prioritize:

1. **Main strategy screen** — full chrome (top bar, outliners, dossier open on a county)  
2. **Character view** — traits/skills lifestyle bar  
3. **Military / army selected** — raise men-at-arms / levy panel  
4. **Council**  
5. **Intrigue / schemes**  
6. **War overview**  
7. Any **map mode** strip you care about first

I’ll translate those into panel wireframes + fill order without copying assets.

---

## Dev build order (unchanged cadence)

1. Shell frames + realm summary + icon row stubs  
2. Selection bus  
3. Holding Raise Levy (mouse)  
4. Army RMB move  
5. Character dossier  
6. Toast / disable empty levy / kill debug HUD  
7. Deepen Horizon A: richer character + holding dossiers, tighter outliner selection, stub Realm/Military/Council icons.
8. Then Horizon B fills: **Character traits → Council → Military MaA panel → Decisions → Map modes**
9. Street/WASD ruler dive stays optional proof only — never the roadmap driver.

---

## Out of scope for Horizon A only

Real council/intrigue/war/religion simulation, production fonts/portraits, Paradox assets, multiplayer.
