# ConveyorManager.gd
extends Node3D

var instance: ConveyorManager = null

var conveyors : Array = []
var update_interval := 0.5
var update_accumulator := 0.0

func _ready():
	instance = self

func register_conveyor(conveyor):
	if instance == null:
		push_error("ConveyorManager not initialized")
		return
	instance.conveyors.append(conveyor)

func _process(delta: float) -> void:
	update_accumulator += delta
	if update_accumulator < update_interval:
		return
	update_accumulator = 0.0

	for conveyor in conveyors:
		update_conveyor(conveyor)



func update_conveyor(conveyor):
	var contents = conveyor.container_manager.get_items_in_slot(0)
	var timer_active = conveyor.timer_active
	var time_since_last_send = conveyor.time_since_last_send
	var send_delay = conveyor.send_delay

	if contents.size() > 0:
		conveyor.render_contents(contents[0])
		if not timer_active:
			conveyor.timer_active = true
			conveyor.time_since_last_send = 0.0
	else:
		conveyor.item_mesh.hide()
		conveyor.timer_active = false
		conveyor.time_since_last_send = 0.0

	if conveyor.timer_active:
		conveyor.time_since_last_send += update_interval
		if conveyor.time_since_last_send >= send_delay:
			
			var neighbor = conveyor.cached_neighbor
			
			if neighbor != null and contents.size() > 0:
				var item_to_move = contents[0]
				
				push_items(neighbor, conveyor, item_to_move)
				conveyor.time_since_last_send = 0.0


#tries to push the first item in the first output slot to the neighbor
func push_items(neighbor, conveyor, item_to_move) -> void:
	if neighbor == null:
#		print_debug("there is no neighbor")
		return
	var neighbor_cm: ContainerManager = neighbor.container_manager
	if neighbor_cm == null:
#		print_debug("there is no CM in neighbor")
		return

	if neighbor_cm.has_space_for_item_in_slot(item_to_move, 0):
#		print_debug("we have space for ", item_to_move)
		if neighbor_cm.add_item_to_slot(item_to_move, 0):
#			print_debug("we added ", item_to_move, " to slot 0")
			conveyor.container_manager.remove_item_from_slot(item_to_move, 0)
#			print_debug("we removed ", item_to_move, " from ourselves")
