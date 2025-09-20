extends Node2D

## Server-side
var player_scores: Dictionary[int, int] = {}
var player_numbers: Dictionary[int, int] = {}

## Both server and client
const HUD_SCORE = preload("res://hud/hud_score.tscn")

@onready var main = get_parent()
@onready var camera_2d: Camera2D = $Camera2D
@onready var elimination_zone: Area2D = $EliminationZone
@onready var platforms: Node = $Platforms
@onready var GUI_player_score_container: HBoxContainer = $HUD/Control/PlayerScoreContainer
@onready var spawn_points: Array = get_node("SpawnPoints").get_children()
@onready var start_timer: Timer = $StartTimer
@onready var start_timer_label: Label = $HUD/Control/StartTimerLabel


func _ready() -> void:
	# Set camera as current
	camera_2d.make_current()
	
	if multiplayer.is_server():
		# Game logic
		start_timer.timeout.connect(_on_game_start)
		elimination_zone.body_entered.connect(_on_player_eliminated)
		# Networking
		multiplayer.peer_connected.connect(server_setup_player)
		for peer_id: int in multiplayer.get_peers():
			server_setup_player(peer_id)

func _physics_process(_delta: float) -> void:
	var start_timer_left: int = int(start_timer.get_time_left())
	start_timer_label.text = str(start_timer_left)
	if start_timer_left == 0:
		start_timer_label.visible = false

func _on_game_start() -> void:
	for platform in platforms.get_children():
		platform.player_scored.connect(_on_player_scored)
		platform.enable_collision()

func _on_player_scored(peer_id: int) -> void:
	if not player_scores.has(peer_id): return
	var current_score = player_scores[peer_id]
	var new_score = current_score + 1
	rpc("update_score", peer_id, new_score)

func _on_player_eliminated(player_body) -> void:
	player_body.set_deferred("linear_damp", 100)
	player_body.set_deferred("angular_damp", 10)
	player_body.set_deferred("gravity_scale", 0.3)

func server_setup_player(peer_id: int) -> void:
	if not main.has_node(str(peer_id)): return # Early exit
	# Server-side only
	server_setup_player_number(peer_id)
	move_player_to_spawn(peer_id)
	# Both server and client
	rpc("setup_player_score", peer_id)

func server_setup_player_number(peer_id: int) -> void:
	if multiplayer.is_server():
		if player_numbers.size() == 0:
			player_numbers[peer_id] = 1
		elif not player_numbers.has(peer_id):
			player_numbers[peer_id] = player_numbers.size() + 1
		
		rpc("send_clients_player_numbers", player_numbers)

func move_player_to_spawn(peer_id: int) -> void:
	var player_node = main.get_node(str(peer_id))
	var spawn_point = spawn_points[player_numbers[peer_id]]
	player_node.global_position = spawn_point.global_position


@rpc("any_peer", "reliable")
func get_player_score(peer_id: int) -> int:
	return player_scores[peer_id]

@rpc("any_peer", "reliable")
func get_player_number(peer_id: int) -> int:
	return player_numbers[peer_id]

@rpc("authority", "reliable")
func send_clients_player_numbers(server_player_numbers: Dictionary) -> void:
	player_numbers = server_player_numbers

@rpc("authority", "call_local", "reliable")
func setup_player_score(peer_id: int) -> void:
	if player_scores.has(peer_id): return # Early exit
	
	player_scores[peer_id] = 0
	
	if not multiplayer.is_server():
		var GUI_player_score_scene = HUD_SCORE.instantiate()
		GUI_player_score_scene.name = str(peer_id)
		GUI_player_score_container.add_child(GUI_player_score_scene)
		GUI_player_score_scene.set_player_number(player_numbers[peer_id])
	
	if multiplayer.is_server():
		for peer in multiplayer.get_peers():
			rpc("setup_player_score", peer)

@rpc("authority", "call_local", "reliable")
func update_score(peer_id: int, amount: int) -> void:
	Helper.log("Updating score data and GUI...")
	player_scores[peer_id] = amount
	if not multiplayer.is_server():
		var GUI_player_score_scene = GUI_player_score_container.get_node(str(peer_id))
		GUI_player_score_scene.update_score_label(amount)
