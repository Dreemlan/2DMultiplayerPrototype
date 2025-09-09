extends Camera2D

func _ready() -> void:
	if multiplayer.is_server():
		make_current()
	else:
		pass
