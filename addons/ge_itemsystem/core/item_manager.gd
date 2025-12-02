## Central item management system.
## Singleton autoload that manages item registration, search, and validation.
extends Node

## Dictionary mapping item IDs to Item instances
## Dictionary[String, Item]
var _items: Dictionary = {}

## EventBus adapter (only coupling point with EventBus)
var _eventbus_adapter: EventBusAdapter

func _ready():
	# Ensure there is only one instance
	if get_tree().get_nodes_in_group("item_manager").size() > 0:
		queue_free()
		return
	add_to_group("item_manager")
	
	# Initialize adapter
	_eventbus_adapter = EventBusAdapter.new()

## Registers an item in the system
## @param item: The item to register
## @return: true if registration was successful
func register_item(item: Item) -> bool:
	if item == null:
		push_error("ItemManager: Attempt to register null item")
		return false
	
	if not item.validate():
		push_error("ItemManager: Item validation failed for '%s'" % item.item_id)
		return false
	
	if _items.has(item.item_id):
		push_warning("ItemManager: Item '%s' already exists, overwriting" % item.item_id)
	
	_items[item.item_id] = item
	
	# Publish event
	var event: ItemCreatedEvent = ItemCreatedEvent.new(item.item_id, item)
	_eventbus_adapter.publish_event(event)
	
	return true

## Gets an item by ID
## @param item_id: The item ID
## @return: Item instance or null if not found
func get_item(item_id: String) -> Item:
	if item_id.is_empty():
		return null
	
	if not _items.has(item_id):
		return null
	
	var item_variant: Variant = _items[item_id]
	if not item_variant is Item:
		return null
	
	return item_variant as Item

## Removes an item from the system
## @param item_id: The item ID
## @return: true if item was removed
func remove_item(item_id: String) -> bool:
	if item_id.is_empty() or not _items.has(item_id):
		return false
	
	var item: Item = _items[item_id] as Item
	_items.erase(item_id)
	
	# Publish event
	var event: ItemDeletedEvent = ItemDeletedEvent.new(item_id)
	_eventbus_adapter.publish_event(event)
	
	return true

## Updates an item (replaces existing item with same ID)
## @param item: The updated item
## @return: true if update was successful
func update_item(item: Item) -> bool:
	if item == null or not item.validate():
		return false
	
	if not _items.has(item.item_id):
		push_warning("ItemManager: Item '%s' not found, registering as new" % item.item_id)
		return register_item(item)
	
	var old_item: Item = _items[item.item_id] as Item
	_items[item.item_id] = item
	
	# Publish event with changed properties
	var changed_properties: Array[String] = []
	var old_properties: Dictionary = old_item.get_all_properties()
	var new_properties: Dictionary = item.get_all_properties()
	
	# Find changed properties
	for key: String in new_properties:
		if not old_properties.has(key) or old_properties[key] != new_properties[key]:
			changed_properties.append(key)
	
	for key: String in old_properties:
		if not new_properties.has(key):
			changed_properties.append(key)
	
	var event: ItemUpdatedEvent = ItemUpdatedEvent.new(item.item_id, item, changed_properties)
	_eventbus_adapter.publish_event(event)
	
	return true

## Finds items by type
## @param type: ItemType.Type to search for
## @return: Array of matching items
func find_items_by_type(type: ItemType.Type) -> Array[Item]:
	var results: Array[Item] = []
	
	for item_variant: Variant in _items.values():
		if not item_variant is Item:
			continue
		
		var item: Item = item_variant as Item
		if item.item_type == type:
			results.append(item)
	
	return results

## Finds items by property value
## @param key: Property key to search
## @param value: Property value to match
## @return: Array of matching items
func find_items_by_property(key: String, value: Variant) -> Array[Item]:
	if key.is_empty():
		return []
	
	var results: Array[Item] = []
	
	for item_variant: Variant in _items.values():
		if not item_variant is Item:
			continue
		
		var item: Item = item_variant as Item
		if item.has_property(key) and item.get_property(key) == value:
			results.append(item)
	
	return results

## Finds items matching multiple property criteria
## @param criteria: Dictionary[String, Variant] with property key-value pairs
## @return: Array of matching items
func find_items_by_properties(criteria: Dictionary) -> Array[Item]:
	if criteria.is_empty():
		return []
	
	var results: Array[Item] = []
	
	for item_variant: Variant in _items.values():
		if not item_variant is Item:
			continue
		
		var item: Item = item_variant as Item
		var matches: bool = true
		
		for key: String in criteria:
			if not item.has_property(key) or item.get_property(key) != criteria[key]:
				matches = false
				break
		
		if matches:
			results.append(item)
	
	return results

## Gets all registered items
## @return: Array of all items
func get_all_items() -> Array[Item]:
	var results: Array[Item] = []
	
	for item_variant: Variant in _items.values():
		if item_variant is Item:
			results.append(item_variant as Item)
	
	return results

## Gets the number of registered items
## @return: int count of items
func get_item_count() -> int:
	return _items.size()

## Checks if an item exists
## @param item_id: The item ID
## @return: true if item exists
func has_item(item_id: String) -> bool:
	return _items.has(item_id)

## Clears all items
func clear_all() -> void:
	var item_ids: Array[String] = []
	for item_id: String in _items.keys():
		item_ids.append(item_id)
	
	_items.clear()
	
	# Publish delete events for all items
	for item_id: String in item_ids:
		var event: ItemDeletedEvent = ItemDeletedEvent.new(item_id)
		_eventbus_adapter.publish_event(event)

## Gets the EventBus adapter
## @return: EventBusAdapter instance
func get_eventbus_adapter() -> EventBusAdapter:
	return _eventbus_adapter

