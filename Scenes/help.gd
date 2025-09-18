extends Label
@onready var tutoriallayer = $CenterContainer

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("help_menu"):
		if tutoriallayer.visible == true:
			tutoriallayer.hide()
		else:
			tutoriallayer.show()
