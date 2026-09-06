extends Node3D
## Builds a low-poly RimWorld-like county + settlement from CSG / simple meshes.

func build() -> void:
	_add_sun()
	_add_environment()
	_add_ground()
	_add_paths()
	_add_houses()
	_add_keep()
	_add_trees()
	_add_boundary_markers()

func _mat(color: Color, rough: float = 0.9) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = rough
	return m

func _box(parent: Node, size: Vector3, pos: Vector3, color: Color, static_body: bool = true) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mi.mesh = mesh
	mi.material_override = _mat(color)
	mi.position = pos
	parent.add_child(mi)
	if static_body:
		var body := StaticBody3D.new()
		var col := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = size
		col.shape = shape
		body.add_child(col)
		mi.add_child(body)
	return mi

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

func _add_ground() -> void:
	# Soft county green — continuous plane, not voxel cubes
	_box(self, Vector3(80, 1, 80), Vector3(0, -0.5, 0), Color(0.34, 0.52, 0.28))
	# Slight meadow patches
	_box(self, Vector3(18, 0.2, 12), Vector3(-18, 0.05, -14), Color(0.40, 0.58, 0.30), false)
	_box(self, Vector3(14, 0.2, 16), Vector3(20, 0.05, 10), Color(0.38, 0.55, 0.27), false)

func _add_paths() -> void:
	_box(self, Vector3(4, 0.12, 36), Vector3(0, 0.06, 2), Color(0.55, 0.42, 0.28), false)
	_box(self, Vector3(28, 0.12, 3.5), Vector3(2, 0.06, 0), Color(0.55, 0.42, 0.28), false)

func _add_houses() -> void:
	var spots := [
		Vector3(-6, 0, -4), Vector3(-10, 0, 2), Vector3(-5, 0, 6),
		Vector3(7, 0, -5), Vector3(11, 0, 1), Vector3(8, 0, 7),
		Vector3(-12, 0, -8), Vector3(14, 0, -3)
	]
	for i in spots.size():
		_house(spots[i], i % 2 == 0)

func _house(origin: Vector3, tall: bool) -> void:
	var h := 2.4 if tall else 2.0
	var w := 3.2 if tall else 2.6
	var d := 3.0 if tall else 2.4
	_box(self, Vector3(w, h, d), origin + Vector3(0, h * 0.5, 0), Color(0.62, 0.48, 0.32))
	# Roof prism-ish: flat low-poly roof slab
	_box(self, Vector3(w + 0.4, 0.35, d + 0.4), origin + Vector3(0, h + 0.2, 0), Color(0.45, 0.22, 0.18), false)

func _add_keep() -> void:
	_box(self, Vector3(5.5, 5.0, 5.5), Vector3(0, 2.5, -12), Color(0.48, 0.48, 0.52))
	_box(self, Vector3(6.2, 0.4, 6.2), Vector3(0, 5.2, -12), Color(0.35, 0.35, 0.4), false)
	_box(self, Vector3(1.6, 1.6, 1.6), Vector3(-2.2, 5.9, -12), Color(0.4, 0.4, 0.45), false)
	_box(self, Vector3(1.6, 1.6, 1.6), Vector3(2.2, 5.9, -12), Color(0.4, 0.4, 0.45), false)

func _add_trees() -> void:
	var pts := [
		Vector3(-22, 0, -10), Vector3(-25, 0, 5), Vector3(-18, 0, 16),
		Vector3(22, 0, -16), Vector3(26, 0, 4), Vector3(18, 0, 18),
		Vector3(-8, 0, 20), Vector3(6, 0, 22), Vector3(-28, 0, -20)
	]
	for p in pts:
		_tree(p)

func _tree(origin: Vector3) -> void:
	_box(self, Vector3(0.5, 1.6, 0.5), origin + Vector3(0, 0.8, 0), Color(0.4, 0.28, 0.16), false)
	_box(self, Vector3(2.2, 2.2, 2.2), origin + Vector3(0, 2.4, 0), Color(0.22, 0.42, 0.22), false)

func _add_boundary_markers() -> void:
	# Subtle county edge posts — regional readability when zoomed out
	for x in [-36, 36]:
		for z in [-36, 0, 36]:
			_box(self, Vector3(0.6, 2.5, 0.6), Vector3(x, 1.25, z), Color(0.7, 0.65, 0.45), false)
	for z in [-36, 36]:
		for x in [-18, 0, 18]:
			_box(self, Vector3(0.6, 2.5, 0.6), Vector3(x, 1.25, z), Color(0.7, 0.65, 0.45), false)
