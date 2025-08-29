extends CanvasLayer

@onready var UI_base : PanelContainer = $CenterContainer/AspectRatioContainer/PanelContainer
@onready var inventory_splitter : HSplitContainer = $CenterContainer/AspectRatioContainer/PanelContainer/HSplitContainer
@onready var recipe_tabs: TabContainer = $"CenterContainer/AspectRatioContainer/PanelContainer/HSplitContainer/crafting menu/TabContainer"
@onready var container_label: Label = $"CenterContainer/AspectRatioContainer/PanelContainer/HSplitContainer/Container menu/Container label"

var menu_open : bool = false

var inventory_item_list : ItemList
var recipe_item_list : ItemList

var current_container = null
var current_building = null



func _ready() -> void:
	self.hide()
	recipe_tabs.tab_changed.connect(_on_tab_container_tab_changed)
	_connect_recipe_list_signals()



func open(target_building):
	current_building = target_building
	var container
	if target_building.name == "ContainerManager":
		container = target_building
		container_label.text = "Inventory"
	else:
		container = target_building.container_manager
		container_label.text = str("Container of ", target_building.name)
	
	
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
	if not inventory_item_list.item_selected.is_connected(_on_inventory_item_selected):
		inventory_item_list.item_selected.connect(_on_inventory_item_selected)
	if not inventory_item_list.item_activated.is_connected(_on_inventory_item_activated):
		inventory_item_list.item_activated.connect(_on_inventory_item_activated)
	
	
	for slot_index in range(container.get_slot_count()):
		var slot = container.slots[slot_index]
		var last_item = null
		var item_count : int = 1
		var index
		for item in slot["contents"]:
			print("we got a ", item.item_name)
			
			if item == last_item:
				item_count += 1
			else:
				item_count = 1
				index = inventory_item_list.add_icon_item(item.item_sprite)
			
			
			inventory_item_list.set_item_text(index, str(item.item_name, " (", item_count, ")"))
			inventory_item_list.set_item_metadata(index, item)
			last_item = item
	
	
	recipe_item_list = recipe_tabs.get_current_tab_control().get_child(0)
	var category_recipes = RecipeDatabase.get_all_recipes(recipe_item_list.name)
	
	recipe_item_list.max_columns = len(category_recipes)
	
	for recipe in category_recipes.values():
		var index = recipe_item_list.add_icon_item(recipe.recipe_sprite)
		recipe_item_list.set_item_text(index, recipe.recipe_name)
		recipe_item_list.set_item_metadata(index, recipe)
	
	show()



func _connect_recipe_list_signals():
	for i in range(recipe_tabs.get_tab_count()):
		var tab = recipe_tabs.get_tab_control(i)
		if tab.get_child_count() > 0 and tab.get_child(0) is ItemList:
			var list = tab.get_child(0)
			if not list.is_connected("item_selected", _on_recipe_selected):
				list.item_selected.connect(_on_recipe_selected.bind(list))



#should craft the recipe if from inventory or set the recipe if on building.
#sets the recipe on a building but no crafting yet.
func _on_recipe_selected(index: int, list: ItemList):
	var recipe = list.get_item_metadata(index)
	if current_container.is_player_inventory == false:
		if recipe:
			print("Selected recipe:", recipe.recipe_name)
			current_building.set_recipe(recipe)
	elif current_container.is_player_inventory == true:
		Player.handcraft_item(recipe)



func _on_inventory_item_selected(index: int) -> void:
	var current_selected_item : Item = inventory_item_list.get_item_metadata(index)
	print("The selected item is: ", current_selected_item.item_name)
	if current_container.is_player_inventory == true:
		if current_selected_item.is_building == true:
			Globals.selected_building = current_selected_item.building_resource
			print("selected building: ", current_selected_item.item_name)



func _on_inventory_item_activated(index: int) -> void:
	var current_selected_item : Item = inventory_item_list.get_item_metadata(index)
	Player.inventory.add_item_to_slot(current_selected_item, 0)
	inventory_item_list.remove_item(index)
	current_container.remove_item_from_slot(current_selected_item, index)



func update_menu():
	if current_container == null:
		return
	
	inventory_item_list = %InventoryList
	inventory_item_list.clear()
	inventory_item_list.deselect_all()
	inventory_item_list.max_columns = current_container.get_slot_count()
	for slot_index in range(current_container.get_slot_count()):
		var slot = current_container.slots[slot_index]
		var last_item = null
		var item_count : int = 1
		var index
		for item in slot["contents"]:
			print("we got a ", item.item_name)
			
			if item == last_item:
				item_count += 1
			else:
				item_count = 1
				index = inventory_item_list.add_icon_item(item.item_sprite)
			
			
			inventory_item_list.set_item_text(index, str(item.item_name, " (", item_count, ")"))
			inventory_item_list.set_item_metadata(index, item)
			last_item = item
	
	
	
	recipe_item_list.clear()
	recipe_item_list.deselect_all()
	
	var category_recipes = RecipeDatabase.get_all_recipes(recipe_item_list.name)
	
	recipe_item_list.max_columns = len(category_recipes)
	
	for recipe in category_recipes.values():
		var index = recipe_item_list.add_icon_item(recipe.recipe_sprite)
		recipe_item_list.set_item_text(index, recipe.recipe_name)
		recipe_item_list.set_item_metadata(index, recipe)



func close_menu() -> void:
	self.hide()
	inventory_item_list = %InventoryList
	
	inventory_item_list.clear()
	inventory_item_list.deselect_all()
	
	recipe_item_list = recipe_tabs.get_current_tab_control().get_child(0)
	recipe_item_list.clear()
	recipe_item_list.deselect_all()
	
	current_building = null
	current_container = null
	menu_open = false



func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("close_menu"):
		close_menu()



func _on_tab_container_tab_changed(_tab: int) -> void:
	_connect_recipe_list_signals()
	update_menu()
