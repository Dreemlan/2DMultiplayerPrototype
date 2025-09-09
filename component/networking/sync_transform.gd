extends Node

@onready var node = get_parent() as RigidBody2D

func _ready() -> void:
	if multiplayer.is_server():
		pass
	else:
		node.freeze = true
		node.freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
		node.gravity_scale = 0.0

func _physics_process(_delta: float) -> void:
	if multiplayer.is_server():
		rpc_id(0, "sync", node.global_position, node.global_rotation)
	else:
		pass

@rpc("authority", "unreliable")
func sync(pos, rot) -> void:
	if multiplayer.is_server():
		pass
	else:
		node.global_position = pos
		node.global_rotation = rot
