extends Node3D

var iron_noise = FastNoiseLite.new()

var ore_map: Dictionary = {}
var ore_types = ["iron", "copper", "coal", "stone"]

func generate_random_ore_map(grid_size_x: int, grid_size_z: int, ore_types: Array):
	for x in range(grid_size_x):
		for z in range(grid_size_z):
			if randf() < 1:
				var ore = ore_types[randi() % ore_types.size()]
				ore_map[Vector3(x, 0, z)] = ore

func visualize_ores():
	for cell in ore_map.keys():
		var oremesh = MeshInstance3D.new()
		var orecube = BoxMesh.new()
		oremesh.scale = Vector3(1, 1, 1)
		oremesh.position = cell + Vector3(0, 0, 0)
		
		var mat = StandardMaterial3D.new()
		match ore_map[cell]:
			"iron":
				mat.albedo_color = Color(0.7, 0.7, 0.7)
			"copper":
				mat.albedo_color = Color(1.0, 0.5, 0.2)
			"coal":
				mat.albedo_color = Color(0.1, 0.1, 0.1)
			"stone":
				mat.albedo_color = Color(1, 0, 0)
		
		orecube.material = mat
		oremesh.mesh = orecube
		add_child(oremesh)

func _ready() -> void:
	randomize()
	generate_random_ore_map(100, 100, ore_types)
	visualize_ores()
