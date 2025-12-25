extends PanelContainer

@onready var text_label: RichTextLabel = $MarginContainer/RichTextLabel

func show_tooltip(text: String, tooltip_position: Vector2):
	text_label.clear()
	text_label.append_text(text)
	global_position = tooltip_position
	show()

func hide_tooltip():
	hide()
