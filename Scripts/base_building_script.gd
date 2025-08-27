extends StaticBody3D

var grid_position: Vector3i
var building_direction : Enums.direction
var building_size : Vector3i
var container_has_space = true
@onready var container_manager: Node = get_node_or_null("ContainerManager")
var unique_script : GDScript = null
var is_recipe_compatible = false
var over_ores : PackedStringArray

var unique_node : Node3D = null

func _ready() -> void:
	if unique_script:
		unique_node = Node3D.new()
		unique_node.set_script(unique_script)
		unique_node.forward_cell_offset = get_forward_cell_offset()
		unique_node.grid_position = grid_position
		
		#sets the ores that the building has beneath, if it cares that is
		unique_node.set("over_ores", over_ores)
		
		self.add_child(unique_node)

	if container_manager != null:
		container_manager.connect("space_changed", _on_space_changed)
	elif container_manager == null:
		container_has_space = false

func get_forward_cell_offset() -> Vector3i:
	var width := building_size.x
	var depth := building_size.z
	
	match building_direction:
		Enums.direction.UP:
			return grid_position + Vector3i(width / 2, 0, -1)
		Enums.direction.RIGHT:
			return grid_position + Vector3i(width, 0, depth / 2)
		Enums.direction.DOWN:
			return grid_position + Vector3i(width / 2, 0, depth)
		Enums.direction.LEFT:
			return grid_position + Vector3i(-1, 0, depth / 2)
	return grid_position


func _on_space_changed(has_space: bool):
	if has_space == true:
		container_has_space = true
	else:
		container_has_space = false



func set_recipe(recipe: Resource) -> void:
	if not is_recipe_compatible:
		push_warning("This building cannot use recipes.")
		return
	
	if unique_node != null and unique_node.has_method("set_recipe"):
		unique_node.set_recipe(recipe)
	else:
		push_warning("Unique node does not support recipes.")
