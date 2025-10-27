extends MarginContainer

@onready var label: Label = %Label


func set_color(color: Color) -> void:
	label.add_theme_color_override("font_color", color)
