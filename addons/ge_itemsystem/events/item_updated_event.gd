## Event published when an item is updated.
## Compatible with EventBus through BaseEvent base class.
class_name ItemUpdatedEvent
extends BaseEvent

## ID of the updated item
var item_id: String

## Reference to the updated item
var item: Item

## List of property keys that changed
var changed_properties: Array[String]

func _init(p_item_id: String = "", p_item: Item = null, p_changed_properties: Array[String] = []):
	super._init()
	item_id = p_item_id
	item = p_item
	changed_properties = p_changed_properties.duplicate()

func validate() -> bool:
	return not item_id.is_empty() and item != null

func _to_string() -> String:
	return "[ItemUpdatedEvent: %s (%d properties)]" % [item_id, changed_properties.size()]
