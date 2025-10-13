extends Node

@onready var node = get_parent()


func _physics_process(_delta: float) -> void:
	if multiplayer.is_server():
		rpc("sync_transform", node.global_position, node.global_rotation)
	else:
		pass


@rpc("authority", "unreliable")
func sync_transform(pos, rot) -> void:
	if multiplayer && multiplayer.is_server():
		pass
	else:
		node.global_position = pos
		node.global_rotation = rot
