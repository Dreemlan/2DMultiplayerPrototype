# Automatically frees self after playing sound
extends AudioStreamPlayer2D

func _ready() -> void:
	finished.connect(Callable(queue_free))
