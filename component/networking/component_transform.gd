extends Node

var enabled: bool = false

@onready var parent_path = ".."


func _enter_tree() -> void:
	enabled = false


func _exit_tree() -> void:
	enabled = false


func _physics_process(_delta: float) -> void:
	if multiplayer.is_server() && enabled:
		var parent_node = get_node_or_null(parent_path)
		if not parent_node: return
		rpc("sync_transform", parent_node.global_position, parent_node.global_rotation)
	else:
		pass


@rpc("authority", "unreliable")
func sync_transform(pos, rot) -> void:
	if multiplayer && multiplayer.is_server():
		pass
	else:
		var parent_node = get_node_or_null(parent_path)
		parent_node.global_position = pos
		parent_node.global_rotation = rot
