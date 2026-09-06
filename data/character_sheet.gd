class_name CharacterSheet
extends Resource
## Stub personality traits, education, and five CK-like skills for character dossiers.

@export var personality_traits: PackedStringArray = PackedStringArray()
@export var education: String = ""
@export var diplomacy: int = 5
@export var martial: int = 5
@export var stewardship: int = 5
@export var intrigue: int = 5
@export var learning: int = 5

func traits_line() -> String:
	if personality_traits.is_empty():
		return "Personality: -"
	return "Personality: %s" % " · ".join(personality_traits)

func education_line() -> String:
	if education.is_empty():
		return "Education: -"
	return "Education: %s" % education

func skills_line() -> String:
	return "Skills: Diplomacy %d · Martial %d · Stewardship %d · Intrigue %d · Learning %d" % [
		diplomacy, martial, stewardship, intrigue, learning
	]

static func make(
	traits: PackedStringArray,
	edu: String,
	dip: int,
	mar: int,
	stew: int,
	intr: int,
	learn: int
) -> CharacterSheet:
	var s := CharacterSheet.new()
	s.personality_traits = traits
	s.education = edu
	s.diplomacy = dip
	s.martial = mar
	s.stewardship = stew
	s.intrigue = intr
	s.learning = learn
	return s