## Basic example of GE-ItemSystem usage.
## Demonstrates item creation, registration, search, and integration.
extends Node

func _ready():
	print("GE-ItemSystem: Basic example initialized")
	
	# Example 1: Create and register basic items
	_example_basic_items()
	
	# Example 2: Items with custom properties
	_example_custom_properties()
	
	# Example 3: Search and filtering
	_example_search()
	
	# Example 4: Item serialization
	_example_serialization()

## Example 1: Create and register basic items
func _example_basic_items() -> void:
	print("\n=== Example 1: Basic Items ===")
	
	# Create a consumable item
	var potion: Item = Item.new("potion_001", "Health Potion", "Restores 50 HP")
	potion.item_type = ItemType.Type.CONSUMABLE
	potion.set_property("heal_amount", 50)
	
	# Create an equipment item
	var sword: Item = Item.new("sword_001", "Iron Sword", "A basic iron sword")
	sword.item_type = ItemType.Type.EQUIPMENT
	sword.set_property("attack", 10)
	sword.set_property("rarity", "common")
	
	# Create a quest item
	var key: Item = Item.new("key_001", "Ancient Key", "A mysterious key")
	key.item_type = ItemType.Type.QUEST
	
	# Register items
	ItemManager.register_item(potion)
	ItemManager.register_item(sword)
	ItemManager.register_item(key)
	
	print("Registered %d items" % ItemManager.get_item_count())

## Example 2: Items with custom properties
func _example_custom_properties() -> void:
	print("\n=== Example 2: Custom Properties ===")
	
	var armor: Item = Item.new("armor_001", "Steel Armor", "Heavy protective armor")
	armor.item_type = ItemType.Type.EQUIPMENT
	
	# Set common properties
	armor.set_property("defense", 25)
	armor.set_property("rarity", "rare")
	armor.set_property("value", 500)
	armor.set_property("weight", 15.5)
	armor.set_property("durability", 100)
	armor.set_property("max_durability", 100)
	
	# Set custom game-specific properties
	armor.set_property("elemental_resistance", {
		"fire": 10,
		"ice": 5,
		"lightning": 0
	})
	armor.set_property("required_level", 5)
	armor.set_property("set_bonus", "warrior_set")
	
	ItemManager.register_item(armor)
	
	# Access properties
	print("Armor defense: %d" % armor.get_property("defense", 0))
	print("Armor rarity: %s" % armor.get_rarity())
	print("Armor value: %d" % armor.get_value())
	print("Armor weight: %.1f" % armor.get_weight())

## Example 3: Search and filtering
func _example_search() -> void:
	print("\n=== Example 3: Search and Filtering ===")
	
	# Find all equipment items
	var equipment: Array[Item] = ItemManager.find_items_by_type(ItemType.Type.EQUIPMENT)
	print("Found %d equipment items" % equipment.size())
	
	# Find items by property
	var rare_items: Array[Item] = ItemManager.find_items_by_property("rarity", "rare")
	print("Found %d rare items" % rare_items.size())
	
	# Find items matching multiple criteria
	var criteria: Dictionary = {
		"item_type": ItemType.Type.EQUIPMENT,
		"rarity": "common"
	}
	var common_equipment: Array[Item] = ItemManager.find_items_by_properties(criteria)
	print("Found %d common equipment items" % common_equipment.size())
	
	# Get specific item
	var sword: Item = ItemManager.get_item("sword_001")
	if sword != null:
		print("Found sword: %s" % sword.name)

## Example 4: Item serialization
func _example_serialization() -> void:
	print("\n=== Example 4: Serialization ===")
	
	var item: Item = Item.new("test_001", "Test Item", "A test item")
	item.set_property("test_prop", 42)
	item.set_property("nested", {"key": "value"})
	
	# Serialize
	var data: Dictionary = item.to_dict()
	print("Serialized item: %s" % JSON.stringify(data))
	
	# Deserialize
	var new_item: Item = Item.new()
	if new_item.from_dict(data):
		print("Deserialized item: %s" % new_item.name)
		print("Test property: %s" % new_item.get_property("test_prop"))

## Example of event subscription (if EventBus is available)
func _setup_event_subscriptions() -> void:
	if not Engine.has_singleton("EventBus"):
		return
	
	var eventbus = Engine.get_singleton("EventBus")
	
	# Subscribe to item events
	eventbus.subscribe(ItemCreatedEvent, _on_item_created)
	eventbus.subscribe(ItemUpdatedEvent, _on_item_updated)
	eventbus.subscribe(ItemDeletedEvent, _on_item_deleted)

func _on_item_created(event: ItemCreatedEvent) -> void:
	print("Event: Item created - %s (%s)" % [event.item.name, event.item_id])

func _on_item_updated(event: ItemUpdatedEvent) -> void:
	print("Event: Item updated - %s (Changed: %s)" % [event.item_id, event.changed_properties])

func _on_item_deleted(event: ItemDeletedEvent) -> void:
	print("Event: Item deleted - %s" % event.item_id)

