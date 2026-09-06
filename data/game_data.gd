extends Node
## Autoload: dynasty / title / realm stubs + live entity counts for HUD.

var dynasty: Dynasty
var title: Title
var realm: Realm

## Stub realm vitals (no economy sim yet).
var gold: int = 120
var prestige: int = 45
var piety: int = 30
## Campaign clock stub.
var date_string: String = "1066.9.15"

func _ready() -> void:
	dynasty = Dynasty.new()
	title = Title.new()
	realm = Realm.new()
	print("[GameData] %s - %s (%s)  %s" % [dynasty.name, title.name, realm.capital_settlement, date_string])

func summary_line() -> String:
	return "%s - %s" % [dynasty.name, title.name]

func dynasty_chip() -> String:
	if dynasty:
		return dynasty.name
	return "—"

## People HUD = civilians only (named NPCs + villagers). Soldiers never counted here.
func count_people() -> int:
	return count_npcs() + count_villagers()

func count_army() -> int:
	return get_tree().get_nodes_in_group("soldiers").size()

func count_villagers() -> int:
	return get_tree().get_nodes_in_group("villagers").size()

func count_npcs() -> int:
	return get_tree().get_nodes_in_group("npcs").size()