## Represents a pure data item in the game.
## Items are data-only - no executable behavior.
## Behavior (use, equip, consume) belongs to external systems (InventorySystem, EquipmentSystem, etc.).
class_name Item
extends RefCounted

## Unique identifier for this item
var item_id: String = ""

## Display name of the item
var name: String = ""

## Description of the item
var description: String = ""

## Type of item (ItemType.Type enum)
var item_type: ItemType.Type = ItemType.Type.MISC

## Custom properties (flexible system for game-specific data)
## Dictionary[String, Variant] - can store any type of data
var properties: Dictionary = {}

## Creation timestamp
var created_at: float = 0.0

## Last modification timestamp
var updated_at: float = 0.0

func _init(p_item_id: String = "", p_name: String = "", p_description: String = "", p_item_type: ItemType.Type = ItemType.Type.MISC):
	item_id = p_item_id
	name = p_name
	description = p_description
	item_type = p_item_type
	properties = {}
	created_at = TimeHelper.get_timestamp()
	updated_at = created_at

## Sets a custom property
## @param key: Property key
## @param value: Property value (any Variant type)
func set_property(key: String, value: Variant) -> void:
	if key.is_empty():
		push_warning("Item: Attempt to set property with empty key")
		return
	properties[key] = value
	updated_at = TimeHelper.get_timestamp()

## Gets a custom property
## @param key: Property key
## @param default: Default value if property doesn't exist
## @return: Property value or default
func get_property(key: String, default: Variant = null) -> Variant:
	if not properties.has(key):
		return default
	return properties[key]

## Checks if a property exists
## @param key: Property key
## @return: true if property exists
func has_property(key: String) -> bool:
	return properties.has(key)

## Removes a property
## @param key: Property key
## @return: true if property was removed
func remove_property(key: String) -> bool:
	if not properties.has(key):
		return false
	properties.erase(key)
	updated_at = TimeHelper.get_timestamp()
	return true

## Gets all properties
## @return: Dictionary with all properties
func get_all_properties() -> Dictionary:
	return properties.duplicate()

## Helper: Gets rarity (common property)
## @return: String rarity or empty string if not set
func get_rarity() -> String:
	return get_property("rarity", "") as String

## Helper: Gets value (common property)
## @return: int value or 0 if not set
func get_value() -> int:
	return get_property("value", 0) as int

## Helper: Gets weight (common property)
## @return: float weight or 0.0 if not set
func get_weight() -> float:
	var weight_variant: Variant = get_property("weight", 0.0)
	if weight_variant is float:
		return weight_variant as float
	if weight_variant is int:
		return float(weight_variant)
	return 0.0

## Helper: Gets durability (common property)
## @return: int durability or -1 if not set
func get_durability() -> int:
	return get_property("durability", -1) as int

## Helper: Gets max durability (common property)
## @return: int max durability or -1 if not set
func get_max_durability() -> int:
	return get_property("max_durability", -1) as int

## Creates a deep copy of this item
## @return: New Item instance with copied data
func duplicate_item() -> Item:
	var new_item: Item = Item.new(item_id, name, description, item_type)
	new_item.properties = properties.duplicate(true)  # Deep copy
	new_item.created_at = created_at
	new_item.updated_at = updated_at
	return new_item

## Serializes the item to a Dictionary
## @return: Dictionary with item data
func to_dict() -> Dictionary:
	return {
		"item_id": item_id,
		"name": name,
		"description": description,
		"item_type": item_type as int,
		"properties": properties.duplicate(true),
		"created_at": created_at,
		"updated_at": updated_at
	}

## Deserializes an item from a Dictionary
## @param data: Dictionary with item data
## @return: true if deserialization was successful
func from_dict(data: Dictionary) -> bool:
	if not data.has("item_id") or not data.has("name"):
		return false
	
	item_id = data.get("item_id", "") as String
	name = data.get("name", "") as String
	description = data.get("description", "") as String
	
	var type_variant: Variant = data.get("item_type", ItemType.Type.MISC)
	if type_variant is int:
		item_type = type_variant as ItemType.Type
	else:
		item_type = ItemType.Type.MISC
	
	var properties_variant: Variant = data.get("properties", {})
	if properties_variant is Dictionary:
		properties = (properties_variant as Dictionary).duplicate(true)
	else:
		properties = {}
	
	created_at = data.get("created_at", TimeHelper.get_timestamp()) as float
	updated_at = data.get("updated_at", created_at) as float
	
	return true

## Validates the item data
## @return: true if item is valid
func validate() -> bool:
	if item_id.is_empty():
		return false
	if name.is_empty():
		return false
	return true

## Gets a string representation of the item
func _to_string() -> String:
	return "[Item: %s (%s)]" % [name, item_id]

