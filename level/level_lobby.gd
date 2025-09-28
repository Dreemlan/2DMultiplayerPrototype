extends Node2D

const LOBBY_PLAYER_CARD = preload("res://gui/hud/lobby_player_card.tscn")


func _ready() -> void:
	if multiplayer.is_server():
		Multiplayer.connect("peer_registered", Callable(_on_player_registered))

func _on_player_registered(peer_id: int) -> void:
	if multiplayer.is_server():
		add_player_card(peer_id)

func add_player_card(peer_id: int) -> void:
	Helper.log("Adding player card")
	var inst = LOBBY_PLAYER_CARD.instantiate()
	inst.name = str(peer_id)
	%PlayerCardContainer.add_child(inst)

#func remove_player_card(peer_id: int) -> void:
	#Helper.log("Removing player card")
	#var player_card = %PlayerCardContainer.get_node(str(peer_id))
	#player_card.queue_free()
