extends Node

var items = {
	"iron": preload("res://Resources/items/item_iron_ore.tres"),
	"copper": preload("res://Resources/items/item_copper_ore.tres"),
	"conveyor" : preload("res://Resources/items/item_conveyor.tres"),
	"assembler" : preload("res://Resources/items/item_assembler.tres"),
	#imported models are cursed, dont preload things with them.
	"mining drill" : load("res://Resources/items/item_mining_drill.tres"),
}

func get_item_resource(item_name: String) -> Item:
	if items.has(item_name):
		return items[item_name]
	else:
		push_warning("Resource not found for: " + item_name)
		return null



#hopefully makes sure the item is infact an item
func _ready():
	for _name in ItemDatabase.items.keys():
		var res = ItemDatabase.get_item_resource(_name)
		if not (res is Item):
			push_error(_name + " is not an Item! It's a " + str(res))
