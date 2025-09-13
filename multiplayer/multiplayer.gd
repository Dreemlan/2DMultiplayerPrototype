extends Node

const PORT := 25565
const IP_ADDRESS := "127.0.0.1"
const MAX_CLIENTS := 8

func _ready() -> void:
	var args = OS.get_cmdline_args()
	var is_server = "--server" in args
	
	if is_server:
		var peer = ENetMultiplayerPeer.new()
		peer.create_server(PORT, MAX_CLIENTS)
		multiplayer.multiplayer_peer = peer
	else:
		var peer = ENetMultiplayerPeer.new()
		peer.create_client(IP_ADDRESS, PORT)
		multiplayer.multiplayer_peer = peer
	
	#Helper.log("Multiplayer> Started")
