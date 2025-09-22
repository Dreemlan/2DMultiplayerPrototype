extends Control

@onready var button_settings: Button = $VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/ButtonSettings
@onready var button_quit: Button = $VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/ButtonQuit

func _ready() -> void:
	# Settings signal
	button_settings.pressed.connect(_on_button_settings_pressed)
	# Quit game signal
	button_quit.pressed.connect(_on_button_quit_pressed)

# Change to settings menu
func _on_button_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://gui/menu/settings_menu.tscn")

# Quit game
func _on_button_quit_pressed() -> void:
	get_tree().quit()
