extends PanelContainer
## Shows name / role / opinion for selected ruler, NPC, or army.

@onready var title_label: Label = %InspectorTitle
@onready var body_label: Label = %InspectorBody

func _ready() -> void:
	clear()

func clear() -> void:
	if title_label:
		title_label.text = "Inspector"
	if body_label:
		body_label.text = "Click a person or the army."

func show_entity(data: Dictionary) -> void:
	if title_label:
		title_label.text = str(data.get("name", "Unknown"))
	var lines: PackedStringArray = []
	lines.append("Role: %s" % str(data.get("role", "—")))
	if data.has("opinion"):
		lines.append("Opinion: %s" % str(data.get("opinion")))
	if data.has("count"):
		lines.append("Soldiers: %s" % str(data.get("count")))
	lines.append("Kind: %s" % str(data.get("kind", "")))
	if body_label:
		body_label.text = "\n".join(lines)