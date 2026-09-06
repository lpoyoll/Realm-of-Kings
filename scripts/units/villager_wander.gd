extends CharacterBody3D
## Simple villager body with idle wander. Levy pool for Raise Levy.

@export var display_name: String = "Villager"
@export var role: String = "Villager"
@export var opinion: int = 40
@export var wander_radius: float = 3.5
@export var move_speed: float = 1.5

var _home: Vector3
var _target: Vector3
var _wait: float = 0.0
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	add_to_group("villagers")
	_home = global_position
	_pick_target()
	if has_node("NameLabel"):
		var nl := $NameLabel as Label3D
		nl.text = display_name
		nl.add_to_group("nameplates")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= _gravity * delta
	else:
		velocity.y = 0.0

	if _wait > 0.0:
		_wait -= delta
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		return

	var to := _target - global_position
	to.y = 0.0
	if to.length() < 0.4:
		_wait = randf_range(1.0, 3.5)
		_pick_target()
		velocity.x = 0.0
		velocity.z = 0.0
	else:
		var dir := to.normalized()
		velocity.x = dir.x * move_speed
		velocity.z = dir.z * move_speed
		look_at(global_position + dir, Vector3.UP)
	move_and_slide()

func _pick_target() -> void:
	var offset := Vector3(
		randf_range(-wander_radius, wander_radius),
		0.0,
		randf_range(-wander_radius, wander_radius)
	)
	_target = _home + offset

func get_inspect_data() -> Dictionary:
	return {
		"name": display_name,
		"role": role,
		"opinion": opinion,
		"kind": "villager",
	}