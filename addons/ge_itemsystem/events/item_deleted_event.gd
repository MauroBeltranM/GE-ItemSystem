## Event published when an item is deleted.
## Compatible with EventBus BaseEvent.
class_name ItemDeletedEvent
extends RefCounted

## Event ID (for BaseEvent compatibility)
var event_id: String

## Timestamp (for BaseEvent compatibility)
var timestamp: float

## ID of the deleted item
var item_id: String

func _init(p_item_id: String = ""):
	event_id = _generate_uuid()
	timestamp = Time.get_ticks_msec() / 1000.0
	item_id = p_item_id

## Generates a simple UUID for event identification
func _generate_uuid() -> String:
	return "%d_%d" % [Time.get_ticks_msec(), randi()]

## Validates the event (for BaseEvent compatibility)
func validate() -> bool:
	return not item_id.is_empty()

