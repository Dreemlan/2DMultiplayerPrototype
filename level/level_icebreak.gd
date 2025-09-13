extends Node2D

const HUD_SCORE = preload("res://hud/hud_score.tscn")

var occupied_points = [false, false, false, false, false, false, false, false]
var player_numbers: Dictionary[int, int] = {}
var player_scores: Dictionary[int, int] = {}

@onready var main = get_parent()
@onready var camera_2d: Camera2D = $Camera2D
@onready var elimination_zone: Area2D = $EliminationZone
@onready var platforms: Node = $Platforms
@onready var player_score_container: HBoxContainer = $HUD/Control/PlayerScoreContainer
@onready var spawn_points: Array = get_node("SpawnPoints").get_children()
@onready var start_timer: Timer = $StartTimer
@onready var start_timer_label: Label = $HUD/Control/StartTimerLabel



func _ready() -> void:
	# Set camera as current
	camera_2d.make_current()
	
	if not multiplayer.is_server(): return
	
	# Game start timer
	start_timer.timeout.connect(_on_game_start)
	
	# Elimination signal
	elimination_zone.body_entered.connect(_on_player_eliminated)
	
	# Connect signal to set up player when they connect
	multiplayer.peer_connected.connect(setup_player)
	
	# Set up each player that's connected
	for peer_id: int in multiplayer.get_peers():
		setup_player(peer_id)


func _physics_process(_delta: float) -> void:
	var start_timer_left: int = int(start_timer.get_time_left())
	start_timer_label.text = str(start_timer_left)
	if start_timer_left == 0:
		start_timer_label.visible = false


# Triggered when game timer ends
func _on_game_start() -> void:
	for platform in platforms.get_children():
		platform.player_scored.connect(_on_player_scored)
		platform.enable_collision()


func _on_player_eliminated(player_body) -> void:
	player_body.set_deferred("linear_damp", 100)
	player_body.set_deferred("angular_damp", 10)
	player_body.set_deferred("gravity_scale", 0.3)


# Register player score and number
# Set up HUD
func setup_player(peer_id: int) -> void:
	if not main.has_node(str(peer_id)): return
	
	var player_node = main.get_node(str(peer_id))
	for i in spawn_points.size():
		if not occupied_points[i]:
			# Move to spawn point
			var point_node = spawn_points[i]
			player_node.global_position = point_node.global_position
			
			# Assign number based on slot
			player_numbers[peer_id] = i
			
			# Mark as occupied
			occupied_points[i] = true
			
			rpc("setup_score", peer_id, i)
			break


@rpc("authority", "call_local", "reliable")
func setup_score(peer_id: int, player_number: int) -> void:
	# Set score and player number
	player_scores[peer_id] = 0
	player_numbers[peer_id] = player_number
	
	# Add HUD element to scene
	var hud_player_score = HUD_SCORE.instantiate()
	player_score_container.add_child(hud_player_score)
	hud_player_score.setup_player_score(player_number + 1)


# Triggered by the platform entity
func _on_player_scored(peer_id: int) -> void:
	if not player_scores.has(peer_id): return
	var current_score = player_scores[peer_id]
	var new_score = current_score + 1
	rpc("update_score", peer_id, new_score)


@rpc("authority", "call_local", "reliable")
func update_score(peer_id: int, amount: int) -> void:
	player_scores[peer_id] = amount
	
	var player_number = player_numbers[peer_id]
	var score_label = player_score_container.get_child(player_number)
	var score = player_scores[peer_id]
	
	score_label.update_score_label(score)
