extends CharacterBody3D
## WASD motor for the walkable ruler (camera-relative).

@export var move_speed: float = 6.5
@export var display_name: String = "Aldric Ashford"
@export var role: String = "Baron"
@export var opinion: int = 100
@export var sheet: CharacterSheet

var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	add_to_group("ruler")
	if sheet == null:
		sheet = CharacterSheet.make(
			PackedStringArray(["Ambitious", "Just"]),
			"Skilled Tactician",
			8, 7, 9, 5, 6
		)
	if has_node("NameLabel"):
		var nl := $NameLabel as Label3D
		nl.text = display_name
		nl.add_to_group("nameplates")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= _gravity * delta
	else:
		velocity.y = 0.0

	var input_dir := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	)
	var basis_yaw := Basis.IDENTITY
	var cam := get_viewport().get_camera_3d()
	if cam:
		var forward := -cam.global_transform.basis.z
		forward.y = 0.0
		if forward.length_squared() > 0.0001:
			forward = forward.normalized()
			var right := cam.global_transform.basis.x
			right.y = 0.0
			right = right.normalized()
			basis_yaw = Basis(right, Vector3.UP, -forward)

	var direction := (basis_yaw * Vector3(input_dir.x, 0.0, input_dir.y))
	if direction.length_squared() > 0.0001:
		direction = direction.normalized()
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
		look_at(global_position + direction, Vector3.UP)
	else:
		velocity.x = move_toward(velocity.x, 0.0, move_speed)
		velocity.z = move_toward(velocity.z, 0.0, move_speed)

	move_and_slide()

func get_inspect_data() -> Dictionary:
	var data: Dictionary = {
		"name": display_name,
		"role": role,
		"opinion": opinion,
		"kind": "ruler",
	}
	_append_sheet_data(data)
	return data

func _append_sheet_data(data: Dictionary) -> void:
	if sheet == null:
		return
	data["traits"] = sheet.personality_traits
	data["education"] = sheet.education
	data["skills"] = {
		"diplomacy": sheet.diplomacy,
		"martial": sheet.martial,
		"stewardship": sheet.stewardship,
		"intrigue": sheet.intrigue,
		"learning": sheet.learning,
	}
	data["traits_line"] = sheet.traits_line()
	data["education_line"] = sheet.education_line()
	data["skills_line"] = sheet.skills_line()