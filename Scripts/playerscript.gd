extends CharacterBody3D
var camera: Camera3D
var tcamera: Camera3D

const GRID_SIZE : int = 1
const JUMP_VELOCITY : float = 5.0

var move_speed : float = 5.0
var mouse_sensitivity : float = 0.002
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var ghost_location : Vector3
var ghost_instance : MeshInstance3D
var ghost_rotation_instance : MeshInstance3D

var container_manager = preload("res://Scenes/Container_manager.tscn")
var inventory

var crafting_module = preload("res://Scripts/buildings/pocket_assembler_script.gd")
var crafter_node : Node3D

func _ready():
	camera = $"FP camera"
	tcamera = $"Top camera"
	
	
	camera.current = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	#summons and adds the initial build ghost
	ghost_instance = summon_first_build_ghost()
	ghost_rotation_instance = summon_rotation_build_ghost()
	add_child(ghost_instance)
	add_child(ghost_rotation_instance)
	ghost_instance.hide()
	ghost_rotation_instance.hide()

	#adds the container module to act as an inventory
	inventory = container_manager.instantiate()
	inventory.is_player_inventory = true
	self.add_child(inventory)
	
	crafter_node = Node3D.new()
	crafter_node.set_script(crafting_module)
	self.add_child(crafter_node)
	
	#adds 1 slot
	inventory.add_slot(84, [])
	
	for x in range(10):
		for item in Globals.starter_kit:
			inventory.add_item_to_slot(item, 0)


#Camera and movement rotation
func _input(event):
	if event is InputEventMouseMotion and Globals.buildmode == false:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)



#gets global position of where mouse clicked
func get_mouse_world_position() -> Vector3:
	var mouse_pos = get_viewport().get_mouse_position()
	var from = tcamera.project_ray_origin(mouse_pos)
	var to = from + tcamera.project_ray_normal(mouse_pos) * 1000
	
	var parameters = PhysicsRayQueryParameters3D.create(from, to, 2, [])
	
	var space_state = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(parameters)
	
	if result:
		return snap_to_grid(result.position)
	return Vector3.ZERO



#snaps the target build position to the grid (hopefully)
func snap_to_grid(buildposition: Vector3) -> Vector3:
	return Vector3(
		round(buildposition.x / GRID_SIZE) * GRID_SIZE,
		0.5,  # assuming flat plane at y=0
		round(buildposition.z / GRID_SIZE) * GRID_SIZE
	)



#toggle between build mode
func build_toggle():
	if Input.is_action_just_pressed("switchcam"):
		if camera.current == true:
			rotation = Vector3(0, 0, 0)
			tcamera.rotation_degrees = Vector3(-90, 0, 0)
			tcamera.current = true
			Globals.buildmode = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif tcamera.current == true:
			camera.current = true
			Globals.buildmode = false
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED



#handle jump, movement etc
func player_movement():
	# Add back in the is_on_floor(), i removed it for testing.
	if Input.is_action_just_pressed("space") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("A", "D", "W", "S")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
		velocity.z = move_toward(velocity.z, 0, move_speed)


#creates the build ghost
func summon_first_build_ghost() -> MeshInstance3D:
	var ghost_object_instance = MeshInstance3D.new()
	var cube_mesh = BoxMesh.new()
	var material = StandardMaterial3D.new()

	material.albedo_color = Color(0, 0.8, 0, 0.5)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.flags_transparent = true
	material.flags_unshaded = true
	cube_mesh.material = material

	ghost_object_instance.mesh = cube_mesh
	
	return ghost_object_instance



#creates the build rotation indicating ghost
func summon_rotation_build_ghost():
	var ghost_object_instance = MeshInstance3D.new()
	var cube_mesh = BoxMesh.new()
	var material = StandardMaterial3D.new()

	material.albedo_color = Color(0.8, 0, 0, 0.5)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.flags_transparent = true
	material.flags_unshaded = true
	cube_mesh.material = material

	ghost_object_instance.mesh = cube_mesh
	ghost_object_instance.scale = Vector3(0.3, 0.3, 0.3)
	
	return ghost_object_instance



#updates the build ghosts position, mesh, rotation indicator, etc
var last_Selected_building = null
func update_build_ghost(ghost_pos, current_ghost_instance : MeshInstance3D, current_ghost_rotation_instance : MeshInstance3D):
	
	if Input.is_action_just_pressed("rotate_clockwise"):
		Globals.building_rotation.y += 90
	if Input.is_action_just_pressed("rotate_counterclockwise"):
		Globals.building_rotation.y += -180
	
	#makes ghost aligned to the grid like the buildings
	var size = Globals.selected_building.building_size
	var offset = Vector3((size.x / 2.0) - 0.5, 0, (size.z / 2.0) - 0.5)
	current_ghost_instance.global_position = ghost_pos + offset
	current_ghost_instance.rotation_degrees = Globals.building_rotation
	
	#gets the offset for the front-middle of the building then applies the offset to the rotation ghost
	var front_offset = get_forward_cell_offset(size, current_ghost_instance.rotation_degrees)
	current_ghost_rotation_instance.global_position = ghost_pos + offset + front_offset

	#if the building changes then match the mesh to the building
	if last_Selected_building != Globals.selected_building.building_mesh:
		last_Selected_building = Globals.selected_building.building_mesh
		var ghost_mesh = Globals.selected_building.building_mesh.duplicate()
		
		var material = StandardMaterial3D.new()
		material.albedo_color = Color(0, 0.8, 0, 0.5)
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.flags_transparent = true
		material.flags_unshaded = true
		
		
		# assign material to all surfaces of the duplicated mesh
		for i in range(ghost_mesh.get_surface_count()):
			ghost_mesh.surface_set_material(i, material)
		current_ghost_instance.mesh = ghost_mesh



#gets the offset for the rotation indicating ghost
var building_direction : Enums.direction
func get_forward_cell_offset(building_size, grotation) -> Vector3:
	var forward = Vector3.ZERO
	
	match int(grotation.y) % 360:
		0:
			forward = Vector3(0, 0, -1)
		90:
			forward = Vector3(1, 0, 0)
		180:
			forward = Vector3(0, 0, 1)
		270:
			forward = Vector3(-1, 0, 0)
	
	return forward * (building_size.z / 2.0)




func handcraft_item(recipe):
	crafter_node.set_recipe(recipe)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	#exit the game when f4 pressed
	if Input.is_action_just_pressed("close_game"):
		get_tree().quit()

	if Input.is_action_just_pressed("open_inventory"):
		PlayerUI.open(inventory)


	player_movement()
	build_toggle()
	move_and_slide()


	#get the mouse pos when buildmode enabled
	if Globals.buildmode == true:
		ghost_location = get_mouse_world_position()
		Globals.building_location = Vector3(ghost_location.x, 0, ghost_location.z)
		
		if Globals.selected_building == null:
			ghost_instance.hide()
			ghost_rotation_instance.hide()
			return
		
		update_build_ghost(ghost_location, ghost_instance, ghost_rotation_instance)
		ghost_instance.show()
		ghost_rotation_instance.show()
		
	elif Globals.buildmode == false:
		ghost_instance.hide()
		ghost_rotation_instance.hide()
