extends CanvasLayer

@onready var UI_base : PanelContainer = $CenterContainer/AspectRatioContainer/PanelContainer
@onready var inventory_splitter : HSplitContainer = $CenterContainer/AspectRatioContainer/PanelContainer/HSplitContainer
@onready var recipe_tabs: TabContainer = $"CenterContainer/AspectRatioContainer/PanelContainer/HSplitContainer/crafting menu/TabContainer"

var menu_open : bool = false

var inventory_item_list : ItemList
var recipe_item_list : ItemList

var current_container = null


func _ready() -> void:
	self.hide()


func open(container):
	if menu_open == true:
		return
	menu_open = true
	
	current_container = container
	
	UI_base.custom_minimum_size.x = get_viewport().size.x / 1.25
	UI_base.custom_minimum_size.y = get_viewport().size.y / 1.25
	inventory_splitter.split_offset = UI_base.custom_minimum_size.x / 2
	
	inventory_item_list = %InventoryList
	inventory_item_list.max_columns = container.get_slot_count()
#	print(inventory_item_list.max_columns, " collumns")
	
	for slot_index in range(container.get_slot_count()):
		var slot = container.slots[slot_index]
		for item in slot["contents"]:
			print("we got a ", item.item_name)
			var index = inventory_item_list.add_icon_item(item.item_sprite)
			inventory_item_list.set_item_text(index, item.item_name)
			inventory_item_list.set_item_metadata(index, item)
	
	
	
	recipe_item_list = recipe_tabs.get_current_tab_control().get_child(0)
	var category_recipes = RecipeDatabase.get_all_recipes(recipe_item_list.name)
	
	recipe_item_list.max_columns = len(category_recipes)
	
	for recipe in category_recipes.values():
		var index = recipe_item_list.add_icon_item(recipe.recipe_sprite)
		recipe_item_list.set_item_text(index, recipe.recipe_name)
		inventory_item_list.set_item_metadata(index, recipe)
	
	show()


#turn into building selection, and a seperate one for recipes/crafting
#func _on_item_list_item_selected(index: int) -> void:
	#current_selected_item = inventory_item_list.get_item_metadata(index)
	#print("The selected item is: ", current_selected_item.name)
	#selected_item.emit(current_selected_item)


func update_menu():
	if current_container == null:
		return
	
	inventory_item_list = %InventoryList
	inventory_item_list.clear()
	inventory_item_list.deselect_all()
	inventory_item_list.max_columns = current_container.get_slot_count()
	for slot_index in range(current_container.get_slot_count()):
		var slot = current_container.slots[slot_index]
		for item in slot["contents"]:
			print("we got a ", item.item_name)
			var index = inventory_item_list.add_icon_item(item.item_sprite)
			inventory_item_list.set_item_text(index, item.item_name)
			inventory_item_list.set_item_metadata(index, item)
	
	
	
	recipe_item_list.clear()
	recipe_item_list.deselect_all()
	
	var category_recipes = RecipeDatabase.get_all_recipes(recipe_item_list.name)
	
	recipe_item_list.max_columns = len(category_recipes)
	
	for recipe in category_recipes.values():
		var index = recipe_item_list.add_icon_item(recipe.recipe_sprite)
		recipe_item_list.set_item_text(index, recipe.recipe_name)
		inventory_item_list.set_item_metadata(index, recipe)



func close_menu() -> void:
	self.hide()
	inventory_item_list = %InventoryList
	
	inventory_item_list.clear()
	inventory_item_list.deselect_all()
	
	recipe_item_list = recipe_tabs.get_current_tab_control().get_child(0)
	recipe_item_list.clear()
	recipe_item_list.deselect_all()
	
	current_container = null
	menu_open = false


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("close_menu"):
		close_menu()



func _on_tab_container_tab_changed(tab: int) -> void:
	update_menu()
