extends Button

#makes game begin
func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/world.tscn")
