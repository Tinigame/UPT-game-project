extends Node3D

@export var output_offsets: Array[Vector3i] = []
@export var forward_cell_offset: Vector3i
var grid_position: Vector3i

var container_manager: ContainerManager
var output_index := 0

func _ready() -> void:
	container_manager = get_own_container_manager()
	add_to_group("splitters")
	
	match get_parent().building_direction:
		Enums.direction.UP:
			output_offsets = [
				Vector3i(-1, 0, 0),  # left
				Vector3i(1, 0, 0),   # right
				Vector3i(0, 0, -1)   # forward
			]
		Enums.direction.RIGHT:
			output_offsets = [
				Vector3i(0, 0, -1),
				Vector3i(0, 0, 1),
				Vector3i(1, 0, 0)
			]
		Enums.direction.DOWN:
			output_offsets = [
				Vector3i(-1, 0, 0),
				Vector3i(1, 0, 0),
				Vector3i(0, 0, 1)
			]
		Enums.direction.LEFT:
			output_offsets = [
				Vector3i(0, 0, -1),
				Vector3i(0, 0, 1),
				Vector3i(-1, 0, 0)
			]
	
	
	if container_manager:
		container_manager.add_slot(1, [])
		container_manager.connect("space_changed", _on_space_changed)

func get_own_container_manager() -> ContainerManager:
	if get_parent().has_node("ContainerManager"):
		return get_parent().get_node("ContainerManager")
	return null

func _on_space_changed(_has_space: bool) -> void:
	var items = container_manager.get_items_in_slot(0)
	if items.size() > 0:
		_send_item(items[0])

func _send_item(item: Item):
	var outputs := []
	for offset in output_offsets:
		var cell = grid_position + offset
		if BuildingManager.occupied_cells.has(cell):
			var neighbor = BuildingManager.occupied_cells[cell]
			if neighbor.has_node("ContainerManager"):
				outputs.append(neighbor)

	if outputs.is_empty():
		return
	
	var target = outputs[output_index % outputs.size()]
	output_index += 1

	var neighbor_cm: ContainerManager = target.get_node("ContainerManager")

	if neighbor_cm.has_space_for_item_in_slot(item, 0):
		if neighbor_cm.add_item_to_slot(item, 0):
			container_manager.remove_item_from_slot(item, 0)


var cached_neighbor: Node3D = null
func update_connections():
	cached_neighbor = check_neighbor(forward_cell_offset)

func check_neighbor(neighbor_position: Vector3i) -> Node3D:
	if BuildingManager.occupied_cells.has(neighbor_position):
		return BuildingManager.occupied_cells[neighbor_position]
	else:
		return null
