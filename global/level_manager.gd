extends Node

const LEVEL_LOBBY = preload("res://level/level_lobby.tscn")
const LEVEL_ICE_BREAK = preload("res://level/level_icebreak.tscn")

var active_level: String = "level_lobby"
var levels = [ LEVEL_ICE_BREAK ]

func _ready() -> void:
	if multiplayer.is_server():
		server_load_level()
		multiplayer.peer_connected.connect(_on_peer_connect)

func server_load_level() -> void:
	if get_child_count() > 0:
		active_level = get_child(0).scene_file_path.get_file().get_basename()
	else:
		add_child(LEVEL_LOBBY.instantiate())

func _on_peer_connect(peer_id: int) -> void:
	if multiplayer.is_server():
		rpc_id(peer_id, "client_load_level", active_level)

@rpc("authority", "reliable")
func client_load_level(level_name: String) -> void:
	# Check if level already exists
	if get_child_count() > 0:
		return
	if multiplayer.is_server():
		return
	else:
		var scene = load("res://level/%s.tscn" % level_name)
		var inst = scene.instantiate()
		add_child(inst)
