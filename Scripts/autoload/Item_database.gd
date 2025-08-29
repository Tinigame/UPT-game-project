extends Node

var items = {
	"iron": preload("res://Resources/items/item_iron_ore.tres"),
	"copper": preload("res://Resources/items/item_copper_ore.tres"),
	"conveyor" : preload("res://Resources/items/item_conveyor.tres"),
	"assembler" : preload("res://Resources/items/item_assembler.tres"),
	"mining drill" : preload("res://Resources/items/item_assembler.tres"),
}

func get_item_resource(item_name: String) -> Resource:
	if items.has(item_name):
		return items[item_name]
	else:
		push_warning("Resource not found for: " + item_name)
		return null
