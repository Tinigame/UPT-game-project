extends CharacterBody3D
@onready var camera: Camera3D = $"FP camera"
@onready var tcamera: Camera3D = $"Top camera"

const GRID_SIZE : int = 1
const SPEED : float = 10.0
const JUMP_VELOCITY : float = 5.0
var MOUSE_SENSITIVITY : float= 0.002
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var ghost_location : Vector3
var ghost_instance : MeshInstance3D


func _ready():
	camera.current = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	#summons and adds the initial build ghost
	ghost_instance = summon_first_build_ghost()
	add_child(ghost_instance)
	ghost_instance.hide()


#Camera and movement rotation
func _input(event):
	if event is InputEventMouseMotion and Globals.buildmode == false:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
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

#handle jump, movement
func player_movement():
	# Handle Jump.
	if Input.is_action_just_pressed("space") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("A", "D", "W", "S")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)


func summon_first_build_ghost() -> MeshInstance3D:
	var ghost_object_instance = MeshInstance3D.new()
	var cube_mesh = BoxMesh.new()
	var material = StandardMaterial3D.new()

	material.albedo_color = Color(0, 0.8, 0, 0.5)  # semi-transparent bluish
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.flags_transparent = true
	material.flags_unshaded = true  # optional, prevents lighting effects
	cube_mesh.material = material

	cube_mesh.size = Vector3(1, 1, 1)  # Set cube dimensions
	ghost_object_instance.mesh = cube_mesh
	
	return ghost_object_instance

func update_build_ghost(ghost_pos, current_ghost_instance):
	current_ghost_instance.global_position = ghost_pos

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	#exit the game when esc pressed
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()

	#get the mouse pos when buildmode enabled
	if Globals.buildmode == true:
		ghost_location = get_mouse_world_position()
		update_build_ghost(ghost_location, ghost_instance)
		ghost_instance.show()
	elif Globals.buildmode == false:
		ghost_instance.hide()

	player_movement()
	build_toggle()
	move_and_slide()
