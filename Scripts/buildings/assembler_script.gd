extends Node3D

var grid_position : Vector3i
var forward_cell_offset : Vector3i
var container_manager : ContainerManager

@export var input_slots : PackedInt32Array = [0]   # one per ingredient
@export var output_slots : PackedInt32Array = [1]     # one per product

var current_recipe : Recipe = null
var is_crafting : bool = false
var crafting_timer : Timer

var cached_neighbor: Node3D = null

var debugname = "assemblinator"

func _ready() -> void:
	self.name = debugname

	container_manager = get_own_container_manager()
	crafting_timer = Timer.new()
	crafting_timer.one_shot = true
	add_child(crafting_timer)
	crafting_timer.connect("timeout", _on_crafting_complete)
	add_to_group("assemblers")
	
	set_recipe(Globals.debug_recipe)


#sets the recipe then calls the array rebuilder
func set_recipe(recipe: Recipe) -> void:
	current_recipe = recipe
#	print("our recipe is ", current_recipe.recipe_name)
	
	set_container_slots()
	
	# (Optional) validate slot counts
	assert(recipe.recipe_ingredients.size() == input_slots.size(), "input_slots count must match number of ingredients")
	assert(recipe.recipe_products.size() == output_slots.size(), "output_slots count must match number of products")



func set_container_slots():

	container_manager.clear_slots()
	input_slots.clear()
	output_slots.clear()

	# Inputs
	for ingridient in current_recipe.recipe_ingredients:
		var ingridients : Array = [ingridient.item] 
		var slot_index = container_manager.add_slot(84, ingridients)
		input_slots.append(slot_index)
#		print("we added slot for: ", ingridient.item.item_name)

	# Outputs
	for product in current_recipe.recipe_products:
		var products : Array = [product.item] 
		var slot_index = container_manager.add_slot(84, products)
		output_slots.append(slot_index)
#		print("we added slot for: ", product.item.item_name)



#processes when valid
func _process(_delta: float) -> void:
	if is_crafting or current_recipe == null or container_manager == null:
		return
	if _has_required_inputs() and _outputs_have_space():
		_consume_inputs()
		_start_crafting()
	push_items()



#checks if the required inputs exist in all the input slots
func _has_required_inputs() -> bool:
	for i in range(current_recipe.recipe_ingredients.size()):
		var need = current_recipe.recipe_ingredients[i]
		var slot := input_slots[i]
		
		if container_manager.get_items_in_slot(slot):
			print("we have ", container_manager.get_items_in_slot(slot))
		
		if container_manager.count_item_in_slot(need.item, slot) < need.amount:
			return false
	return true



func has_space() -> bool:
	return get_parent().container_has_space



func _outputs_have_space() -> bool:
	# Minimal check: if ContainerManager exposes slot_free_space, use it.
	# Otherwise skip this and rely on add_item_to_slot() returning false when full.
	if container_manager.has_method("slot_free_space"):
		for i in range(current_recipe.recipe_products.size()):
			var want = current_recipe.recipe_products[i]
			var slot := output_slots[i]
			var free : int = container_manager.slot_free_space(slot)
			if free >= 0 and free < want.amount:
#				print("we dont have enough space in outputs")
				return false
	return true



#removes required amount of items from a slot according to the recipe
func _consume_inputs() -> void:
	for i in range(current_recipe.recipe_ingredients.size()):
		var need = current_recipe.recipe_ingredients[i]
		var slot := input_slots[i]
		var removed := container_manager.remove_n_of_item_from_slot(need.item, need.amount, slot)
		if removed != need.amount:
			# Shouldn't happen because we check first, but guard anyway
			push_warning("Assembler consumed less than required; check input logic.")
			# Rollback would go here if you want it.



func _start_crafting() -> void:
#	print("we started crafting!!")
	is_crafting = true
	crafting_timer.start(current_recipe.crafting_time)



#once crafting finishes add products to output slots, also try to push them out
func _on_crafting_complete() -> void:
	# Produce items to outputs
	for i in range(current_recipe.recipe_products.size()):
		var out = current_recipe.recipe_products[i]
		var slot := output_slots[i]
		for k in range(out.amount):
#			print("we made this many items: ", out.amount)
			var ok := container_manager.add_item_to_slot(out.item, slot)
#			print("we finished craftin ", out.item.item_name)
			if not ok:
				# Slot is full; you can buffer, drop, or pause here.
				break
	
	is_crafting = false



#tries to push the first item in the first output slot to the neighbor
func push_items() -> void:
	if cached_neighbor == null:
		return

	# Always talk to the neighbor’s container_manager directly
	var neighbor_cm: ContainerManager = cached_neighbor.container_manager
	if neighbor_cm == null:
		return

	# Push only from the FIRST output slot for simplicity
	if output_slots.size() == 0:
		return
	
	
	var out_slot := output_slots[0]
	var items := container_manager.get_items_in_slot(out_slot)
	if items.size() == 0:
		return

	var item_to_move = items[0]
	# ✅ use ContainerManager API directly instead of neighbor.container_has_space
	if neighbor_cm.has_space_for_item_in_slot(item_to_move, 0):
		if neighbor_cm.add_item_to_slot(item_to_move, 0):
			container_manager.remove_item_from_slot(item_to_move, out_slot)



func get_own_container_manager() -> ContainerManager:
	if get_parent().has_node("ContainerManager"):
		return get_parent().get_node("ContainerManager")
	return null



func update_connections():
	cached_neighbor = check_neighbor(forward_cell_offset)



func check_neighbor(neighbor_position: Vector3i) -> Node3D:
	if BuildingManager.occupied_cells.has(neighbor_position):
		return BuildingManager.occupied_cells[neighbor_position]
	return null
