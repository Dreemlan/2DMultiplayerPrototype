extends Node

@onready var node = get_parent() as RigidBody2D


func _ready() -> void:
	if multiplayer.is_server():
		pass
	else:
		# Disable client physics
		node.freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
		node.freeze = true
		node.gravity_scale = 0.0


func _physics_process(_delta: float) -> void:
	if multiplayer.is_server():
		# Send clients position and rotation
		rpc("sync_transform", node.global_position, node.global_rotation)
	else:
		pass


@rpc("authority", "unreliable")
func sync_transform(pos, rot) -> void:
	if multiplayer.is_server():
		pass
	else:
		# Update client position and rotation to match server
		node.global_position = pos
		node.global_rotation = rot
