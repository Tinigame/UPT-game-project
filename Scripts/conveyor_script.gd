extends Node3D

var grid_position: Vector3i
var debugname = "conveyorinator"

#the offset required to see where the forward cell is
var forward_cell_offset : Vector3i

func _ready() -> void:
	var container_manager = preload("res://Scenes/Container_manager.tscn")
	var container_manager_node = container_manager.instantiate()
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
