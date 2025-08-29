extends Node3D
class_name HandAssembler

var container_manager: ContainerManager

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

	# Craft instantly once
	if _has_required_inputs():
		_consume_inputs()
		print("we eated the inputs")
		PlayerUI.update_menu()
		_craft_once()
		print("we crafted the outputs")
		PlayerUI.update_menu()


func _has_required_inputs() -> bool:
	for i in range(current_recipe.recipe_ingredients.size()):
		var need = current_recipe.recipe_ingredients[i]
		var slot : int = 0

		var count : int = container_manager.count_item_in_slot(need.item, slot)
		if count < need.amount:
			print("missing required ingridients")
			return false
	return true



func _consume_inputs() -> void:
	for i in range(current_recipe.recipe_ingredients.size()):
		var need = current_recipe.recipe_ingredients[i]
		var slot: int = 0

		var removed: int = container_manager.remove_n_of_item_from_slot(need.item, need.amount, slot)
		
		PlayerUI.update_menu()
		
		if removed != need.amount:
			push_warning("HandAssembler: consumed less than required, input mismatch.")


func _craft_once() -> void:
	for i in range(current_recipe.recipe_products.size()):
		var product = current_recipe.recipe_products[i]
		var slot: int = 0

		for k in range(product.amount):
			var ok: bool = container_manager.add_item_to_slot(product.item, slot)
			if not ok:
				push_warning("HandAssembler: output slot full while crafting!")
				break
		
		PlayerUI.update_menu()
