# ConveyorManager.gd
extends Node3D

static var instance: ConveyorManager = null

var conveyors : Array = []
var update_interval := 0.5
var update_accumulator := 0.0

func _ready():
	instance = self

static func register_conveyor(conveyor):
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
	# Your conveyor update logic goes here (same as before)
	var contents = conveyor.container_manager.get_items()
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
				if neighbor.container_has_space == true:
					var item_to_move = contents[0]
					if neighbor.container_manager.has_space_for_item(item_to_move):
						neighbor.container_manager.add_item(item_to_move)
						conveyor.container_manager.remove_item(item_to_move)
						conveyor.time_since_last_send = 0.0
