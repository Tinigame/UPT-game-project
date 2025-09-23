extends Node

var container_manager : ContainerManager


var tier_1_item : Array = [preload("res://Resources/items/item_hull_component.tres")] 
var tier_1_amount : int = 50
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
	var amount = container_manager.count_item_in_slot(tier_1_item[0], 0)
	if amount >= tier_1_amount:
		tier_1_completed = true
		print("YIPEEEE")
