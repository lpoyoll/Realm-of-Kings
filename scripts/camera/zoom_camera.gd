extends Node3D
## Continuous zoom: street (~8–12m) <-> regional (~40–60m). Q/E orbit optional.

@export var follow: Node3D
@export var min_height: float = 9.0
@export var max_height: float = 50.0
@export var zoom_speed: float = 3.0
@export var orbit_speed: float = 1.4
@export var pitch_street: float = -35.0
@export var pitch_regional: float = -58.0
@export var follow_lerp: float = 8.0

var _distance: float = 16.0
var _yaw: float = 40.0
var _cam: Camera3D

func _ready() -> void:
	_cam = Camera3D.new()
	_cam.name = "Camera3D"
	_cam.current = true
	_cam.fov = 50.0
	add_child(_cam)
	_distance = 16.0
	_apply_transform(true)

func get_zoom_label() -> String:
	var t := inverse_lerp(min_height, max_height, _distance)
	if t < 0.33:
		return "Street"
	elif t < 0.66:
		return "Local"
	return "Regional"

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_distance = clampf(_distance - zoom_speed, min_height, max_height)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_distance = clampf(_distance + zoom_speed, min_height, max_height)

func _process(delta: float) -> void:
	if Input.is_action_pressed("camera_orbit_left"):
		_yaw -= rad_to_deg(orbit_speed * delta)
	if Input.is_action_pressed("camera_orbit_right"):
		_yaw += rad_to_deg(orbit_speed * delta)
	_apply_transform(false, delta)

func _apply_transform(immediate: bool = false, delta: float = 0.016) -> void:
	if follow == null:
		return
	var t := inverse_lerp(min_height, max_height, _distance)
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