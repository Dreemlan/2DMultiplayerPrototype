extends CanvasLayer

const PLAYER_SCORE_SCENE = preload("uid://dm0bo1etoumqy")

@onready var player_score_container: HBoxContainer = %PlayerScoreContainer


func setup_player_hud(network_id: int) -> void:
	var player_score = PLAYER_SCORE_SCENE.instantiate()
	player_score.name = str(network_id)
	var color: Color = get_parent().player_colors[multiplayer.get_peers().size()]
	player_score_container.add_child(player_score)
	player_score.set_color(color)
