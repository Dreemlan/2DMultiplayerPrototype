extends Node

const PORT := 25565
const IP_ADDRESS := "127.0.0.1"
const MAX_CLIENTS := 8

var player_list: Dictionary = {}

func _ready() -> void:
	var args = OS.get_cmdline_args()
	var is_server = "--server" in args
	
	if is_server:
		var peer = ENetMultiplayerPeer.new()
		peer.create_server(PORT, MAX_CLIENTS)
		multiplayer.multiplayer_peer = peer
		multiplayer.peer_connected.connect(_on_peer_connect)
		multiplayer.peer_disconnected.connect(_on_peer_disconnect)
	else:
		var peer = ENetMultiplayerPeer.new()
		peer.create_client(IP_ADDRESS, PORT)
		multiplayer.multiplayer_peer = peer
	
	Helper.log("Multiplayer started")

func _on_peer_connect(peer_id: int) -> void:
	Helper.log("%s connected" % peer_id)
	register_player(peer_id)
	PlayerManager.spawn_player(peer_id)

func _on_peer_disconnect(peer_id: int) -> void:
	Helper.log("%s disconnected" % peer_id)


@rpc("authority", "reliable")
func register_player(peer_id: int) -> void:
	# This code will run every time a peer connects to the server
	
	# Client and server each register the player to player list
	if player_list.has(peer_id): return
	var player_id = player_list.size() + 1
	player_list[peer_id] = player_id
	
	# Then the server tells all connected peers to do the same
	if multiplayer.is_server():
		for peer in multiplayer.get_peers():
			rpc("register_player", peer)
	
	Helper.log("Registered player: %s, %s" % [peer_id, player_id])
