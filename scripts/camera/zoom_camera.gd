extends Node3D
## Continuous zoom: street (~10–12m) <-> strategy (~55–65m). Default = strategy home.
## At strategy zoom follows settlement focus; at street follows ruler.

@export var follow: Node3D
@export var settlement_focus: Node3D
@export var min_height: float = 11.0
@export var max_height: float = 58.0
@export var zoom_speed: float = 3.5
@export var orbit_speed: float = 1.4
@export var pitch_street: float = -35.0
@export var pitch_strategy: float = -62.0
@export var follow_lerp: float = 8.0

var _distance: float = 55.0
var _yaw: float = 40.0
var _cam: Camera3D

func _ready() -> void:
	_cam = Camera3D.new()
	_cam.name = "Camera3D"
	_cam.current = true
	_cam.fov = 48.0
	add_child(_cam)
	# Strategy home — start near max height
	_distance = max_height - 3.0
	_apply_transform(true)

func get_zoom_label() -> String:
	var t := inverse_lerp(min_height, max_height, _distance)
	# Strategy is the default/home band (high zoom)
	if t > 0.55:
		return "Strategy"
	return "Street"

func get_zoom_t() -> float:
	return inverse_lerp(min_height, max_height, _distance)

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

func _follow_target() -> Node3D:
	var t := get_zoom_t()
	# Strategy: prefer settlement center; Street: ruler
	if t > 0.55 and settlement_focus != null:
		return settlement_focus
	if follow != null:
		return follow
	return settlement_focus

func _apply_transform(immediate: bool = false, delta: float = 0.016) -> void:
	var target_node := _follow_target()
	if target_node == null:
		return
	var t := get_zoom_t()
	var pitch := lerpf(pitch_street, pitch_strategy, t)
	var look_height := lerpf(1.2, 0.4, t)
	var target := target_node.global_position + Vector3(0, look_height, 0)
	var offset := Vector3(0, 0, _distance)
	var basis := Basis.from_euler(Vector3(deg_to_rad(pitch), deg_to_rad(_yaw), 0.0))
	var desired := target + basis * offset
	if immediate:
		global_position = desired
	else:
		global_position = global_position.lerp(desired, clampf(follow_lerp * delta, 0.0, 1.0))
	look_at(target, Vector3.UP)
	if _cam:
		_cam.fov = lerpf(55.0, 42.0, t)