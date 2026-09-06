extends CanvasLayer
const _CouncilDataScript = preload("res://data/council.gd")
## CK3-like UI shell: top bar, outliner, side panel, bottom speed/alerts.
## Mouse: panels STOP clicks; empty center IGNORE so the 3D map receives picks.
## Selection bus: select_holding / select_character / select_army (map + outliner).

signal raise_levy_pressed
signal go_to_pressed(target: Node)

enum SelKind { NONE, HOLDING, CHARACTER, ARMY }

var camera_rig: Node3D
var army: Node3D
var muster: Node
var settlement: Node3D

var selected: Node = null
var sel_kind: SelKind = SelKind.NONE
var _last_army_count: int = -1
var _last_people_count: int = -1

var _root: Control
var _outliner: PanelContainer
var _side: PanelContainer
var _holdings_box: VBoxContainer
var _people_box: VBoxContainer
var _armies_box: VBoxContainer
var _vassals_box: VBoxContainer
var _factions_box: VBoxContainer
var _side_title: Label
var _side_body: Label
var _side_extra: Label
var _holding_levy_label: Label
var _raise_btn: Button
var _goto_btn: Button
var _move_hint: Label
var _date_label: Label
var _gold_label: Label
var _prestige_label: Label
var _piety_label: Label
var _lifestyle_label: Label
var _dynasty_label: Label
var _alert_label: Label
var _counts_label: Label
var _zoom_label: Label
var _pause_btn: Button
var _speed1_btn: Button
var _speed2_btn: Button

var _panel_style: StyleBoxFlat
var _bar_style: StyleBoxFlat
var _btn_style: StyleBoxFlat
var _row_style: StyleBoxFlat
var _row_selected_style: StyleBoxFlat
var _modal_style: StyleBoxFlat

var _holding_panel: VBoxContainer
var _character_panel: VBoxContainer
var _army_panel: VBoxContainer
var _realm_panel: VBoxContainer
var _realm_body: Label
var _char_body: Label
var _char_traits: Label
var _char_education: Label
var _char_skills: Label
var _char_dynasty: Label
var _army_body: Label

var _stub_modal: PanelContainer
var _stub_modal_title: Label
var _stub_modal_body: Label

var _council_modal: PanelContainer
var _council_liege: Label
var _council_rows: VBoxContainer

var _military_modal: PanelContainer
var _military_levy_label: Label
var _military_marshal_label: Label

var _decisions_modal: PanelContainer
var _decisions_rows: VBoxContainer

func _ready() -> void:
	_build_styles()
	_build_ui()
	_show_panel(SelKind.NONE)
	_populate_realm()
	set_status("Ready")

func bind(camera: Node3D, army_node: Node3D, muster_node: Node, settlement_node: Node3D = null) -> void:
	camera_rig = camera
	army = army_node
	muster = muster_node
	settlement = settlement_node
	_refresh_outliner()
	_populate_realm()

func set_status(text: String) -> void:
	if _alert_label:
		_alert_label.text = text

func clear_selection() -> void:
	selected = null
	sel_kind = SelKind.NONE
	_populate_realm()
	_show_panel(SelKind.NONE)
	_refresh_outliner()

func select_holding(node: Node) -> void:
	selected = node
	sel_kind = SelKind.HOLDING
	_populate_holding(node)
	_show_panel(SelKind.HOLDING)
	_refresh_outliner()

func select_character(node: Node) -> void:
	selected = node
	sel_kind = SelKind.CHARACTER
	_populate_character(node)
	_show_panel(SelKind.CHARACTER)
	_refresh_outliner()

func select_army(node: Node) -> void:
	selected = node
	sel_kind = SelKind.ARMY
	_populate_army(node)
	_show_panel(SelKind.ARMY)
	_refresh_outliner()

func refresh_outliner() -> void:
	_refresh_outliner()

func _process(_delta: float) -> void:
	_refresh_top()
	_refresh_counts()
	_maybe_dim_outliner()
	var army_n := 0
	if army and army.has_method("get_count"):
		army_n = army.get_count()
	var people_n := GameData.count_people() if is_instance_valid(GameData) else 0
	if army_n != _last_army_count or people_n != _last_people_count:
		_last_army_count = army_n
		_last_people_count = people_n
		_refresh_outliner()
		if sel_kind == SelKind.NONE:
			_populate_realm()
	if _military_modal and _military_modal.visible:
		_refresh_military_levy()
	if sel_kind == SelKind.ARMY:
		_populate_army(army if army else selected)
	elif sel_kind == SelKind.HOLDING:
		_update_raise_enabled()
		_update_holding_levy_line()

func _build_styles() -> void:
	_panel_style = StyleBoxFlat.new()
	_panel_style.bg_color = Color(0.14, 0.12, 0.10, 0.94)
	_panel_style.border_color = Color(0.42, 0.38, 0.32, 1.0)
	_panel_style.set_border_width_all(2)
	_panel_style.set_corner_radius_all(4)
	_panel_style.content_margin_left = 10
	_panel_style.content_margin_right = 10
	_panel_style.content_margin_top = 8
	_panel_style.content_margin_bottom = 8

	_bar_style = StyleBoxFlat.new()
	_bar_style.bg_color = Color(0.12, 0.11, 0.10, 0.96)
	_bar_style.border_color = Color(0.35, 0.40, 0.45, 1.0)
	_bar_style.set_border_width_all(1)
	_bar_style.set_corner_radius_all(2)
	_bar_style.content_margin_left = 12
	_bar_style.content_margin_right = 12
	_bar_style.content_margin_top = 6
	_bar_style.content_margin_bottom = 6

	_btn_style = StyleBoxFlat.new()
	_btn_style.bg_color = Color(0.28, 0.24, 0.18, 1.0)
	_btn_style.border_color = Color(0.55, 0.48, 0.32, 1.0)
	_btn_style.set_border_width_all(1)
	_btn_style.set_corner_radius_all(3)
	_btn_style.content_margin_left = 10
	_btn_style.content_margin_right = 10
	_btn_style.content_margin_top = 4
	_btn_style.content_margin_bottom = 4

	_row_style = StyleBoxFlat.new()
	_row_style.bg_color = Color(0.18, 0.16, 0.14, 0.0)
	_row_style.set_content_margin_all(4)

	_row_selected_style = StyleBoxFlat.new()
	_row_selected_style.bg_color = Color(0.32, 0.28, 0.18, 0.85)
	_row_selected_style.border_color = Color(0.70, 0.58, 0.28, 1.0)
	_row_selected_style.set_border_width_all(1)
	_row_selected_style.set_corner_radius_all(2)
	_row_selected_style.set_content_margin_all(4)

	_modal_style = StyleBoxFlat.new()
	_modal_style.bg_color = Color(0.12, 0.11, 0.09, 0.97)
	_modal_style.border_color = Color(0.55, 0.48, 0.32, 1.0)
	_modal_style.set_border_width_all(2)
	_modal_style.set_corner_radius_all(6)
	_modal_style.content_margin_left = 16
	_modal_style.content_margin_right = 16
	_modal_style.content_margin_top = 12
	_modal_style.content_margin_bottom = 12

func _style_panel(p: PanelContainer, bar: bool = false) -> void:
	p.add_theme_stylebox_override("panel", _bar_style if bar else _panel_style)
	p.mouse_filter = Control.MOUSE_FILTER_STOP

func _style_button(b: Button) -> void:
	b.add_theme_stylebox_override("normal", _btn_style)
	var hover := _btn_style.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.38, 0.32, 0.22, 1.0)
	b.add_theme_stylebox_override("hover", hover)
	var pressed := _btn_style.duplicate() as StyleBoxFlat
	pressed.bg_color = Color(0.22, 0.18, 0.12, 1.0)
	b.add_theme_stylebox_override("pressed", pressed)
	b.add_theme_color_override("font_color", Color(0.92, 0.88, 0.75))

func _label(text: String, size: int = 14, color: Color = Color(0.90, 0.86, 0.78)) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	return l

func _section_header(text: String) -> Label:
	return _label(text, 13, Color(0.72, 0.68, 0.55))

func _build_ui() -> void:
	_root = Control.new()
	_root.name = "Root"
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)

	_build_top_bar()
	_build_outliner()
	_build_side_panel()
	_build_bottom_bar()
	_build_stub_modal()
	_build_council_window()
	_build_military_window()
	_build_decisions_window()

func _build_top_bar() -> void:
	var top := PanelContainer.new()
	top.name = "TopBar"
	_style_panel(top, true)
	top.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top.offset_left = 8
	top.offset_top = 8
	top.offset_right = -8
	top.offset_bottom = 78
	_root.add_child(top)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 4)
	top.add_child(col)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 18)
	col.add_child(row)

	_date_label = _label("1066.9.15", 16, Color(0.95, 0.90, 0.70))
	row.add_child(_date_label)

	row.add_child(_sep())
	_gold_label = _label("Gold: 0", 14, Color(0.95, 0.82, 0.35))
	row.add_child(_gold_label)
	_prestige_label = _label("Prestige: 0", 14, Color(0.75, 0.85, 0.95))
	row.add_child(_prestige_label)
	_piety_label = _label("Piety: 0", 14, Color(0.85, 0.75, 0.95))
	row.add_child(_piety_label)

	row.add_child(_sep())
	_lifestyle_label = _label("Lifestyle: Stewardship (stub)", 13, Color(0.70, 0.78, 0.72))
	row.add_child(_lifestyle_label)

	row.add_child(_sep())
	_dynasty_label = _label("Dynasty", 15, Color(0.95, 0.85, 0.45))
	row.add_child(_dynasty_label)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(spacer)

	_counts_label = _label("People: 0   Army: 0", 13, Color(0.75, 0.72, 0.65))
	row.add_child(_counts_label)
	_zoom_label = _label("Zoom: Strategy", 13, Color(0.65, 0.70, 0.75))
	row.add_child(_zoom_label)

	var icons := HBoxContainer.new()
	icons.name = "IconRow"
	icons.add_theme_constant_override("separation", 6)
	col.add_child(icons)

	var stub_names: PackedStringArray = PackedStringArray([
		"Realm", "Military", "Council", "Court", "Intrigue", "Decisions"
	])
	for n in stub_names:
		var b := Button.new()
		b.text = str(n)
		var title_name: String = str(n)
		var is_live: bool = title_name == "Council" or title_name == "Military" or title_name == "Decisions"
		if is_live:
			b.tooltip_text = title_name
		else:
			b.tooltip_text = "%s — Coming" % title_name
		_style_button(b)
		b.custom_minimum_size = Vector2(78, 0)
		b.pressed.connect(func() -> void: _open_stub_window(title_name))
		icons.add_child(b)

func _sep() -> Label:
	return _label("|", 14, Color(0.45, 0.42, 0.38))

func _build_outliner() -> void:
	_outliner = PanelContainer.new()
	_outliner.name = "Outliner"
	_style_panel(_outliner)
	_outliner.set_anchors_preset(Control.PRESET_LEFT_WIDE)
	_outliner.offset_left = 8
	_outliner.offset_top = 86
	_outliner.offset_right = 220
	_outliner.offset_bottom = -56
	_root.add_child(_outliner)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 4)
	margin.add_theme_constant_override("margin_right", 4)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_bottom", 4)
	_outliner.add_child(margin)

	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(scroll)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 6)
	scroll.add_child(vbox)

	vbox.add_child(_label("OUTLINER", 14, Color(0.85, 0.78, 0.55)))

	vbox.add_child(_section_header("Holdings"))
	_holdings_box = VBoxContainer.new()
	_holdings_box.add_theme_constant_override("separation", 2)
	vbox.add_child(_holdings_box)

	vbox.add_child(_section_header("Vassals"))
	_vassals_box = VBoxContainer.new()
	_vassals_box.add_theme_constant_override("separation", 2)
	vbox.add_child(_vassals_box)
	_vassals_box.add_child(_label("None", 12, Color(0.55, 0.52, 0.48)))

	vbox.add_child(_section_header("People"))
	_people_box = VBoxContainer.new()
	_people_box.add_theme_constant_override("separation", 2)
	vbox.add_child(_people_box)

	vbox.add_child(_section_header("Armies"))
	_armies_box = VBoxContainer.new()
	_armies_box.add_theme_constant_override("separation", 2)
	vbox.add_child(_armies_box)

	vbox.add_child(_section_header("Factions"))
	_factions_box = VBoxContainer.new()
	_factions_box.add_theme_constant_override("separation", 2)
	vbox.add_child(_factions_box)
	_factions_box.add_child(_label("None", 12, Color(0.55, 0.52, 0.48)))

func _build_side_panel() -> void:
	_side = PanelContainer.new()
	_side.name = "SidePanel"
	_style_panel(_side)
	_side.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
	_side.offset_left = -300
	_side.offset_top = 86
	_side.offset_right = -8
	_side.offset_bottom = -56
	_root.add_child(_side)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 6)
	margin.add_theme_constant_override("margin_right", 6)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_bottom", 4)
	_side.add_child(margin)

	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 8)
	margin.add_child(stack)

	_side_title = _label("Realm", 16, Color(0.95, 0.90, 0.70))
	stack.add_child(_side_title)

	# Realm (no selection)
	_realm_panel = VBoxContainer.new()
	_realm_panel.add_theme_constant_override("separation", 6)
	stack.add_child(_realm_panel)
	_realm_panel.add_child(_section_header("Realm"))
	_realm_body = _label("", 14)
	_realm_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_realm_panel.add_child(_realm_body)
	_realm_panel.add_child(_label("Select a holding, person, or army\non the map or outliner.", 12, Color(0.60, 0.58, 0.52)))

	# Holding
	_holding_panel = VBoxContainer.new()
	_holding_panel.add_theme_constant_override("separation", 6)
	stack.add_child(_holding_panel)
	_holding_panel.add_child(_section_header("Holding"))
	_side_body = _label("Ashford", 14)
	_side_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_holding_panel.add_child(_side_body)
	_side_extra = _label("Buildings:\n- Keep\n- Market\n- Houses\n- Farms", 13, Color(0.78, 0.74, 0.66))
	_side_extra.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_holding_panel.add_child(_side_extra)
	_holding_levy_label = _label("Available levy: —", 13, Color(0.80, 0.78, 0.62))
	_holding_levy_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_holding_panel.add_child(_holding_levy_label)
	_raise_btn = Button.new()
	_raise_btn.text = "Raise Levy"
	_style_button(_raise_btn)
	_raise_btn.pressed.connect(func() -> void: raise_levy_pressed.emit())
	_holding_panel.add_child(_raise_btn)

	# Character
	_character_panel = VBoxContainer.new()
	_character_panel.add_theme_constant_override("separation", 6)
	stack.add_child(_character_panel)
	_character_panel.add_child(_section_header("Character"))
	_char_body = _label("", 14)
	_char_body.name = "CharBody"
	_char_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_character_panel.add_child(_char_body)
	_char_dynasty = _label("", 13, Color(0.95, 0.85, 0.45))
	_char_dynasty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_character_panel.add_child(_char_dynasty)
	_char_traits = _label("Personality: -", 13, Color(0.78, 0.74, 0.66))
	_char_traits.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_character_panel.add_child(_char_traits)
	_char_education = _label("Education: -", 13, Color(0.78, 0.74, 0.66))
	_char_education.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_character_panel.add_child(_char_education)
	_char_skills = _label("Skills: -", 12, Color(0.72, 0.78, 0.82))
	_char_skills.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_character_panel.add_child(_char_skills)
	_goto_btn = Button.new()
	_goto_btn.text = "Go to"
	_style_button(_goto_btn)
	_goto_btn.pressed.connect(_on_goto)
	_character_panel.add_child(_goto_btn)

	# Army
	_army_panel = VBoxContainer.new()
	_army_panel.add_theme_constant_override("separation", 6)
	stack.add_child(_army_panel)
	_army_panel.add_child(_section_header("Army"))
	_army_body = _label("", 14)
	_army_body.name = "ArmyBody"
	_army_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_army_panel.add_child(_army_body)
	_move_hint = _label("Right-click map to move", 13, Color(0.70, 0.85, 0.70))
	_move_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_army_panel.add_child(_move_hint)

func _build_stub_modal() -> void:
	_stub_modal = PanelContainer.new()
	_stub_modal.name = "StubModal"
	_stub_modal.add_theme_stylebox_override("panel", _modal_style)
	_stub_modal.mouse_filter = Control.MOUSE_FILTER_STOP
	_stub_modal.visible = false
	_stub_modal.set_anchors_preset(Control.PRESET_CENTER)
	_stub_modal.offset_left = -180
	_stub_modal.offset_top = -90
	_stub_modal.offset_right = 180
	_stub_modal.offset_bottom = 90
	_root.add_child(_stub_modal)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	_stub_modal.add_child(v)

	_stub_modal_title = _label("Window", 18, Color(0.95, 0.90, 0.70))
	v.add_child(_stub_modal_title)
	_stub_modal_body = _label("Coming", 14, Color(0.78, 0.74, 0.66))
	_stub_modal_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(_stub_modal_body)

	var close_btn := Button.new()
	close_btn.text = "Close"
	_style_button(close_btn)
	close_btn.pressed.connect(_close_stub_window)
	v.add_child(close_btn)

func _open_stub_window(title_text: String) -> void:
	if title_text == "Council":
		_open_council_window()
		return
	if title_text == "Military":
		_open_military_window()
		return
	if title_text == "Decisions":
		_open_decisions_window()
		return
	if _stub_modal == null:
		return
	if _council_modal:
		_council_modal.visible = false
	if _military_modal:
		_military_modal.visible = false
	if _decisions_modal:
		_decisions_modal.visible = false
	_stub_modal_title.text = title_text
	_stub_modal_body.text = "Coming — %s window stub (Horizon B)." % title_text
	_stub_modal.visible = true
	set_status("%s (Coming)" % title_text)

func _close_stub_window() -> void:
	if _stub_modal:
		_stub_modal.visible = false

func _build_council_window() -> void:
	_council_modal = PanelContainer.new()
	_council_modal.name = "CouncilModal"
	_council_modal.add_theme_stylebox_override("panel", _modal_style)
	_council_modal.mouse_filter = Control.MOUSE_FILTER_STOP
	_council_modal.visible = false
	_council_modal.set_anchors_preset(Control.PRESET_CENTER)
	_council_modal.offset_left = -260
	_council_modal.offset_top = -200
	_council_modal.offset_right = 260
	_council_modal.offset_bottom = 200
	_root.add_child(_council_modal)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	_council_modal.add_child(v)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	v.add_child(header)
	header.add_child(_label("Council", 18, Color(0.95, 0.90, 0.70)))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_child(spacer)
	var close_btn := Button.new()
	close_btn.text = "Close"
	_style_button(close_btn)
	close_btn.pressed.connect(_close_council_window)
	header.add_child(close_btn)

	_council_liege = _label("Liege: —", 13, Color(0.75, 0.80, 0.70))
	_council_liege.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(_council_liege)

	var col_hdr := HBoxContainer.new()
	col_hdr.add_theme_constant_override("separation", 8)
	v.add_child(col_hdr)
	var job_h := _label("Job", 12, Color(0.72, 0.68, 0.55))
	job_h.custom_minimum_size = Vector2(120, 0)
	col_hdr.add_child(job_h)
	var name_h := _label("Appointee", 12, Color(0.72, 0.68, 0.55))
	name_h.custom_minimum_size = Vector2(150, 0)
	name_h.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col_hdr.add_child(name_h)
	var task_h := _label("Task", 12, Color(0.72, 0.68, 0.55))
	task_h.custom_minimum_size = Vector2(130, 0)
	col_hdr.add_child(task_h)

	_council_rows = VBoxContainer.new()
	_council_rows.name = "CouncilRows"
	_council_rows.add_theme_constant_override("separation", 4)
	v.add_child(_council_rows)

	v.add_child(_label("Click a councillor to open their dossier.", 11, Color(0.55, 0.52, 0.48)))

func _open_council_window() -> void:
	if _council_modal == null:
		_build_council_window()
	if _stub_modal:
		_stub_modal.visible = false
	if _military_modal:
		_military_modal.visible = false
	if _decisions_modal:
		_decisions_modal.visible = false
	_refresh_council_rows()
	_council_modal.visible = true
	set_status("Council")

func _close_council_window() -> void:
	if _council_modal:
		_council_modal.visible = false

func _refresh_council_rows() -> void:
	if _council_rows == null:
		return
	_clear_box(_council_rows)

	# Liege header from ruler group
	var liege_name := "—"
	var rulers: Array = get_tree().get_nodes_in_group("ruler")
	if rulers.size() > 0 and is_instance_valid(rulers[0]):
		liege_name = _CouncilDataScript.person_display_name(rulers[0])
		if liege_name.is_empty():
			liege_name = str(rulers[0].name)
	if _council_liege:
		_council_liege.text = "Liege: %s" % liege_name

	for job in _CouncilDataScript.job_defs():
		var job_label: String = str(job.get("label", "Job"))
		var task_label: String = str(job.get("task", "—"))
		var appointee: Node = _CouncilDataScript.resolve_appointee(get_tree(), job)
		var appointee_name := "Vacant"
		var has_appointee: bool = false
		if appointee != null and is_instance_valid(appointee):
			has_appointee = true
			appointee_name = _CouncilDataScript.person_display_name(appointee)
			if appointee_name.is_empty():
				appointee_name = str(appointee.name)

		var row := Button.new()
		row.alignment = HORIZONTAL_ALIGNMENT_LEFT
		row.text = "%s   |   %s   |   %s" % [job_label, appointee_name, task_label]
		row.tooltip_text = "%s — %s (%s)" % [job_label, appointee_name, task_label]
		_style_button(row)
		if has_appointee:
			var captured: Node = appointee
			row.pressed.connect(func() -> void:
				select_character(captured)
				set_status("Council -> %s" % _CouncilDataScript.person_display_name(captured))
			)
		else:
			row.disabled = true
		_council_rows.add_child(row)


func _build_military_window() -> void:
	_military_modal = PanelContainer.new()
	_military_modal.name = "MilitaryModal"
	_military_modal.add_theme_stylebox_override("panel", _modal_style)
	_military_modal.mouse_filter = Control.MOUSE_FILTER_STOP
	_military_modal.visible = false
	_military_modal.set_anchors_preset(Control.PRESET_CENTER)
	_military_modal.offset_left = -280
	_military_modal.offset_top = -240
	_military_modal.offset_right = 280
	_military_modal.offset_bottom = 240
	_root.add_child(_military_modal)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	_military_modal.add_child(v)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	v.add_child(header)
	header.add_child(_label("Military", 18, Color(0.95, 0.90, 0.70)))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_child(spacer)
	var close_btn := Button.new()
	close_btn.text = "Close"
	_style_button(close_btn)
	close_btn.pressed.connect(_close_military_window)
	header.add_child(close_btn)

	_military_marshal_label = _label("Marshal: Captain Rhea (stub)", 13, Color(0.75, 0.80, 0.70))
	v.add_child(_military_marshal_label)

	v.add_child(_section_header("Levies"))
	_military_levy_label = _label("Raised: 0", 14, Color(0.90, 0.86, 0.78))
	v.add_child(_military_levy_label)
	var levy_hint := _label(
		"Raise Levy from the Holding panel. When the army is selected, RMB the map to move.",
		11,
		Color(0.55, 0.52, 0.48)
	)
	levy_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(levy_hint)

	v.add_child(_section_header("Men-at-Arms (stub)"))
	var maa_hdr := HBoxContainer.new()
	maa_hdr.add_theme_constant_override("separation", 8)
	v.add_child(maa_hdr)
	var type_h := _label("Regiment", 12, Color(0.72, 0.68, 0.55))
	type_h.custom_minimum_size = Vector2(140, 0)
	maa_hdr.add_child(type_h)
	var size_h := _label("Size", 12, Color(0.72, 0.68, 0.55))
	size_h.custom_minimum_size = Vector2(60, 0)
	maa_hdr.add_child(size_h)
	var act_h := _label("Recruit", 12, Color(0.72, 0.68, 0.55))
	act_h.custom_minimum_size = Vector2(100, 0)
	maa_hdr.add_child(act_h)

	var maa_types: PackedStringArray = PackedStringArray(["Bowmen", "Spearmen", "Light Horse"])
	for maa_name in maa_types:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		v.add_child(row)
		var name_l := _label(str(maa_name), 13, Color(0.90, 0.86, 0.78))
		name_l.custom_minimum_size = Vector2(140, 0)
		row.add_child(name_l)
		var size_l := _label("0", 13, Color(0.78, 0.74, 0.66))
		size_l.custom_minimum_size = Vector2(60, 0)
		row.add_child(size_l)
		var recruit := Button.new()
		recruit.text = "Coming"
		recruit.disabled = true
		recruit.tooltip_text = "Coming"
		_style_button(recruit)
		recruit.custom_minimum_size = Vector2(100, 0)
		row.add_child(recruit)

	var maa_note := _label(
		"MaA sizes stay at 0 until recruited onto the map. Levies are the only raised troops.",
		11,
		Color(0.55, 0.52, 0.48)
	)
	maa_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(maa_note)

func _open_military_window() -> void:
	if _military_modal == null:
		_build_military_window()
	if _stub_modal:
		_stub_modal.visible = false
	if _council_modal:
		_council_modal.visible = false
	if _decisions_modal:
		_decisions_modal.visible = false
	_refresh_military_levy()
	_military_modal.visible = true
	set_status("Military")

func _close_military_window() -> void:
	if _military_modal:
		_military_modal.visible = false

func _refresh_military_levy() -> void:
	if _military_levy_label == null:
		return
	var count: int = 0
	if army and army.has_method("get_count"):
		count = int(army.get_count())
	else:
		count = get_tree().get_nodes_in_group("soldiers").size()
	_military_levy_label.text = "Raised: %d (on map)" % count

func _build_decisions_window() -> void:
	_decisions_modal = PanelContainer.new()
	_decisions_modal.name = "DecisionsModal"
	_decisions_modal.add_theme_stylebox_override("panel", _modal_style)
	_decisions_modal.mouse_filter = Control.MOUSE_FILTER_STOP
	_decisions_modal.visible = false
	_decisions_modal.set_anchors_preset(Control.PRESET_CENTER)
	_decisions_modal.offset_left = -260
	_decisions_modal.offset_top = -200
	_decisions_modal.offset_right = 260
	_decisions_modal.offset_bottom = 200
	_root.add_child(_decisions_modal)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	_decisions_modal.add_child(v)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	v.add_child(header)
	header.add_child(_label("Decisions", 18, Color(0.95, 0.90, 0.70)))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_child(spacer)
	var close_btn := Button.new()
	close_btn.text = "Close"
	_style_button(close_btn)
	close_btn.pressed.connect(_close_decisions_window)
	header.add_child(close_btn)

	v.add_child(_label("Personal decisions (panel stub — no map bodies).", 11, Color(0.55, 0.52, 0.48)))

	_decisions_rows = VBoxContainer.new()
	_decisions_rows.name = "DecisionsRows"
	_decisions_rows.add_theme_constant_override("separation", 6)
	v.add_child(_decisions_rows)

	_add_decision_row("Hold Court", "Grant audiences; small opinion bump for councillors.", true, _on_hold_court)
	_add_decision_row("Host Feast", "Spend a little gold to host a feast (toast stub).", true, _on_host_feast)
	_add_decision_row("Invite Knights", "Coming", false, Callable())
	_add_decision_row("Send Gift", "Coming", false, Callable())

func _add_decision_row(title_text: String, hint: String, enabled: bool, on_press: Callable) -> void:
	if _decisions_rows == null:
		return
	var row := Button.new()
	row.alignment = HORIZONTAL_ALIGNMENT_LEFT
	if enabled:
		row.text = title_text
		row.tooltip_text = hint
		row.disabled = false
		if on_press.is_valid():
			row.pressed.connect(on_press)
	else:
		row.text = "%s — Coming" % title_text
		row.tooltip_text = "Coming"
		row.disabled = true
	_style_button(row)
	_decisions_rows.add_child(row)

func _open_decisions_window() -> void:
	if _decisions_modal == null:
		_build_decisions_window()
	if _stub_modal:
		_stub_modal.visible = false
	if _council_modal:
		_council_modal.visible = false
	if _military_modal:
		_military_modal.visible = false
	_decisions_modal.visible = true
	set_status("Decisions")

func _close_decisions_window() -> void:
	if _decisions_modal:
		_decisions_modal.visible = false

func _on_hold_court() -> void:
	var bumped: int = 0
	for job in _CouncilDataScript.job_defs():
		var appointee: Node = _CouncilDataScript.resolve_appointee(get_tree(), job)
		if appointee == null or not is_instance_valid(appointee):
			continue
		if "opinion" in appointee:
			var cur: int = int(appointee.opinion)
			appointee.opinion = clampi(cur + 2, 0, 100)
			bumped += 1
	if sel_kind == SelKind.CHARACTER and selected != null and is_instance_valid(selected):
		_populate_character(selected)
	if bumped > 0:
		set_status("Held court — councillor opinion +2 (%d)." % bumped)
	else:
		set_status("Held court — no councillors to impress.")

func _on_host_feast() -> void:
	var cost: int = 10
	if is_instance_valid(GameData):
		if GameData.gold >= cost:
			GameData.gold -= cost
			set_status("Hosted a feast (-%d gold)." % cost)
		else:
			set_status("Hosted a feast (not enough gold for %d stub cost)." % cost)
	else:
		set_status("Hosted a feast.")

func _build_bottom_bar() -> void:
	var bottom := PanelContainer.new()
	bottom.name = "BottomBar"
	_style_panel(bottom, true)
	bottom.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bottom.offset_left = 8
	bottom.offset_top = -48
	bottom.offset_right = -8
	bottom.offset_bottom = -8
	_root.add_child(bottom)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	bottom.add_child(row)

	_pause_btn = Button.new()
	_pause_btn.text = "Pause"
	_style_button(_pause_btn)
	_pause_btn.pressed.connect(_on_pause)
	row.add_child(_pause_btn)

	_speed1_btn = Button.new()
	_speed1_btn.text = "1x"
	_style_button(_speed1_btn)
	_speed1_btn.pressed.connect(func() -> void: Engine.time_scale = 1.0)
	row.add_child(_speed1_btn)

	_speed2_btn = Button.new()
	_speed2_btn.text = "2x"
	_style_button(_speed2_btn)
	_speed2_btn.pressed.connect(func() -> void: Engine.time_scale = 2.0)
	row.add_child(_speed2_btn)

	row.add_child(_sep())

	_alert_label = _label("Ready", 13, Color(0.85, 0.80, 0.60))
	_alert_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(_alert_label)

func _show_panel(kind: SelKind) -> void:
	_holding_panel.visible = kind == SelKind.HOLDING
	_character_panel.visible = kind == SelKind.CHARACTER
	_army_panel.visible = kind == SelKind.ARMY
	_realm_panel.visible = kind == SelKind.NONE
	match kind:
		SelKind.HOLDING:
			_side_title.text = "Holding"
		SelKind.CHARACTER:
			_side_title.text = "Character"
		SelKind.ARMY:
			_side_title.text = "Army"
		_:
			_side_title.text = "Realm"

func _populate_realm() -> void:
	if _realm_body == null:
		return
	var title_name := "Baron of Ashford"
	var dynasty_name := "Ashford"
	var people_n := 0
	var army_n := 0
	if is_instance_valid(GameData):
		if GameData.title:
			title_name = str(GameData.title.name)
		if GameData.dynasty:
			dynasty_name = str(GameData.dynasty.name)
		people_n = GameData.count_people()
		army_n = GameData.count_army()
	var lines: PackedStringArray = PackedStringArray()
	lines.append("Title: %s" % title_name)
	lines.append("Dynasty: House %s" % dynasty_name)
	lines.append("People: %d" % people_n)
	lines.append("Army: %d" % army_n)
	_realm_body.text = "\n".join(lines)

func _populate_holding(node: Node) -> void:
	var data: Dictionary = {}
	if node and node.has_method("get_inspect_data"):
		data = node.get_inspect_data()
	var holding_name := str(data.get("name", "Ashford"))
	_side_body.text = holding_name
	var buildings: Array = data.get("buildings", ["Keep", "Market", "Houses", "Farms"])
	var lines: PackedStringArray = PackedStringArray(["Buildings:"])
	for b in buildings:
		lines.append("- %s" % str(b))
	_side_extra.text = "\n".join(lines)
	_update_holding_levy_line()
	_update_raise_enabled()

func _levy_limits() -> Vector2i:
	var min_l := 4
	var max_l := 8
	if muster:
		if "min_levy" in muster:
			min_l = int(muster.min_levy)
		if "max_levy" in muster:
			max_l = int(muster.max_levy)
	return Vector2i(min_l, max_l)

func _available_levy_estimate() -> int:
	var limits: Vector2i = _levy_limits()
	var max_l: int = limits.y
	var villagers := 0
	if is_instance_valid(GameData):
		villagers = GameData.count_villagers()
	else:
		villagers = get_tree().get_nodes_in_group("villagers").size()
	var army_n := 0
	if army and army.has_method("get_count"):
		army_n = army.get_count()
	var room: int = maxi(max_l - army_n, 0)
	return clampi(mini(villagers, room), 0, max_l)

func _update_holding_levy_line() -> void:
	if _holding_levy_label == null:
		return
	var limits: Vector2i = _levy_limits()
	var available: int = _available_levy_estimate()
	var villagers := 0
	if is_instance_valid(GameData):
		villagers = GameData.count_villagers()
	_holding_levy_label.text = "Available levy: ~%d  (villagers %d, capped %d–%d)" % [
		available, villagers, limits.x, limits.y
	]

func _update_raise_enabled() -> void:
	if _raise_btn == null:
		return
	var can: bool = false
	if muster and muster.has_method("can_muster"):
		can = muster.can_muster()
	_raise_btn.disabled = not can
	if can:
		_raise_btn.text = "Raise Levy"
		_raise_btn.tooltip_text = "Muster villagers into a levy"
		return
	var villagers := 0
	if is_instance_valid(GameData):
		villagers = GameData.count_villagers()
	else:
		villagers = get_tree().get_nodes_in_group("villagers").size()
	var army_n := 0
	if army and army.has_method("get_count"):
		army_n = army.get_count()
	var limits: Vector2i = _levy_limits()
	var reason := "unavailable"
	if villagers <= 0:
		reason = "No villagers left"
	elif army_n >= limits.y:
		reason = "Levy already mustered"
	elif army_n > 0:
		reason = "Levy already mustered"
	_raise_btn.text = "Raise Levy — %s" % reason
	_raise_btn.tooltip_text = reason

func _populate_character(node: Node) -> void:
	var data: Dictionary = {}
	if node and node.has_method("get_inspect_data"):
		data = node.get_inspect_data()
	var is_ruler: bool = false
	if node and node.is_in_group("ruler"):
		is_ruler = true
	elif str(data.get("kind", "")) == "ruler":
		is_ruler = true
	elif str(data.get("role", "")).to_lower().find("baron") >= 0:
		is_ruler = true

	if _char_body:
		var lines: PackedStringArray = PackedStringArray()
		lines.append(str(data.get("name", "Unknown")))
		lines.append("Role: %s" % str(data.get("role", "-")))
		if data.has("opinion"):
			lines.append("Opinion: %s" % str(data.get("opinion")))
		_char_body.text = "\n".join(lines)

	if _char_dynasty:
		if is_ruler and is_instance_valid(GameData):
			_char_dynasty.visible = true
			_char_dynasty.text = "Dynasty: House %s" % GameData.dynasty_chip()
		else:
			_char_dynasty.visible = false
			_char_dynasty.text = ""

	if _char_traits:
		_char_traits.text = str(data.get("traits_line", "Personality: -"))
	if _char_education:
		_char_education.text = str(data.get("education_line", "Education: -"))
	if _char_skills:
		_char_skills.text = str(data.get("skills_line", "Skills: -"))
func _populate_army(node: Node) -> void:
	var count := 0
	var army_node: Node = army if army else node
	if army_node and army_node.has_method("get_count"):
		count = army_node.get_count()
	elif army_node and army_node.has_method("get_inspect_data"):
		var d: Dictionary = army_node.get_inspect_data()
		count = int(d.get("count", 0))
	if _army_body:
		_army_body.text = "Ashford Levy\nSoldiers: %d\nCommander: Captain Rhea (stub)" % count
	if _move_hint:
		_move_hint.text = "Right-click map to move"

func _on_goto() -> void:
	if selected:
		go_to_pressed.emit(selected)

func _on_pause() -> void:
	if Engine.time_scale > 0.0:
		Engine.time_scale = 0.0
		_pause_btn.text = "Resume"
	else:
		Engine.time_scale = 1.0
		_pause_btn.text = "Pause"

func _refresh_top() -> void:
	if not is_instance_valid(GameData):
		return
	if _date_label:
		_date_label.text = GameData.date_string
	if _gold_label:
		_gold_label.text = "Gold: %d" % GameData.gold
	if _prestige_label:
		_prestige_label.text = "Prestige: %d" % GameData.prestige
	if _piety_label:
		_piety_label.text = "Piety: %d" % GameData.piety
	if _lifestyle_label:
		_lifestyle_label.text = "Lifestyle: Stewardship (stub)"
	if _dynasty_label:
		_dynasty_label.text = "House %s" % GameData.dynasty_chip()

func _refresh_counts() -> void:
	if _counts_label and is_instance_valid(GameData):
		_counts_label.text = "People: %d   Army: %d" % [GameData.count_people(), GameData.count_army()]
	if _zoom_label and camera_rig and camera_rig.has_method("get_zoom_label"):
		_zoom_label.text = "Zoom: %s" % camera_rig.get_zoom_label()

func _maybe_dim_outliner() -> void:
	if _outliner == null or camera_rig == null:
		return
	var street: bool = false
	if camera_rig.has_method("get_zoom_label"):
		street = camera_rig.get_zoom_label() == "Street"
	_outliner.modulate = Color(1, 1, 1, 0.45) if street else Color(1, 1, 1, 1)

func _clear_box(box: VBoxContainer) -> void:
	for c in box.get_children():
		c.queue_free()

func _make_row(text: String, selected_row: bool, on_press: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.flat = true
	b.add_theme_color_override("font_color", Color(0.90, 0.86, 0.78))
	b.add_theme_color_override("font_hover_color", Color(1.0, 0.95, 0.70))
	if selected_row:
		b.add_theme_stylebox_override("normal", _row_selected_style)
		b.add_theme_stylebox_override("hover", _row_selected_style)
	else:
		b.add_theme_stylebox_override("normal", _row_style)
	b.pressed.connect(on_press)
	return b

func _refresh_outliner() -> void:
	if _holdings_box == null:
		return
	_clear_box(_holdings_box)
	_clear_box(_people_box)
	_clear_box(_armies_box)

	# Holdings
	var hold_name := "Ashford"
	if settlement and settlement.has_method("get_inspect_data"):
		hold_name = str(settlement.get_inspect_data().get("name", "Ashford"))
	var hold_sel: bool = sel_kind == SelKind.HOLDING
	_holdings_box.add_child(_make_row(hold_name, hold_sel, func() -> void:
		if settlement:
			select_holding(settlement)
	))

	# People: ruler + named NPCs
	var people: Array = []
	people.append_array(get_tree().get_nodes_in_group("ruler"))
	people.append_array(get_tree().get_nodes_in_group("npcs"))
	for p in people:
		if p == null or not is_instance_valid(p):
			continue
		var pname := str(p.name)
		if "display_name" in p:
			pname = str(p.display_name)
		elif p.has_method("get_inspect_data"):
			pname = str(p.get_inspect_data().get("name", p.name))
		var is_sel: bool = sel_kind == SelKind.CHARACTER and selected == p
		var captured: Node = p
		_people_box.add_child(_make_row(pname, is_sel, func() -> void:
			select_character(captured)
		))

	# Armies if count > 0
	var army_count := 0
	if army and army.has_method("get_count"):
		army_count = army.get_count()
	if army_count > 0:
		var is_sel: bool = sel_kind == SelKind.ARMY
		_armies_box.add_child(_make_row("Ashford Levy (%d)" % army_count, is_sel, func() -> void:
			if army:
				select_army(army)
		))
	else:
		_armies_box.add_child(_label("(none mustered)", 12, Color(0.55, 0.52, 0.48)))