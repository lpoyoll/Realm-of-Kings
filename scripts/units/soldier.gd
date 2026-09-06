extends CharacterBody3D
## Steel-colored levy soldier. Direct steering toward formation slot (v0 nav-friendly).

@export var move_speed: float = 5.0
@export var display_name: String = "Levy Soldier"
@export var role: String = "Soldier"
@export var opinion: int = 55

var slot_offset: Vector3 = Vector3.ZERO
var army_target: Vector3 = Vector3.ZERO
var has_orders: bool = false
var unit_index: int = 0
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var agent: NavigationAgent3D = get_node_or_null("NavigationAgent3D") as NavigationAgent3D

func _ready() -> void:
	add_to_group("people")
	add_to_group("soldiers")
	if agent:
		agent.path_desired_distance = 0.5
		agent.target_desired_distance = 0.5
		agent.avoidance_enabled = false

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= _gravity * delta
	else:
		velocity.y = 0.0

	if not has_orders:
		velocity.x = move_toward(velocity.x, 0.0, move_speed)
		velocity.z = move_toward(velocity.z, 0.0, move_speed)
		move_and_slide()
		return

	var desired := army_target + slot_offset
	desired.y = global_position.y

	var dir := Vector3.ZERO
	var used_nav := false
	if agent:
		var map_rid: RID = agent.get_navigation_map()
		if map_rid.is_valid() and NavigationServer3D.map_get_iteration_id(map_rid) > 0:
			agent.target_position = desired
			if not agent.is_navigation_finished():
				var next_pos := agent.get_next_path_position()
				dir = next_pos - global_position
				dir.y = 0.0
				used_nav = true
	if not used_nav:
		dir = desired - global_position
		dir.y = 0.0

	if dir.length() > 0.25:
		dir = dir.normalized()
		velocity.x = dir.x * move_speed
		velocity.z = dir.z * move_speed
		look_at(global_position + dir, Vector3.UP)
	else:
		velocity.x = 0.0
		velocity.z = 0.0
	move_and_slide()

func set_order(target: Vector3, offset: Vector3) -> void:
	army_target = target
	slot_offset = offset
	has_orders = true
	if agent:
		agent.target_position = target + offset

func set_slot(index: int, offset: Vector3) -> void:
	unit_index = index
	slot_offset = offset

func set_move_target(world_pos: Vector3) -> void:
	army_target = world_pos
	slot_offset = Vector3.ZERO
	has_orders = true

func get_inspect_data() -> Dictionary:
	return {
		"name": display_name,
		"role": role,
		"opinion": opinion,
		"kind": "soldier",
	}