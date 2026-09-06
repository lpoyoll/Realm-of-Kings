extends Node3D
## Tiny army of real soldier units — muster near ruler and march as a group.

@export var soldier_count: int = 12
@export var formation_spacing: float = 1.35
@export var columns: int = 4

var soldiers: Array[Node] = []
var _move_target: Vector3 = Vector3.ZERO
var _mustering: bool = false

func setup(soldier_scene: PackedScene, spawn_origin: Vector3) -> void:
	for i in soldier_count:
		var s = soldier_scene.instantiate()
		s.unit_index = i
		s.slot_offset = _slot_for(i)
		add_child(s)
		s.global_position = spawn_origin + s.slot_offset + Vector3(0, 0.1, 0)
		soldiers.append(s)
	_move_target = spawn_origin
	_push_orders()

func _slot_for(index: int) -> Vector3:
	var row := int(index / columns)
	var col := index % columns
	var x := (col - (columns - 1) * 0.5) * formation_spacing
	var z := row * formation_spacing
	return Vector3(x, 0.0, z)

func muster_near(world_pos: Vector3) -> void:
	_mustering = true
	_move_target = world_pos + Vector3(0, 0, 4.0)
	_push_orders()

func move_to(world_pos: Vector3) -> void:
	_mustering = false
	_move_target = world_pos
	_push_orders()

func _push_orders() -> void:
	for s in soldiers:
		if s and is_instance_valid(s) and s.has_method("set_order"):
			s.set_order(_move_target, s.slot_offset)

func unit_count() -> int:
	return soldiers.size()
