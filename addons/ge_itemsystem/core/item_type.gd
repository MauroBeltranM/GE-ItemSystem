## Item type enumeration.
## Common item types that most games use.
## Can be extended with custom types via string.
class_name ItemType
extends RefCounted

## Enum of common item types
enum Type {
	CONSUMABLE,  # Potions, food, etc.
	EQUIPMENT,   # Weapons, armor
	QUEST,       # Quest items
	MATERIAL,    # Crafting materials
	MISC,        # Miscellaneous
	CUSTOM       # Custom types (use string)
}

## Gets a string representation of a type
## @param type: The ItemType.Type enum value
## @return: String representation
static func type_to_string(type: Type) -> String:
	match type:
		Type.CONSUMABLE:
			return "consumable"
		Type.EQUIPMENT:
			return "equipment"
		Type.QUEST:
			return "quest"
		Type.MATERIAL:
			return "material"
		Type.MISC:
			return "misc"
		Type.CUSTOM:
			return "custom"
		_:
			return "unknown"

## Converts a string to ItemType.Type
## @param type_string: String representation of type
## @return: ItemType.Type enum value, or CUSTOM if not found
static func string_to_type(type_string: String) -> Type:
	match type_string.to_lower():
		"consumable":
			return Type.CONSUMABLE
		"equipment":
			return Type.EQUIPMENT
		"quest":
			return Type.QUEST
		"material":
			return Type.MATERIAL
		"misc":
			return Type.MISC
		"custom":
			return Type.CUSTOM
		_:
			return Type.CUSTOM

