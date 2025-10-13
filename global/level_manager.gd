# Holds the active level/scene as a child
# Interface for loading/unloading levels on both server and client
extends Node

const LEVEL_LOBBY = preload("res://level/level_lobby.tscn")

var active_level: String = "level_lobby"


func _ready() -> void:
	if multiplayer.is_server():
		multiplayer.peer_connected.connect(_on_peer_connected)


func _on_peer_connected(_peer_id: int) -> void:
	if multiplayer.is_server():
		rpc("load_level", active_level)


@rpc("authority", "call_local", "reliable")
func load_level(level_name: String) -> void:
	var level_scene = load("level/%s.tscn" % level_name)
	var inst_level = level_scene.instantiate()
	add_child(inst_level)
	
	Helper.log("Loaded level: %s" % inst_level.name)
