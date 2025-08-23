extends CanvasLayer

@onready var UI_base : PanelContainer = $CenterContainer/AspectRatioContainer/PanelContainer
@onready var inventory_splitter : HSplitContainer = $CenterContainer/AspectRatioContainer/PanelContainer/HSplitContainer

var menu_open : bool = false

var inventory_item_list : ItemList


func _ready() -> void:
	self.hide()


func open(container):
	if menu_open == true:
		return
	menu_open = true
	
	UI_base.custom_minimum_size.x = get_viewport().size.x / 1.25
	UI_base.custom_minimum_size.y = get_viewport().size.y / 1.25
	inventory_splitter.split_offset = UI_base.custom_minimum_size.x / 2
	
	inventory_item_list = %ItemList
	inventory_item_list.max_columns = container.get_slot_count()
	print(inventory_item_list.max_columns, " collumns")
	
	
	for slot_index in range(container.get_slot_count()):
		var slot = container.slots[slot_index]
		for item in slot["contents"]:
			print("we got a ", item.item_name)
			var index = inventory_item_list.add_icon_item(item.item_sprite)
			inventory_item_list.set_item_text(index, item.item_name)
			inventory_item_list.set_item_metadata(index, item)
	
	show()


#turn into building selection, and a seperate one for recipes/crafting
#func _on_item_list_item_selected(index: int) -> void:
	#current_selected_item = inventory_item_list.get_item_metadata(index)
	#print("The selected item is: ", current_selected_item.name)
	#selected_item.emit(current_selected_item)


func close_menu() -> void:
	self.hide()
	inventory_item_list = %ItemList
	
	inventory_item_list.clear()
	inventory_item_list.deselect_all()
	
	menu_open = false


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("close_menu"):
		close_menu()
