extends CanvasLayer


func _ready() -> void:
	%ButtonSettings.pressed.connect(_on_button_settings_pressed)

func _on_button_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://gui/menu/settings_menu.tscn")
