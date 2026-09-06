extends Node
## Raise Levy (R): convert existing villagers into soldiers (no spawn-from-nowhere).
## Population conserved: People -N, Army +N. Named NPCs are never levy fodder.

const SOLDIER_SCENE := preload("res://scenes/entities/soldier.tscn")

@export var min_levy: int = 4
@export var max_levy: int = 8

var army: Node3D
var muster_point: Marker3D
var spawn_points: Array[Vector3] = [] # unused for conversion; kept for setup API compat
var _mustered: bool = false

signal muster_finished(count: int)

func setup(army_node: Node3D, point: Marker3D, spawns: Array[Vector3] = []) -> void:
	army = army_node
	muster_point = point
	spawn_points = spawns

func can_muster() -> bool:
	if army == null:
		return false
	if army.get_count() >= max_levy:
		return false
	var villagers := get_tree().get_nodes_in_group("villagers")
	if villagers.is_empty():
		return false
	return true

func raise_levy() -> void:
	if not can_muster():
		return
	var current: int = army.get_count() if army else 0
	if current >= max_levy:
		_mustered = true
		return

	var desired := randi_range(min_levy, max_levy)
	var need := clampi(desired - current, 0, max_levy - current)
	if need <= 0:
		_mustered = true
		return

	var villagers: Array = get_tree().get_nodes_in_group("villagers")
	# Prefer living, freeable bodies only
	villagers = villagers.filter(func(v: Node) -> bool: return v != null and is_instance_valid(v))
	if villagers.is_empty():
		return

	# Shuffle then take up to need (convert what's available if under 4)
	villagers.shuffle()
	var take := mini(need, villagers.size())
	if take <= 0:
		return

	var yard: Vector3 = muster_point.global_position if muster_point else Vector3(0, 0.2, -7)
	var parent_node: Node = get_parent()
	var converted := 0

	for i in take:
		var villager: Node = villagers[i]
		if villager == null or not is_instance_valid(villager):
			continue
		var pos: Vector3 = (villager as Node3D).global_position if villager is Node3D else yard
		pos.y = 0.2

		# Remove civilian from tree/groups before creating soldier
		if villager.is_in_group("villagers"):
			villager.remove_from_group("villagers")
		if villager.is_in_group("people"):
			villager.remove_from_group("people")
		villager.queue_free()

		var soldier: CharacterBody3D = SOLDIER_SCENE.instantiate()
		parent_node.add_child(soldier)
		soldier.global_position = pos
		var slot := Vector3(((current + converted) % 4 - 1.5) * 1.3, 0.0, float((current + converted) / 4) * 1.3)
		if army and army.has_method("register_soldier"):
			army.register_soldier(soldier)
		if soldier.has_method("set_order"):
			soldier.set_order(yard, slot)
		converted += 1

	_mustered = true
	if army:
		muster_finished.emit(army.get_count())