extends Node3D
#summons buildings when player calls the function to do it

@export var building_base : PackedScene

var id = 0
var buildings : Array = []
var occupied_cells : Dictionary = {}

func _physics_process(_delta: float) -> void:
	if Globals.buildmode == true and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		build_building(Globals.selected_building)


func has_required_ore(required_cells: Array) -> bool:
	for cell in required_cells:
		if Globals.ore_map.has(cell):
			return true  # found the needed ore
	return false  # none of the cells had it


func build_building(build_info : Building):
		var building = building_base.instantiate()
		
		#Add the required cells into a list
		var required_x = int(build_info.building_size.x)
		var required_z = int(build_info.building_size.z)
		var required_cells : Array[Vector3i] = []
		for x in range(required_x):
			for z in range(required_z):
				var cell = Vector3i(Globals.building_location) + Vector3i(x, 0, z)
				required_cells.append(cell)
		
		if build_info.only_buildable_on_ores == true:
			if has_required_ore(required_cells) == false:
				print("no ores")
				return
			else:
				pass
		
		
		#check if those cells are already in use
		for cell in required_cells:
			if occupied_cells.has(cell):
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
		
		#checks if the building is even sized and then applies an offset
		var offset = Vector3((build_info.building_size.x / 2.0) - 0.5, 0, (build_info.building_size.z / 2.0) - 0.5)
		
		#moves the building to the location
		var final_position = Vector3((Globals.building_location.x + offset.x) * 1, build_info.building_size.y / 2, (Globals.building_location.z + offset.z) * 1)
		building.position = final_position
		
		#adds the building to the tree and to the array
		add_child(building)
		buildings.append(building)    
		
		#mark the cells as occupied
		for cell in required_cells:
			occupied_cells[cell] = building
			if Globals.ore_map.has(cell):
				print("ORE FOUND:", Globals.ore_map[cell])
			else:
				print("No ore at", cell)
