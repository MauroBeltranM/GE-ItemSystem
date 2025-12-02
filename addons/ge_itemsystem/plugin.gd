## Plugin script for GE-ItemSystem.
## Registers ItemManager as autoload singleton.
@tool
extends EditorPlugin

func _enter_tree():
	# Add ItemManager as autoload singleton
	add_autoload_singleton("ItemManager", "res://addons/ge_itemsystem/core/item_manager.gd")

func _exit_tree():
	# Remove autoload singleton
	remove_autoload_singleton("ItemManager")

