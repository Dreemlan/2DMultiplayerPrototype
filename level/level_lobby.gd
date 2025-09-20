extends Node2D

func _ready() -> void:
	if multiplayer.is_server():
		multiplayer.peer_connected.connect(_on_peer_connect)
		multiplayer.peer_disconnected.connect(_on_peer_disconnect)

func _on_peer_connect(peer: int) -> void:
	pass

func _on_peer_disconnect(peer: int) -> void:
	pass

func _on_player_ready(body) -> void:
	pass

func _on_player_unready(body) -> void:
	pass
