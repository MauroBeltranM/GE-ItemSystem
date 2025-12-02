## Event published when an item is updated.
## Compatible with EventBus BaseEvent.
class_name ItemUpdatedEvent
extends RefCounted

## Event ID (for BaseEvent compatibility)
var event_id: String

## Timestamp (for BaseEvent compatibility)
var timestamp: float

## ID of the updated item
var item_id: String

## Reference to the updated item
var item: Item

## List of property keys that changed
var changed_properties: Array[String]

func _init(p_item_id: String = "", p_item: Item = null, p_changed_properties: Array[String] = []):
	event_id = _generate_uuid()
	timestamp = Time.get_ticks_msec() / 1000.0
	item_id = p_item_id
	item = p_item
	changed_properties = p_changed_properties.duplicate()

## Generates a simple UUID for event identification
func _generate_uuid() -> String:
	return "%d_%d" % [Time.get_ticks_msec(), randi()]

## Validates the event (for BaseEvent compatibility)
func validate() -> bool:
	return not item_id.is_empty() and item != null

