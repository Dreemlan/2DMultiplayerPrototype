extends Node

const PLAYER_SCENE = preload("res://entity/player.tscn")

@onready var game_world = get_parent().get_node("Main")

@rpc("authority", "reliable")
func spawn_player(peer_id: int) -> void:
	var player_node_name = str(peer_id)
	if game_world.has_node(player_node_name): return
	
	var player = PLAYER_SCENE.instantiate()
	player.name = player_node_name
	game_world.add_child(player)
	
	if multiplayer.is_server():
		for peer in multiplayer.get_peers():
			rpc("spawn_player", peer)
