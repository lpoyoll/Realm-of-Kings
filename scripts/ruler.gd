extends CharacterBody3D
## Controllable walkable ruler (low-poly placeholder body).

@export var move_speed: float = 6.5
@export var display_name: String = "Lord Aldric Ashford"

var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	add_to_group("ruler")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= _gravity * delta
	else:
		velocity.y = 0.0

	var wish := Vector3.ZERO
	var cam := get_viewport().get_camera_3d()
	var forward := Vector3(0, 0, -1)
	var right := Vector3(1, 0, 0)
	if cam:
		forward = -cam.global_transform.basis.z
		forward.y = 0.0
		if forward.length_squared() > 0.0001:
			forward = forward.normalized()
		right = cam.global_transform.basis.x
		right.y = 0.0
		if right.length_squared() > 0.0001:
			right = right.normalized()

	if Input.is_physical_key_pressed(KEY_W):
		wish += forward
	if Input.is_physical_key_pressed(KEY_S):
		wish -= forward
	if Input.is_physical_key_pressed(KEY_D):
		wish += right
	if Input.is_physical_key_pressed(KEY_A):
		wish -= right

	if wish.length_squared() > 0.0001:
		wish = wish.normalized()
		velocity.x = wish.x * move_speed
		velocity.z = wish.z * move_speed
		look_at(global_position + wish, Vector3.UP)
	else:
		velocity.x = move_toward(velocity.x, 0.0, move_speed)
		velocity.z = move_toward(velocity.z, 0.0, move_speed)

	move_and_slide()
