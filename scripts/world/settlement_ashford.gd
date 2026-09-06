extends Node3D
## Ashford settlement Pass 1 - muted medieval holding, strategy-readable.
## Keep/houses/roads/fields/trees; soft fog + warmer sun. No neon ground.

@onready var muster_point: Marker3D = $MusterPoint
@onready var nav_region: NavigationRegion3D = $NavigationRegion3D

var house_spawns: Array[Vector3] = []
var farm_spawns: Array[Vector3] = []
var settlement_focus: Marker3D

# Muted earth palette (CK3 map vibe - desaturated olives/browns/stone)
const C_GRASS_A := Color(0.34, 0.40, 0.28)
const C_GRASS_B := Color(0.30, 0.36, 0.24)
const C_GRASS_C := Color(0.38, 0.42, 0.30)
const C_DIRT := Color(0.42, 0.34, 0.24)
const C_DIRT_DARK := Color(0.36, 0.28, 0.20)
const C_ROAD := Color(0.28, 0.24, 0.20)
const C_YARD := Color(0.48, 0.42, 0.32)
const C_STONE := Color(0.38, 0.38, 0.40)
const C_STONE_DARK := Color(0.30, 0.30, 0.33)
const C_STONE_ROOF := Color(0.32, 0.28, 0.28)
const C_BANNER := Color(0.18, 0.28, 0.55)
const C_BANNER_ACCENT := Color(0.72, 0.58, 0.22)
const C_MARKET := Color(0.50, 0.42, 0.32)
const C_STALL := Color(0.55, 0.32, 0.24)
const C_FIELD_CROP := Color(0.40, 0.38, 0.22)
const C_FIELD_SOIL := Color(0.36, 0.30, 0.20)
const C_FURROW := Color(0.28, 0.22, 0.15)
const C_TRUNK := Color(0.32, 0.24, 0.16)
const C_CANOPY_A := Color(0.22, 0.34, 0.20)
const C_CANOPY_B := Color(0.26, 0.38, 0.22)
const C_CANOPY_C := Color(0.18, 0.30, 0.18)
const C_WALL_A := Color(0.55, 0.48, 0.38)
const C_WALL_B := Color(0.50, 0.44, 0.36)
const C_WALL_C := Color(0.58, 0.50, 0.40)
const C_ROOF_A := Color(0.42, 0.26, 0.20)
const C_ROOF_B := Color(0.38, 0.28, 0.22)
const C_ROOF_C := Color(0.45, 0.30, 0.18)
const C_ROOF_D := Color(0.35, 0.24, 0.22)
const C_DOOR := Color(0.28, 0.20, 0.14)

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

func _cyl(radius: float, height: float, pos: Vector3, color: Color, static_body: bool = false) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mi.mesh = mesh
	mi.material_override = _mat(color)
	mi.position = pos
	add_child(mi)
	if static_body:
		var body := StaticBody3D.new()
		var col := CollisionShape3D.new()
		var shape := CylinderShape3D.new()
		shape.radius = radius
		shape.height = height
		col.shape = shape
		body.collision_layer = 1
		body.collision_mask = 0
		body.add_child(col)
		mi.add_child(body)
	return mi

func _build() -> void:
	_add_sun()
	_add_environment()
	_add_terrain()
	_add_roads()
	_add_keep()
	_add_market()
	_add_houses()
	_add_farms()
	_add_trees()

func _add_terrain() -> void:
	# Base muted grass slab (collision) - olive, not neon
	_box(Vector3(72, 1.0, 72), Vector3(0, -0.5, 0), C_GRASS_A, true)
	# Overlapping grass tone patches (no collision) for variation
	_box(Vector3(22, 0.04, 18), Vector3(-14, 0.02, -16), C_GRASS_B, false)
	_box(Vector3(20, 0.04, 16), Vector3(16, 0.02, 14), C_GRASS_C, false)
	_box(Vector3(18, 0.035, 14), Vector3(-18, 0.025, 12), C_GRASS_C, false)
	_box(Vector3(16, 0.035, 20), Vector3(18, 0.025, -12), C_GRASS_B, false)
	_box(Vector3(14, 0.03, 12), Vector3(0, 0.03, 18), C_GRASS_B, false)
	_box(Vector3(12, 0.03, 10), Vector3(-8, 0.03, -20), C_GRASS_C, false)
	# Dirt / worn patches near roads and keep approaches
	_box(Vector3(10, 0.05, 8), Vector3(-4, 0.04, 0), C_DIRT, false)
	_box(Vector3(8, 0.05, 7), Vector3(6, 0.04, -2), C_DIRT_DARK, false)
	_box(Vector3(7, 0.045, 6), Vector3(2, 0.035, 8), C_DIRT, false)
	_box(Vector3(9, 0.045, 5), Vector3(-10, 0.035, 4), C_DIRT_DARK, false)
	# Thin raised layers for slight height noise (far edges)
	_box(Vector3(8, 0.12, 6), Vector3(-26, 0.06, -22), C_GRASS_B, false)
	_box(Vector3(7, 0.10, 5), Vector3(25, 0.05, 22), C_GRASS_C, false)
	_box(Vector3(6, 0.08, 8), Vector3(24, 0.04, -20), C_DIRT, false)
	_box(Vector3(5, 0.09, 7), Vector3(-24, 0.045, 20), C_GRASS_B, false)

func _add_roads() -> void:
	# Darker than yards - packed earth paths
	_box(Vector3(3.2, 0.07, 34), Vector3(0, 0.035, 0), C_ROAD, false)
	_box(Vector3(26, 0.07, 2.8), Vector3(2, 0.035, 2), C_ROAD, false)
	# Spur to farms / market edge
	_box(Vector3(10, 0.06, 2.0), Vector3(-8, 0.03, 6), C_ROAD, false)
	_box(Vector3(2.0, 0.06, 8), Vector3(8, 0.03, -2), C_ROAD, false)

func _add_keep() -> void:
	# Darker stone keep - taller landmark
	_box(Vector3(5.8, 5.6, 5.8), Vector3(0, 2.8, -12), C_STONE)
	_box(Vector3(6.6, 0.4, 6.6), Vector3(0, 5.7, -12), C_STONE_DARK, false)
	# Pitched keep roof
	_box(Vector3(7.0, 0.28, 3.5), Vector3(0, 6.1, -12), C_STONE_ROOF, false, Vector3(0, 0, 30))
	_box(Vector3(7.0, 0.28, 3.5), Vector3(0, 6.1, -12), Color(0.30, 0.26, 0.26), false, Vector3(0, 0, -30))
	# Corner towers
	_box(Vector3(1.5, 1.8, 1.5), Vector3(-2.4, 6.5, -12), C_STONE_DARK, false)
	_box(Vector3(1.5, 1.8, 1.5), Vector3(2.4, 6.5, -12), C_STONE_DARK, false)
	# Clearer banner + CoA plate on keep face (toward settlement)
	_box(Vector3(0.08, 2.6, 1.0), Vector3(0, 7.2, -8.9), C_BANNER, false)
	# Pole
	_box(Vector3(0.1, 3.2, 0.1), Vector3(0, 7.4, -9.05), Color(0.25, 0.22, 0.18), false)
	# CoA plate on keep wall (readable from strategy cam)
	_box(Vector3(1.4, 1.6, 0.12), Vector3(0, 3.4, -9.05), C_BANNER, false)
	_box(Vector3(0.7, 0.7, 0.08), Vector3(0, 3.5, -8.95), C_BANNER_ACCENT, false)
	# Keep yard / muster - lighter than road
	_box(Vector3(11, 0.06, 9), Vector3(0, 0.03, -7), C_YARD, false)
	if muster_point:
		muster_point.position = Vector3(0, 0.1, -7)

func _add_market() -> void:
	_box(Vector3(8.5, 0.08, 8.5), Vector3(8, 0.04, 2), C_MARKET, false)
	# Stall body + roof
	_box(Vector3(2.5, 1.05, 2.1), Vector3(8, 0.55, 2), C_STALL, false)
	_box(Vector3(3.0, 0.18, 1.2), Vector3(8, 1.25, 2), Color(0.48, 0.22, 0.16), false, Vector3(0, 0, 18))
	# Second small stall for market read
	_box(Vector3(1.8, 0.9, 1.5), Vector3(10.2, 0.5, 0.5), Color(0.50, 0.36, 0.26), false)
	_box(Vector3(2.1, 0.14, 0.9), Vector3(10.2, 1.05, 0.5), Color(0.40, 0.24, 0.18), false, Vector3(0, 0, -15))

func _add_houses() -> void:
	# Varied footprints + roof tints (10 houses)
	var house_defs := [
		{"pos": Vector3(-6, 0, -3), "w": 3.2, "d": 2.8, "h": 2.3, "wall": C_WALL_A, "roof": C_ROOF_A},
		{"pos": Vector3(-10, 0, 1), "w": 2.4, "d": 2.2, "h": 1.8, "wall": C_WALL_B, "roof": C_ROOF_B},
		{"pos": Vector3(-5, 0, 5), "w": 2.8, "d": 2.4, "h": 2.0, "wall": C_WALL_C, "roof": C_ROOF_C},
		{"pos": Vector3(7, 0, -4), "w": 3.0, "d": 2.6, "h": 2.15, "wall": C_WALL_A, "roof": C_ROOF_D},
		{"pos": Vector3(12, 0, 0), "w": 2.6, "d": 3.0, "h": 1.9, "wall": C_WALL_B, "roof": C_ROOF_A},
		{"pos": Vector3(9, 0, 6), "w": 2.5, "d": 2.3, "h": 2.05, "wall": C_WALL_C, "roof": C_ROOF_B},
		{"pos": Vector3(-11, 0, -7), "w": 3.4, "d": 2.5, "h": 2.4, "wall": C_WALL_A, "roof": C_ROOF_C},
		{"pos": Vector3(14, 0, -5), "w": 2.3, "d": 2.1, "h": 1.75, "wall": C_WALL_B, "roof": C_ROOF_D},
		{"pos": Vector3(-8, 0, 8), "w": 2.9, "d": 2.7, "h": 2.1, "wall": C_WALL_C, "roof": C_ROOF_A},
		{"pos": Vector3(4, 0, 8), "w": 2.7, "d": 2.5, "h": 1.95, "wall": C_WALL_A, "roof": C_ROOF_B},
	]
	for i in house_defs.size():
		var d: Dictionary = house_defs[i]
		_house(d.pos, d.w, d.d, d.h, d.wall, d.roof, i % 3 == 0)
		house_spawns.append(d.pos + Vector3(0, 0.2, d.d * 0.5 + 0.8))

func _house(origin: Vector3, w: float, d: float, h: float, wall: Color, roof: Color, long_eave: bool) -> void:
	_box(Vector3(w, h, d), origin + Vector3(0, h * 0.5, 0), wall)
	var roof_y := h + 0.12
	var eave := 0.45 if long_eave else 0.3
	_box(Vector3(w + eave, 0.2, d * 0.55), origin + Vector3(0, roof_y, -d * 0.12), roof, false, Vector3(28, 0, 0))
	_box(Vector3(w + eave, 0.2, d * 0.55), origin + Vector3(0, roof_y, d * 0.12), roof, false, Vector3(-28, 0, 0))
	# Door accent
	_box(Vector3(0.5, 1.05, 0.08), origin + Vector3(0, 0.52, d * 0.5 + 0.02), C_DOOR, false)
	# Tiny window plate for silhouette
	_box(Vector3(0.35, 0.35, 0.06), origin + Vector3(w * 0.28, h * 0.55, d * 0.5 + 0.02), Color(0.45, 0.50, 0.55), false)

func _add_farms() -> void:
	var farms := [
		{"pos": Vector3(-16, 0, 6), "crop": C_FIELD_CROP},
		{"pos": Vector3(-18, 0, -2), "crop": Color(0.44, 0.36, 0.20)},
		{"pos": Vector3(18, 0, 8), "crop": Color(0.36, 0.40, 0.22)},
	]
	for f in farms:
		_farm(f.pos, f.crop)
		farm_spawns.append(f.pos + Vector3(0, 0.2, 0))

func _farm(origin: Vector3, crop: Color) -> void:
	# Soil base + crop tint - not pale green rectangles
	_box(Vector3(6.8, 0.05, 5.4), origin + Vector3(0, 0.025, 0), C_FIELD_SOIL, false)
	_box(Vector3(6.2, 0.06, 4.8), origin + Vector3(0, 0.055, 0), crop, false)
	# Furrow lines - thin darker strips across field
	for i in range(5):
		var z := -1.8 + i * 0.9
		_box(Vector3(5.8, 0.04, 0.12), origin + Vector3(0, 0.08, z), C_FURROW, false)
	# Shed
	_box(Vector3(1.6, 1.2, 1.6), origin + Vector3(-2.0, 0.6, -1.6), Color(0.48, 0.38, 0.28))
	_box(Vector3(1.9, 0.16, 1.0), origin + Vector3(-2.0, 1.3, -1.6), C_ROOF_B, false, Vector3(0, 0, 22))
	# Fence posts
	var posts := [
		Vector3(-3.1, 0.4, -2.4), Vector3(3.1, 0.4, -2.4),
		Vector3(-3.1, 0.4, 2.4), Vector3(3.1, 0.4, 2.4),
		Vector3(0.0, 0.4, -2.4), Vector3(0.0, 0.4, 2.4),
	]
	for p in posts:
		_box(Vector3(0.12, 0.8, 0.12), origin + p, Color(0.34, 0.26, 0.18), false)

func _add_trees() -> void:
	var spots := [
		Vector3(-22, 0, -10), Vector3(22, 0, -14), Vector3(-20, 0, 14),
		Vector3(20, 0, 16), Vector3(0, 0, 20), Vector3(-24, 0, 4),
		Vector3(24, 0, -4), Vector3(-12, 0, 16),
	]
	for i in spots.size():
		_tree(spots[i], 0.9 + (i % 3) * 0.15)

func _tree(origin: Vector3, scale: float = 1.0) -> void:
	# Trunk (cylinder) + layered canopy blobs
	_cyl(0.22 * scale, 1.5 * scale, origin + Vector3(0, 0.75 * scale, 0), C_TRUNK, false)
	_box(Vector3(1.6 * scale, 1.1 * scale, 1.6 * scale), origin + Vector3(0, 1.9 * scale, 0), C_CANOPY_A, false)
	_box(Vector3(1.2 * scale, 0.9 * scale, 1.2 * scale), origin + Vector3(0.25 * scale, 2.5 * scale, -0.15 * scale), C_CANOPY_B, false)
	_box(Vector3(1.0 * scale, 0.7 * scale, 1.0 * scale), origin + Vector3(-0.2 * scale, 2.9 * scale, 0.1 * scale), C_CANOPY_C, false)

func _add_sun() -> void:
	var light := DirectionalLight3D.new()
	light.name = "Sun"
	light.rotation_degrees = Vector3(-48, 40, 0)
	light.light_energy = 0.78
	light.light_color = Color(1.0, 0.94, 0.82)
	light.shadow_enabled = true
	add_child(light)

func _add_environment() -> void:
	var we := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.52, 0.60, 0.68)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.48, 0.50, 0.46)
	env.ambient_light_energy = 0.55
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	# Soft fog / horizon wash
	env.fog_enabled = true
	env.fog_light_color = Color(0.58, 0.62, 0.66)
	env.fog_density = 0.0045
	env.fog_aerial_perspective = 0.35
	env.fog_sky_affect = 0.6
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
