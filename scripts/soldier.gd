extends CharacterBody3D
## Individual army soldier — real unit that follows formation slots.

@export var unit_index: int = 0
@export var move_speed: float = 5.0

var slot_offset: Vector3 = Vector3.ZERO
var army_target: Vector3 = Vector3.ZERO
var has_orders: bool = false
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	add_to_group("soldier")

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
	var to := desired - global_position
	to.y = 0.0
	if to.length() > 0.25:
		var dir := to.normalized()
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
