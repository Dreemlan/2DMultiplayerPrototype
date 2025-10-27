class_name SpawnManager
extends Node

var player_scene: PackedScene

var players: Array = []
var player_colors: Array = [ Color.RED, Color.GREEN, Color.BLUE, Color.WEB_PURPLE, Color.ORANGE ]

@onready var spawn_path: Node2D = get_tree().current_scene.get_node("%SpawnPath")


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
		players.erase(network_id)
		player_to_remove.queue_free()


func _add_player_to_game(network_id: int) -> void:
	var player_idx: int = players.size()
	players.append(network_id)
	var player_to_add = player_scene.instantiate()
	player_to_add.name = str(network_id)
	player_to_add.set_multiplayer_authority(1)
	spawn_path.add_child(player_to_add)
	player_to_add.set_color(player_colors[player_idx])
	player_added.emit(network_id)
