extends VBoxContainer

func set_player_number(player_number: int) -> void:
	%PlayerLabel.text = "P%s" % player_number

func update_score_label(score: int) -> void:
	%ScoreLabel.text = str(score)
