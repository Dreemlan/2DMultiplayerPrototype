extends Node

const PORT := 25565
const IP_ADDRESS := "127.0.0.1"
const MAX_CLIENTS := 8

var player_list: Dictionary = {}

#
#func _ready() -> void:
	#var args = OS.get_cmdline_args()
	#var is_server = "--server" in args
	#
	#if is_server:
		#var peer = ENetMultiplayerPeer.new()
		#peer.create_server(PORT, MAX_CLIENTS)
		#multiplayer.multiplayer_peer = peer
		#multiplayer.peer_connected.connect(_on_peer_connect)
		#multiplayer.peer_disconnected.connect(_on_peer_disconnect)
	#else:
		#var peer = ENetMultiplayerPeer.new()
		#peer.create_client(IP_ADDRESS, PORT)
		#multiplayer.multiplayer_peer = peer
	#
	#Helper.log("Multiplayer started")


func create_client() -> bool:
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(IP_ADDRESS, PORT)
	if not peer: return false
	multiplayer.multiplayer_peer = peer
	multiplayer.connected_to_server.connect(_on_connect_to_server)
	multiplayer.connection_failed.connect(_on_failed_to_connect)
	Helper.log("Attempting to connect to server...")
	return true

func _on_connect_to_server() -> void:
	Helper.log("Successfully connected to server")

func _on_failed_to_connect() -> void:
	Helper.log("Failed to connect to server")


func create_server() -> bool:
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, MAX_CLIENTS)
	if not peer: return false
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connect)
	multiplayer.peer_disconnected.connect(_on_peer_disconnect)
	Helper.log("Server started")
	return true

func _on_peer_connect(peer_id: int) -> void:
	Helper.log("%s connected" % peer_id)

func _on_peer_disconnect(peer_id: int) -> void:
	Helper.log("%s disconnected" % peer_id)
