extends Node3D
#summons buildings when player calls the function to do it

var building_base : PackedScene = preload("res://Scenes/building.tscn")
var container_manager : PackedScene = preload("res://Scenes/Container_manager.tscn")

var id = 0
var buildings : Array = []
var occupied_cells : Dictionary = {}

func _physics_process(_delta: float) -> void:
	if Globals.buildmode == true and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and PlayerUI.menu_open == false:
		build_building(Globals.selected_building)
	if Globals.buildmode == true and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and PlayerUI.menu_open == false:
		remove_building()


func has_required_ore(required_cells: Array) -> bool:
	for cell in required_cells:
		if Globals.ore_map.has(cell):
			return true  # found the needed ore
	return false  # none of the cells had it

func get_direction_of_building(brotation):
	var y_deg = int(round(brotation.y)) % 360
	match y_deg:
		0:
			return Enums.direction.UP
		90:
			return Enums.direction.RIGHT
		180:
			return Enums.direction.DOWN
		270:
			return Enums.direction.LEFT
		_:
			print("ey boss idk the fuck this rotation is")
			return Enums.direction.UP  # default/fallback

func build_building(build_info : Building):
	
	#if there is no building selected and user clicks on a building then open its UI
	if Globals.selected_building == null:
		var xn = int(1)
		var zn = int(1)
		var req_cells : Array[Vector3i] = []
		for x in range(xn):
			for z in range(zn):
				var cell = Vector3i(Globals.building_location) + Vector3i(x, 0, z)
				req_cells.append(cell)
	
		for cell in req_cells:
			if occupied_cells.has(cell):
				var build = occupied_cells[cell]
				open_building_UI(build)
			else:	
				return
		return
	
	if PlayerUI.menu_open == true:
		return
	
	
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
			for cell in required_cells:
				if Globals.ore_map.has(cell):
					building.over_ores.append(Globals.ore_map[cell])
	
	
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
	
	#moves the building to the location and rotation
	var final_position = Vector3((Globals.building_location.x + offset.x) * 1, build_info.building_size.y / 2, (Globals.building_location.z + offset.z) * 1)
	building.position = final_position
	building.rotation_degrees = Globals.building_rotation
	building.grid_position = Globals.building_location
	building.building_size = build_info.building_size

	building.unique_script = build_info.building_script

	building.building_direction = get_direction_of_building(building.rotation_degrees)

	#adds the container module to the building if needed
	if build_info.has_container == true:
		var container = container_manager.instantiate()
		building.add_child(container)

		# Create the minimum number of empty slots so it can hold items at all
		for i in range(build_info.container_max_slots):
			container.add_slot(1, [])  # capacity=1 for now, no restrictions

		# Optional: store reference for later recipe configuration
		building.container_manager = container
	
	if build_info.uses_recipes == true:
		building.is_recipe_compatible = true

	#adds the building to the tree and to the array
	add_child(building)
	buildings.append(building)
	
	#mark the cells as occupied
	for cell in required_cells:
		occupied_cells[cell] = building
#			if Globals.ore_map.has(cell):
#				print("ORE FOUND:", Globals.ore_map[cell])
#			else:
#				print("No ore at", cell)

	update_conveyor_neighbors()



func open_building_UI(target_building):
	PlayerUI.open(target_building)



func remove_building():
	var target_cell: Vector3i = Globals.building_location
	if not occupied_cells.has(target_cell):
		return
	
	#gets the building instance
	var building = occupied_cells[target_cell]
	
	#frees the cells that the building occupied
	var size = building.building_size
	var base = building.grid_position
	for x in range(size.x):
		for z in range(size.z):
			var cell = base + Vector3i(x, 0, z)
			if occupied_cells.has(cell) and occupied_cells[cell] == building:
				occupied_cells.erase(cell)
	
	#removes building from list of buildings then deletes it
	buildings.erase(building)
	building.queue_free()
	
	update_conveyor_neighbors()


func update_conveyor_neighbors():
	for conveyor in get_tree().get_nodes_in_group("conveyors"):
		conveyor.update_connections()

	for miner in get_tree().get_nodes_in_group("miners"):
		miner.update_connections()
	
	for assembler in get_tree().get_nodes_in_group("assemblers"):
		assembler.update_connections()
