## Adapter for PersistenceSystem integration.
## Implements PersistenceAdapter interface to allow ItemSystem to save/load items.
## This is the ONLY coupling point with PersistenceSystem in the entire ItemSystem.
## 
## NOTE: This adapter requires that GE-PersistenceSystem is installed.
## If PersistenceAdapter class is not available, this code will not compile.
## 
## To use this adapter, register it with PersistenceManager:
## var adapter = ItemSystemPersistenceAdapter.new()
## PersistenceManager.register_adapter(adapter)
## 
## IMPORTANT: This adapter must extend PersistenceAdapter from PersistenceSystem.
## If PersistenceSystem is not installed, this adapter cannot be used.
## The rest of ItemSystem works fine without PersistenceSystem.
class_name ItemSystemPersistenceAdapter
extends RefCounted

## Reference to ItemManager (if available)
var _item_manager: Node = null

## Current data version
var _version: int = 1

func _init():
	_check_itemmanager_availability()

## Checks if ItemManager is available
func _check_itemmanager_availability() -> void:
	if Engine.has_singleton("ItemManager"):
		_item_manager = Engine.get_singleton("ItemManager")
		return
	
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree != null:
		var root: Node = tree.root
		if root != null:
			var itemmanager_node: Node = root.get_node_or_null("ItemManager")
			if itemmanager_node != null:
				_item_manager = itemmanager_node

## Serializes all items to a Dictionary
## @return: Dictionary with serialized item data
func serialize() -> Dictionary:
	if _item_manager == null:
		push_warning("ItemSystemPersistenceAdapter: ItemManager not available")
		return {}
	
	if not _item_manager.has_method("get_all_items"):
		push_warning("ItemSystemPersistenceAdapter: ItemManager does not have get_all_items() method")
		return {}
	
	var items: Array[Item] = _item_manager.get_all_items()
	var data: Dictionary = {
		"version": _version,
		"items": []
	}
	
	for item: Item in items:
		if item != null:
			data["items"].append(item.to_dict())
	
	return data

## Deserializes items from a Dictionary
## @param data: Dictionary with serialized item data
## @return: true if deserialization was successful
func deserialize(data: Dictionary) -> bool:
	if _item_manager == null:
		push_warning("ItemSystemPersistenceAdapter: ItemManager not available")
		return false
	
	if not data.has("items"):
		push_warning("ItemSystemPersistenceAdapter: Data does not contain 'items' key")
		return false
	
	var items_variant: Variant = data["items"]
	if not items_variant is Array:
		push_warning("ItemSystemPersistenceAdapter: 'items' is not an Array")
		return false
	
	var items_array: Array = items_variant as Array
	var loaded_count: int = 0
	
	for item_data_variant: Variant in items_array:
		if not item_data_variant is Dictionary:
			continue
		
		var item_data: Dictionary = item_data_variant as Dictionary
		var item: Item = Item.new()
		
		if item.from_dict(item_data):
			if _item_manager.has_method("register_item"):
				if _item_manager.register_item(item):
					loaded_count += 1
			else:
				push_warning("ItemSystemPersistenceAdapter: ItemManager does not have register_item() method")
	
	return loaded_count > 0

## Gets the system name
## @return: String with the system name
func get_system_name() -> String:
	return "ItemSystem"

## Gets the data category
## @return: DataCategory.Category enum value (or int if DataCategory not available)
func get_category() -> Variant:
	# Use SAVEGAME category (items are game data)
	# Check if DataCategory exists
	if ClassDB.class_exists("DataCategory"):
		# Try to access enum value
		# SAVEGAME = 1 in DataCategory.Category enum
		return 1  # SAVEGAME
	return 1  # Default to SAVEGAME (1)

## Gets the current data version
## @return: int with the version
func get_version() -> int:
	return _version

## Migrates data from an old version to the current version
## @param data: Data in old version
## @param from_version: Source version
## @param to_version: Target version
## @return: Migrated data, or original data if no migration
func migrate_data(data: Dictionary, from_version: int, to_version: int) -> Dictionary:
	if from_version == to_version:
		return data
	
	# For now, no migration needed (version 1)
	# Future versions can implement migration here
	if from_version < to_version:
		push_warning("ItemSystemPersistenceAdapter: No migrator for version %d -> %d" % [from_version, to_version])
	
	return data

## Validates data before deserializing
## @param data: Data to validate
## @return: true if data is valid
func validate_data(data: Dictionary) -> bool:
	if not data.has("version"):
		return false
	
	var version_variant: Variant = data["version"]
	if not version_variant is int:
		return false
	
	if not data.has("items"):
		return false
	
	var items_variant: Variant = data["items"]
	if not items_variant is Array:
		return false
	
	return true

## Gets estimated size of serialized data
## @return: Estimated size in bytes, or -1 if cannot calculate
func get_estimated_size() -> int:
	if _item_manager == null:
		return -1
	
	if not _item_manager.has_method("get_all_items"):
		return -1
	
	var items: Array[Item] = _item_manager.get_all_items()
	var estimated: int = 100  # Base overhead
	
	for item: Item in items:
		estimated += 50  # Base item overhead
		estimated += item.item_id.length() * 2
		estimated += item.name.length() * 2
		estimated += item.description.length() * 2
		estimated += item.properties.size() * 20  # Rough estimate per property
	
	return estimated

