class_name CouncilData
extends RefCounted
## CK3-like council job stubs: job_id -> preferred display_name / role + task label.
## Appointees resolve at runtime from live npcs/ruler nodes (map stays source of truth).
## Assignments: Mira Goods=Chancellor, Steward Corvin=Steward, Captain Rhea=Marshal,
## Elowen Ashford=Spymaster, Father Alden=Court Chaplain.

static func job_defs() -> Array:
	return [
		{
			"id": "chancellor",
			"label": "Chancellor",
			"names": ["Mira Goods"],
			"roles": ["Merchant", "Chancellor"],
			"task": "Fabricate Claim",
		},
		{
			"id": "steward",
			"label": "Steward",
			"names": ["Steward Corvin"],
			"roles": ["Steward"],
			"task": "Collect Taxes",
		},
		{
			"id": "marshal",
			"label": "Marshal",
			"names": ["Captain Rhea"],
			"roles": ["Captain", "Marshal"],
			"task": "Organize Army",
		},
		{
			"id": "spymaster",
			"label": "Spymaster",
			"names": ["Elowen Ashford"],
			"roles": ["Heir", "Spymaster"],
			"task": "Disrupt Schemes",
		},
		{
			"id": "court_chaplain",
			"label": "Court Chaplain",
			"names": ["Father Alden"],
			"roles": ["Priest", "Court Chaplain", "Chaplain"],
			"task": "Domestic Affairs",
		},
	]

static func person_display_name(node: Node) -> String:
	if node == null or not is_instance_valid(node):
		return ""
	if "display_name" in node:
		return str(node.display_name)
	if node.has_method("get_inspect_data"):
		return str(node.get_inspect_data().get("name", node.name))
	return str(node.name)

static func person_role(node: Node) -> String:
	if node == null or not is_instance_valid(node):
		return ""
	if "role" in node:
		return str(node.role)
	if node.has_method("get_inspect_data"):
		return str(node.get_inspect_data().get("role", ""))
	return ""

## Resolve appointee Node for a job def by scanning groups. Returns null if vacant.
static func resolve_appointee(tree: SceneTree, job: Dictionary) -> Node:
	if tree == null:
		return null
	var candidates: Array = []
	candidates.append_array(tree.get_nodes_in_group("ruler"))
	candidates.append_array(tree.get_nodes_in_group("npcs"))
	var names: Array = job.get("names", [])
	var roles: Array = job.get("roles", [])
	# Prefer exact display_name match
	for n in candidates:
		if n == null or not is_instance_valid(n):
			continue
		var dn: String = person_display_name(n)
		for want in names:
			if dn == str(want):
				return n
	# Fallback: role match
	for n in candidates:
		if n == null or not is_instance_valid(n):
			continue
		var role: String = person_role(n)
		for want in roles:
			if role == str(want):
				return n
	return null