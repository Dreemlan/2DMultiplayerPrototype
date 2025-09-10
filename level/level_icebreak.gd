extends Node2D

const HUD_SCORE = preload("res://hud/hud_score.tscn")

var occupied_points = [false, false, false, false, false, false, false, false]
var scores = {}

@onready var ice: Node = $Ice
@onready var main = get_parent()
@onready var player_score_container: HBoxContainer = $HUD/Control/PlayerScoreContainer
@onready var spawn_points: Array = get_node("SpawnPoints").get_children()


func _ready() -> void:
	if multiplayer.is_server():
		for platform in ice.get_children():
			platform.player_scored.connect(_on_player_scored)
		
		multiplayer.peer_connected.connect(_on_player_connect)
		
		for peer_id: int in multiplayer.get_peers():
			scores[peer_id] = 0
			setup_player(peer_id)


func _on_player_connect(peer_id: int) -> void:
	setup_player(peer_id)


func setup_player(peer_id: int) -> void:
	if main.has_node(str(peer_id)):
		var player_node = main.get_node(str(peer_id))
		
		# Spawn
		for i in spawn_points.size():
			var point_node = spawn_points[i]
			if occupied_points[i] == false:
				player_node.global_position = point_node.global_position
				occupied_points[i] = true
				
				# HUD
				rpc("update_score_hud", i)
				
				break


func _on_player_scored(peer_id: int) -> void:
	if scores.has(peer_id):
		scores[peer_id] += 1
	else:
		scores[peer_id] = 1


@rpc("authority", "call_local", "reliable")
func update_score_hud(player_number: int) -> void:
	var hud_player_score = HUD_SCORE.instantiate()
	player_score_container.add_child(hud_player_score)
	hud_player_score.setup_player_score(player_number + 1)
