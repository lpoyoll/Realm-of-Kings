extends Node
## Raise Levy (R): spawn 4–8 soldiers at houses/farms, path to keep yard, register with army.
## Only one muster (or top-up to max once). Skip disband.
## Soldiers join the army list immediately so HUD counts match map entities (AC9).

const SOLDIER_SCENE := preload("res://scenes/entities/soldier.tscn")

@export var min_levy: int = 4
@export var max_levy: int = 8

var army: Node3D
var muster_point: Marker3D
var spawn_points: Array[Vector3] = []
var _mustered: bool = false

signal muster_finished(count: int)

func setup(army_node: Node3D, point: Marker3D, spawns: Array[Vector3]) -> void:
	army = army_node
	muster_point = point
	spawn_points = spawns

func can_muster() -> bool:
	if army == null:
		return false
	if _mustered and army.get_count() >= max_levy:
		return false
	return true

func raise_levy() -> void:
	if not can_muster():
		return
	var current := 0
	if army:
		current = army.get_count()
	var target_total := max_levy if _mustered else randi_range(min_levy, max_levy)
	var need := clampi(target_total - current, 0, max_levy)
	if need <= 0:
		_mustered = true
		return

	var yard: Vector3 = muster_point.global_position if muster_point else Vector3(0, 0.2, -7)
	for i in need:
		var soldier: CharacterBody3D = SOLDIER_SCENE.instantiate()
		var spawn: Vector3
		if spawn_points.size() > 0:
			spawn = spawn_points[(current + i) % spawn_points.size()]
		else:
			spawn = yard + Vector3(randf_range(-6, 6), 0, randf_range(4, 10))
		spawn.y = 0.2
		# Add under main briefly so transform is valid, then register (reparents into army).
		get_parent().add_child(soldier)
		soldier.global_position = spawn
		var slot := Vector3(((current + i) % 4 - 1.5) * 1.3, 0.0, float((current + i) / 4) * 1.3)
		if army and army.has_method("register_soldier"):
			army.register_soldier(soldier)
		if soldier.has_method("set_order"):
			soldier.set_order(yard, slot)

	_mustered = true
	if army:
		muster_finished.emit(army.get_count())