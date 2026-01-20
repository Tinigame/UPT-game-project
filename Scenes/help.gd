extends Label

@onready var tutoriallayer = $CenterContainer
@onready var tutorialtext_et: Label = $"CenterContainer/HBoxContainer/Tutorialtext ET"
@onready var tutorialtext_en: Label = $"CenterContainer/HBoxContainer/Tutorialtext EN"

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("help_menu"):
		if TranslationServer.get_locale() == "et":
			tutorialtext_et.show()
			tutorialtext_en.hide()
		else:
			tutorialtext_en.show()
			tutorialtext_et.hide()

		if tutoriallayer.visible == true:
			tutoriallayer.hide()
		else: 
			tutoriallayer.show()

	if Input.is_action_just_pressed("close_menu"):
		tutoriallayer.hide()
