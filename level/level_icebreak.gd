extends Node2D

var occupied_points = [false, false, false, false, false, false, false, false]

@onready var main = get_parent()
@onready var spawn_points: Array = get_node("SpawnPoints").get_children()


func _ready() -> void:
	if multiplayer.is_server():
		multiplayer.peer_connected.connect(_on_player_connect)
		
		for peer_id: int in multiplayer.get_peers():
			set_player_spawn_position(peer_id)


func _on_player_connect(peer_id: int) -> void:
	set_player_spawn_position(peer_id)


func set_player_spawn_position(peer_id: int) -> void:
	if main.has_node(str(peer_id)):
		for i in spawn_points.size():
			var point_node = spawn_points[i]
			if occupied_points[i] == false:
				main.get_node(str(peer_id)).global_position = point_node.global_position
				occupied_points[i] = true
				break
