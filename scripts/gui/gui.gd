extends CanvasLayer

const PLAYER_SCORE_SCENE = preload("uid://dm0bo1etoumqy")

var player_scores: Dictionary = {}

@onready var player_score_container: HBoxContainer = %PlayerScoreContainer

@onready var spawn_path: Node2D = %SpawnPath




func _on_player_scored(network_id: int) -> void:
	Helper.log("Player %s has scored" % network_id)
	if not player_scores.has(network_id):
		player_scores.set(network_id, 0)
	player_scores[network_id] += 1
	_update_player_hud(network_id)


func _update_player_hud(network_id: int) -> void:
	var player_score_card = player_score_container.get_node(str(network_id))
	player_score_card.set_score(player_scores[network_id])


func setup_player_hud(network_id: int) -> void:
	var inst = PLAYER_SCORE_SCENE.instantiate()
	inst.name = str(network_id)
	player_score_container.add_child(inst)
