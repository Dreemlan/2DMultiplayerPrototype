extends Node2D

const HUD_ICEBREAK_SCORE = preload("uid://dms1txqocx2vk")

var player_can_collide: Dictionary[int, bool] = {}

@onready var elimination_zone: Area2D = $EliminationZone
@onready var level_manager = get_parent()
@onready var level_scores: Dictionary[int, int] = {}
@onready var tile_map_layer: TileMapLayer = $TileMapLayer


func _enter_tree() -> void:
	if multiplayer.is_server():
		for peer_id in Multiplayer.peer_display_names.keys():
			PlayerManager.spawn_player(peer_id, scene_file_path.get_file().get_basename())
			rpc("hud_score_update", peer_id, 0)


func _physics_process(_delta: float) -> void:
	if multiplayer.is_server():
		for player in PlayerManager.current_player_nodes.values():
			var peer_id = int(player.name)
			
			if not player.is_on_floor():
				player_can_collide[peer_id] = true
			
			var last_collision = null
			if player_can_collide[peer_id] == true:
				# Set up RNG
				var rng_num = randi_range(0, 10)
				# Handle collision
				var latest_collision = player.get_last_slide_collision()
				if last_collision != latest_collision:
					var col_rng = randi_range(0, 10)
					if col_rng == rng_num: 
					
						# Get cell coords
						var cell_coords: Vector2 = tile_map_layer.local_to_map(latest_collision.get_position() - latest_collision.get_normal())
						
						# Get tile id using cell coords
						var tile_id = tile_map_layer.get_cell_source_id(cell_coords)
						var destroyed_tile_id = 2
						
						# Destroy tile
						if tile_id == 0:
							rpc("destroy_tile", cell_coords, destroyed_tile_id)
						
						# Cleanup
						player_can_collide[peer_id] = false
						last_collision = latest_collision
						
						AudioManager.emit_audio("sfx_destruction_ice", player.global_position)
					
					else:
						if not level_scores.has(peer_id):
							level_scores.set(peer_id, 0)
						var new_score: int = level_scores[peer_id]
						new_score += 1
						level_scores.set(peer_id, new_score)
						
						rpc("hud_score_update", peer_id, new_score)
						Helper.log(new_score)
						
						player_can_collide[peer_id] = false
						last_collision = latest_collision
						
						AudioManager.emit_audio("footstep_snow_000", player.global_position)


@rpc("authority", "call_local", "reliable")
func destroy_tile(cell_coords, destroyed_tile_id) -> void:
	tile_map_layer.set_cell(cell_coords, destroyed_tile_id)


@rpc("authority", "call_local", "reliable")
func hud_score_update(peer_id: int, score: int) -> void:
	var peer_id_str = str(peer_id)
	if not %PlayerScoreContainer.has_node(peer_id_str):
		var inst = HUD_ICEBREAK_SCORE.instantiate()
		%PlayerScoreContainer.add_child(inst)
		inst.name = peer_id_str
	var hud_score = %PlayerScoreContainer.get_node_or_null(peer_id_str)
	if hud_score != null:
		hud_score.update_score_label(score)
