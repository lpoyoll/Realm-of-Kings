extends CanvasLayer
const _CouncilDataScript = preload("res://data/council.gd")
## CK3-like UI shell: top bar, outliner, side panel, bottom speed/alerts.
## Visual chrome from res://ui/theme/ck3_theme.tres (Marissa density lock).
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

var _theme: Theme
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
var _gold_chip: PanelContainer
var _prestige_chip: PanelContainer
var _piety_chip: PanelContainer
var _lifestyle_chip: PanelContainer
var _dynasty_chip: PanelContainer
var _alert_label: Label
var _counts_label: Label
var _zoom_label: Label
var _pause_btn: Button
var _speed1_btn: Button
var _speed2_btn: Button

var _holding_panel: VBoxContainer
var _character_panel: VBoxContainer
var _army_panel: VBoxContainer
var _realm_panel: VBoxContainer
var _realm_body: Label
var _char_name: Label
var _char_role: Label
var _char_body: Label
var _char_education: Label
var _char_dynasty: Label
var _char_portrait: PanelContainer
var _trait_chips: HFlowContainer
var _skill_row: HBoxContainer
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
	_theme = Ck3Theme.get_theme()
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
	var army_n: int = 0
	if army and army.has_method("get_count"):
		army_n = int(army.get_count())
	var people_n: int = GameData.count_people() if is_instance_valid(GameData) else 0
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

func _label(text: String, variation: String = "BodyLabel") -> Label:
	return Ck3Theme.make_label(text, variation)

func _section_header(text: String) -> Label:
	return Ck3Theme.make_label(text, "SectionLabel")

func _style_panel(p: PanelContainer, bar: bool = false) -> void:
	if bar:
		p.theme_type_variation = "TopBar"
	p.mouse_filter = Control.MOUSE_FILTER_STOP

func _build_ui() -> void:
	_root = Control.new()
	_root.name = "Root"
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _theme:
		_root.theme = _theme
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
	top.offset_left = 8.0
	top.offset_top = 8.0
	top.offset_right = -8.0
	top.offset_bottom = 60.0
	_root.add_child(top)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.custom_minimum_size = Vector2(0, 44)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	top.add_child(row)

	_date_label = _label("1066.9.15", "AccentLabel")
	_date_label.add_theme_font_size_override("font_size", 14)
	row.add_child(_date_label)

	_gold_chip = Ck3Theme.make_chip("Gold 0", true)
	row.add_child(_gold_chip)
	_prestige_chip = Ck3Theme.make_chip("Prestige 0", true)
	row.add_child(_prestige_chip)
	_piety_chip = Ck3Theme.make_chip("Piety 0", true)
	row.add_child(_piety_chip)
	_lifestyle_chip = Ck3Theme.make_chip("Lifestyle Stewardship", true)
	row.add_child(_lifestyle_chip)

	var crest: Color = Color(0.85, 0.7, 0.15)
	var house: String = "Ashford"
	if is_instance_valid(GameData) and GameData.dynasty:
		house = str(GameData.dynasty.name)
		crest = GameData.dynasty.color
	_dynasty_chip = Ck3Theme.make_dynasty_chip(house, crest)
	row.add_child(_dynasty_chip)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(spacer)

	var icons := HBoxContainer.new()
	icons.name = "IconRow"
	icons.add_theme_constant_override("separation", 6)
	row.add_child(icons)

	var stub_items: Array = [
		{"abbr": "Rlm", "title": "Realm", "live": false},
		{"abbr": "Mil", "title": "Military", "live": true},
		{"abbr": "Cou", "title": "Council", "live": true},
		{"abbr": "Crt", "title": "Court", "live": false},
		{"abbr": "Int", "title": "Intrigue", "live": false},
		{"abbr": "Dec", "title": "Decisions", "live": true},
	]
	for item in stub_items:
		var b := Button.new()
		var title_name: String = str(item["title"])
		var is_live: bool = bool(item["live"])
		b.text = str(item["abbr"])
		if is_live:
			b.tooltip_text = title_name
			b.theme_type_variation = "GhostButton"
		else:
			b.tooltip_text = "%s — Coming" % title_name
			b.theme_type_variation = "ComingButton"
		b.custom_minimum_size = Vector2(40, 30)
		b.pressed.connect(func() -> void: _open_stub_window(title_name))
		icons.add_child(b)

	_counts_label = _label("People 0  Army 0", "MuteLabel")
	row.add_child(_counts_label)
	_zoom_label = _label("Strategy", "MuteLabel")
	row.add_child(_zoom_label)

func _build_outliner() -> void:
	_outliner = PanelContainer.new()
	_outliner.name = "Outliner"
	_style_panel(_outliner)
	_outliner.set_anchors_preset(Control.PRESET_LEFT_WIDE)
	_outliner.offset_left = 8.0
	_outliner.offset_top = 68.0
	_outliner.offset_right = 240.0
	_outliner.offset_bottom = -56.0
	_root.add_child(_outliner)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	_outliner.add_child(margin)

	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(scroll)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 8)
	scroll.add_child(vbox)

	vbox.add_child(_label("OUTLINER", "SectionLabel"))

	vbox.add_child(_label("Holdings", "MuteLabel"))
	_holdings_box = VBoxContainer.new()
	_holdings_box.add_theme_constant_override("separation", 2)
	vbox.add_child(_holdings_box)

	vbox.add_child(_label("Vassals", "MuteLabel"))
	_vassals_box = VBoxContainer.new()
	_vassals_box.add_theme_constant_override("separation", 2)
	vbox.add_child(_vassals_box)
	_vassals_box.add_child(_label("None", "MuteLabel"))

	vbox.add_child(_label("People", "MuteLabel"))
	_people_box = VBoxContainer.new()
	_people_box.add_theme_constant_override("separation", 2)
	vbox.add_child(_people_box)

	vbox.add_child(_label("Armies", "MuteLabel"))
	_armies_box = VBoxContainer.new()
	_armies_box.add_theme_constant_override("separation", 2)
	vbox.add_child(_armies_box)

	vbox.add_child(_label("Factions", "MuteLabel"))
	_factions_box = VBoxContainer.new()
	_factions_box.add_theme_constant_override("separation", 2)
	vbox.add_child(_factions_box)
	_factions_box.add_child(_label("None", "MuteLabel"))

func _build_side_panel() -> void:
	_side = PanelContainer.new()
	_side.name = "SidePanel"
	_style_panel(_side)
	_side.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
	_side.offset_left = -300.0
	_side.offset_top = 68.0
	_side.offset_right = -8.0
	_side.offset_bottom = -56.0
	_root.add_child(_side)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	_side.add_child(margin)

	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 8)
	margin.add_child(stack)

	_side_title = _label("Realm", "TitleLabel")
	stack.add_child(_side_title)

	# Realm (no selection)
	_realm_panel = VBoxContainer.new()
	_realm_panel.add_theme_constant_override("separation", 8)
	stack.add_child(_realm_panel)
	_realm_panel.add_child(_section_header("Realm"))
	_realm_body = _label("", "BodyLabel")
	_realm_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_realm_panel.add_child(_realm_body)
	_realm_panel.add_child(_label("Select a holding, person, or army\non the map or outliner.", "MuteLabel"))

	# Holding
	_holding_panel = VBoxContainer.new()
	_holding_panel.add_theme_constant_override("separation", 8)
	stack.add_child(_holding_panel)
	_holding_panel.add_child(_section_header("Holding"))
	_side_body = _label("Ashford", "BodyLabel")
	_side_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_holding_panel.add_child(_side_body)
	_side_extra = _label("Buildings:\n- Keep\n- Market\n- Houses\n- Farms", "MuteLabel")
	_side_extra.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_holding_panel.add_child(_side_extra)
	_holding_levy_label = _label("Available levy: —", "BodyLabel")
	_holding_levy_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_holding_panel.add_child(_holding_levy_label)
	_raise_btn = Button.new()
	_raise_btn.text = "Raise Levy"
	_raise_btn.theme_type_variation = "PrimaryButton"
	_raise_btn.custom_minimum_size = Vector2(0, 32)
	_raise_btn.pressed.connect(func() -> void: raise_levy_pressed.emit())
	_holding_panel.add_child(_raise_btn)

	# Character
	_character_panel = VBoxContainer.new()
	_character_panel.add_theme_constant_override("separation", 8)
	stack.add_child(_character_panel)
	_character_panel.add_child(_section_header("Character"))

	var char_header := HBoxContainer.new()
	char_header.add_theme_constant_override("separation", 12)
	_character_panel.add_child(char_header)
	_char_portrait = Ck3Theme.make_portrait("?", 72.0)
	char_header.add_child(_char_portrait)
	var char_title_col := VBoxContainer.new()
	char_title_col.add_theme_constant_override("separation", 4)
	char_title_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	char_header.add_child(char_title_col)
	_char_name = _label("", "TitleLabel")
	_char_name.name = "CharName"
	_char_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	char_title_col.add_child(_char_name)
	_char_role = _label("", "MuteLabel")
	_char_role.name = "CharRole"
	_char_role.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	char_title_col.add_child(_char_role)
	_char_body = _label("", "BodyLabel")
	_char_body.name = "CharBody"
	_char_body.visible = false
	_char_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	char_title_col.add_child(_char_body)
	_char_dynasty = _label("", "AccentLabel")
	_char_dynasty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	char_title_col.add_child(_char_dynasty)

	_char_education = _label("Education: -", "MuteLabel")
	_char_education.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_character_panel.add_child(_char_education)

	_character_panel.add_child(_label("Traits", "SectionLabel"))
	_trait_chips = HFlowContainer.new()
	_trait_chips.add_theme_constant_override("h_separation", 6)
	_trait_chips.add_theme_constant_override("v_separation", 6)
	_character_panel.add_child(_trait_chips)

	_character_panel.add_child(_label("Skills", "SectionLabel"))
	_skill_row = HBoxContainer.new()
	_skill_row.add_theme_constant_override("separation", 6)
	_character_panel.add_child(_skill_row)

	_goto_btn = Button.new()
	_goto_btn.text = "Go to"
	_goto_btn.theme_type_variation = "GhostButton"
	_goto_btn.custom_minimum_size = Vector2(0, 28)
	_goto_btn.pressed.connect(_on_goto)
	_character_panel.add_child(_goto_btn)

	# Army
	_army_panel = VBoxContainer.new()
	_army_panel.add_theme_constant_override("separation", 8)
	stack.add_child(_army_panel)
	_army_panel.add_child(_section_header("Army"))
	_army_body = _label("", "BodyLabel")
	_army_body.name = "ArmyBody"
	_army_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_army_panel.add_child(_army_body)
	_move_hint = _label("Right-click map to move", "MuteLabel")
	_move_hint.add_theme_color_override("font_color", Ck3Theme.color("positive"))
	_move_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_army_panel.add_child(_move_hint)

func _build_stub_modal() -> void:
	_stub_modal = PanelContainer.new()
	_stub_modal.name = "StubModal"
	_stub_modal.mouse_filter = Control.MOUSE_FILTER_STOP
	_stub_modal.visible = false
	_stub_modal.set_anchors_preset(Control.PRESET_CENTER)
	_stub_modal.offset_left = -180.0
	_stub_modal.offset_top = -90.0
	_stub_modal.offset_right = 180.0
	_stub_modal.offset_bottom = 90.0
	_root.add_child(_stub_modal)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	_stub_modal.add_child(v)

	_stub_modal_title = _label("Window", "TitleLabel")
	v.add_child(_stub_modal_title)
	_stub_modal_body = _label("Coming", "MuteLabel")
	_stub_modal_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(_stub_modal_body)

	var close_btn := Button.new()
	close_btn.text = "Close"
	close_btn.theme_type_variation = "GhostButton"
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
	_council_modal.mouse_filter = Control.MOUSE_FILTER_STOP
	_council_modal.visible = false
	_council_modal.set_anchors_preset(Control.PRESET_CENTER)
	_council_modal.offset_left = -260.0
	_council_modal.offset_top = -200.0
	_council_modal.offset_right = 260.0
	_council_modal.offset_bottom = 200.0
	_root.add_child(_council_modal)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	_council_modal.add_child(v)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	v.add_child(header)
	header.add_child(_label("Council", "TitleLabel"))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_child(spacer)
	var close_btn := Button.new()
	close_btn.text = "Close"
	close_btn.theme_type_variation = "GhostButton"
	close_btn.pressed.connect(_close_council_window)
	header.add_child(close_btn)

	_council_liege = _label("Liege: —", "MuteLabel")
	_council_liege.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(_council_liege)

	var col_hdr := HBoxContainer.new()
	col_hdr.add_theme_constant_override("separation", 8)
	v.add_child(col_hdr)
	var job_h := _label("Job", "MuteLabel")
	job_h.custom_minimum_size = Vector2(120, 0)
	col_hdr.add_child(job_h)
	var name_h := _label("Appointee", "MuteLabel")
	name_h.custom_minimum_size = Vector2(150, 0)
	name_h.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col_hdr.add_child(name_h)
	var task_h := _label("Task", "MuteLabel")
	task_h.custom_minimum_size = Vector2(130, 0)
	col_hdr.add_child(task_h)

	_council_rows = VBoxContainer.new()
	_council_rows.name = "CouncilRows"
	_council_rows.add_theme_constant_override("separation", 4)
	v.add_child(_council_rows)

	v.add_child(_label("Click a councillor to open their dossier.", "MuteLabel"))

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

	var liege_name: String = "—"
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
		var appointee_name: String = "Vacant"
		var has_appointee: bool = false
		if appointee != null and is_instance_valid(appointee):
			has_appointee = true
			appointee_name = _CouncilDataScript.person_display_name(appointee)
			if appointee_name.is_empty():
				appointee_name = str(appointee.name)

		var row := Button.new()
		row.alignment = HORIZONTAL_ALIGNMENT_LEFT
		row.text = ""
		row.tooltip_text = "%s — %s (%s)" % [job_label, appointee_name, task_label]
		row.custom_minimum_size = Vector2(0, 44)
		row.clip_text = true
		if has_appointee:
			row.theme_type_variation = "ListRow"
			var captured: Node = appointee
			row.pressed.connect(func() -> void:
				select_character(captured)
				set_status("Council -> %s" % _CouncilDataScript.person_display_name(captured))
			)
		else:
			row.theme_type_variation = "ComingButton"
			row.disabled = true
		var row_margin := MarginContainer.new()
		row_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		row_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row_margin.add_theme_constant_override("margin_left", 8)
		row_margin.add_theme_constant_override("margin_right", 8)
		row_margin.add_theme_constant_override("margin_top", 4)
		row_margin.add_theme_constant_override("margin_bottom", 4)
		row.add_child(row_margin)
		var row_col := VBoxContainer.new()
		row_col.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row_col.add_theme_constant_override("separation", 0)
		row_margin.add_child(row_col)
		var job_l := _label(job_label, "BodyLabel")
		job_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row_col.add_child(job_l)
		var name_l := _label(appointee_name, "MuteLabel")
		name_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row_col.add_child(name_l)
		_council_rows.add_child(row)


func _build_military_window() -> void:
	_military_modal = PanelContainer.new()
	_military_modal.name = "MilitaryModal"
	_military_modal.mouse_filter = Control.MOUSE_FILTER_STOP
	_military_modal.visible = false
	_military_modal.set_anchors_preset(Control.PRESET_CENTER)
	_military_modal.offset_left = -280.0
	_military_modal.offset_top = -240.0
	_military_modal.offset_right = 280.0
	_military_modal.offset_bottom = 240.0
	_root.add_child(_military_modal)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	_military_modal.add_child(v)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	v.add_child(header)
	header.add_child(_label("Military", "TitleLabel"))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_child(spacer)
	var close_btn := Button.new()
	close_btn.text = "Close"
	close_btn.theme_type_variation = "GhostButton"
	close_btn.pressed.connect(_close_military_window)
	header.add_child(close_btn)

	_military_marshal_label = _label("Marshal: Captain Rhea (stub)", "MuteLabel")
	v.add_child(_military_marshal_label)

	v.add_child(_section_header("Levies"))
	_military_levy_label = _label("Raised: 0", "BodyLabel")
	v.add_child(_military_levy_label)
	var levy_hint := _label(
		"Raise Levy from the Holding panel. When the army is selected, RMB the map to move.",
		"MuteLabel"
	)
	levy_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(levy_hint)

	v.add_child(_section_header("Men-at-Arms (stub)"))
	var maa_hdr := HBoxContainer.new()
	maa_hdr.add_theme_constant_override("separation", 8)
	v.add_child(maa_hdr)
	var type_h := _label("Regiment", "MuteLabel")
	type_h.custom_minimum_size = Vector2(140, 0)
	maa_hdr.add_child(type_h)
	var size_h := _label("Size", "MuteLabel")
	size_h.custom_minimum_size = Vector2(60, 0)
	maa_hdr.add_child(size_h)
	var act_h := _label("Recruit", "MuteLabel")
	act_h.custom_minimum_size = Vector2(100, 0)
	maa_hdr.add_child(act_h)

	var maa_types: PackedStringArray = PackedStringArray(["Bowmen", "Spearmen", "Light Horse"])
	for maa_name in maa_types:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		v.add_child(row)
		var name_l := _label(str(maa_name), "BodyLabel")
		name_l.custom_minimum_size = Vector2(140, 0)
		row.add_child(name_l)
		var size_l := _label("0", "MuteLabel")
		size_l.custom_minimum_size = Vector2(60, 0)
		row.add_child(size_l)
		var recruit := Button.new()
		recruit.text = "Coming"
		recruit.disabled = true
		recruit.tooltip_text = "Coming"
		recruit.theme_type_variation = "ComingButton"
		recruit.custom_minimum_size = Vector2(100, 28)
		row.add_child(recruit)

	var maa_note := _label(
		"MaA sizes stay at 0 until recruited onto the map. Levies are the only raised troops.",
		"MuteLabel"
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
	_decisions_modal.mouse_filter = Control.MOUSE_FILTER_STOP
	_decisions_modal.visible = false
	_decisions_modal.set_anchors_preset(Control.PRESET_CENTER)
	_decisions_modal.offset_left = -260.0
	_decisions_modal.offset_top = -200.0
	_decisions_modal.offset_right = 260.0
	_decisions_modal.offset_bottom = 200.0
	_root.add_child(_decisions_modal)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	_decisions_modal.add_child(v)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	v.add_child(header)
	header.add_child(_label("Decisions", "TitleLabel"))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_child(spacer)
	var close_btn := Button.new()
	close_btn.text = "Close"
	close_btn.theme_type_variation = "GhostButton"
	close_btn.pressed.connect(_close_decisions_window)
	header.add_child(close_btn)

	v.add_child(_label("Personal decisions (panel stub — no map bodies).", "MuteLabel"))

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
	row.custom_minimum_size = Vector2(0, 30)
	if enabled:
		row.text = title_text
		row.tooltip_text = hint
		row.disabled = false
		row.theme_type_variation = "PrimaryButton"
		if on_press.is_valid():
			row.pressed.connect(on_press)
	else:
		row.text = "%s — Coming" % title_text
		row.tooltip_text = "Coming"
		row.disabled = true
		row.theme_type_variation = "ComingButton"
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
	bottom.offset_left = 8.0
	bottom.offset_top = -48.0
	bottom.offset_right = -8.0
	bottom.offset_bottom = -8.0
	_root.add_child(bottom)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	bottom.add_child(row)

	_pause_btn = Button.new()
	_pause_btn.text = "Pause"
	_pause_btn.theme_type_variation = "GhostButton"
	_pause_btn.custom_minimum_size = Vector2(0, 28)
	_pause_btn.pressed.connect(_on_pause)
	row.add_child(_pause_btn)

	_speed1_btn = Button.new()
	_speed1_btn.text = "1x"
	_speed1_btn.theme_type_variation = "GhostButton"
	_speed1_btn.custom_minimum_size = Vector2(40, 28)
	_speed1_btn.pressed.connect(func() -> void: Engine.time_scale = 1.0)
	row.add_child(_speed1_btn)

	_speed2_btn = Button.new()
	_speed2_btn.text = "2x"
	_speed2_btn.theme_type_variation = "GhostButton"
	_speed2_btn.custom_minimum_size = Vector2(40, 28)
	_speed2_btn.pressed.connect(func() -> void: Engine.time_scale = 2.0)
	row.add_child(_speed2_btn)

	_alert_label = _label("Ready", "AccentLabel")
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
	var title_name: String = "Baron of Ashford"
	var dynasty_name: String = "Ashford"
	var people_n: int = 0
	var army_n: int = 0
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
	var holding_name: String = str(data.get("name", "Ashford"))
	_side_body.text = holding_name
	var buildings: Array = data.get("buildings", ["Keep", "Market", "Houses", "Farms"])
	var lines: PackedStringArray = PackedStringArray(["Buildings:"])
	for b in buildings:
		lines.append("- %s" % str(b))
	_side_extra.text = "\n".join(lines)
	_update_holding_levy_line()
	_update_raise_enabled()

func _levy_limits() -> Vector2i:
	var min_l: int = 4
	var max_l: int = 8
	if muster:
		if "min_levy" in muster:
			min_l = int(muster.min_levy)
		if "max_levy" in muster:
			max_l = int(muster.max_levy)
	return Vector2i(min_l, max_l)

func _available_levy_estimate() -> int:
	var limits: Vector2i = _levy_limits()
	var max_l: int = limits.y
	var villagers: int = 0
	if is_instance_valid(GameData):
		villagers = GameData.count_villagers()
	else:
		villagers = get_tree().get_nodes_in_group("villagers").size()
	var army_n: int = 0
	if army and army.has_method("get_count"):
		army_n = int(army.get_count())
	var room: int = maxi(max_l - army_n, 0)
	return clampi(mini(villagers, room), 0, max_l)

func _update_holding_levy_line() -> void:
	if _holding_levy_label == null:
		return
	var limits: Vector2i = _levy_limits()
	var available: int = _available_levy_estimate()
	var villagers: int = 0
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
		can = bool(muster.can_muster())
	_raise_btn.disabled = not can
	_raise_btn.theme_type_variation = "PrimaryButton"
	if can:
		_raise_btn.text = "Raise Levy"
		_raise_btn.tooltip_text = "Muster villagers into a levy"
		return
	var villagers: int = 0
	if is_instance_valid(GameData):
		villagers = GameData.count_villagers()
	else:
		villagers = get_tree().get_nodes_in_group("villagers").size()
	var army_n: int = 0
	if army and army.has_method("get_count"):
		army_n = int(army.get_count())
	var limits: Vector2i = _levy_limits()
	var reason: String = "unavailable"
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

	var char_name: String = str(data.get("name", "Unknown"))
	if _char_portrait:
		Ck3Theme.set_portrait_initials(_char_portrait, Ck3Theme.initials_of(char_name))

	if _char_name:
		_char_name.text = char_name
	if _char_role:
		var role_bits: PackedStringArray = PackedStringArray()
		role_bits.append(str(data.get("role", "-")))
		if data.has("opinion"):
			role_bits.append("Opinion: %s" % str(data.get("opinion")))
		_char_role.text = " / ".join(role_bits)
	if _char_body:
		_char_body.text = ""

	if _char_dynasty:
		if is_ruler and is_instance_valid(GameData):
			_char_dynasty.visible = true
			_char_dynasty.text = "Dynasty: House %s" % GameData.dynasty_chip()
		else:
			_char_dynasty.visible = false
			_char_dynasty.text = ""

	if _char_education:
		_char_education.text = str(data.get("education_line", "Education: -"))

	var traits_val: Variant = data.get("traits", PackedStringArray())
	var traits_arr: PackedStringArray = PackedStringArray()
	if traits_val is PackedStringArray:
		traits_arr = traits_val
	elif traits_val is Array:
		for t in traits_val:
			traits_arr.append(str(t))
	if _trait_chips:
		Ck3Theme.fill_trait_chips(_trait_chips, traits_arr)

	var skills_val: Variant = data.get("skills", {})
	var skills_dict: Dictionary = skills_val if skills_val is Dictionary else {}
	if _skill_row:
		Ck3Theme.fill_skill_row(_skill_row, skills_dict)

func _populate_army(node: Node) -> void:
	var count: int = 0
	var army_node: Node = army if army else node
	if army_node and army_node.has_method("get_count"):
		count = int(army_node.get_count())
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

func _set_chip_text(chip: PanelContainer, text: String) -> void:
	var l: Label = Ck3Theme.chip_label(chip)
	if l:
		l.text = text

func _refresh_top() -> void:
	if not is_instance_valid(GameData):
		return
	if _date_label:
		_date_label.text = GameData.date_string
	_set_chip_text(_gold_chip, "Gold %d" % GameData.gold)
	_set_chip_text(_prestige_chip, "Prestige %d" % GameData.prestige)
	_set_chip_text(_piety_chip, "Piety %d" % GameData.piety)
	_set_chip_text(_lifestyle_chip, "Lifestyle Stewardship")
	if _dynasty_chip:
		Ck3Theme.set_dynasty_chip_name(_dynasty_chip, GameData.dynasty_chip())

func _refresh_counts() -> void:
	if _counts_label and is_instance_valid(GameData):
		_counts_label.text = "People %d  Army %d" % [GameData.count_people(), GameData.count_army()]
	if _zoom_label and camera_rig and camera_rig.has_method("get_zoom_label"):
		_zoom_label.text = str(camera_rig.get_zoom_label())

func _maybe_dim_outliner() -> void:
	if _outliner == null or camera_rig == null:
		return
	var street: bool = false
	if camera_rig.has_method("get_zoom_label"):
		street = camera_rig.get_zoom_label() == "Street"
	_outliner.modulate = Color(1, 1, 1, 0.45) if street else Color(1, 1, 1, 1)

func _clear_box(box: VBoxContainer) -> void:
	Ck3Theme.clear_box(box)

func _make_row(text: String, subtitle: String, selected_row: bool, on_press: Callable) -> Button:
	var b := Button.new()
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.custom_minimum_size = Vector2(0, 32 if subtitle.is_empty() else 40)
	if subtitle.is_empty():
		b.text = text
	else:
		b.text = "%s\n%s" % [text, subtitle]
	b.theme_type_variation = "ListRowSelected" if selected_row else "ListRow"
	if not subtitle.is_empty():
		b.tooltip_text = "%s — %s" % [text, subtitle]
	b.pressed.connect(on_press)
	return b

func _role_of(node: Node) -> String:
	if node == null:
		return ""
	if "role" in node:
		return str(node.role)
	if node.has_method("get_inspect_data"):
		return str(node.get_inspect_data().get("role", ""))
	return ""

func _refresh_outliner() -> void:
	if _holdings_box == null:
		return
	_clear_box(_holdings_box)
	_clear_box(_people_box)
	_clear_box(_armies_box)

	# Holdings
	var hold_name: String = "Ashford"
	if settlement and settlement.has_method("get_inspect_data"):
		hold_name = str(settlement.get_inspect_data().get("name", "Ashford"))
	var hold_sel: bool = sel_kind == SelKind.HOLDING
	_holdings_box.add_child(_make_row(hold_name, "County seat", hold_sel, func() -> void:
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
		var pname: String = str(p.name)
		if "display_name" in p:
			pname = str(p.display_name)
		elif p.has_method("get_inspect_data"):
			pname = str(p.get_inspect_data().get("name", p.name))
		var role_line: String = _role_of(p)
		var is_sel: bool = sel_kind == SelKind.CHARACTER and selected == p
		var captured: Node = p
		_people_box.add_child(_make_row(pname, role_line, is_sel, func() -> void:
			select_character(captured)
		))

	# Armies if count > 0
	var army_count: int = 0
	if army and army.has_method("get_count"):
		army_count = int(army.get_count())
	if army_count > 0:
		var is_sel_army: bool = sel_kind == SelKind.ARMY
		_armies_box.add_child(_make_row("Ashford Levy", "%d soldiers" % army_count, is_sel_army, func() -> void:
			if army:
				select_army(army)
		))
	else:
		_armies_box.add_child(_label("(none mustered)", "MuteLabel"))
