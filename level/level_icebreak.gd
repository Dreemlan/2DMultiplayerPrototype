extends Node2D

# Entities of level
const PLAYER_SCENE = preload("res://entity/player_icebreak.tscn")

@onready var game_started: bool = false

## Server-side
var player_scores: Dictionary[int, int] = {}
var player_numbers: Dictionary[int, int] = {}
var player_nodes: Array = []
var player_can_collide: Dictionary[int, bool] = {}

## Both server and client
const HUD_SCORE = preload("res://gui/hud/hud_score.tscn")

@onready var level_manager = get_parent()
@onready var camera_2d: Camera2D = $Camera2D
@onready var elimination_zone: Area2D = $EliminationZone
@onready var GUI_player_score_container: HBoxContainer = $HUD/Control/PlayerScoreContainer
@onready var spawn_points: Array = get_node("SpawnPoints").get_children()
@onready var tile_map_layer: TileMapLayer = $TileMapLayer


func _ready() -> void:
	if multiplayer.is_server():
		elimination_zone.body_entered.connect(_on_player_eliminated)
		multiplayer.peer_connected.connect(server_setup_player)
		for peer_id: int in multiplayer.get_peers():
			server_setup_player(peer_id)

func _physics_process(_delta: float) -> void:
	
	if multiplayer.is_server():
		if not game_started: return
		
		# Player collision with ice checks
		for player: CharacterBody2D in player_nodes:
			var peer_id = int(player.name)
			
			if not player.is_on_floor():
				player_can_collide[peer_id] = true
			
			var last_collision = null
			if player_can_collide[peer_id] == true:
				var latest_collision = player.get_last_slide_collision()
				if last_collision != latest_collision:
					# Get cell coords
					var cell_coords: Vector2 = tile_map_layer.local_to_map(latest_collision.get_position() - latest_collision.get_normal())
					# Get tile id using cell coords
					var tile_id = tile_map_layer.get_cell_source_id(cell_coords)
					var destroyed_tile_id = 2
					if tile_id == 0:
						tile_map_layer.set_cell(cell_coords, destroyed_tile_id)
					
					_on_player_scored(peer_id)
					
					player_can_collide[peer_id] = false
					last_collision = latest_collision


func _on_game_start() -> void:
	game_started = true

func _on_player_scored(peer_id: int) -> void:
	if not player_scores.has(peer_id): return
	var current_score = player_scores[peer_id]
	var new_score = current_score + 1
	rpc("update_score", peer_id, new_score)

func _on_player_eliminated(player_body) -> void:
	Helper.log("%s has been eliminated" % player_body.name)
	var peer_id = int(player_body.name)
	rpc("despawn_player", peer_id)

func server_setup_player(peer_id: int) -> void:
	if has_node(str(peer_id)): return # Early exit
	Helper.log("Setting up player %s" % peer_id)
	player_can_collide[peer_id] = true
	server_setup_player_number(peer_id)
	spawn_player(peer_id)
	move_player_to_spawn(peer_id)
	rpc("setup_player_score", peer_id)
	
	# Check if game should start
	if player_nodes.size() == multiplayer.get_peers().size():
		Helper.log("All players have loaded and are ready")
		_on_game_start()

func server_setup_player_number(peer_id: int) -> void:
	if multiplayer.is_server():
		if player_numbers.size() == 0:
			player_numbers[peer_id] = 1
		elif not player_numbers.has(peer_id):
			player_numbers[peer_id] = player_numbers.size() + 1
		
		rpc("send_clients_player_numbers", player_numbers)

func move_player_to_spawn(peer_id: int) -> void:
	var player_node = get_node(str(peer_id))
	var spawn_point = spawn_points[player_numbers[peer_id]]
	player_node.global_position = spawn_point.global_position


@rpc("authority", "reliable")
func spawn_player(peer_id: int) -> void:
	var player_node_name = str(peer_id)
	if has_node(player_node_name): return
	
	var player = PLAYER_SCENE.instantiate()
	player.name = player_node_name
	add_child(player)
	player.get_node("SyncTransform").syncing = true
	player_nodes.append(player)
	
	if multiplayer.is_server():
		for peer in multiplayer.get_peers():
			rpc("spawn_player", peer)

@rpc("authority", "call_local", "reliable")
func despawn_player(peer_id: int) -> void:
	#Helper.log("Despawning player %s" % peer_id)
	var player_node_name = str(peer_id)
	if not has_node(player_node_name): return
	var player = get_node(player_node_name)
	remove_child(player)

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
	player_scores[peer_id] = amount
	if not multiplayer.is_server():
		var GUI_player_score_scene = GUI_player_score_container.get_node(str(peer_id))
		GUI_player_score_scene.update_score_label(amount)
