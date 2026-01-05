extends CanvasLayer

@onready var UI_base : PanelContainer = $MarginContainer/PanelContainer
@onready var recipe_tabs: TabContainer = $MarginContainer/PanelContainer/HBoxContainer/Craftingpanel/VSplitContainer/Craftingtabs
@onready var container_label: Label = $MarginContainer/PanelContainer/HBoxContainer/Containerpanel/VSplitContainer/Containerlabel

@onready var io_container_panel: PanelContainer = $MarginContainer/PanelContainer/HBoxContainer/IOContainerPanel
@onready var container_panel: PanelContainer = $MarginContainer/PanelContainer/HBoxContainer/Containerpanel



var menu_open : bool = false

var inventory_item_list : ItemList
var recipe_item_list : ItemList

var current_container = null
var current_building = null

#var feedbacklayer

func _ready() -> void:
	self.hide()
	recipe_tabs.tab_changed.connect(_on_tab_container_tab_changed)
	_connect_recipe_list_signals()
	



func open(target_building):
	current_building = target_building
	var container
	
	
	
	if menu_open == true:
		return
	menu_open = true
	
	inventory_item_list = %InventoryList
	
	
	if target_building.name == "ContainerManager":
		container = target_building
		container_label.text = str("Inventuur (", container.slot_free_space(0), "/", container.slots[0].capacity, " vaba kohta)")
		
	else:
		container = target_building.container_manager
		container_label.text = str("Ehitise ",  target_building.name, " Konteiner")
	
	
	current_container = container
	
	
	
	if container.is_player_inventory == true:
		show_single_container(container)
	else:
		match target_building.container_manager.ui_mode:
			"none":
				return
			"single":
				show_single_container(container)
			"io":
				show_io_container(container)

	for list in [inventory_item_list, input_list, output_list]:
		if list and not list.item_activated.is_connected(on_container_item_activated):
			list.item_activated.connect(on_container_item_activated.bind(list))
	
	
	recipe_item_list = recipe_tabs.get_current_tab_control()
	

	var category_recipes = RecipeDatabase.get_all_recipes(recipe_item_list.name)
	
	for recipe in category_recipes.values():
		if recipe.recipe_name == "Debug belt making":
			continue

		var index = recipe_item_list.add_icon_item(recipe.recipe_sprite)
		
		# Build tooltip strings
		var ingredients_text := ""
		for ing in recipe.recipe_ingredients:
			ingredients_text += str(ing.item.item_name, " x", ing.amount, "\n")
		
		var products_text := ""
		for prod in recipe.recipe_products:
			products_text += str(prod.item.item_name, " x", prod.amount, "\n")
		
		#Sobimatud tootmismeetodid
		var bad_crafters = tr("DISALLOWED_CRAFTERS") + ": " + Enums.get_disallowed_crafter_name(recipe.disallowed_crafters)
		
		
		
		var tooltip_text : String = recipe.recipe_name + "\n" \
			+ tr("INGREDIENTS") + ":\n" + ingredients_text \
			+ tr("PRODUCTS") + ":\n" + products_text \
			+ tr("CRAFTING_TIME") + ": " + str(recipe.crafting_time) + "s\n" \
			+ bad_crafters

		recipe_item_list.set_item_tooltip_enabled(index, true)
		recipe_item_list.set_item_tooltip(index, tooltip_text)
		recipe_item_list.set_item_text(index, recipe.recipe_name)
		recipe_item_list.set_item_metadata(index, recipe)
	
	show()



func show_single_container(container):
	io_container_panel.hide()
	container_panel.show()
	
	for i in range(container.get_slot_count()):
		var slot = container.slots[i]
		match slot["role"]:
			"storage":
				fill_item_list_from_slot(inventory_item_list, slot, i)


@onready var input_list: ItemList = $MarginContainer/PanelContainer/HBoxContainer/IOContainerPanel/VSplitContainer/VSplitContainer2/VSplitContainer/Inputslist
@onready var output_list: ItemList = $MarginContainer/PanelContainer/HBoxContainer/IOContainerPanel/VSplitContainer/VSplitContainer2/VSplitContainer2/Outputslist

func show_io_container(container):
	container_panel.hide()
	io_container_panel.show()

	input_list.clear()
	output_list.clear()

	for i in range(container.get_slot_count()):
		var slot = container.slots[i]
		match slot["role"]:
			"input":
				fill_item_list_from_slot(input_list, slot, i)
			"output":
				fill_item_list_from_slot(output_list, slot, i)



func fill_item_list_from_slot(list : ItemList, slot : Dictionary, slot_index : int):
	var last_item = null
	var item_count := 1
	var index := -1

	for item in slot["contents"]:
		if item == last_item:
			item_count += 1
		else:
			item_count = 1
			index = list.add_icon_item(item.item_sprite)

			# Store BOTH item and slot index
			list.set_item_metadata(index, {
				"item": item,
				"slot_index": slot_index
			})

		list.set_item_text(index, "%s (%d)" % [item.item_name, item_count])
		last_item = item




func _connect_recipe_list_signals():
	for i in range(recipe_tabs.get_tab_count()):
		

		
		var tab = recipe_tabs.get_tab_control(i)
		if not tab.is_connected("item_selected", _on_recipe_selected):
			tab.item_selected.connect(_on_recipe_selected.bind(tab))



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



#should move item to player inventory
func on_container_item_activated(index: int, list: ItemList) -> void:
	if current_container.is_player_inventory:
		return

	var data = list.get_item_metadata(index)
	if data == null:
		return

	var item: Item = data["item"]
	var slot_index: int = data["slot_index"]

	# Try to move ONE item
	if Player.inventory.add_item_to_slot(item, 0):
		current_container.remove_item_from_slot(item, slot_index)
		update_menu()



func update_menu():
	if current_container == null:
		return
	
	inventory_item_list = %InventoryList
	inventory_item_list.clear()
	inventory_item_list.deselect_all()
	if current_container.is_player_inventory == true:
		show_single_container(current_container)
	else:
		match current_container.ui_mode:
			"none":
				return
			"single":
				show_single_container(current_container)
			"io":
				show_io_container(current_container)
	
	
	
	recipe_item_list.clear()
	recipe_item_list.deselect_all()
	recipe_item_list = recipe_tabs.get_current_tab_control()
	var category_recipes = RecipeDatabase.get_all_recipes(recipe_item_list.name)
	
	for recipe in category_recipes.values():
		if recipe.recipe_name == "Debug belt making":
			continue

		var index = recipe_item_list.add_icon_item(recipe.recipe_sprite)
		
		#constructs ingridients tooltip text
		var ingredients_text = ""
		for ing in recipe.recipe_ingredients:
			ingredients_text += str(ing.item.item_name, " x", ing.amount, "\n")
		
		#constructs products tooltip text
		var products_text = ""
		for prod in recipe.recipe_products:
			products_text += str(prod.item.item_name, " x", prod.amount, "\n")
		
		
		var bad_crafters = tr("DISALLOWED_CRAFTERS") + ": " + Enums.get_disallowed_crafter_name(recipe.disallowed_crafters)
		
		
		
		var tooltip_text : String = recipe.recipe_name + "\n" \
			+ tr("INGREDIENTS") + ":\n" + ingredients_text \
			+ tr("PRODUCTS") + ":\n" + products_text \
			+ tr("CRAFTING_TIME") + ": " + str(recipe.crafting_time) + "s\n" \
			+ bad_crafters
		
		recipe_item_list.set_item_tooltip_enabled(index, true)
		recipe_item_list.set_item_tooltip(index, tooltip_text)
		recipe_item_list.set_item_text(index, recipe.recipe_name)
		recipe_item_list.set_item_metadata(index, recipe)



func close_menu() -> void:
	self.hide()
	inventory_item_list = %InventoryList
	
	inventory_item_list.clear()
	inventory_item_list.deselect_all()
	
	recipe_item_list = recipe_tabs.get_current_tab_control()
	recipe_item_list.clear()
	recipe_item_list.deselect_all()
	
	current_building = null
	current_container = null
	menu_open = false



func _on_tab_container_tab_changed(_tab: int) -> void:
	_connect_recipe_list_signals()
	update_menu()
