extends Node2D

var player_can_collide: Dictionary[int, bool] = {}

@onready var tile_map_layer: TileMapLayer = $TileMapLayer


func _enter_tree() -> void:
	if multiplayer.is_server():
		for peer_id in Multiplayer.peer_display_names.keys():
			PlayerManager.spawn_player(peer_id, scene_file_path.get_file().get_basename())


func _physics_process(_delta: float) -> void:
	if multiplayer.is_server():
		for player in PlayerManager.current_player_nodes.values():
			var peer_id = int(player.name)
			
			if not player.is_on_floor():
				player_can_collide[peer_id] = true
			
			var last_collision = null
			if player_can_collide[peer_id] == true:
				# Set up RNG
				var rng_num = randi_range(0, 20)
				# Handle collision
				var latest_collision = player.get_last_slide_collision()
				if last_collision != latest_collision:
					var col_rng = randi_range(0, 20)
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


@rpc("authority", "call_local", "reliable")
func destroy_tile(cell_coords, destroyed_tile_id) -> void:
	tile_map_layer.set_cell(cell_coords, destroyed_tile_id)
