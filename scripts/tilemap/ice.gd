extends TileMapLayer

var destroyed_cells: Array = []

var scores: Dictionary = {}

signal player_scored(network_id: int)
signal player_won(network_id: int)


func _enter_tree() -> void:
	get_tree().get_multiplayer().peer_connected.connect(_peer_connected)


func _peer_connected(network_id: int) -> void:
	if get_tree().get_multiplayer().has_multiplayer_peer() and is_multiplayer_authority():
		rpc_id(network_id, "destroy_cells", destroyed_cells)


func _add_player_score(network_id: int) -> void:
	if not scores.has(network_id):
		scores.set(network_id, 0)
	
	if scores[network_id] >= 3:
		player_won.emit(network_id)
	else:
		scores[network_id] += 1
		player_scored.emit(network_id)


func queue_cell_destruction(cell: Vector2i, network_id: int) -> void:
	cell = Vector2i(cell.x, cell.y)
	destroyed_cells.append(cell)
	rpc("destroy_cells", destroyed_cells)
	_add_player_score(network_id)


@rpc("authority", "call_local", "reliable")
func destroy_cells(cells: Array) -> void:
	if cells.size() <= 0: return
	
	for cell in cells:
		erase_cell(cell)
