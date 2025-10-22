# Holds the active level/scene as a child
# Interface for loading/unloading levels on both server and client
extends Node

const LEVEL_LOBBY = preload("res://level/level_lobby.tscn")

var active_level: String = ""
var player_scores: Dictionary[int, int] = {}


func _ready() -> void:
	if multiplayer.is_server():
		multiplayer.peer_connected.connect(_on_peer_connected)
		load_level("level_lobby", false)


func _on_peer_connected(peer_id: int) -> void:
	if multiplayer.is_server():
		rpc_id(peer_id, "load_level", active_level, false)


@rpc("authority", "call_local", "reliable")
func load_level(level_basename: String, reload: bool) -> void:
	if reload: active_level = ""
	if level_basename == active_level: return
	
	if get_child_count() > 0:
		for child in get_children():
			child.queue_free()
			while is_instance_valid(child):
				await get_tree().process_frame
	
	active_level = level_basename
	
	PlayerManager.despawn_all_players()
	
	await get_tree().process_frame
	
	var level_scene = load("level/%s.tscn" % level_basename)
	var inst_level = level_scene.instantiate()
	call_deferred("add_child", inst_level)
	
	if not level_basename == "level_lobby":
		inst_level.round_won.connect(_on_round_won)
	
	Helper.log("Loaded level: %s" % level_basename)


func _on_round_won(player_id) -> void:
	var player_name = str(player_id)
	rpc("add_won_popup", player_name)
	rpc("load_level", active_level, true)


@rpc("authority", "reliable")
func add_won_popup(player_name: String) -> void:
	var scene = load("res://gui/round_won_popup.tscn")
	var inst = scene.instantiate()
	if inst:
		inst.set_player(player_name)
	add_child(inst)
