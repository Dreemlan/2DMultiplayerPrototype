extends Node

@onready var level_manager: Node = get_node("/root/Main/LevelManager")


@rpc("authority", "reliable")
func spawn_player(peer_id: int, level_name: String, level_basename: String) -> void:
	var player_node_name = str(peer_id)
	var player_scene = load("res://entity/player_%s.tscn" % level_basename)
	
	var level = level_manager.get_node(level_name)
	if level.has_node(player_node_name): return
	
	Helper.log("Spawning player entity for %s" % peer_id)
	
	var inst = player_scene.instantiate()
	inst.name = player_node_name
	level.add_child(inst)
	
	# At this point, the player will exist first on server, then client
	# So begin adding components, such as syncing transforms
	ComponentManager.add_sync_component_to_node(inst)
	
	if multiplayer.is_server():
		for peer in multiplayer.get_peers():
			rpc("spawn_player", peer, level_name, level_basename)


@rpc("authority", "reliable")
func despawn_player(peer_id: int, level_name: String) -> void:
	var player_node_name = str(peer_id)
	var level = level_manager.get_node(level_name)
	var player_node = level.get_node(player_node_name)
	Helper.log("Despawning player entity of %s" % peer_id)
	player_node.queue_free()
	
	if multiplayer.is_server():
		for peer in multiplayer.get_peers():
			rpc("despawn_player", peer_id, level_name)
