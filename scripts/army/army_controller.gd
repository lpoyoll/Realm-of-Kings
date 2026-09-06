extends Node3D
## Manages the physical soldier list. UI must call get_count() — never invent numbers.

@export var formation_spacing: float = 1.35
@export var columns: int = 4

var soldiers: Array[Node] = []
var _move_target: Vector3 = Vector3.ZERO
var selected: bool = false

func get_count() -> int:
	_prune()
	return soldiers.size()

func _prune() -> void:
	soldiers = soldiers.filter(func(s: Node) -> bool: return s != null and is_instance_valid(s))

func register_soldier(soldier: Node) -> void:
	if soldier == null or not is_instance_valid(soldier):
		return
	if soldiers.has(soldier):
		return
	soldiers.append(soldier)
	if soldier.get_parent() != self:
		var gp: Vector3 = soldier.global_position
		if soldier.get_parent():
			soldier.get_parent().remove_child(soldier)
		add_child(soldier)
		soldier.global_position = gp
	var idx := soldiers.size() - 1
	if soldier.has_method("set_slot"):
		soldier.set_slot(idx, _slot_for(idx))
	elif "slot_offset" in soldier:
		soldier.slot_offset = _slot_for(idx)

func _slot_for(index: int) -> Vector3:
	var row := index div columns
	var col := index % columns
	var x := (col - (columns - 1) * 0.5) * formation_spacing
	var z := float(row) * formation_spacing
	return Vector3(x, 0.0, z)

func move_to(world_pos: Vector3) -> void:
	_move_target = world_pos
	_push_orders()

func _push_orders() -> void:
	_prune()
	for i in soldiers.size():
		var s: Node = soldiers[i]
		var offset := _slot_for(i)
		if s.has_method("set_order"):
			s.set_order(_move_target, offset)
		elif s.has_method("set_move_target"):
			s.set_move_target(_move_target + offset)

func get_inspect_data() -> Dictionary:
	return {
		"name": "Ashford Levy",
		"role": "Army",
		"opinion": 0,
		"kind": "army",
		"count": get_count(),
	}