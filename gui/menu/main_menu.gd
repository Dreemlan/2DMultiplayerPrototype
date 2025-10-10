extends CanvasLayer

var client_display_name: String = "Noob"

func _ready() -> void:
	%ButtonHost.pressed.connect(_on_button_host_pressed)
	%ButtonJoin.pressed.connect(_on_button_join_pressed)
	%ButtonSettings.pressed.connect(_on_button_settings_pressed)
	%ButtonQuit.pressed.connect(_on_button_quit_pressed)
	
	multiplayer.connected_to_server.connect(_on_connect_to_server)


func _on_button_host_pressed() -> void:
	if Multiplayer.create_server(): hide()

func _on_button_join_pressed() -> void:
	client_display_name = %LineEditDisplayName.text
	if client_display_name == "":
		client_display_name = "Noob"
	if not Multiplayer.create_client(): Helper.log("Failed to create client")

func _on_button_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://gui/menu/settings_menu.tscn")

func _on_button_quit_pressed() -> void:
	get_tree().quit()


func _on_connect_to_server() -> void:
	Multiplayer.register_peer_name.rpc_id(1, multiplayer.get_unique_id(), client_display_name)
	hide()
