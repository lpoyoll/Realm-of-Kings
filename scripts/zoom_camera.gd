extends Node3D
## Continuous zoom camera: regional overview <-> street / character follow.

@export var follow: Node3D
@export var min_distance: float = 6.0
@export var max_distance: float = 55.0
@export var zoom_speed: float = 2.5
@export var orbit_speed: float = 1.4
@export var pitch_street: float = -35.0
@export var pitch_regional: float = -55.0
@export var follow_lerp: float = 8.0

var _distance: float = 18.0
var _yaw: float = 35.0
var _cam: Camera3D

func _ready() -> void:
	_cam = Camera3D.new()
	_cam.name = "Camera3D"
	_cam.current = true
	_cam.fov = 50.0
	add_child(_cam)
	_apply_transform(true)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_distance = clampf(_distance - zoom_speed, min_distance, max_distance)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_distance = clampf(_distance + zoom_speed, min_distance, max_distance)

func _process(delta: float) -> void:
	if Input.is_physical_key_pressed(KEY_Q):
		_yaw -= rad_to_deg(orbit_speed * delta)
	if Input.is_physical_key_pressed(KEY_E):
		_yaw += rad_to_deg(orbit_speed * delta)
	_apply_transform(false, delta)

func _apply_transform(immediate: bool = false, delta: float = 0.016) -> void:
	if follow == null:
		return
	var t := inverse_lerp(min_distance, max_distance, _distance)
	var pitch := lerpf(pitch_street, pitch_regional, t)
	var target := follow.global_position + Vector3(0, 1.2, 0)
	var offset := Vector3(0, 0, _distance)
	var basis := Basis.from_euler(Vector3(deg_to_rad(pitch), deg_to_rad(_yaw), 0.0))
	var desired := target + basis * offset
	if immediate:
		global_position = desired
	else:
		global_position = global_position.lerp(desired, clampf(follow_lerp * delta, 0.0, 1.0))
	look_at(target, Vector3.UP)
	if _cam:
		_cam.fov = lerpf(55.0, 45.0, t)
