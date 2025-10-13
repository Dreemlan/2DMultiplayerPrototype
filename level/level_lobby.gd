# A lobby featuring a multitude of levels to select
# Player entities are spawned in and can run around
# Will feature an area to customize appearance
extends Node2D

const LOBBY_PLAYER_CARD = preload("res://gui/hud_lobby_player_card.tscn")

var player_ready_status: Dictionary[int, bool] = {}
var target_level

@onready var level_manager = get_parent()
@onready var lobby_ready: Node2D = $LevelLobbyReadyArea
@onready var lobby_timer: Timer = $HUD/Control/LevelLobbyTimer
@onready var player_card_container: HBoxContainer = $HUD/Control/MarginContainer/VBoxContainer/PlayerCardContainer


func _ready() -> void:
	if multiplayer.is_server():
		Multiplayer.peer_registered.connect(_on_setup_player)
		lobby_ready.player_ready.connect(_on_player_ready)
		lobby_timer.timer_finished.connect(_on_timer_finished)


func _on_setup_player(target_peer: int) -> void:
	if multiplayer.is_server():
		var registered_players: Array = Multiplayer.peer_display_names.keys()
		for p in registered_players:
			if p == target_peer: continue
			var p_name = Multiplayer.peer_display_names[p]
			rpc_id(target_peer, "add_player_card", p, p_name)
		
		player_ready_status[target_peer] = false
		
		var target_name = Multiplayer.peer_display_names[target_peer]
		rpc("add_player_card", target_peer, target_name)
		
		PlayerManager.spawn_player(target_peer, self.name, scene_file_path.get_file().get_basename())


func _on_player_ready(level: PackedScene, player_node: Node, ready_status: bool) -> void:
	if multiplayer.is_server():
		target_level = level
		
		var peer_id = int(player_node.name)
		player_ready_status[peer_id] = ready_status
		
		rpc("update_player_card_ready", peer_id, ready_status)
		
		check_all_players_ready()


func _on_timer_finished() -> void:
	if multiplayer.is_server():
		level_manager.rpc("load_level", target_level)


func check_all_players_ready() -> void:
	if multiplayer.is_server():
		for status in player_ready_status.values():
			if status == false:
				rpc("stop_lobby_timer")
		rpc("start_lobby_timer")


@rpc("authority", "call_local", "reliable")
func add_player_card(peer_id: int, display_name: String) -> void:
	if player_card_container.has_node(str(peer_id)): return
	
	var inst_card = LOBBY_PLAYER_CARD.instantiate()
	player_card_container.add_child(inst_card)
	inst_card.name = str(peer_id)
	inst_card.set_display_name(display_name)
	
	Helper.log("Added player card: %d (%s)" % [peer_id, display_name])


@rpc("authority", "call_local", "reliable")
func set_player_card_ready(peer_id: int, status: bool) -> void:
	var player_card = player_card_container.get_node(str(peer_id))
	player_card.set_ready_status(status)


@rpc("authority", "call_local", "reliable")
func start_lobby_timer() -> void:
	lobby_timer.start()


@rpc("authority", "call_local", "reliable")
func stop_lobby_timer() -> void:
	lobby_timer.stop()
