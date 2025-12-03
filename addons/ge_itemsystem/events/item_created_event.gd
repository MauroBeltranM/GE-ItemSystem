## Event published when an item is created/registered.
## Compatible with EventBus through EventCompatible base class.
class_name ItemCreatedEvent
extends EventCompatible

## ID of the created item
var item_id: String

## Reference to the created item
var item: Item

func _init(p_item_id: String = "", p_item: Item = null):
	super._init()
	item_id = p_item_id
	item = p_item

func validate() -> bool:
	return not item_id.is_empty() and item != null
