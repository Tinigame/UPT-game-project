extends Node3D
#summons buildings when player calls the function to do it

@export var building_base : PackedScene

var id = 0
var buildings : Array = []
var occupied_cells : Dictionary = {}

func _physics_process(_delta: float) -> void:
	if Globals.buildmode == true and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		build_building(Globals.selected_building)


func build_building(build_info : Building):
		var building = building_base.instantiate()
		
		#Add the required cells into a list
		var required_x = int(build_info.building_size.x)
		var required_z = int(build_info.building_size.z)
		var required_cells : Array
		for x in range(required_x):
			for z in range(required_z):
				required_cells.append(Globals.building_location + Vector3(x, 0, z))
		
		#check if those cells are already in use
		for cell in required_cells:
			if occupied_cells.has(cell):
				print(cell, " building space occupied")
				return
		
		#adds collision shape to building
		var building_collision = CollisionShape3D.new()
		var collision_shape = BoxShape3D.new()
		collision_shape.size = build_info.building_size
		building_collision.shape = collision_shape
		building.add_child(building_collision)
		
		#adds mesh to building
		var building_mesh = MeshInstance3D.new()
		building_mesh.mesh = build_info.building_mesh
		building.add_child(building_mesh)
		
		#adds a name to the building and an id
		building.name = String(build_info.building_name + str(id))
		id = id + 1
		
		#moves the building to the correct position
		building.position = Vector3(Globals.building_location.x, build_info.building_size.y / 2, Globals.building_location.z)
		
		add_child(building)
		buildings.append(building)    
		
		#mark the cells as occupied
		for cell in required_cells:
			occupied_cells[cell] = building
