extends Node

var buildmode = false
var building_location = Vector3(0, 0, 0)
var building_rotation = Vector3(0, 0, 0)
var selected_building: Resource = null
var old_building
var ore_map: Dictionary

var debug_item = preload("res://Resources/buildings/conveyor_belt.tres")
var debug_recipe = preload("res://Resources/recipes/debug_recipe.tres")
var debug_mode: bool = false
var speedrun_timer_started: bool = false

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("temp_select_building_1"):
		_toggle_building("res://Resources/buildings/conveyor_belt.tres", "conveyor")

	elif Input.is_action_just_pressed("temp_select_building_2"):
		_toggle_building("uid://bg763wlyjknto", "splitter")

	elif Input.is_action_just_pressed("temp_select_building_3"):
		_toggle_building("res://Resources/buildings/assembler.tres", "assembler")

	elif Input.is_action_just_pressed("temp_select_building_4"):
		_toggle_building("res://Resources/buildings/mining_drill.tres", "mining drill")

	elif Input.is_action_just_pressed("temp_deselect_building"):
		selected_building = null
		print("no building selected")
		
	elif Input.is_action_just_pressed("toggle_debug_mode"):
		debug_mode = !debug_mode
		print("Debug mode", "enabled" if debug_mode else "disabled")


func _toggle_building(path: String, bname: String) -> void:
	var building_res = load(path)
	
	# if same building is already selected, deselect it
	if selected_building == building_res:
		selected_building = null
		print(bname, "deselected")
	else:
		selected_building = building_res
		print("selected", bname)
