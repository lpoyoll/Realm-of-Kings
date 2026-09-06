extends CharacterBody3D
## Named NPC with nameplate, role/opinion stubs, and light idle wander.

@export var display_name: String = "NPC"
@export var role: String = "Courtier"
@export var opinion: int = 50
@export var accent_color: Color = Color(0.7, 0.5, 0.3)
@export var wander_radius: float = 2.0
@export var move_speed: float = 1.4

var _home: Vector3
var _target: Vector3
var _wait: float = 0.0
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	add_to_group("people")
	add_to_group("npcs")
	_home = global_position
	_pick_target()
	_apply_accent()
	_ensure_label()
	if has_node("SelectArea"):
		var area := $SelectArea as Area3D
		area.collision_layer = 4
		area.collision_mask = 0
		area.monitoring = false
		area.monitorable = true

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
		_wait = randf_range(1.5, 4.0)
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

func _apply_accent() -> void:
	if has_node("Accent"):
		var mi := $Accent as MeshInstance3D
		var mat := StandardMaterial3D.new()
		mat.albedo_color = accent_color
		mat.roughness = 0.8
		mi.material_override = mat

func _ensure_label() -> void:
	if has_node("NameLabel"):
		($NameLabel as Label3D).text = display_name
		return
	var label := Label3D.new()
	label.name = "NameLabel"
	label.text = display_name
	label.position = Vector3(0, 2.15, 0)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.font_size = 28
	label.outline_size = 6
	label.modulate = Color(1.0, 0.92, 0.55)
	add_child(label)

func get_inspect_data() -> Dictionary:
	return {
		"name": display_name,
		"role": role,
		"opinion": opinion,
		"kind": "npc",
	}