extends CanvasLayer

@onready var label: Label = $Control/Label

func _process(_delta: float) -> void:
	label.text = "PEER ID: %s" % str(multiplayer.get_unique_id())
