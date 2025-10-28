extends TileMapLayer

var destroyed_cells: Array = []

var round_wins: Dictionary = {}

signal player_won(network_id: int)


func _enter_tree() -> void:
	get_tree().get_multiplayer().peer_connected.connect(_peer_connected)


func _peer_connected(network_id: int) -> void:
	if get_tree().get_multiplayer().has_multiplayer_peer() and is_multiplayer_authority():
		rpc_id(network_id, "destroy_cells", destroyed_cells)


func _add_player_round_win(network_id: int) -> void:
	if not round_wins.has(network_id):
		round_wins.set(network_id, 0)
	
	if round_wins[network_id] >= 3:
		player_won.emit(network_id)
	else:
		round_wins[network_id] += 1


func queue_cell_destruction(cell: Vector2i) -> void:
	cell = Vector2i(cell.x, cell.y)
	destroyed_cells.append(cell)
	rpc("destroy_cells", destroyed_cells)


@rpc("authority", "call_local", "reliable")
func destroy_cells(cells: Array) -> void:
	if cells.size() <= 0: return
	
	for cell in cells:
		erase_cell(cell)
