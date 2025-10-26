extends Node

const GAME_SCENE = "res://scenes/game.tscn"
const MAIN_MENU_SCENE = "res://scenes/main_menu.tscn"
const SERVER_PORT: int = 42069

var is_hosting_game: bool = false


func create_server() -> void:
	is_hosting_game = true
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	peer = ENetMultiplayerPeer.new()
	peer.create_server(SERVER_PORT)
	get_tree().get_multiplayer().multiplayer_peer = peer
	Helper.log("Server created!")


func create_client(host_ip: String = "localhost", host_port: int = SERVER_PORT) -> void:
	is_hosting_game = false
	_setup_client_connection_signals()
	
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	peer = ENetMultiplayerPeer.new()
	peer.create_client(host_ip, host_port)
	get_tree().get_multiplayer().multiplayer_peer = peer
	Helper.log("Client created!")


func _setup_client_connection_signals() -> void:
	Helper.log("Setting up client connection signals...")
	if not multiplayer.server_disconnected.is_connected(_server_disconnected):
		multiplayer.server_disconnected.connect(_server_disconnected)


func _server_disconnected() -> void:
	Helper.log("Server disconnected")
	terminate_connection_load_main_menu()


func load_game_scene() -> void:
	Helper.log("Loading game scene...")
	get_tree().call_deferred(&"change_scene_to_packed", preload(GAME_SCENE))


func terminate_connection_load_main_menu():
	Helper.log("Terminating connection and loading main menu...")
	_load_main_menu()
	_terminate_connection()
	_disconnect_client_connection_signals()


func _load_main_menu() -> void:
	get_tree().call_deferred(&"change_scene_to_packed", preload(MAIN_MENU_SCENE))


func _terminate_connection() -> void:
	Helper.log("Terminating connection...")
	get_tree().get_multiplayer().multiplayer_peer = null


func _disconnect_client_connection_signals() -> void:
	Helper.log("Disconnecting client connection signals...")
	if get_tree().get_multiplayer().server_disconnected.has_connections():
		get_tree().get_multiplayer().server_disconnected.disconnect(_server_disconnected)
