class_name Building
extends Resource

@export var building_name : String

@export var building_size : Vector3
@export var building_mesh : Mesh

@export var building_health : float

@export var only_buildable_on_ores : bool = false

#what item is required to place the building
#idk what type this should be so its like ignore for future
#var building_ingredient
