extends Node

var buildmode = false
var building_location = Vector3(0, 0, 0)
var building_rotation = Vector3(0, 0, 0)
var selected_building = preload("res://Resources/buildings/conveyor_belt.tres")
var ore_map : Dictionary

var debug_item = preload("res://Resources/buildings/conveyor_belt.tres")
var debug_recipe = preload("res://Resources/recipes/debug_recipe.tres")

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("temp_select_building_1"):
		selected_building = preload("res://Resources/buildings/conveyor_belt.tres")
		print("selected conveyor")
	elif Input.is_action_just_pressed("temp_select_building_2"):
		selected_building = preload("res://Resources/buildings/2x2 rock.tres")
		print("selected 2x2 rock")
	elif Input.is_action_just_pressed("temp_select_building_3"):
		selected_building = preload("res://Resources/buildings/mining_drill.tres")
		print("selected mining drill")
	elif Input.is_action_just_pressed("temp_select_building_4"):
		selected_building = preload("res://Resources/buildings/assembler.tres")
		print("selected assembler")
	elif Input.is_action_just_pressed("temp_deselect_building"):
		selected_building = null
		print("nothing selected")
