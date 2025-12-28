extends Node3D
var placeholder_texture = preload("uid://catthc6he4qgc")

var grid_position: Vector3i
var debugname := "crosser"

var conveyor_contents: Array = []
var forward_cell_offset: Vector3i
var container_manager: ContainerManager = null

var time_since_last_send := 0.0
var timer_active := false
var send_delay := 1.0

#holy hell im not gonna lie what did the AI cook on this one, im sorry future self
#as long as it works???


# neighbor 2 tiles ahead (Node or null)
var cached_neighbor: Node3D = null
# also keep immediate front as fallback
var cached_front_neighbor: Node3D = null

func _ready() -> void:
	container_manager = get_own_container_manager()
	self.name = debugname
	add_to_group("crossers")
	summon_rendering_cube()
	ConveyorManager.register_conveyor(self)
	
	# ensure we have at least one slot
	if container_manager:
		container_manager.connect("space_changed", _on_container_space_changed)
		if container_manager.get_slot_count() == 0:
			container_manager.add_slot(1, [])
		conveyor_contents = container_manager.get_items_in_slot(0)
		container_manager.ui_mode = "single"

	# compute neighbors now (and rely on BuildingManager.update_conveyor_neighbors to call update_connections later)
	update_connections()

func get_own_container_manager() -> ContainerManager:
	if get_parent() and get_parent().has_node("ContainerManager"):
		return get_parent().get_node("ContainerManager")
	return null


func _on_container_space_changed(_has_space: bool) -> void:
	conveyor_contents = container_manager.get_items_in_slot(0)
	_process_contents_change()


func _process_contents_change() -> void:
	if conveyor_contents.size() > 0:
		render_contents(conveyor_contents[0])
		if not timer_active:
			timer_active = true
			time_since_last_send = 0.0
	else:
		if item_mesh:
			item_mesh.hide()
		timer_active = false
		time_since_last_send = 0.0


# Visual item representation
var item_mesh := MeshInstance3D.new()
var item_material := StandardMaterial3D.new()

func summon_rendering_cube():
	item_mesh.mesh = BoxMesh.new()
	item_material.albedo_texture = placeholder_texture
	item_material.uv1_triplanar = true
	item_material.uv1_scale = Vector3(1, 1, 1)
	item_mesh.mesh.surface_set_material(0, item_material)
	item_mesh.position = Vector3(0, 0.5, 0)
	item_mesh.scale = Vector3(0.5, 0.5, 0.5)
	item_mesh.hide()
	add_child(item_mesh)

func render_contents(item) -> void:
	if not item:
		return
	item_material.albedo_texture = item.item_sprite
	item_mesh.show()


# Called from BuildingManager when the world changed (neighbors added/removed)
func update_connections() -> void:
	# compute target 2 tiles ahead using a robust method:
	var target_pos := _compute_two_ahead_cell()
	var front_pos := _compute_front_cell()

	# fetch nodes if present
	if BuildingManager.occupied_cells.has(target_pos):
		cached_neighbor = BuildingManager.occupied_cells[target_pos]
	else:
		cached_neighbor = null

	if BuildingManager.occupied_cells.has(front_pos):
		cached_front_neighbor = BuildingManager.occupied_cells[front_pos]
	else:
		cached_front_neighbor = null

	# debug
	#print_debug("Crosser update_connections: grid=", grid_position, " front=", front_pos, " target2=", target_pos, " cached=", cached_neighbor, " front_cached=", cached_front_neighbor)


func _compute_front_cell() -> Vector3i:
	# If forward_cell_offset looks like an absolute position (equal to grid + something),
	# treat it as absolute, otherwise if it's a small vector like (0,0,1), treat as relative.
	if forward_cell_offset == null:
		# fallback: assume forward is north
		return grid_position + Vector3i(0, 0, -1)
	# detect absolute vs relative by magnitude: if roughly the same as grid_position, treat as absolute
	if forward_cell_offset.distance_to(grid_position) >= 1:
		# forward_cell_offset already absolute
		return forward_cell_offset
	else:
		# relative direction; add to grid_position
		return grid_position + forward_cell_offset

func _compute_two_ahead_cell() -> Vector3i:
	var front := _compute_front_cell()
	# two ahead = grid_position + (front - grid_position) * 2
	var dir := front - grid_position
	return grid_position + dir * 2


# ConveyorManager will call this via the registered loop; we need to expose the fields it expects:
func _process(delta: float) -> void:
	# handle timer for sending
	if timer_active:
		time_since_last_send += delta
		if time_since_last_send >= send_delay:
			_try_send()
			time_since_last_send = 0.0


func _try_send() -> void:
	if not container_manager:
		return
	var items := container_manager.get_items_in_slot(0)
	if items.size() == 0:
		return
	var item_to_move : Item = items[0]
	# Prefer two-ahead neighbor
	if cached_neighbor and cached_neighbor.container_manager:
		var ncm: ContainerManager = cached_neighbor.container_manager
		if ncm.has_space_for_item_in_slot(item_to_move, 0):
			if ncm.add_item_to_slot(item_to_move, 0):
				container_manager.remove_item_from_slot(item_to_move, 0)
				return
	# fallback to front neighbor
	if cached_front_neighbor and cached_front_neighbor.container_manager:
		var fcm: ContainerManager = cached_front_neighbor.container_manager
		if fcm.has_space_for_item_in_slot(item_to_move, 0):
			if fcm.add_item_to_slot(item_to_move, 0):
				container_manager.remove_item_from_slot(item_to_move, 0)
				return
	# nothing available - keep item (do not drop)
	return
