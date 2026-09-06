class_name Ck3Theme
extends RefCounted
## CK3 chrome helpers — StyleBox/Theme live in ui/theme/*.tres; this is layout only.

const THEME_PATH := "res://ui/theme/ck3_theme.tres"

static var _cached: Theme

static func get_theme() -> Theme:
	if _cached == null:
		_cached = load(THEME_PATH) as Theme
	return _cached

static func color(token: String) -> Color:
	var t: Theme = get_theme()
	if t != null and t.has_color(token, "Ck3"):
		return t.get_color(token, "Ck3")
	return Color.WHITE

static func make_label(text: String, variation: String = "BodyLabel") -> Label:
	var l := Label.new()
	l.text = text
	l.theme_type_variation = variation
	return l

static func make_chip(text: String, vital: bool = false) -> PanelContainer:
	var p := PanelContainer.new()
	p.theme_type_variation = "ChipVital" if vital else "Chip"
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var l := Label.new()
	l.text = text
	l.theme_type_variation = "MuteLabel" if vital else "BodyLabel"
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(l)
	return p

static func chip_label(chip: PanelContainer) -> Label:
	if chip.get_child_count() > 0:
		return chip.get_child(0) as Label
	return null

static func make_portrait(initials: String, px: float = 72.0) -> PanelContainer:
	var frame := PanelContainer.new()
	frame.theme_type_variation = "PortraitFrame"
	frame.custom_minimum_size = Vector2(px, px)
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var center := CenterContainer.new()
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_child(center)
	var l := Label.new()
	l.name = "Initials"
	l.text = initials
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.theme_type_variation = "TitleLabel"
	l.add_theme_font_size_override("font_size", 20)
	l.add_theme_color_override("font_color", color("accent"))
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(l)
	return frame

static func set_portrait_initials(frame: PanelContainer, initials: String) -> void:
	var initials_lbl: Label = frame.find_child("Initials", true, false) as Label
	if initials_lbl:
		initials_lbl.text = initials

static func make_dynasty_chip(house_name: String, crest: Color = Color.BLACK) -> PanelContainer:
	var wrap := PanelContainer.new()
	wrap.theme_type_variation = "Chip"
	wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrap.add_child(row)
	var shield := PanelContainer.new()
	shield.theme_type_variation = "Shield"
	shield.custom_minimum_size = Vector2(20, 24)
	shield.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if crest.a > 0.0 and crest != Color.BLACK:
		var sb := StyleBoxFlat.new()
		sb.bg_color = crest
		sb.border_color = color("rim_gold")
		sb.set_border_width_all(1)
		sb.set_corner_radius_all(2)
		shield.add_theme_stylebox_override("panel", sb)
	row.add_child(shield)
	var name_l := Label.new()
	name_l.name = "HouseName"
	name_l.text = "House %s" % house_name
	name_l.theme_type_variation = "AccentLabel"
	name_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(name_l)
	return wrap

static func set_dynasty_chip_name(chip: PanelContainer, house_name: String) -> void:
	var name_l: Label = chip.find_child("HouseName", true, false) as Label
	if name_l:
		name_l.text = "House %s" % house_name

static func initials_of(display_name: String) -> String:
	var parts: PackedStringArray = display_name.strip_edges().split(" ", false)
	if parts.is_empty():
		return "?"
	if parts.size() == 1:
		return parts[0].substr(0, mini(2, parts[0].length())).to_upper()
	var a: String = parts[0].substr(0, 1)
	var b: String = parts[parts.size() - 1].substr(0, 1)
	return (a + b).to_upper()

static func clear_box(box: Node) -> void:
	if box == null:
		return
	for c in box.get_children():
		c.queue_free()

static func fill_trait_chips(box: Container, traits: PackedStringArray) -> void:
	clear_box(box)
	if traits.is_empty():
		box.add_child(make_label("No traits", "MuteLabel"))
		return
	for t in traits:
		box.add_child(make_chip(str(t), false))

static func fill_skill_row(box: Container, skills: Dictionary) -> void:
	clear_box(box)
	var pairs: Array = [
		["DIP", int(skills.get("diplomacy", 0))],
		["MRT", int(skills.get("martial", 0))],
		["STW", int(skills.get("stewardship", 0))],
		["INT", int(skills.get("intrigue", 0))],
		["LRN", int(skills.get("learning", 0))],
	]
	for pair in pairs:
		box.add_child(make_chip("%s %d" % [pair[0], pair[1]], true))
