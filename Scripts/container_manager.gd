extends Node3D

var max_items = 0
var free_slots = 0
var _content : Array[Item] = []

var debugitem

func _ready() -> void:
	debugitem = preload("res://Resources/items/conveyor_belt_item.tres")

func set_max_items(new_max_items):
	max_items = new_max_items
	free_slots = max_items


func add_item(item:Item):
	if free_slots > 0:
		free_slots -= 1
		_content.append(item)
	else:
		return


func remove_item(item:Item):
	_content.erase(item)
	free_slots += 1


func get_items() -> Array[Item]:
	return _content


func debug_populate_containers():
	add_item(debugitem)


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug_populate_containers"):
		print("populating containers")
		debug_populate_containers()
