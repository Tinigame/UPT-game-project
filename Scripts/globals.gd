extends Node

var buildmode = false
var building_location = Vector3(0, 0, 0)
var selected_building = preload("res://Resources/buildings/conveyor_belt.tres")

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("temp_select_building_1"):
		selected_building = preload("res://Resources/buildings/conveyor_belt.tres")
		print("selected conveyor")
	elif Input.is_action_just_pressed("temp_select_building_2"):
		selected_building = preload("res://Resources/buildings/2x2 rock.tres")
		print("selected 2x2 rock")
