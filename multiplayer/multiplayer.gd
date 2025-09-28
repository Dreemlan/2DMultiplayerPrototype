extends Node

const PORT := 25565
const IP_ADDRESS := "127.0.0.1"
const MAX_CLIENTS := 8

var peer = ENetMultiplayerPeer.new()
var peer_display_names: Dictionary[int, String] = {}

signal peer_registered(peer_id: int)


func create_client() -> bool:
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


@rpc("any_peer", "reliable")
func server_register_peer(display_name) -> void:
	var peer_id: int = multiplayer.get_remote_sender_id()
	if peer_display_names.values().has(display_name):
		Helper.log("Peer already registered")
		display_name += "Noob"
	Helper.log("Registering %s as %s" % [peer_id, display_name])
	peer_display_names[peer_id] = display_name
	emit_signal("peer_registered", peer_id)
