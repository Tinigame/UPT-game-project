extends CanvasLayer

@export var popup_lifetime : = 1.5
@export var error_color : = Color.RED
@export var success_color : = Color.GREEN
@onready var speedruntimer: Label = $Speedruntimer


@onready var kill_timer: Timer = $Timer

var label = Label.new()
var feedback_showing = false

func _ready() -> void:
	self.layer = 2
	init_message()



func init_message():
	label.hide()
	label.text = ""
	label.add_theme_color_override("font_color", error_color)
	label.add_theme_color_override("font_color", error_color)
	label.add_theme_font_size_override("font_size", 20)
	label.z_index = 100
	self.add_child(label)
	print("added the damn label")



func show_message(text: String, is_error := false):
	if feedback_showing:
		return
	label.text = text
	
	label.add_theme_color_override("font_color", error_color)
	if is_error:
		label.add_theme_color_override("font_color", error_color)
	else:
		label.add_theme_color_override("font_color", success_color)

	label.show()
	label.add_theme_font_size_override("font_size", 20)

	label.position = get_viewport().get_mouse_position()

	kill_timer.start(popup_lifetime)
	feedback_showing = true



func _on_timer_timeout() -> void:
	label.hide()
	label.text = ""
	feedback_showing = false


var time_since_start : float
func _process(delta: float) -> void:
	if Globals.speedrun_timer_started == true:
		time_since_start += delta
		speedruntimer.text = str("Aeg: ", time_since_start).pad_decimals(2)
