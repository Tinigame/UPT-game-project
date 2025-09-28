extends Node

var recipes : = {
	"Buildings": {},
	"Intermediates": {},
	"Consumables": {},
}

func _ready():
	_load_recipes_from("res://Resources/recipes")

	for cat in recipes.keys():
		print("Loaded %d recipes in %s" % [recipes[cat].size(), cat])


#tries loading every recipe in the recipe folder then adds it to the database
func _load_recipes_from(path: String):
	var dir = DirAccess.open(path)
	if dir == null:
		push_error("RecipeDatabase: directory not found: " + path)
		return

	dir.list_dir_begin()
	var fname = dir.get_next()
	while fname != "":
		if fname.ends_with(".tres") or fname.ends_with(".tres.remap") or fname.ends_with(".res"):
			var res_path = path + "/" + fname
			var resource = load(res_path)
			if resource is Recipe:
				if not recipes.has(resource.recipe_tab):
					recipes[resource.recipe_tab] = "Buildings"
				recipes[resource.recipe_tab][resource.recipe_name] = resource
		fname = dir.get_next()
	dir.list_dir_end()


func get_recipe_resource(recipe_category: String, recipe_name: String) -> Recipe:
	if recipes.has(recipe_category):
		var recipe_list = recipes[recipe_category]
		if recipe_list.has(recipe_name):
			return recipe_list[recipe_name]
	push_warning("Recipe not found: %s/%s" % [recipe_category, recipe_name])
	return null


func get_all_recipes(recipe_category: String) -> Dictionary:
	return recipes.get(recipe_category, {})
