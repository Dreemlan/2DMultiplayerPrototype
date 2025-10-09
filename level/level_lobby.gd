extends Node2D

const LOBBY_PLAYER_CARD = preload("res://gui/hud/lobby_player_card.tscn")

var ready_statuses: Dictionary = {}

@onready var area_ready: Area2D = $AreaReady

func _ready() -> void:
	if multiplayer.is_server():
		# Connect signals
		Multiplayer.connect("peer_registered", Callable(_on_player_registered))
		area_ready.body_entered.connect(player_ready.bind(true))
		area_ready.body_exited.connect(player_ready.bind(false))

# When a player is transitioned from multiplayer.gd
func _on_player_registered(peer_id: int) -> void:
	if multiplayer.is_server():
		add_player_card(peer_id)
		ready_statuses[peer_id] = false
		spawn_player(peer_id)

# Spawn player to run around and interact with lobby
func spawn_player(peer_id: int) -> void:
	if multiplayer.is_server():
		PlayerManager.spawn_player(peer_id, self.name, scene_file_path.get_file().get_basename())

# Add HUD element just for fluff
func add_player_card(peer_id: int) -> void:
	if multiplayer.is_server():
		Helper.log("Adding player card")
		var inst = LOBBY_PLAYER_CARD.instantiate()
		inst.name = str(peer_id)
		%PlayerCardContainer.add_child(inst)

func update_player_card_ready(peer_id: int, status: bool) -> void:
	if multiplayer.is_server():
		var player_card = %PlayerCardContainer.get_node(str(peer_id))
		player_card.update_ready_status(status)

func player_ready(player_node: Node, ready_status: bool) -> void:
	if multiplayer.is_server():
		var peer_id = int(player_node.name)
		ready_statuses[peer_id] = true
		update_player_card_ready(peer_id, ready_status)
		if all_players_ready():
			transition_to_level()

func all_players_ready() -> bool:
	for status in ready_statuses.values():
		if status == false:
			Helper.log("Not all players are ready")
			return false
	return true

func transition_to_level() -> void:
	pass
