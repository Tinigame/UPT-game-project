extends Node

var container_manager : ContainerManager

# hull component
var tier_1_item : Array = [preload("res://Resources/items/item_hull_component.tres")]
#var tier_1_item : Array = [preload("uid://dnx2ktbw4m5t0")]
var tier_1_amount : int = 25
#var tier_1_amount : int = 1
var tier_1_completed : bool = false

# electrical components
var tier_2_item : Array = [preload("uid://ddlws1uul1ugp")]
#var tier_2_item : Array = [preload("uid://bwlfgu77hlfb")]
var tier_2_amount : int = 20
#var tier_2_amount : int = 2
var tier_2_completed : bool = false


var forward_cell_offset : Vector3i
var grid_position : Vector3i

var goal_billboard
var goal_text

var billboard = Sprite3D.new()
var text = Label3D.new()



func _ready() -> void:
	container_manager = get_own_container_manager()
	container_manager.add_slot(84, tier_1_item)
	create_goal_billboard()
	container_manager.ui_mode = "single"

# Mida sa siit otsid?

func create_goal_billboard():
	var bilbboardimage = tier_1_item[0].item_sprite.get_image()
	bilbboardimage.resize(64, 64, Image.INTERPOLATE_NEAREST)
	var bilbtext = ImageTexture.create_from_image(bilbboardimage)
	billboard.texture = bilbtext
	billboard.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	billboard.position = self.position + Vector3(0, 3, 0)
	
	text.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	text.text = str("Eesmärk: ", tier_1_amount, " " , tr(tier_1_item[0].name_key))
	text.position = self.position + Vector3(0, 2, 0)
	
	add_child(billboard)
	add_child(text)
	
	return


func update_goal_billboard():
	var bilbboardimage = tier_2_item[0].item_sprite.get_image()
	bilbboardimage.resize(64, 64, Image.INTERPOLATE_NEAREST)
	var bilbtext = ImageTexture.create_from_image(bilbboardimage)
	
	
	text.text = str("Eesmärk: ", tier_2_amount, " " , tr(tier_2_item[0].name_key))
	billboard.texture = bilbtext


func get_own_container_manager() -> ContainerManager:
	if get_parent().has_node("ContainerManager"):
		return get_parent().get_node("ContainerManager")
	return null



func _physics_process(_delta: float) -> void:
	var amount = container_manager.count_item_in_slot(tier_1_item[0], 0)
	if amount >= tier_1_amount:
		tier_1_completed = true
		update_goal_billboard()
		
		container_manager.clear_slots()
		container_manager.add_slot(84, tier_2_item)
	
	if tier_1_completed == true and container_manager.count_item_in_slot(tier_2_item[0], 0) >= tier_2_amount:
		tier_2_completed = true
		text.text = "Eesmärk täidetud!"
		billboard.texture = preload("uid://dir0exoj5ej8o")
		Globals.speedrun_timer_started = false
