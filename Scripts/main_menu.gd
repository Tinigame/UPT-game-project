extends CenterContainer

@onready var playbutton: Button = $CanvasLayer/VBoxContainer/Playbutton
@onready var estonian_button: TextureButton = $CanvasLayer/VBoxContainer/HBoxContainer/estonian
@onready var english_button: TextureButton = $CanvasLayer/VBoxContainer/HBoxContainer/english

func _ready() -> void:
	playbutton.pressed.connect(start_game)
	
	estonian_button.pressed.connect(change_language_to_et)
	english_button.pressed.connect(change_language_to_en)
	
	var bgroup = ButtonGroup.new()

	estonian_button.toggle_mode = true
	english_button.toggle_mode = true

	estonian_button.button_group = bgroup
	english_button.button_group = bgroup
	
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func start_game():
	print("we gamed")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_child(0).hide()

func change_language_to_et():
	TranslationServer.set_locale("et")
	
func change_language_to_en():
	TranslationServer.set_locale("en")
	
