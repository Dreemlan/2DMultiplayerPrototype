extends CanvasLayer

@onready var button_host: Button = $Control/VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/ButtonHost
@onready var button_join: Button = $Control/VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/ButtonJoin
@onready var button_settings: Button = $Control/VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/ButtonSettings
@onready var button_quit: Button = $Control/VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/ButtonQuit

func _ready() -> void:
	button_host.pressed.connect(_on_button_host_pressed)
	button_join.pressed.connect(_on_button_join_pressed)
	button_settings.pressed.connect(_on_button_settings_pressed)
	button_quit.pressed.connect(_on_button_quit_pressed)
	
	multiplayer.connected_to_server.connect(_on_connect_to_server)


func _on_connect_to_server() -> void:
	hide()

func _on_button_host_pressed() -> void:
	if Multiplayer.create_server(): hide()

func _on_button_join_pressed() -> void:
	Multiplayer.create_client()

func _on_button_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://gui/menu/settings_menu.tscn")

func _on_button_quit_pressed() -> void:
	get_tree().quit()
