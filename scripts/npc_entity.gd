extends CharacterBody3D
## Named NPC or villager — real world entity with simple idle wander.

@export var display_name: String = "Villager"
@export var is_notable: bool = false
@export var wander_radius: float = 4.0
@export var move_speed: float = 1.6

var _home: Vector3
var _target: Vector3
var _wait: float = 0.0
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	add_to_group("npc")
	_home = global_position
	_pick_target()
	_ensure_label()

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
	if to.length() < 0.35:
		_wait = randf_range(1.2, 3.5)
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
	var offset := Vector3(randf_range(-wander_radius, wander_radius), 0.0, randf_range(-wander_radius, wander_radius))
	_target = _home + offset

func _ensure_label() -> void:
	if has_node("NameLabel"):
		($NameLabel as Label3D).text = display_name
		return
	var label := Label3D.new()
	label.name = "NameLabel"
	label.text = display_name
	label.position = Vector3(0, 2.1, 0)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.font_size = 28 if is_notable else 22
	label.outline_size = 6
	label.modulate = Color(1.0, 0.92, 0.55) if is_notable else Color(0.92, 0.92, 0.92)
	add_child(label)
