extends Label

var fps

func _physics_process(_delta: float) -> void:
	getfps()

func getfps():
	await get_tree().create_timer(0.1).timeout
	fps = Engine.get_frames_per_second()
	text = str("fps: ", fps)
