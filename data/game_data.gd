extends Node
## Autoload: dynasty / title / realm stubs + live entity counts for HUD.

var dynasty: Dynasty
var title: Title
var realm: Realm

func _ready() -> void:
	dynasty = Dynasty.new()
	title = Title.new()
	realm = Realm.new()
	print("[GameData] %s - %s (%s)" % [dynasty.name, title.name, realm.capital_settlement])

func summary_line() -> String:
	return "%s - %s" % [dynasty.name, title.name]

func count_people() -> int:
	return get_tree().get_nodes_in_group("people").size()

func count_army() -> int:
	return get_tree().get_nodes_in_group("soldiers").size()

func count_villagers() -> int:
	return get_tree().get_nodes_in_group("villagers").size()

func count_npcs() -> int:
	return get_tree().get_nodes_in_group("npcs").size()