extends Node3D


var ore_grid_size : float = 1000
var oregridx : float = 1000.0
var oregridy : float = 1000.0

var ore_map: Dictionary = {}
var ore_types = ["iron", "copper", "coal", "stone"]

func generate_iron_ore_with_noise(grid_size : float):
	var iron_noise = FastNoiseLite.new()
	iron_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	iron_noise.seed = randi()
	
	var half = grid_size / 2
	
	for x in range(-half, half):
		for z in range(-half, half):
			var number = iron_noise.get_noise_2d(x, z)
			
			if number > 0.3:
				ore_map[Vector3(x, 0, z)] = "iron"

func generate_copper_ore_with_noise(grid_size : float):
	var copper_noise = FastNoiseLite.new()
	copper_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	copper_noise.seed = randi()
	
	var half = grid_size / 2
	
	for x in range(-half, half):
		for z in range(-half, half):
			var number = copper_noise.get_noise_2d(x, z)
			
			if number > 0.3:
				ore_map[Vector3(x, 0, z)] = "copper"

func visualize_ores():
	# Create the base mesh (Box)
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(1, 1, 1)

	# Create material and enable per-instance color
	var mat = StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	box_mesh.material = mat

	# Create the multimesh
	var multimesh = MultiMesh.new()
	multimesh.mesh = box_mesh
	multimesh.use_colors = true
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.instance_count = ore_map.size()

	# Create the instance container
	var multimesh_instance = MultiMeshInstance3D.new()
	multimesh_instance.multimesh = multimesh
	multimesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	# Assign transform and color to each instance
	var i = 0
	for cell in ore_map.keys():
		var transform = Transform3D()
		transform.origin = cell
		multimesh.set_instance_transform(i, transform)

		var color := Color.WHITE
		match ore_map[cell]:
			"iron":
				color = Color(0.1, 0.1, 1)
			"copper":
				color = Color(1.0, 0.1, 0.1)
			"coal":
				color = Color(0, 0, 0)
			"stone":
				color = Color(0, 1, 0)

		multimesh.set_instance_color(i, color)
		i += 1

	add_child(multimesh_instance)


func _ready() -> void:
	generate_copper_ore_with_noise(ore_grid_size)
	generate_iron_ore_with_noise(ore_grid_size)

#	self.position.x -= oregridx / 2
#	self.position.z -= oregridy / 2 
	visualize_ores()
