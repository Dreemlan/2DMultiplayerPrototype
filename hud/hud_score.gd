extends VBoxContainer

@export var ice_block: Node

@onready var player: Label = $Player
@onready var score: Label = $Score

func _process(_delta: float) -> void:
	if ice_block:
		score.text = str(ice_block.total_score)
	else:
		score.text = "X"
