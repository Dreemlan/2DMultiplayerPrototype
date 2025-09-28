extends Node

@onready var node = get_parent()

var syncing: bool = false


func _ready() -> void:
	if multiplayer.is_server():
		pass
	else:
		pass


func _physics_process(_delta: float) -> void:
	if not syncing: return
	
	if multiplayer.is_server():
		# Send clients position and rotation
		rpc("sync_transform", node.global_position, node.global_rotation)
	else:
		pass


@rpc("authority", "unreliable")
func sync_transform(pos, rot) -> void:
	if multiplayer && multiplayer.is_server():
		pass
	else:
		# Update client position and rotation to match server
		node.global_position = pos
		node.global_rotation = rot
