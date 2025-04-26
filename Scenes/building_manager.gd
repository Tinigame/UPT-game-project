extends Node3D
#summons buildings when player calls the function to do it

@export var building_base : PackedScene

func _physics_process(_delta: float) -> void:
	if Globals.buildmode == true and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		build_building(Globals.selected_building)


func build_building(build_info : Building):
		var building = building_base.instantiate()
		
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
		
		#make the buildings get stored in a 
		#list or sumth so you can manage their location and health
		
		add_child(building)		
