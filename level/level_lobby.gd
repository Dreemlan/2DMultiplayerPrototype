extends Node2D

const LOBBY_PLAYER_CARD = preload("res://gui/hud/lobby_player_card.tscn")

var ready_statuses: Dictionary[int, bool] = {}

@onready var level_icebreak_ready_area: Area2D = $AreaReadyLevelIceBreak
@onready var level_lobby_timer: Timer = $HUD/Control/LevelLobbyTimer
@onready var player_card_container: HBoxContainer = $HUD/Control/MarginContainer/VBoxContainer/PlayerCardContainer

func _ready() -> void:
	if multiplayer.is_server():
		Multiplayer.connect("peer_registered", Callable(_on_player_registered))
		level_icebreak_ready_area.body_entered.connect(_on_player_ready.bind(true))
		level_icebreak_ready_area.body_exited.connect(_on_player_ready.bind(false))
		level_lobby_timer.timer_finished.connect(_on_timer_finished)

func _on_player_registered(new_peer_id: int) -> void:
	if multiplayer.is_server():
		var registered_players: Array = Multiplayer.peer_display_names.keys()
		for p in registered_players:
			var p_name = Multiplayer.peer_display_names[p]
			if p == new_peer_id: continue
			rpc_id(new_peer_id, "add_player_card", p, p_name)
		
		ready_statuses[new_peer_id] = false
		spawn_player(new_peer_id)
		var new_name: String = Multiplayer.peer_display_names[new_peer_id]
		rpc("add_player_card", new_peer_id, new_name)

func _on_player_ready(player_node: Node, ready_status: bool) -> void:
	if multiplayer.is_server():
		var peer_id = int(player_node.name)
		ready_statuses[peer_id] = ready_status
		rpc("update_player_card_ready", peer_id, ready_status)
		if all_players_ready():
			rpc("start_lobby_timer")
		else:
			rpc("stop_lobby_timer")

func spawn_player(peer_id: int) -> void:
	PlayerManager.spawn_player(peer_id, self.name, scene_file_path.get_file().get_basename())

func all_players_ready() -> bool:
	for status in ready_statuses.values():
		if status == false:
			Helper.log("Not all players are ready")
			return false
	return true


@rpc("authority", "call_local", "reliable")
func add_player_card(peer_id: int, display_name: String) -> void:
	if player_card_container.has_node(str(peer_id)): return
	
	var inst = LOBBY_PLAYER_CARD.instantiate()
	inst.name = str(peer_id)
	player_card_container.add_child(inst)
	inst.set_card_name(display_name)
	
	Helper.log("Added player card for peer %d (%s)" % [peer_id, display_name])

func _on_timer_finished() -> void:
	get_parent().load_level("level_icebreak")

@rpc("authority", "call_local", "reliable")
func update_player_card_ready(peer_id: int, status: bool) -> void:
	var player_card = player_card_container.get_node(str(peer_id))
	player_card.update_ready_status(status)

@rpc("authority", "call_local", "reliable")
func start_lobby_timer() -> void:
	level_lobby_timer.start()

@rpc("authority", "call_local", "reliable")
func stop_lobby_timer() -> void:
	level_lobby_timer.stop()
