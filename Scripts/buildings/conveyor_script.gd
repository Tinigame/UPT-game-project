extends Node3D

var grid_position: Vector3i
var debugname = "conveyorinator"

var conveyor_contents : Array

#the offset required to see where the forward cell is
var forward_cell_offset : Vector3i
var container_manager

#delays and timers for delaying item movement
var time_since_last_send := 0.0
var timer_active := false  # track whether the timer is running
var last_contents := []
var send_delay := 1.0  # seconds to wait before sending next item

func _ready() -> void:
	container_manager = get_own_container_manager()
	self.name = debugname
	add_to_group("conveyors")
	summon_rendering_mesh()
	ConveyorManager.register_conveyor(self)
	
	if container_manager:
		container_manager.connect("space_changed", _on_container_space_changed)
		# Initialize contents now
		container_manager.add_slot(1, [])
		conveyor_contents = container_manager.get_items_in_slot(0)
		last_contents = conveyor_contents.duplicate()

#the bool looks like it isnt used but for some reason it makes stuff more stable
func _on_container_space_changed(_has_space : bool):
	# Update contents when container changes
	conveyor_contents = container_manager.get_items_in_slot(0)
	# Then handle showing/hiding items or starting timer, etc
	_process_contents_change()


func _process_contents_change():
	if conveyor_contents.size() > 0:
		render_contents(conveyor_contents[0])
		if not timer_active:
			timer_active = true
			time_since_last_send = 0.0
	else:
		item_mesh.hide()
		timer_active = false
		time_since_last_send = 0.0



func get_own_container_manager() -> ContainerManager:
	if get_parent().has_node("ContainerManager"):
		return get_parent().get_node("ContainerManager")
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


var cached_neighbor: Node3D = null

func update_connections():
	cached_neighbor = check_neighbor(forward_cell_offset)

func check_neighbor(neighbor_position: Vector3i) -> Node3D:
	if BuildingManager.occupied_cells.has(neighbor_position):
		return BuildingManager.occupied_cells[neighbor_position]
	else:
		return null
