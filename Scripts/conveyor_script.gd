extends Node3D

var grid_position: Vector3i
var debugname = "conveyorinator"

var conveyor_contents : Array

#the offset required to see where the forward cell is
var forward_cell_offset : Vector3i


var container_manager
var container_manager_node
func _ready() -> void:
	container_manager = preload("res://Scenes/Container_manager.tscn")
	container_manager_node = container_manager.instantiate()
	container_manager_node.set_max_items(1)
	self.add_child(container_manager_node)
	self.name = debugname
	add_to_group("conveyors")



func update_connections():
	check_neighbor(forward_cell_offset)

func check_neighbor(offset: Vector3i) -> Node3D:
	var pos = grid_position + offset
	if BuildingManager.occupied_cells.has(pos):
		return BuildingManager.occupied_cells[pos]
	return null


#TODO todo, should visibly display the contents ingame somehow, using the mesh maybe
func render_contents(contents):
	for thing in contents:
		print("the container has a ", thing.item_name, " in it.")
	return

func _physics_process(_delta: float) -> void:
	conveyor_contents = container_manager_node.get_items()
	render_contents(conveyor_contents)
	
	
