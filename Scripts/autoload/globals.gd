extends Node

var buildmode = false
var building_location = Vector3(0, 0, 0)
var building_rotation = Vector3(0, 0, 0)
var selected_building = null
var ore_map : Dictionary

var debug_item = preload("res://Resources/buildings/conveyor_belt.tres")
var debug_recipe = preload("res://Resources/recipes/debug_recipe.tres")
var debug_mode : bool = false
var speedrun_timer_started : bool = false

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("temp_select_building_1"):
		selected_building = preload("res://Resources/buildings/conveyor_belt.tres")
		print("selected conveyor")
	elif Input.is_action_just_pressed("temp_select_building_2"):
		selected_building = preload("uid://bg763wlyjknto")
		print("selected splitter")
	elif Input.is_action_just_pressed("temp_select_building_3"):
		selected_building = preload("res://Resources/buildings/assembler.tres")
		print("selected assembler")
	elif Input.is_action_just_pressed("temp_select_building_4"):
		selected_building = preload("res://Resources/buildings/mining_drill.tres")
		print("selected mining drill")
	elif Input.is_action_just_pressed("temp_select_building_5"):
		selected_building = preload("uid://mb62a3jadg2u")
		print("selected chemical reactor")



	elif Input.is_action_just_pressed("temp_deselect_building"):
		selected_building = null
		print("no building selected")
		
	elif Input.is_action_just_pressed("toggle_debug_mode"):
		if debug_mode == true:
			debug_mode = false
			print("Debug mode disabled")
		else:
			debug_mode = true
			print("Debug mode enabled")
