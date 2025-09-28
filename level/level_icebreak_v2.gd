extends Node2D

func _ready() -> void:
	if multiplayer.is_server():
		multiplayer.peer_connected.connect(spawn_player)
		multiplayer.peer_disconnected.connect(despawn_player)
	else:
		pass

func spawn_player(peer_id: int) -> void:
	if multiplayer.is_server():
		PlayerManager.spawn_player(peer_id, self.name, scene_file_path.get_file().get_basename())

func despawn_player(peer_id: int) -> void:
	if multiplayer.is_server():
		PlayerManager.despawn_player(peer_id, self.name)
