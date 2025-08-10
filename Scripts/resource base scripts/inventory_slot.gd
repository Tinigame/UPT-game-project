class_name InventorySlot
extends Resource

@export var allowed_item: Resource = null  # null means anything allowed
@export var capacity: int = 1
var contents: Array[Item] = []

func has_space_for(item: Item) -> bool:
	if allowed_item and item.resource_path != allowed_item.resource_path:
		return false
	return contents.size() < capacity

func add_item(item: Item) -> bool:
	if has_space_for(item):
		contents.append(item)
		return true
	return false

func remove_item(item: Item) -> bool:
	if contents.has(item):
		contents.erase(item)
		return true
	return false
