extends Node

var container_manager : ContainerManager

#var tier_1_item : Array[Item] = [preload("res://Resources/items/item_hull_component.tres")]
var tier_1_item : Array[Item] = [preload("res://Resources/items/item_iron_ore.tres")]
var tier_1_amount : int = 5
var tier_1_completed : bool = false

var forward_cell_offset : Vector3i
var grid_position : Vector3i

func _ready() -> void:
	container_manager = get_own_container_manager()
	container_manager.add_slot(84, tier_1_item)




func get_own_container_manager() -> ContainerManager:
	if get_parent().has_node("ContainerManager"):
		return get_parent().get_node("ContainerManager")
	return null



func _physics_process(delta: float) -> void:
	if container_manager.get_items_in_slot(0).count(tier_1_item) == tier_1_amount:
		tier_1_completed = true
		print("YIPEEEE")
