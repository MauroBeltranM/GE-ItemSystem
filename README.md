# GE-ItemSystem

Agnostic item system for Godot 4.x with extensible properties, persistence, and event integration.

## Description

GE-ItemSystem is a pure data item management system designed to be completely agnostic and reusable. Items are data-only (no executable behavior) - behavior like "use", "equip", or "consume" belongs to external systems (InventorySystem, EquipmentSystem, etc.).

## Features

- ✅ **Agnostic**: Does not depend on specific systems, works with any game
- ✅ **Pure Data**: Items are data-only, no executable behavior
- ✅ **Extensible**: Flexible property system for custom game data
- ✅ **Type-Safe**: Full typing in GDScript
- ✅ **Clean Code**: Separation of concerns, low coupling
- ✅ **Persistence**: Integration with PersistenceSystem via adapter
- ✅ **Events**: Integration with EventBus via adapter
- ✅ **Modular**: Easy to integrate with other systems

## Philosophy

**Items are pure data** - they define WHAT an item is (properties), not WHAT it does (behavior).

- ✅ ItemSystem defines: id, name, description, type, properties
- ❌ ItemSystem does NOT define: use(), equip(), consume() - these belong to InventorySystem, EquipmentSystem, etc.

This design ensures maximum reusability and prevents coupling to specific game logic.

## Installation

1. Copy the `addons/ge_itemsystem` folder to your Godot project
2. Go to `Project > Project Settings > Plugins`
3. Enable the "GE ItemSystem" plugin
4. ItemManager will automatically load as Autoload

## Basic Usage

### 1. Create and Register Items

```gdscript
# Create a basic item
var sword = Item.new("sword_001", "Iron Sword", "A basic iron sword")
sword.item_type = ItemType.Type.EQUIPMENT
sword.set_property("attack", 10)
sword.set_property("rarity", "common")

# Register the item
ItemManager.register_item(sword)
```

### 2. Items with Custom Properties

```gdscript
var potion = Item.new("potion_001", "Health Potion", "Restores 50 HP")
potion.item_type = ItemType.Type.CONSUMABLE
potion.set_property("heal_amount", 50)
potion.set_property("value", 25)
potion.set_property("weight", 0.5)

# Custom game-specific properties
potion.set_property("effect_duration", 5.0)
potion.set_property("cooldown", 10.0)

ItemManager.register_item(potion)
```

### 3. Search and Filter Items

```gdscript
# Find all equipment items
var equipment = ItemManager.find_items_by_type(ItemType.Type.EQUIPMENT)

# Find items by property
var rare_items = ItemManager.find_items_by_property("rarity", "rare")

# Find items matching multiple criteria
var criteria = {
    "rarity": "common",
    "value": 100  # Note: This searches in properties, not direct fields
}
var results = ItemManager.find_items_by_properties(criteria)

# Get specific item
var sword = ItemManager.get_item("sword_001")
```

### 4. Access Item Properties

```gdscript
var item = ItemManager.get_item("sword_001")

# Get custom property
var attack = item.get_property("attack", 0)

# Use helper methods for common properties
var rarity = item.get_rarity()
var value = item.get_value()
var weight = item.get_weight()
var durability = item.get_durability()

# Check if property exists
if item.has_property("custom_stat"):
    var stat = item.get_property("custom_stat")
```

## Item Types

The system provides common item types via `ItemType` enum:

- `CONSUMABLE` - Potions, food, etc.
- `EQUIPMENT` - Weapons, armor
- `QUEST` - Quest items
- `MATERIAL` - Crafting materials
- `MISC` - Miscellaneous
- `CUSTOM` - For custom types (use string in properties)

## Property System

Items support a flexible property system for custom game data:

```gdscript
# Simple properties
item.set_property("attack", 10)
item.set_property("defense", 5)

# Complex properties
item.set_property("stats", {
    "strength": 10,
    "agility": 5,
    "intelligence": 3
})

# Nested properties
item.set_property("effects", [
    {"type": "poison", "damage": 5},
    {"type": "slow", "duration": 3.0}
])
```

## Integration with PersistenceSystem

Register the adapter to enable save/load functionality:

```gdscript
# In your game initialization
var adapter = ItemSystemPersistenceAdapter.new()
PersistenceManager.register_adapter(adapter)

# Items will be automatically saved/loaded with game saves
PersistenceManager.save_game("slot1")
PersistenceManager.load_game("slot1")
```

## Integration with EventBus

The system automatically publishes events when items are created, updated, or deleted:

```gdscript
# Subscribe to item events
EventBus.subscribe(ItemCreatedEvent, _on_item_created)
EventBus.subscribe(ItemUpdatedEvent, _on_item_updated)
EventBus.subscribe(ItemDeletedEvent, _on_item_deleted)

func _on_item_created(event: ItemCreatedEvent):
    print("Item created: %s" % event.item.name)
```

## Project Structure

```
addons/ge_itemsystem/
├── plugin.cfg
├── plugin.gd
├── core/
│   ├── item.gd                    # Item class (pure data)
│   ├── item_manager.gd           # Singleton manager
│   └── item_type.gd              # Item type enum
├── adapters/
│   ├── persistence_adapter.gd    # PersistenceSystem adapter
│   └── eventbus_adapter.gd        # EventBus adapter
├── events/
│   ├── item_created_event.gd
│   ├── item_updated_event.gd
│   └── item_deleted_event.gd
└── examples/
    └── basic_example.gd
```

## Main API

### ItemManager

- `register_item(item: Item)` - Registers an item
- `get_item(item_id: String) -> Item` - Gets item by ID
- `remove_item(item_id: String)` - Removes an item
- `update_item(item: Item)` - Updates an item
- `find_items_by_type(type: ItemType.Type) -> Array[Item]` - Finds by type
- `find_items_by_property(key: String, value: Variant) -> Array[Item]` - Finds by property
- `find_items_by_properties(criteria: Dictionary) -> Array[Item]` - Finds by multiple criteria
- `get_all_items() -> Array[Item]` - Gets all items
- `get_item_count() -> int` - Gets item count
- `has_item(item_id: String) -> bool` - Checks if item exists
- `clear_all()` - Clears all items

### Item

- `set_property(key: String, value: Variant)` - Sets a property
- `get_property(key: String, default: Variant) -> Variant` - Gets a property
- `has_property(key: String) -> bool` - Checks if property exists
- `remove_property(key: String)` - Removes a property
- `get_all_properties() -> Dictionary` - Gets all properties
- `get_rarity() -> String` - Helper for rarity
- `get_value() -> int` - Helper for value
- `get_weight() -> float` - Helper for weight
- `get_durability() -> int` - Helper for durability
- `to_dict() -> Dictionary` - Serializes to Dictionary
- `from_dict(data: Dictionary) -> bool` - Deserializes from Dictionary
- `duplicate_item() -> Item` - Creates a copy

## What ItemSystem Does NOT Include

By design, ItemSystem does NOT include:

- ❌ **Stack size** - Belongs to InventorySystem
- ❌ **Executable behavior** (use, equip, consume) - Belongs to InventorySystem, EquipmentSystem, etc.
- ❌ **Inventory logic** - Belongs to InventorySystem
- ❌ **Equipment logic** - Belongs to EquipmentSystem
- ❌ **Crafting logic** - Belongs to CraftingSystem

This keeps ItemSystem pure, agnostic, and reusable across different games.

## Requirements

- Godot 4.0+
- GDScript
- GE-PersistenceSystem (optional, for save/load)
- GE-EventBus (optional, for events)

## License

MIT License - See LICENSE file for details

## Contributing

Contributions are welcome! Please read the contributing guidelines before submitting pull requests.

## Support

For issues, questions, or suggestions, please open an issue on the repository.
