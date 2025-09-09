extends Camera2D

@onready var player = get_parent() as RigidBody2D

func _ready() -> void:
	if multiplayer.is_server():
		pass
	elif player.name == str(multiplayer.get_unique_id()):
		make_current()
