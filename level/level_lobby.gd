# A lobby featuring a multitude of levels to select
# Player entities are spawned in and can run around
# Will feature an area to customize appearance
extends Node2D

const LOBBY_PLAYER_CARD = preload("res://gui/hud_lobby_player_card.tscn")

var ready_statuses: Dictionary[int, bool] = {}
var target_level

@onready var lobby_level_ready_area: Node2D = $LobbyLevelReadyArea
@onready var lobby_timer: Timer = $HUD/Control/LevelLobbyTimer
@onready var player_card_container: HBoxContainer = $HUD/Control/MarginContainer/VBoxContainer/PlayerCardContainer


func _ready() -> void:
	if multiplayer.is_server():
		Multiplayer.peer_registered.connect(_on_peer_registered)
		lobby_level_ready_area.player_ready.connect(_on_player_ready)
		lobby_timer.timer_finished.connect(_on_timer_finished)


func _on_peer_registered(target_peer: int) -> void:
	if multiplayer.is_server():
		var registered_players: Array = Multiplayer.peer_display_names.keys()
		for p in registered_players:
			if p == target_peer: continue
			var p_name = Multiplayer.peer_display_names[p]
			rpc_id(target_peer, "add_player_card", p, p_name)
		
		ready_statuses[target_peer] = false
		
		var target_name = Multiplayer.peer_display_names[target_peer]
		rpc("add_player_card", target_peer, target_name)
		
		PlayerManager.spawn_player(target_peer, self.name, scene_file_path.get_file().get_basename())


func _on_player_ready(level: PackedScene, player_node: Node, ready_status: bool) -> void:
	if multiplayer.is_server():
		target_level = level
		var peer_id = int(player_node.name)
		ready_statuses[peer_id] = ready_status
		rpc("update_player_card_ready", peer_id, ready_status)
		if all_players_ready(): rpc("start_lobby_timer")
		else: rpc("stop_lobby_timer")


func all_players_ready() -> bool:
	for status in ready_statuses.values():
		if status == false:
			Helper.log("Not all players are ready")
			return false
	return true


func _on_timer_finished() -> void:
	pass


@rpc("authority", "call_local", "reliable")
func add_player_card(peer_id: int, display_name: String) -> void:
	if player_card_container.has_node(str(peer_id)): return
	
	var inst = LOBBY_PLAYER_CARD.instantiate()
	inst.name = str(peer_id)
	player_card_container.add_child(inst)
	inst.set_card_name(display_name)
	
	Helper.log("Added player card for peer %d (%s)" % [peer_id, display_name])


@rpc("authority", "call_local", "reliable")
func update_player_card_ready(peer_id: int, status: bool) -> void:
	var player_card = player_card_container.get_node(str(peer_id))
	player_card.update_ready_status(status)


@rpc("authority", "call_local", "reliable")
func start_lobby_timer() -> void:
	lobby_timer.start()


@rpc("authority", "call_local", "reliable")
func stop_lobby_timer() -> void:
	lobby_timer.stop()
