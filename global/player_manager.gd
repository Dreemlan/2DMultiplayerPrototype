extends Node

var current_player_nodes: Dictionary = {}

@onready var level_manager: Node = get_node("/root/Main/LevelManager")


func _ready() -> void:
	multiplayer.peer_disconnected.connect(_on_peer_disconnect)


func _on_peer_disconnect(peer_id: int) -> void:
	despawn_player(peer_id)


@rpc("authority", "reliable")
func spawn_player(peer_id: int, level_basename: String) -> void:
	var player_node_name = str(peer_id)
	var player_scene = load("res://entity/player_%s.tscn" % level_basename)
	
	if has_node(player_node_name):
		Helper.log("Attempted to spawn player, but already exists: %s" % player_node_name)
		return
	
	Helper.log("Spawning player: %s" % peer_id)
	
	var player_inst = player_scene.instantiate()
	player_inst.name = player_node_name
	add_child(player_inst)
	
	current_player_nodes[peer_id] = player_inst
	
	await get_tree().process_frame
	
	ComponentManager.setup_player(player_inst, level_basename)
	
	if multiplayer.is_server():
		for peer in multiplayer.get_peers():
			rpc("spawn_player", peer, level_basename)
	else:
		Helper.log("Sending acknowledge request to server")
		rpc_id(1, "acknowledge_spawn", peer_id)


@rpc("authority", "reliable")
func despawn_player(peer_id: int) -> void:
	var player_node_name = str(peer_id)
	var player_node = get_node_or_null(player_node_name)
	
	if player_node:
		Helper.log("Despawning player entity of %s" % peer_id)
		player_node.call_deferred("queue_free")
	
	if multiplayer.is_server():
		for peer in multiplayer.get_peers():
			rpc("despawn_player", peer_id)


func despawn_all_players() -> void:
	for peer in multiplayer.get_peers():
		despawn_player(peer)


@rpc("any_peer", "reliable")
func acknowledge_spawn(target_peer: int) -> void:
	if multiplayer.is_server():
		var sender = multiplayer.get_remote_sender_id()
		rpc_id(sender, "acknowledge_spawn", target_peer)
		
		if current_player_nodes.has(target_peer):
			var target_player_node = current_player_nodes[target_peer]
			ComponentManager.activate_components(target_player_node)
	else:
		if current_player_nodes.has(target_peer):
			var target_player_node = current_player_nodes[target_peer]
			ComponentManager.activate_components(target_player_node)
