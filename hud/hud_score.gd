extends VBoxContainer

@onready var player_label: Label = $PlayerLabel
@onready var score_label: Label = $ScoreLabel

func setup_player_score(player_number: int) -> void:
	player_label.text = "P%s" % player_number

func update_score_label(score: int) -> void:
	score_label.text = str(score)
