class_name ContainerManager
extends Node3D

#Each slot is:
#{ contents: [], capacity: int, allowed_types: [] }
var slots: Array = []


signal space_changed(has_space: bool)

var is_player_inventory : bool = false

var debugitem : Item



# Adds a new slot with capacity and optional allowed item types
func add_slot(capacity: int, allowed_types: Array = []) -> int:
	slots.append({
		"contents": [],
		"capacity": capacity,
		"allowed_types": allowed_types
	})
	emit_signal("space_changed", has_any_space())
	return slots.size() - 1


func clear_slots():
	slots.clear()
	emit_signal("space_changed", has_any_space())


#returns the number of total slots
func get_slot_count() -> int:
	return slots.size()



#counts the amount of similar items in the same slot
func count_item_in_slot(item: Item, slot: int) -> int:
	var n := 0
	for thing in get_items_in_slot(slot):
		if thing == item:
			n += 1
	return n



#removes N amount of items from a slot, then returns how many were removed
func remove_n_of_item_from_slot(item: Item, n: int, slot: int) -> int:
	var items_removed := 0

	var items := get_items_in_slot(slot).duplicate()

	for i in range(items.size() - 1, -1, -1):
		if items[i] == item:
			remove_item_from_slot(items[i], slot)
			items_removed += 1
			if items_removed == n:
				break
	return items_removed



#sets the maximum amount of items that can fit in the specific slot
func set_max_items_for_slot(slot_index: int, new_capacity: int) -> void:
	if slot_index < 0 or slot_index >= slots.size():
		return
	slots[slot_index]["capacity"] = new_capacity
	emit_signal("space_changed", has_any_space())



#adds item to slot if it fits the slots filter, returns false if addition not possible
func add_item_to_slot(item : Item, slot_index: int) -> bool:
	
	#if invalid slot then return false
	if slot_index < 0 or slot_index >= slots.size():
		return false

	var slot = slots[slot_index]

	#Check if this slot has a filter and the item matches
	if slot["allowed_types"].size() > 0 and not (item in slot["allowed_types"]):
		print_debug("item not allowed by filter")
		return false

	#if slot has less than available capacity, add item
	if slot["contents"].size() < slot["capacity"]:
		slot["contents"].append(item)
		emit_signal("space_changed", has_any_space())
		return true
	return false



#removes item from the slot (obviously)
func remove_item_from_slot(item, slot_index: int) -> void:
	#if invalid slot then return
	if slot_index < 0 or slot_index >= slots.size():
		return
	
	var slot = slots[slot_index]
	
	#if item exists in the slot then remove it
	if slot["contents"].has(item):
		slot["contents"].erase(item)
		emit_signal("space_changed", has_any_space())



#returns the item from specified slot
func get_items_in_slot(slot_index: int) -> Array:
	#returns nuthin if slot index or slots are invalid
	if slot_index < 0 or slot_index >= slots.size():
		return []
	return slots[slot_index]["contents"]



#tbh no idea, gpt invention
func slot_free_space(slot_index: int) -> int:
	if slot_index < 0 or slot_index >= slots.size():
		return -1
	var slot = slots[slot_index]
	return slot["capacity"] - slot["contents"].size()


#returns true if the slot has space for more items of the same type
func has_space_for_item_in_slot(item, slot_index: int) -> bool:
	#if invalid slot then return
	if slot_index < 0 or slot_index >= slots.size():
		return false

	var slot = slots[slot_index]
	
	#checks if this slot has a filter and the item matches it
	if slot["allowed_types"].size() > 0 and not (item in slot["allowed_types"]):
		return false

	return slot["contents"].size() < slot["capacity"]



#returns true if the container has any space atall
func has_any_space() -> bool:
	for slot in slots:
		if slot["contents"].size() < slot["capacity"]:
			return true
	return false



# Debug function
func debug_populate_slot(slot_index: int):
	debugitem = load("res://Resources/items/item_conveyor.tres")
	print("DEBUGITEM CLASS: ", debugitem, debugitem.get_class())
	add_item_to_slot(debugitem, slot_index)
	PlayerUI.update_menu()



func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug_populate_containers"):
		print("populating slot 0")
		debug_populate_slot(0)
