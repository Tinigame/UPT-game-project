extends Node3D
class_name HandAssembler

var container_manager: ContainerManager

var input_slots: PackedInt32Array = []
var output_slots: PackedInt32Array = []

var current_recipe: Recipe = null
var is_crafting: bool = false


func _ready() -> void:
	# Find sibling container_manager (assumes HandAssembler is a child of Player)
	if get_parent().has_node("ContainerManager"):
		container_manager = get_parent().get_node("ContainerManager")
	else:
		push_error("HandAssembler could not find sibling ContainerManager!")
		return

	self.name = "HandAssembler"


# Called externally to set what to craft
func set_recipe(recipe: Recipe) -> void:
	if container_manager == null:
		return

	current_recipe = recipe
	_set_container_slots()

	# Validate slot counts
	assert(recipe.recipe_ingredients.size() == input_slots.size(), 
		"HandAssembler: input_slots count mismatch")
	assert(recipe.recipe_products.size() == output_slots.size(), 
		"HandAssembler: output_slots count mismatch")

	# Craft instantly once
	if _has_required_inputs() and _outputs_have_space():
		_consume_inputs()
		PlayerUI.update_menu()
		_craft_once()
		PlayerUI.update_menu()


func _set_container_slots() -> void:
	container_manager.clear_slots()
	input_slots.clear()
	output_slots.clear()

	# Inputs
	for ingredient in current_recipe.recipe_ingredients:
		var ing_types: Array = [ingredient.item]
		var slot_index: int = container_manager.add_slot(84, ing_types)
		input_slots.append(slot_index)

	# Outputs
	for product in current_recipe.recipe_products:
		var prod_types: Array = [product.item]
		var slot_index: int = container_manager.add_slot(84, prod_types)
		output_slots.append(slot_index)


func _has_required_inputs() -> bool:
	for i in range(current_recipe.recipe_ingredients.size()):
		var need = current_recipe.recipe_ingredients[i]
		var slot: int = input_slots[i]

		var count: int = container_manager.count_item_in_slot(need.item, slot)
		if count < need.amount:
			return false
	return true


func _outputs_have_space() -> bool:
	# Minimal check: ensure each output slot can fit at least the required items
	for i in range(current_recipe.recipe_products.size()):
		var want = current_recipe.recipe_products[i]
		var slot: int = output_slots[i]

		var free: int = container_manager.slot_free_space(slot)
		if free < want.amount:
			return false
	return true


func _consume_inputs() -> void:
	for i in range(current_recipe.recipe_ingredients.size()):
		var need = current_recipe.recipe_ingredients[i]
		var slot: int = input_slots[i]

		var removed: int = container_manager.remove_n_of_item_from_slot(
			need.item, need.amount, slot
		)
		if removed != need.amount:
			push_warning("HandAssembler: consumed less than required, input mismatch.")


func _craft_once() -> void:
	for i in range(current_recipe.recipe_products.size()):
		var product = current_recipe.recipe_products[i]
		var slot: int = output_slots[i]

		for k in range(product.amount):
			var ok: bool = container_manager.add_item_to_slot(product.item, slot)
			if not ok:
				push_warning("HandAssembler: output slot full while crafting!")
				break
