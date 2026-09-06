extends Node3D
## Ashford settlement: keep, market, 8â€“12 houses, 2â€“3 farms, roads, muster point, flat navmesh.

@onready var muster_point: Marker3D = $MusterPoint
@onready var nav_region: NavigationRegion3D = $NavigationRegion3D

var house_spawns: Array[Vector3] = []
var farm_spawns: Array[Vector3] = []

func _ready() -> void:
	_build()
	_bake_flat_navmesh()

func get_muster_marker() -> Marker3D:
	return muster_point

func get_levy_spawn_points() -> Array[Vector3]:
	var pts: Array[Vector3] = []
	pts.append_array(house_spawns)
	pts.append_array(farm_spawns)
	return pts

func _mat(color: Color, rough: float = 0.9) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = rough
	return m

func _box(size: Vector3, pos: Vector3, color: Color, static_body: bool = true) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mi.mesh = mesh
	mi.material_override = _mat(color)
	mi.position = pos
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
	# Ground
	_box(Vector3(70, 1, 70), Vector3(0, -0.5, 0), Color(0.34, 0.52, 0.28))
	# Roads
	_box(Vector3(3.5, 0.1, 32), Vector3(0, 0.05, 0), Color(0.55, 0.42, 0.28), false)
	_box(Vector3(24, 0.1, 3.2), Vector3(2, 0.05, 2), Color(0.55, 0.42, 0.28), false)
	# Keep (taller)
	_box(Vector3(5.5, 5.2, 5.5), Vector3(0, 2.6, -12), Color(0.48, 0.48, 0.55))
	_box(Vector3(6.2, 0.4, 6.2), Vector3(0, 5.4, -12), Color(0.35, 0.35, 0.42), false)
	_box(Vector3(1.5, 1.5, 1.5), Vector3(-2.1, 6.1, -12), Color(0.4, 0.4, 0.48), false)
	_box(Vector3(1.5, 1.5, 1.5), Vector3(2.1, 6.1, -12), Color(0.4, 0.4, 0.48), false)
	# Keep yard / muster
	_box(Vector3(10, 0.08, 8), Vector3(0, 0.04, -7), Color(0.5, 0.45, 0.35), false)
	if muster_point:
		muster_point.position = Vector3(0, 0.1, -7)
	# Market plaza
	_box(Vector3(8, 0.12, 8), Vector3(8, 0.06, 2), Color(0.62, 0.55, 0.4), false)
	_box(Vector3(2.2, 1.2, 2.2), Vector3(8, 0.7, 2), Color(0.7, 0.35, 0.25), false)
	# Houses (10)
	var house_spots := [
		Vector3(-6, 0, -3), Vector3(-10, 0, 1), Vector3(-5, 0, 5),
		Vector3(7, 0, -4), Vector3(12, 0, 0), Vector3(9, 0, 6),
		Vector3(-11, 0, -7), Vector3(14, 0, -5), Vector3(-8, 0, 8),
		Vector3(4, 0, 8)
	]
	for i in house_spots.size():
		_house(house_spots[i], i % 2 == 0)
		house_spawns.append(house_spots[i] + Vector3(0, 0.2, 2.2))
	# Farms (3)
	var farms := [Vector3(-16, 0, 6), Vector3(-18, 0, -2), Vector3(18, 0, 8)]
	for f in farms:
		_farm(f)
		farm_spawns.append(f + Vector3(0, 0.2, 0))
	# Trees
	for p in [Vector3(-22, 0, -10), Vector3(22, 0, -14), Vector3(-20, 0, 14), Vector3(20, 0, 16), Vector3(0, 0, 20)]:
		_tree(p)

func _house(origin: Vector3, tall: bool) -> void:
	var h := 2.4 if tall else 2.0
	var w := 3.0 if tall else 2.5
	var d := 2.8 if tall else 2.3
	_box(Vector3(w, h, d), origin + Vector3(0, h * 0.5, 0), Color(0.62, 0.48, 0.32))
	_box(Vector3(w + 0.35, 0.32, d + 0.35), origin + Vector3(0, h + 0.18, 0), Color(0.45, 0.22, 0.18), false)

func _farm(origin: Vector3) -> void:
	_box(Vector3(6, 0.08, 5), origin + Vector3(0, 0.04, 0), Color(0.45, 0.55, 0.28), false)
	_box(Vector3(1.8, 1.4, 1.8), origin + Vector3(-1.5, 0.7, -1.2), Color(0.55, 0.4, 0.25))

func _tree(origin: Vector3) -> void:
	_box(Vector3(0.45, 1.5, 0.45), origin + Vector3(0, 0.75, 0), Color(0.4, 0.28, 0.16), false)
	_box(Vector3(2.0, 2.0, 2.0), origin + Vector3(0, 2.3, 0), Color(0.22, 0.42, 0.22), false)

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
	# Flat walkable quad covering the settlement
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