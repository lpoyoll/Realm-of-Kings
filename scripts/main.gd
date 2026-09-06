extends Node3D
## V0.1 entry: Ashford settlement, ruler, NPCs, villagers, strategy camera, CK3 UI shell, muster, army.

const SETTLEMENT_SCENE := preload("res://scenes/world/settlement_ashford.tscn")
const RULER_SCENE := preload("res://scenes/entities/ruler.tscn")
const NPC_SCENE := preload("res://scenes/entities/npc.tscn")
const VILLAGER_SCENE := preload("res://scenes/entities/villager.tscn")
const ARMY_SCENE := preload("res://scenes/entities/army.tscn")
const SHELL_SCENE := preload("res://ui/ck3_shell.tscn")

var settlement: Node3D
var ruler: CharacterBody3D
var army: Node3D
var muster: Node
var camera_rig: Node3D
var hud: CanvasLayer
var selected: Node = null

func _ready() -> void:
	_spawn_settlement()
	_spawn_ruler()
	_spawn_npcs()
	_spawn_villagers()
	_spawn_army_and_muster()
	_setup_camera()
	_setup_ui()

func _spawn_settlement() -> void:
	settlement = SETTLEMENT_SCENE.instantiate()
	settlement.name = "SettlementAshford"
	add_child(settlement)

func _spawn_ruler() -> void:
	ruler = RULER_SCENE.instantiate()
	ruler.sheet = CharacterSheet.make(
		PackedStringArray(["Ambitious", "Just"]),
		"Skilled Tactician",
		8, 7, 9, 5, 6
	)
	add_child(ruler)
	ruler.global_position = Vector3(0, 0.2, 4)

func _spawn_npcs() -> void:
	var defs := [
		{
			"name": "Steward Corvin",
			"role": "Steward",
			"opinion": 72,
			"pos": Vector3(1.5, 0.2, -10.5),
			"color": Color(0.35, 0.55, 0.85),
			"sheet": CharacterSheet.make(
				PackedStringArray(["Diligent", "Temperate"]),
				"Fortune Builder",
				6, 3, 12, 7, 5
			),
		},
		{
			"name": "Captain Rhea",
			"role": "Captain",
			"opinion": 65,
			"pos": Vector3(6, 0.2, 5),
			"color": Color(0.75, 0.25, 0.25),
			"sheet": CharacterSheet.make(
				PackedStringArray(["Brave", "Wrathful"]),
				"Brilliant Strategist",
				4, 14, 5, 6, 3
			),
		},
		{
			"name": "Father Alden",
			"role": "Priest",
			"opinion": 58,
			"pos": Vector3(-5.5, 0.2, -3.5),
			"color": Color(0.9, 0.9, 0.85),
			"sheet": CharacterSheet.make(
				PackedStringArray(["Zealous", "Compassionate"]),
				"Theologian",
				7, 2, 4, 3, 13
			),
		},
		{
			"name": "Mira Goods",
			"role": "Merchant",
			"opinion": 48,
			"pos": Vector3(8, 0.2, 3.5),
			"color": Color(0.85, 0.55, 0.15),
			"sheet": CharacterSheet.make(
				PackedStringArray(["Gregarious", "Greedy"]),
				"Midwell Educated",
				10, 3, 11, 8, 6
			),
		},
		{
			"name": "Elowen Ashford",
			"role": "Heir",
			"opinion": 90,
			"pos": Vector3(-2, 0.2, -9),
			"color": Color(0.7, 0.35, 0.75),
			"sheet": CharacterSheet.make(
				PackedStringArray(["Curious", "Ambitious"]),
				"Charismatic Negotiator",
				9, 5, 6, 10, 8
			),
		},
	]
	for d in defs:
		var npc = NPC_SCENE.instantiate()
		npc.display_name = d.name
		npc.role = d.role
		npc.opinion = d.opinion
		npc.accent_color = d.color
		npc.sheet = d.sheet
		add_child(npc)
		npc.global_position = d.pos

func _spawn_villagers() -> void:
	# ~16 villagers so a levy of 4–8 leaves civilians remaining
	var names := [
		"Bram", "Elsa", "Tomlin", "Nessa", "Hud", "Petra", "Owen", "Kira",
		"Joss", "Willa", "Edda", "Rolf", "Mara", "Seth", "Lina", "Garr"
	]
	var spots := [
		Vector3(-9, 0.2, 1), Vector3(-4, 0.2, 7), Vector3(9, 0.2, 2),
		Vector3(12, 0.2, -2), Vector3(-11, 0.2, -6), Vector3(5, 0.2, 8),
		Vector3(-2, 0.2, -5), Vector3(3, 0.2, 3), Vector3(-14, 0.2, 5),
		Vector3(16, 0.2, 7), Vector3(-7, 0.2, 10), Vector3(10, 0.2, -7),
		Vector3(-15, 0.2, -1), Vector3(15, 0.2, 4), Vector3(1, 0.2, 10),
		Vector3(-6, 0.2, -8)
	]
	for i in mini(names.size(), spots.size()):
		var v = VILLAGER_SCENE.instantiate()
		v.display_name = names[i]
		add_child(v)
		v.global_position = spots[i]

func _spawn_army_and_muster() -> void:
	army = ARMY_SCENE.instantiate()
	army.name = "Army"
	add_child(army)

	var muster_script := load("res://scripts/army/muster.gd")
	muster = muster_script.new()
	muster.name = "Muster"
	add_child(muster)

	await get_tree().process_frame
	var marker: Marker3D = null
	var spawns: Array[Vector3] = []
	if settlement and settlement.has_method("get_muster_marker"):
		marker = settlement.get_muster_marker()
	if settlement and settlement.has_method("get_levy_spawn_points"):
		spawns = settlement.get_levy_spawn_points()
	muster.setup(army, marker, spawns)
	muster.muster_finished.connect(func(c: int) -> void:
		if hud:
			hud.set_status("Levy mustering (%d)" % c)
			if hud.has_method("refresh_outliner"):
				hud.refresh_outliner()
	)

func _setup_camera() -> void:
	var cam_script := load("res://scripts/camera/zoom_camera.gd")
	camera_rig = cam_script.new()
	camera_rig.name = "ZoomCamera"
	camera_rig.follow = ruler
	# Strategy default follows settlement center
	if settlement and settlement.has_method("get_settlement_focus"):
		camera_rig.settlement_focus = settlement.get_settlement_focus()
	elif settlement:
		camera_rig.settlement_focus = settlement
	add_child(camera_rig)

func _setup_ui() -> void:
	hud = SHELL_SCENE.instantiate()
	add_child(hud)
	hud.bind(camera_rig, army, muster, settlement)
	hud.raise_levy_pressed.connect(_do_muster)
	hud.go_to_pressed.connect(_on_go_to)

func _do_muster() -> void:
	if muster and muster.has_method("raise_levy"):
		if muster.can_muster():
			var before := get_tree().get_nodes_in_group("villagers").size()
			muster.raise_levy()
			var after := get_tree().get_nodes_in_group("villagers").size()
			var n := maxi(before - after, 0)
			if hud:
				hud.set_status("Levy mustering (%d)" % n)
				if hud.has_method("refresh_outliner"):
					hud.refresh_outliner()
				# Keep holding panel open with updated Raise button state
				if settlement and hud.has_method("select_holding"):
					hud.select_holding(settlement)
		else:
			var villagers_left := get_tree().get_nodes_in_group("villagers").size()
			if villagers_left == 0:
				hud.set_status("No villagers left to levy")
			else:
				hud.set_status("Levy already at capacity")

func _on_go_to(target: Node) -> void:
	if target == null or not is_instance_valid(target):
		return
	if camera_rig == null:
		return
	# Street zoom + follow the character when possible
	if "follow" in camera_rig and target is Node3D:
		camera_rig.follow = target
	if "_distance" in camera_rig and "min_height" in camera_rig:
		camera_rig._distance = camera_rig.min_height + 1.0
	if hud:
		hud.set_status("Following %s" % _display_name_of(target))

func _display_name_of(node: Node) -> String:
	if node == null:
		return "?"
	if "display_name" in node:
		return str(node.display_name)
	if node.has_method("get_inspect_data"):
		return str(node.get_inspect_data().get("name", node.name))
	return str(node.name)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
		return
	if event.is_action_pressed("muster"):
		# Optional shortcut — canonical path is holding panel Raise Levy
		_do_muster()
		return
	if event.is_action_pressed("pause"):
		if Engine.time_scale > 0.0:
			Engine.time_scale = 0.0
		else:
			Engine.time_scale = 1.0
		return
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_try_select()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_try_army_move()

func _try_select() -> void:
	var hit := _raycast()
	if hit.is_empty():
		_clear_selection()
		return
	var collider: Object = hit.get("collider")
	var node: Node = collider as Node
	while node:
		# Soldier → select owning army
		if node.is_in_group("soldiers"):
			_select_army()
			return
		if node == army or (army and node.get_parent() == army):
			_select_army()
			return
		if node.is_in_group("holdings") or node == settlement:
			_select_holding()
			return
		if node.is_in_group("npcs") or node.is_in_group("ruler") or node.is_in_group("villagers"):
			_select_character(node)
			return
		if node.has_method("get_inspect_data"):
			var data: Dictionary = node.get_inspect_data()
			var kind := str(data.get("kind", ""))
			if kind == "holding":
				_select_holding()
				return
			if kind == "army":
				_select_army()
				return
			_select_character(node)
			return
		node = node.get_parent()
	_clear_selection()

func _clear_selection() -> void:
	selected = null
	if hud and hud.has_method("clear_selection"):
		hud.clear_selection()

func _select_holding() -> void:
	selected = settlement
	if hud and hud.has_method("select_holding"):
		hud.select_holding(settlement)

func _select_character(node: Node) -> void:
	selected = node
	if hud and hud.has_method("select_character"):
		hud.select_character(node)

func _select_army() -> void:
	selected = army
	if hud and hud.has_method("select_army"):
		hud.select_army(army)

func _try_army_move() -> void:
	# Only when army is the current selection (CK3-like order flow)
	var army_selected: bool = false
	if hud and "sel_kind" in hud:
		army_selected = hud.sel_kind == hud.SelKind.ARMY
	elif selected == army:
		army_selected = true
	if not army_selected or army == null:
		return
	if army.has_method("get_count") and army.get_count() <= 0:
		return
	var hit := _raycast()
	var pos: Vector3
	if hit.is_empty():
		var plane_hit: Variant = _ray_plane()
		if plane_hit == null:
			return
		pos = plane_hit
	else:
		pos = hit.position
	if army.has_method("move_to"):
		army.move_to(pos)
		if hud:
			hud.set_status("Army marching")

func _raycast() -> Dictionary:
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		return {}
	var mouse := get_viewport().get_mouse_position()
	var from := cam.project_ray_origin(mouse)
	var dir := cam.project_ray_normal(mouse)
	var q := PhysicsRayQueryParameters3D.create(from, from + dir * 500.0)
	q.collide_with_areas = true
	q.collision_mask = 0xFFFFFFFF
	return get_world_3d().direct_space_state.intersect_ray(q)

func _ray_plane() -> Variant:
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		return null
	var mouse := get_viewport().get_mouse_position()
	var from := cam.project_ray_origin(mouse)
	var dir := cam.project_ray_normal(mouse)
	if absf(dir.y) < 0.0001:
		return null
	var t := -from.y / dir.y
	if t < 0.0:
		return null
	return from + dir * t