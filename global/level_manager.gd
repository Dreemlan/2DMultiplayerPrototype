# Holds the active level/scene as a child
# Interface for loading/unloading levels on both server and client
extends Node

const LEVEL_LOBBY = preload("res://level/level_lobby.tscn")

var active_level: String = ""


func _ready() -> void:
	if multiplayer.is_server():
		multiplayer.peer_connected.connect(_on_peer_connected)
		
		load_level("level_lobby")


func _on_peer_connected(peer_id: int) -> void:
	if multiplayer.is_server():
		Helper.log("Loading level for peer: %s" % peer_id)
		rpc_id(peer_id, "load_level", active_level)


@rpc("authority", "call_local", "reliable")
func load_level(level_basename: String) -> void:
	if level_basename == active_level:
		Helper.log("Level already loaded: %s" % active_level)
		return
	
	if get_child_count() > 0:
		var old_level = get_child(0)
		if old_level:
			old_level.call_deferred("queue_free")
	
	active_level = level_basename
	
	PlayerManager.despawn_all_players()
	
	await get_tree().process_frame
	
	var level_scene = load("level/%s.tscn" % level_basename)
	var inst_level = level_scene.instantiate()
	call_deferred("add_child", inst_level)
	
	Helper.log("Loaded level: %s" % level_basename)
