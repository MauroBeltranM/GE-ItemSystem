## Adapter to communicate with EventBus in a decoupled way.
## This is the ONLY coupling point with EventBus in the entire ItemSystem.
## Allows ItemSystem to work with or without EventBus available.
class_name EventBusAdapter
extends RefCounted

## If EventBus is available
var _eventbus_available: bool = false

## Reference to EventBus (if available)
## NOTE: This is the ONLY coupling point with EventBus in the entire system
var _eventbus: Node = null

func _init():
	_check_eventbus_availability()

## Checks if EventBus is available
func _check_eventbus_availability() -> void:
	if Engine.has_singleton("EventBus"):
		_eventbus_available = true
		_eventbus = Engine.get_singleton("EventBus")
		return
	
	if ClassDB.class_exists("EventBus"):
		_eventbus_available = true
		var tree: SceneTree = Engine.get_main_loop() as SceneTree
		if tree != null:
			var root: Node = tree.root
			if root != null:
				var eventbus_node: Node = root.get_node_or_null("EventBus")
				if eventbus_node != null:
					_eventbus = eventbus_node
					return
	
	_eventbus_available = false

## Publishes an event through EventBus if available.
## @param event: The event to publish (must have event_id and timestamp fields for compatibility)
func publish_event(event: RefCounted) -> void:
	if not _eventbus_available or _eventbus == null:
		return
	
	if event == null:
		push_warning("EventBusAdapter: Attempt to publish null event")
		return
	
	if not _is_base_event_compatible(event):
		push_warning("EventBusAdapter: Event is not compatible with BaseEvent")
		return
	
	if _eventbus.has_method("publish"):
		_eventbus.publish(event)
	else:
		push_warning("EventBusAdapter: EventBus does not have publish() method")

## Checks if an event is compatible with EventBus
func _is_base_event_compatible(event: RefCounted) -> bool:
	if event == null:
		return false
	
	if not event.has("event_id") or not event.has("timestamp"):
		return false
	
	if event.has_method("validate"):
		var validation_result_variant: Variant = event.validate()
		if validation_result_variant is bool:
			var validation_result: bool = validation_result_variant as bool
			if not validation_result:
				return false
	
	return true

## Checks if EventBus is available
func is_eventbus_available() -> bool:
	return _eventbus_available

## Gets adapter information
func get_adapter_info() -> Dictionary:
	return {
		"eventbus_available": _eventbus_available,
		"eventbus_instance": _eventbus != null
	}

