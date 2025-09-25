extends Node

var container_manager : ContainerManager


var tier_1_item : Array = [preload("res://Resources/items/item_hull_component.tres")] 
var tier_1_amount : int = 50
var tier_1_completed : bool = false

var forward_cell_offset : Vector3i
var grid_position : Vector3i

var goal_billboard
var goal_text




func _ready() -> void:
	container_manager = get_own_container_manager()
	container_manager.add_slot(84, tier_1_item)
	create_goal_billboard()



func create_goal_billboard():
	var billboard = Sprite3D.new()
	var text = Label3D.new()
	billboard.texture = preload("res://Assets/Textures/ai-generated-8214374_960_720.jpg")
	billboard.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	billboard.position = self.position + Vector3(0, 3, 0)
	
	text.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	text.text = "Goal: 50 hull components"
	text.position = self.position + Vector3(0, 2, 0)
	
	add_child(billboard)
	add_child(text)
	
	return




func get_own_container_manager() -> ContainerManager:
	if get_parent().has_node("ContainerManager"):
		return get_parent().get_node("ContainerManager")
	return null



func _physics_process(_delta: float) -> void:
	var amount = container_manager.count_item_in_slot(tier_1_item[0], 0)
	if amount >= tier_1_amount:
		tier_1_completed = true
		print("YIPEEEE")
