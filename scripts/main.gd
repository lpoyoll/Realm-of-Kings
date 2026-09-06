extends Node3D
## V0 entry: Ashford settlement, ruler, NPCs, villagers, camera, HUD, muster, army.

const SETTLEMENT_SCENE := preload("res://scenes/world/settlement_ashford.tscn")
const RULER_SCENE := preload("res://scenes/entities/ruler.tscn")
const NPC_SCENE := preload("res://scenes/entities/npc.tscn")
const VILLAGER_SCENE := preload("res://scenes/entities/villager.tscn")
const ARMY_SCENE := preload("res://scenes/entities/army.tscn")
const HUD_SCENE := preload("res://ui/hud.tscn")
const INSPECTOR_SCENE := preload("res://ui/inspector.tscn")

var settlement: Node3D
var ruler: CharacterBody3D
var army: Node3D
var muster: Node
var camera_rig: Node3D
var hud: CanvasLayer
var inspector: PanelContainer
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
	add_child(ruler)
	ruler.global_position = Vector3(0, 0.2, 4)

func _spawn_npcs() -> void:
	var defs := [
		{"name": "Steward Corvin", "role": "Steward", "opinion": 72, "pos": Vector3(1.5, 0.2, -10.5), "color": Color(0.35, 0.55, 0.85)},
		{"name": "Captain Rhea", "role": "Captain", "opinion": 65, "pos": Vector3(6, 0.2, 5), "color": Color(0.75, 0.25, 0.25)},
		{"name": "Father Alden", "role": "Priest", "opinion": 58, "pos": Vector3(-5.5, 0.2, -3.5), "color": Color(0.9, 0.9, 0.85)},
		{"name": "Mira Goods", "role": "Merchant", "opinion": 48, "pos": Vector3(8, 0.2, 3.5), "color": Color(0.85, 0.55, 0.15)},
		{"name": "Elowen Ashford", "role": "Heir", "opinion": 90, "pos": Vector3(-2, 0.2, -9), "color": Color(0.7, 0.35, 0.75)},
	]
	for d in defs:
		var npc = NPC_SCENE.instantiate()
		npc.display_name = d.name
		npc.role = d.role
		npc.opinion = d.opinion
		npc.accent_color = d.color
		add_child(npc)
		npc.global_position = d.pos

func _spawn_villagers() -> void:
	var names := ["Bram", "Elsa", "Tomlin", "Nessa", "Hud", "Petra", "Owen", "Kira", "Joss", "Willa", "Edda", "Rolf"]
	var spots := [
		Vector3(-9, 0.2, 1), Vector3(-4, 0.2, 7), Vector3(9, 0.2, 2),
		Vector3(12, 0.2, -2), Vector3(-11, 0.2, -6), Vector3(5, 0.2, 8),
		Vector3(-2, 0.2, -5), Vector3(3, 0.2, 3), Vector3(-14, 0.2, 5),
		Vector3(16, 0.2, 7), Vector3(-7, 0.2, 10), Vector3(10, 0.2, -7)
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
			hud.set_status("Levy mustered: %d soldiers" % c)
	)

func _setup_camera() -> void:
	var cam_script := load("res://scripts/camera/zoom_camera.gd")
	camera_rig = cam_script.new()
	camera_rig.name = "ZoomCamera"
	camera_rig.follow = ruler
	add_child(camera_rig)

func _setup_ui() -> void:
	hud = HUD_SCENE.instantiate()
	add_child(hud)
	hud.bind(camera_rig, army, muster)
	hud.muster_pressed.connect(_do_muster)
	inspector = INSPECTOR_SCENE.instantiate()
	hud.add_child(inspector)

func _do_muster() -> void:
	if muster and muster.has_method("raise_levy"):
		if muster.can_muster():
			muster.raise_levy()
			hud.set_status("Raising levy - soldiers pathing to keep yard")
		else:
			hud.set_status("Levy already mustered")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
		return
	if event.is_action_pressed("muster"):
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
		return
	var collider: Object = hit.get("collider")
	var node: Node = collider as Node
	while node:
		if node.is_in_group("npcs") or node.is_in_group("ruler") or node.is_in_group("soldiers") or node == army:
			_select(node)
			return
		if node.has_method("get_inspect_data"):
			_select(node)
			return
		node = node.get_parent()
	# Click ground clears / or select army if near soldiers
	selected = null
	if inspector:
		inspector.clear()
	if hud:
		hud.set_selected("Selected: -")

func _select(node: Node) -> void:
	selected = node
	var data: Dictionary = {}
	if node.has_method("get_inspect_data"):
		data = node.get_inspect_data()
	elif node == army and army.has_method("get_inspect_data"):
		data = army.get_inspect_data()
	if inspector:
		inspector.show_entity(data)
	if hud:
		hud.set_selected("Selected: %s" % str(data.get("name", node.name)))

func _try_army_move() -> void:
	if army == null:
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