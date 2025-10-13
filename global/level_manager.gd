# Holds the active level/scene as a child
# Interface for loading/unloading levels on both server and client
extends Node
const LEVEL_LOBBY = preload("res://level/level_lobby.tscn")
var active_level: String = "level_lobby"

func _ready() -> void:
	if multiplayer.is_server():
		server_load_level()

func server_load_level() -> void:
	if get_child_count() > 0:
		active_level = get_child(0).scene_file_path.get_file().get_basename()
	else:
		add_child(LEVEL_LOBBY.instantiate())
