extends Node2D

var ready_status: Dictionary = {}
var ready_yes_count := 0

@onready var ready_count: Label = $GUI/Control/ReadyCount
@onready var door_ice_break: Area2D = $DoorIceBreak

func _ready() -> void:
	if multiplayer.is_server():
		for peer in multiplayer.get_peers():
			ready_status[peer] = false
		
		door_ice_break.body_entered.connect(_on_player_ready)
		door_ice_break.body_exited.connect(_on_player_unready)
		multiplayer.peer_connected.connect(_on_peer_connect)
		multiplayer.peer_disconnected.connect(_on_peer_disconnect)

func _on_peer_connect(peer: int) -> void:
	ready_status[peer] = false
	ready_count.text = "0/%s Ready" % ready_status.size()
	print(ready_status)

func _on_peer_disconnect(peer: int) -> void:
	ready_status.erase(peer)
	ready_count.text = "0/%s Ready" % ready_status.size()

func _on_player_ready(body) -> void:
	ready_status[int(body.name)] = true
	
	for status in ready_status.values():
		if status == true:
			ready_yes_count += 1
		if ready_yes_count == multiplayer.get_peers().size():
			ready_count.text = "Starting..."
	
	ready_count.text = "%s/%s Ready" % [ready_yes_count, ready_status.size()]

func _on_player_unready(body) -> void:
	ready_status[int(body.name)] = false
	ready_count.text = "%s/%s Ready" % [ready_yes_count, ready_status.size()]
