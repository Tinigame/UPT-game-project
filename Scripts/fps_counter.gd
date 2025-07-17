extends Label

var fps

func _physics_process(delta: float) -> void:
	fps = Engine.get_frames_per_second()
	
	text = str("fps: ", fps)
