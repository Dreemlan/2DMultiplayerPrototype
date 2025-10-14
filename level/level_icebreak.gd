extends Node2D

var game_started: bool = false

@onready var level_start_timer: Node = $HUD/Control/PlayerScoreContainer/LevelStartTimer


func _enter_tree() -> void:
	if multiplayer.is_server():
		for peer_id in Multiplayer.peer_display_names.keys():
			PlayerManager.spawn_player(peer_id, scene_file_path.get_file().get_basename())


func _ready() -> void:
	if multiplayer.is_server():
		level_start_timer.timer_finished.connect(_on_timer_finished)


func _on_timer_finished() -> void:
	game_started = true


func should_game_start() -> bool:
	var state: bool = false
	for peer_id in multiplayer.get_peers():
		if not has_node(str(peer_id)):
			Helper.log("Not all players have loaded")
			state = false
		else:
			state = true
	Helper.log("All players have loaded, starting match...")
	return state
