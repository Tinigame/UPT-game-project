extends Node3D

var grid_position: Vector3i
var debugname = "conveyorinator"

var conveyor_contents : Array

#the offset required to see where the forward cell is
var forward_cell_offset : Vector3i

var container_manager
func _ready() -> void:
	container_manager = get_own_container_manager()
	self.name = debugname
	add_to_group("conveyors")
	summon_rendering_mesh()

func get_own_container_manager() -> ContainerManager:
	if get_parent().has_node("ContainerManager"):
		return get_parent().get_node("ContainerManager")
	return null


func update_connections():
	check_neighbor(forward_cell_offset)

func check_neighbor(offset: Vector3i) -> Node3D:
	var pos = grid_position + offset
	if BuildingManager.occupied_cells.has(pos):
		return BuildingManager.occupied_cells[pos]
	else:
		return null


#TODO todo, should visibly display the contents ingame somehow, using the mesh maybe
var item_mesh = MeshInstance3D.new()
func summon_rendering_mesh():
	item_mesh.mesh = BoxMesh.new()
	item_mesh.position = self.position + Vector3(0, 1, 0)
	item_mesh.scale = Vector3(0.5, 0.5, 0.5)
	item_mesh.hide()
	add_child(item_mesh)


func render_contents(item):
	item_mesh.show()
	item_mesh.mesh = item.item_mesh
	item_mesh.scale = Vector3(0.5, 0.5, 0.5)
	item_mesh.position = self.position + Vector3(0, 1, 0)


var send_delay := 1.0  # seconds to wait before sending next item
var time_since_last_send := 0.0
var timer_active := false  # track whether the timer is running
var last_contents := []
func _physics_process(_delta: float) -> void:
	conveyor_contents = container_manager.get_items()

	# Show or hide the item mesh as before
	if conveyor_contents != last_contents:
		if conveyor_contents.size() > 0:
			render_contents(conveyor_contents[0])
		else:
			item_mesh.hide()
	
	# Timer control: start or reset timer based on items presence
	if conveyor_contents.size() > 0:
		# If timer not active, start it
		if not timer_active:
			timer_active = true
			time_since_last_send = 0.0  # reset timer on new item arrival
	else:
		# No items, stop timer and hide mesh
		timer_active = false
		time_since_last_send = 0.0
		item_mesh.hide()

	# Only count time and send if timer is active
	if timer_active:
		time_since_last_send += _delta
		if time_since_last_send >= send_delay:
			var neighbor = check_neighbor(forward_cell_offset)
			if neighbor != null and conveyor_contents.size() > 0:
				if neighbor.container_has_space == true:
					var item_to_move = conveyor_contents[0]
					if neighbor.container_manager.has_space_for_item(item_to_move):
						neighbor.container_manager.add_item(item_to_move)
						container_manager.remove_item(item_to_move)
						time_since_last_send = 0.0  # restart timer after sending
					else:
						# neighbor full, maybe pause or wait for next frame
						pass
