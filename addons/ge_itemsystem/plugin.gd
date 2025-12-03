## Plugin for GE-ItemSystem.
## Registers ItemManager as autoload singleton.
@tool
extends EditorPlugin

const AUTOLOAD_NAME = "ItemManager"
const AUTOLOAD_PATH = "res://addons/ge_itemsystem/core/item_manager.gd"

func _enter_tree():
	# Register the autoload singleton
	add_autoload_singleton(AUTOLOAD_NAME, AUTOLOAD_PATH)

func _exit_tree():
	# Remove the autoload singleton when plugin is disabled
	remove_autoload_singleton(AUTOLOAD_NAME)
