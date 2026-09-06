extends CanvasLayer
## HUD: dynasty/title, people & army counts from live nodes, muster, zoom, time scale.

@onready var dynasty_label: Label = %DynastyLabel
@onready var counts_label: Label = %CountsLabel
@onready var selected_label: Label = %SelectedLabel
@onready var zoom_label: Label = %ZoomLabel
@onready var status_label: Label = %StatusLabel
@onready var muster_button: Button = %MusterButton
@onready var pause_button: Button = %PauseButton
@onready var speed1_button: Button = %Speed1Button
@onready var speed2_button: Button = %Speed2Button

var camera_rig: Node3D
var army: Node3D
var muster: Node

signal muster_pressed

func _ready() -> void:
	if muster_button:
		muster_button.pressed.connect(func() -> void: muster_pressed.emit())
	if pause_button:
		pause_button.pressed.connect(_on_pause)
	if speed1_button:
		speed1_button.pressed.connect(func() -> void: Engine.time_scale = 1.0)
	if speed2_button:
		speed2_button.pressed.connect(func() -> void: Engine.time_scale = 2.0)

func bind(camera: Node3D, army_node: Node3D, muster_node: Node) -> void:
	camera_rig = camera
	army = army_node
	muster = muster_node

func set_status(text: String) -> void:
	if status_label:
		status_label.text = text

func set_selected(text: String) -> void:
	if selected_label:
		selected_label.text = text

func _process(_delta: float) -> void:
	_refresh()

func _refresh() -> void:
	if dynasty_label and is_instance_valid(GameData):
		dynasty_label.text = GameData.summary_line()
	# AC9: counts come from live groups / army list — never magic numbers.
	var people_n := GameData.count_people() if is_instance_valid(GameData) else 0
	var army_n := 0
	if army and army.has_method("get_count"):
		army_n = army.get_count()
	elif is_instance_valid(GameData):
		army_n = GameData.count_army()
	else:
		army_n = get_tree().get_nodes_in_group("soldiers").size()
	# Keep army HUD aligned with soldier nodes on the map.
	var soldiers_on_map := get_tree().get_nodes_in_group("soldiers").size()
	army_n = soldiers_on_map
	if counts_label:
		counts_label.text = "People: %d   Army: %d" % [people_n, army_n]
	if zoom_label and camera_rig and camera_rig.has_method("get_zoom_label"):
		zoom_label.text = "Zoom: %s (wheel)" % camera_rig.get_zoom_label()

func _on_pause() -> void:
	if Engine.time_scale > 0.0:
		Engine.time_scale = 0.0
	else:
		Engine.time_scale = 1.0