extends Node

const PLAYER = preload("res://entity/player.tscn")

func _ready() -> void:
	if multiplayer.is_server():
		multiplayer.peer_connected.connect(spawn_player)

@rpc("authority", "reliable")
func spawn_player(peer_id: int) -> void:
	if has_node(str(peer_id)): return
	
	var player = PLAYER.instantiate()
	player.name = str(peer_id)
	add_child(player)
	
	if multiplayer.is_server():
		for peer in multiplayer.get_peers():
			rpc_id(0, "spawn_player", peer)
