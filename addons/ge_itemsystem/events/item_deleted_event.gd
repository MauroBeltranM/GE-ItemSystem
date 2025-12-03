## Event published when an item is deleted.
## Compatible with EventBus through EventCompatible base class.
class_name ItemDeletedEvent
extends EventCompatible

## ID of the deleted item
var item_id: String

func _init(p_item_id: String = ""):
	super._init()
	item_id = p_item_id

func validate() -> bool:
	return not item_id.is_empty()
