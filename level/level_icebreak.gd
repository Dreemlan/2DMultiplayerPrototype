extends Node2D

var game_started: bool = false

# Static variables on both server and client
@onready var level_start_timer: Node = $HUD/Control/PlayerScoreContainer/LevelStartTimer

func _ready() -> void:
	if multiplayer.is_server():
		level_start_timer.timer_finished.connect(start_game)
		for peer_id in Multiplayer.peer_display_names.keys():
			spawn_player(peer_id)

func spawn_player(peer_id: int) -> void:
	if multiplayer.is_server():
		PlayerManager.spawn_player(peer_id, self.name, scene_file_path.get_file().get_basename())

func start_game() -> void:
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

@rpc("authority", "call_local", "reliable")
func start_timer() -> void:
	level_start_timer.start()
