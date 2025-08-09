class_name ContainerManager
extends Node3D

var max_items := 0
var free_slots := 0
var _content: Array[Item] = []

var debugitem

signal space_changed(has_space: bool)

func _ready() -> void:
	debugitem = preload("res://Resources/items/conveyor_2.tres")

func set_max_items(new_max_items: int) -> void:
	max_items = new_max_items
	free_slots = max_items
	emit_signal("space_changed", free_slots > 0)

func add_item(item) -> bool:
	if free_slots > 0:
		free_slots -= 1
		_content.append(item)
		emit_signal("space_changed", free_slots > 0)
		return true
	return false

func remove_item(item: Item) -> void:
	if _content.has(item):
		_content.erase(item)
		free_slots += 1
		emit_signal("space_changed", free_slots > 0)

func get_items() -> Array[Item]:
	return _content

func has_space_for_item(_item: Item) -> bool:
	return free_slots > 0

func debug_populate_containers():
	print("DEBUGITEM CLASS: ", debugitem, debugitem.get_class())
	add_item(debugitem)
	emit_signal("space_changed", free_slots > 0)

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug_populate_containers"):
		print("populating containers")
		debug_populate_containers()
