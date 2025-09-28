extends CanvasLayer

func _ready() -> void:
	%ButtonHost.pressed.connect(_on_button_host_pressed)
	%ButtonJoin.pressed.connect(_on_button_join_pressed)
	%ButtonSettings.pressed.connect(_on_button_settings_pressed)
	%ButtonQuit.pressed.connect(_on_button_quit_pressed)
	
	multiplayer.connected_to_server.connect(_on_connect_to_server)


func _on_button_host_pressed() -> void:
	if Multiplayer.create_server(): hide()

func _on_button_join_pressed() -> void:
	var client_display_name: String = %LineEditDisplayName.text
	if client_display_name == "":
		client_display_name = "Noob"
	if not Multiplayer.create_client(client_display_name): Helper.log("Failed to create client")

func _on_button_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://gui/menu/settings_menu.tscn")

func _on_button_quit_pressed() -> void:
	get_tree().quit()


func _on_connect_to_server() -> void:
	hide()
