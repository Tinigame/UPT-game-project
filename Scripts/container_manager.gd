class_name ContainerManager
extends Node3D

# Each slot is:
# { contents: [], capacity: int, allowed_types: [] }
var slots: Array = []

var debugitem
signal space_changed(has_space: bool)

func _ready() -> void:
	debugitem = preload("res://Resources/items/item_conveyor.tres")

# Adds a new slot with capacity and optional allowed item types
func add_slot(capacity: int, allowed_types: Array = []):
	# allowed_types example: ["iron_ore", "coal"]
	slots.append({
		"contents": [],
		"capacity": capacity,
		"allowed_types": allowed_types
	})
	emit_signal("space_changed", has_any_space())

func set_max_items_for_slot(slot_index: int, new_capacity: int) -> void:
	if slot_index < 0 or slot_index >= slots.size():
		return
	slots[slot_index]["capacity"] = new_capacity
	emit_signal("space_changed", has_any_space())

func add_item_to_slot(item, slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= slots.size():
		return false

	var slot = slots[slot_index]

	# Check if this slot has a filter and the item matches
	if slot["allowed_types"].size() > 0 and not (item.item_type in slot["allowed_types"]):
		return false

	if slot["contents"].size() < slot["capacity"]:
		slot["contents"].append(item)
		emit_signal("space_changed", has_any_space())
		return true
	return false

func remove_item_from_slot(item, slot_index: int) -> void:
	if slot_index < 0 or slot_index >= slots.size():
		return
	var slot = slots[slot_index]
	if slot["contents"].has(item):
		slot["contents"].erase(item)
		emit_signal("space_changed", has_any_space())

func get_items_in_slot(slot_index: int) -> Array:
	if slot_index < 0 or slot_index >= slots.size():
		return []
	return slots[slot_index]["contents"]

func has_space_for_item_in_slot(item, slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= slots.size():
		return false

	var slot = slots[slot_index]
	if slot["allowed_types"].size() > 0 and not (item.item_type in slot["allowed_types"]):
		return false

	return slot["contents"].size() < slot["capacity"]

func has_any_space() -> bool:
	for slot in slots:
		if slot["contents"].size() < slot["capacity"]:
			return true
	return false

# Debug function
func debug_populate_slot(slot_index: int):
	print("DEBUGITEM CLASS: ", debugitem, debugitem.get_class())
	add_item_to_slot(debugitem, slot_index)

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug_populate_containers"):
		print("populating slot 0")
		debug_populate_slot(0)
