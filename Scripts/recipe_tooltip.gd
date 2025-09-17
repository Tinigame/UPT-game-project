extends Panel

@onready var name_label = $VBoxContainer/RecipeName
@onready var ingredients_box = $VBoxContainer/IngredientsBox
@onready var products_box = $VBoxContainer/ProductsBox
@onready var time_label = $VBoxContainer/CraftingTimeLabel



func show_recipe(recipe: Recipe):
	name_label.text = recipe.recipe_name
	time_label.text = str("Craft time: ", recipe.crafting_time, "s")



	for child in ingredients_box.get_children():
		child.queue_free()
	for child in products_box.get_children():
		child.queue_free()



	#adds ingridients
	for slot in recipe.recipe_ingredients:
		var h = HBoxContainer.new()
		var tex = TextureRect.new()
		tex.texture = slot.item.item_sprite
		tex.custom_minimum_size = Vector2(32, 32)
		h.add_child(tex)
		h.add_child(Label.new())
		h.get_child(1).text = "x" + str(slot.amount)
		ingredients_box.add_child(h)



	#adds products
	for slot in recipe.recipe_products:
		var h = HBoxContainer.new()
		var tex = TextureRect.new()
		tex.texture = slot.item.item_sprite
		tex.custom_minimum_size = Vector2(32, 32)
		h.add_child(tex)
		h.add_child(Label.new())
		h.get_child(1).text = "x" + str(slot.amount)
		products_box.add_child(h)
