class_name SpawnManager
extends Node

@onready var spawn_path: Node2D = get_tree().current_scene.get_node("%SpawnPath")
@onready var gui: CanvasLayer = get_parent().get_node("GUI")

signal player_added(network_id: int)


func _ready() -> void:
	get_tree().get_multiplayer().peer_connected.connect(_peer_connected)
	get_tree().get_multiplayer().peer_disconnected.connect(_peer_disconnected)
	
	_add_player_to_game(1)


func _peer_connected(network_id: int) -> void:
	Helper.log("Peer connected: %s" % network_id)
	_add_player_to_game(network_id)


func _peer_disconnected(network_id: int) -> void:
	Helper.log("Peer disconnected: %s" % network_id)
	var player_to_remove = spawn_path.find_child(str(network_id), false, false)
	if player_to_remove:
		spawn_path.players.erase(network_id)
		player_to_remove.queue_free()


func _add_player_to_game(network_id: int) -> void:
	spawn_path.setup_player(network_id)
	#player_to_add.player_scored.connect(gui._on_player_scored)
	player_added.emit(network_id)
	spawn_path.players.append(network_id)
