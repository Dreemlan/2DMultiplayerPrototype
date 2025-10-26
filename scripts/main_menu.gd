extends CanvasLayer


func _ready() -> void:
	%Server.pressed.connect(_on_server_pressed)
	%Client.pressed.connect(_on_client_pressed)


func _on_server_pressed() -> void:
	NetworkManager.create_server()
	NetworkManager.load_game_scene()


func _on_client_pressed() -> void:
	NetworkManager.load_game_scene()
	NetworkManager.create_client()
