extends Node3D
## Ashford settlement: keep, market, houses with pitched roofs, farms, roads.
## RimWorld-adjacent: clear top-down footprints, flatter materials (not CSG stacks as look).

@onready var muster_point: Marker3D = $MusterPoint
@onready var nav_region: NavigationRegion3D = $NavigationRegion3D

var house_spawns: Array[Vector3] = []
var farm_spawns: Array[Vector3] = []
var settlement_focus: Marker3D

func _ready() -> void:
	add_to_group("holdings")
	_ensure_focus_marker()
	_build()
	_bake_flat_navmesh()

func get_muster_marker() -> Marker3D:
	return muster_point

func get_settlement_focus() -> Marker3D:
	return settlement_focus

func get_levy_spawn_points() -> Array[Vector3]:
	var pts: Array[Vector3] = []
	pts.append_array(house_spawns)
	pts.append_array(farm_spawns)
	return pts

func _ensure_focus_marker() -> void:
	settlement_focus = get_node_or_null("SettlementFocus") as Marker3D
	if settlement_focus == null:
		settlement_focus = Marker3D.new()
		settlement_focus.name = "SettlementFocus"
		add_child(settlement_focus)
	settlement_focus.position = Vector3(0, 0.1, 0)

func _mat(color: Color, rough: float = 1.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = rough
	m.metallic = 0.0
	return m

func _box(size: Vector3, pos: Vector3, color: Color, static_body: bool = true, rot_deg: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mi.mesh = mesh
	mi.material_override = _mat(color)
	mi.position = pos
	mi.rotation_degrees = rot_deg
	add_child(mi)
	if static_body:
		var body := StaticBody3D.new()
		var col := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = size
		col.shape = shape
		body.collision_layer = 1
		body.collision_mask = 0
		body.add_child(col)
		mi.add_child(body)
	return mi

func _build() -> void:
	_add_sun()
	_add_environment()
	# Ground â€” flat field
	_box(Vector3(70, 1, 70), Vector3(0, -0.5, 0), Color(0.36, 0.50, 0.30))
	# Roads â€” clear footprints from above
	_box(Vector3(3.5, 0.08, 32), Vector3(0, 0.04, 0), Color(0.58, 0.48, 0.34), false)
	_box(Vector3(24, 0.08, 3.2), Vector3(2, 0.04, 2), Color(0.58, 0.48, 0.34), false)
	# Keep â€” solid footprint + flat roof plate + banner towers
	_box(Vector3(5.5, 5.0, 5.5), Vector3(0, 2.5, -12), Color(0.52, 0.52, 0.58))
	_box(Vector3(6.4, 0.35, 6.4), Vector3(0, 5.2, -12), Color(0.38, 0.38, 0.44), false)
	# Pitched keep roof ridge (rotated thin box)
	_box(Vector3(6.6, 0.25, 3.4), Vector3(0, 5.55, -12), Color(0.42, 0.28, 0.28), false, Vector3(0, 0, 28))
	_box(Vector3(6.6, 0.25, 3.4), Vector3(0, 5.55, -12), Color(0.40, 0.26, 0.26), false, Vector3(0, 0, -28))
	_box(Vector3(1.4, 1.6, 1.4), Vector3(-2.2, 5.9, -12), Color(0.45, 0.45, 0.50), false)
	_box(Vector3(1.4, 1.6, 1.4), Vector3(2.2, 5.9, -12), Color(0.45, 0.45, 0.50), false)
	# Banner accent
	_box(Vector3(0.12, 2.2, 0.8), Vector3(0, 6.8, -9.2), Color(0.22, 0.35, 0.72), false)
	# Keep yard / muster
	_box(Vector3(10, 0.06, 8), Vector3(0, 0.03, -7), Color(0.55, 0.48, 0.38), false)
	if muster_point:
		muster_point.position = Vector3(0, 0.1, -7)
	# Market plaza + stall
	_box(Vector3(8, 0.1, 8), Vector3(8, 0.05, 2), Color(0.64, 0.56, 0.42), false)
	_box(Vector3(2.4, 1.0, 2.0), Vector3(8, 0.55, 2), Color(0.72, 0.38, 0.28), false)
	_box(Vector3(2.8, 0.2, 1.1), Vector3(8, 1.2, 2), Color(0.55, 0.22, 0.18), false, Vector3(0, 0, 20))
	# Houses (10) with pitched roofs
	var house_spots := [
		Vector3(-6, 0, -3), Vector3(-10, 0, 1), Vector3(-5, 0, 5),
		Vector3(7, 0, -4), Vector3(12, 0, 0), Vector3(9, 0, 6),
		Vector3(-11, 0, -7), Vector3(14, 0, -5), Vector3(-8, 0, 8),
		Vector3(4, 0, 8)
	]
	for i in house_spots.size():
		_house(house_spots[i], i % 2 == 0)
		house_spawns.append(house_spots[i] + Vector3(0, 0.2, 2.2))
	# Farms (3) â€” flat patches + fence posts
	var farms := [Vector3(-16, 0, 6), Vector3(-18, 0, -2), Vector3(18, 0, 8)]
	for f in farms:
		_farm(f)
		farm_spawns.append(f + Vector3(0, 0.2, 0))
	# Trees â€” simple trunk + canopy blob
	for p in [Vector3(-22, 0, -10), Vector3(22, 0, -14), Vector3(-20, 0, 14), Vector3(20, 0, 16), Vector3(0, 0, 20)]:
		_tree(p)

func _house(origin: Vector3, tall: bool) -> void:
	var h := 2.2 if tall else 1.85
	var w := 3.0 if tall else 2.5
	var d := 2.6 if tall else 2.2
	# Footprint body
	_box(Vector3(w, h, d), origin + Vector3(0, h * 0.5, 0), Color(0.68, 0.55, 0.40))
	# Pitched roof (two slanted plates) â€” readable from strategy cam
	var roof_y := h + 0.15
	var roof_col := Color(0.48, 0.24, 0.20) if tall else Color(0.52, 0.28, 0.22)
	_box(Vector3(w + 0.4, 0.22, d * 0.55), origin + Vector3(0, roof_y, -d * 0.12), roof_col, false, Vector3(28, 0, 0))
	_box(Vector3(w + 0.4, 0.22, d * 0.55), origin + Vector3(0, roof_y, d * 0.12), roof_col, false, Vector3(-28, 0, 0))
	# Door accent strip (silhouette detail)
	_box(Vector3(0.55, 1.1, 0.08), origin + Vector3(0, 0.55, d * 0.5 + 0.02), Color(0.35, 0.25, 0.18), false)

func _farm(origin: Vector3) -> void:
	# Flat crop patch (brown/green)
	_box(Vector3(6.5, 0.06, 5.2), origin + Vector3(0, 0.03, 0), Color(0.42, 0.52, 0.26), false)
	_box(Vector3(5.8, 0.04, 2.0), origin + Vector3(0, 0.06, 0.8), Color(0.50, 0.42, 0.28), false)
	# Shed
	_box(Vector3(1.6, 1.2, 1.6), origin + Vector3(-1.8, 0.6, -1.4), Color(0.58, 0.44, 0.30))
	_box(Vector3(1.9, 0.18, 1.0), origin + Vector3(-1.8, 1.3, -1.4), Color(0.45, 0.25, 0.20), false, Vector3(0, 0, 22))
	# Fence posts around patch
	var posts := [
		Vector3(-3.0, 0.4, -2.3), Vector3(3.0, 0.4, -2.3),
		Vector3(-3.0, 0.4, 2.3), Vector3(3.0, 0.4, 2.3),
		Vector3(0.0, 0.4, -2.3), Vector3(0.0, 0.4, 2.3),
	]
	for p in posts:
		_box(Vector3(0.12, 0.8, 0.12), origin + p, Color(0.40, 0.30, 0.20), false)

func _tree(origin: Vector3) -> void:
	_box(Vector3(0.4, 1.4, 0.4), origin + Vector3(0, 0.7, 0), Color(0.42, 0.30, 0.18), false)
	_box(Vector3(1.8, 1.6, 1.8), origin + Vector3(0, 2.1, 0), Color(0.24, 0.44, 0.24), false)

func _add_sun() -> void:
	var light := DirectionalLight3D.new()
	light.name = "Sun"
	light.rotation_degrees = Vector3(-50, 35, 0)
	light.light_energy = 1.15
	light.shadow_enabled = true
	add_child(light)

func _add_environment() -> void:
	var we := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.55, 0.72, 0.88)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.55, 0.58, 0.62)
	env.ambient_light_energy = 0.45
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	we.environment = env
	add_child(we)

func _bake_flat_navmesh() -> void:
	if nav_region == null:
		return
	var nmesh := NavigationMesh.new()
	nmesh.agent_radius = 0.4
	nmesh.agent_height = 1.8
	nmesh.agent_max_climb = 0.4
	var verts := PackedVector3Array([
		Vector3(-28, 0.05, -28),
		Vector3(28, 0.05, -28),
		Vector3(28, 0.05, 28),
		Vector3(-28, 0.05, 28),
	])
	nmesh.vertices = verts
	nmesh.clear_polygons()
	nmesh.add_polygon(PackedInt32Array([0, 1, 2, 3]))
	nav_region.navigation_mesh = nmesh

func get_inspect_data() -> Dictionary:
	return {
		"name": "Ashford",
		"role": "Barony capital",
		"kind": "holding",
		"buildings": ["Keep", "Market", "Houses (10)", "Farms (3)"],
	}
