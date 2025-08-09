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

#script that gets put on the building base
@export var building_script : GDScript
#does the building have a container_manager
@export var has_container : bool = false
#max amount of unique items that can be in the container at a time
@export var container_max_slots : int = 0
