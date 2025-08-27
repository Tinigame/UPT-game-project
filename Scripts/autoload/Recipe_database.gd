extends Node

var building_recipes = {
	"eldritch belt duplication" = preload("res://Resources/recipes/debug_recipe.tres"),
	"belt making" = preload("res://Resources/recipes/conveyor_from_ore.tres")
}

var intermediates_recipes = {
	"eldritch belt duplication" = preload("res://Resources/recipes/debug_recipe.tres"),
}

var consumables_recipes = {
	"eldritch belt duplication" = preload("res://Resources/recipes/debug_recipe.tres"),
}

var recipes = {
	"buildings" = building_recipes,
	"intermediates" = intermediates_recipes,
	"consumables" = consumables_recipes,
}

func get_recipe_resource(recipe_category : String, recipe_name: String) -> Resource:
	var recipe_list = recipes[recipe_category]
	if recipe_list.has(recipe_name):
		return recipe_list[recipe_name]
	else:
		push_warning("Resource not found for: " + recipe_name)
		return null

func get_all_recipes(recipe_category : String):
	var recipe_list = recipes[recipe_category]
	return recipe_list
