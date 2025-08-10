extends Node3D

var grid_position: Vector3i
var debugname = "mininginator"

var conveyor_contents : Array

#the offset required to see where the forward cell is
var forward_cell_offset : Vector3i
var container_manager

#delays and timers for delaying item movement
var time_since_last_send := 0.0
var timer_active := false  # track whether the timer is running
var last_contents := []
var send_delay := 1.0  # seconds to wait before sending next item

var mining_ticker
var over_ores : PackedStringArray
var ores : Array

func set_over_ores(ores : PackedStringArray):
	over_ores = ores
	print(over_ores)


func _ready() -> void:
	container_manager = get_own_container_manager()
	self.name = debugname
	
	ores = get_unique_ore_resources(over_ores)
	mining_ticker = Timer.new()
	mining_ticker.wait_time = 1
	add_child(mining_ticker)
	mining_ticker.start()
	mining_ticker.connect("timeout", Callable(self, "mine_ore").bind(ores))
	
	if container_manager:
		container_manager.connect("space_changed", _on_container_space_changed)
		# Initialize contents now
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
		if not timer_active:
			timer_active = true
			time_since_last_send = 0.0
	else:
		timer_active = false
		time_since_last_send = 0.0



func get_own_container_manager() -> ContainerManager:
	if get_parent().has_node("ContainerManager"):
		return get_parent().get_node("ContainerManager")
	return null


var cached_neighbor: Node3D = null

func update_connections():
	cached_neighbor = check_neighbor(forward_cell_offset)

func check_neighbor(offset: Vector3i) -> Node3D:
	var pos = grid_position + offset
	if BuildingManager.occupied_cells.has(pos):
		return BuildingManager.occupied_cells[pos]
	else:
		return null

func get_unique_ore_resources(ore_names: Array) -> Array:
	var unique_ores : Array
	for ore_name in ore_names:
		if not unique_ores.has(ore_name):
			unique_ores.append(ore_name)

	var ore_resources = []
	for ore_name in unique_ores:
		var ore_res = ItemDatabase.get_item_resource(ore_name)
		if ore_res != null:
			ore_resources.append(ore_res)

	return ore_resources



func mine_ore(ores):
	for ore in ores:
		print("we added this to our ore buffer: ", ore)
		container_manager.add_item_to_slot(ore, 0)
