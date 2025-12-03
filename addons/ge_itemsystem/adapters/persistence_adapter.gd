## Adapter for PersistenceSystem integration.
## Implements PersistenceAdapter interface to allow ItemSystem to save/load items.
## This is the ONLY coupling point with PersistenceSystem in the entire ItemSystem.
## 
## NOTE: This adapter requires that GE-PersistenceSystem is installed.
## 
## To use this adapter, register it with PersistenceManager:
## var adapter = ItemSystemPersistenceAdapter.new()
## PersistenceManager.register_adapter(adapter)
class_name ItemSystemPersistenceAdapter
extends PersistenceAdapter

const CURRENT_VERSION: int = 1

## Reference to ItemManager (lazy initialized)
var _item_manager: Node = null

## Gets the ItemManager instance (lazy initialization)
func _get_manager() -> Node:
	if _item_manager == null:
		_item_manager = ManagerBase.find_manager("ItemManager")
	return _item_manager

## Serializes all items to a Dictionary
## @return: Dictionary with serialized item data
func serialize() -> Dictionary:
	var manager: Node = _get_manager()
	if manager == null:
		push_warning("ItemSystemPersistenceAdapter: ItemManager not available")
		return {}
	
	if not manager.has_method("get_all_items"):
		push_warning("ItemSystemPersistenceAdapter: ItemManager does not have get_all_items() method")
		return {}
	
	var items: Array[Item] = manager.get_all_items()
	var data: Dictionary = {
		"version": CURRENT_VERSION,
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
	var manager: Node = _get_manager()
	if manager == null:
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
			if manager.has_method("register_item"):
				if manager.register_item(item):
					loaded_count += 1
			else:
				push_warning("ItemSystemPersistenceAdapter: ItemManager does not have register_item() method")
	
	return loaded_count > 0

func get_system_name() -> String:
	return "ItemSystem"

func get_category() -> DataCategory.Category:
	return DataCategory.Category.SAVEGAME

func get_version() -> int:
	return CURRENT_VERSION

func validate_data(data: Dictionary) -> bool:
	if not data.has("version") or not data["version"] is int:
		return false
	if not data.has("items") or not data["items"] is Array:
		return false
	return true
