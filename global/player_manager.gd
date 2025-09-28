extends Node

const SYNC_TRANSFORM = preload("uid://jnlnvsgv7t3m")

@onready var level_manager: Node = get_node("/root/Main/LevelManager")


func spawn_player(peer_id: int, level_name: String, level_basename: String) -> void:
	var player_node_name = str(peer_id)
	var player_scene = load("res://entity/player_%s.tscn" % level_basename)
	
	var level = level_manager.get_node(level_name)
	if level.has_node(player_node_name): return
	
	Helper.log("Spawning player %s" % peer_id)
	
	var inst = player_scene.instantiate()
	inst.name = player_node_name
	level.add_child(inst)


func despawn_player(peer_id: int, level_name: String) -> void:
	var player_node_name = str(peer_id)
	var level = level_manager.get_node(level_name)
	var player_node = level.get_node(player_node_name)
	Helper.log("Despawning player %s" % peer_id)
	player_node.queue_free()


func add_sync_component(node: Node) -> void:
	node.add_child(SYNC_TRANSFORM.instantiate())
