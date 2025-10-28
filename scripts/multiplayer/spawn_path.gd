extends Node2D

const PLAYER_SCENE = preload("uid://dr1mjanfdji7y")

var players: Array = []
var player_colors: Array = [ Color.RED, Color.GREEN, Color.BLUE, Color.WEB_PURPLE, Color.ORANGE ]


func setup_player(network_id: int) -> void:
	spawn_player_node(network_id)
	
	for peer in get_tree().get_multiplayer().get_peers():
		rpc_id(network_id, "spawn_player_node", peer)


@rpc("authority", "reliable")
func spawn_player_node(network_id: int) -> void:
	if has_node(str(network_id)):
		# Set color using idx
		var player_idx = players.find(network_id)
		var color = player_colors[player_idx]
		var player_node = get_node(str(network_id))
		player_node.set_color(color)
		return
	
	# Add child
	var player_node = PLAYER_SCENE.instantiate()
	player_node.name = str(network_id)
	player_node.set_multiplayer_authority(1)
	add_child(player_node)
	
	# Set color using idx
	var player_idx = players.find(network_id)
	var color = player_colors[player_idx]
	player_node.set_color(color)
