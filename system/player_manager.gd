extends Node

const PLAYER = preload("res://entity/player.tscn")

@onready var main = get_parent()

func _ready() -> void:
	if multiplayer.is_server():
		multiplayer.peer_connected.connect(spawn_player)

@rpc("authority", "reliable")
func spawn_player(peer_id: int) -> void:
	if main.has_node(str(peer_id)): return
	
	Helper.log("Spawning player: %s" % peer_id)
	
	var player = PLAYER.instantiate()
	player.name = str(peer_id)
	main.add_child(player)
	
	if multiplayer.is_server():
		for peer in multiplayer.get_peers():
			rpc("spawn_player", peer)
