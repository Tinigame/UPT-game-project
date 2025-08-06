extends StaticBody3D

var grid_position: Vector3i
var building_direction : Enums.direction

var unique_script : GDScript = null

func _ready() -> void:
	if unique_script:
		var unique_node = Node3D.new()
		unique_node.set_script(unique_script)
		unique_node.forward_cell_offset = get_forward_cell_offset()
		unique_node.grid_position = grid_position
		self.add_child(unique_node)

func get_forward_cell_offset() -> Vector3i:
	match building_direction:
		Enums.direction.UP:
			return Vector3i(0, 0, -1)
		Enums.direction.RIGHT:
			return Vector3i(1, 0, 0)
		Enums.direction.DOWN:
			return Vector3i(0, 0, 1)
		Enums.direction.LEFT:
			return Vector3i(-1, 0, 0)
	return Vector3i.ZERO
