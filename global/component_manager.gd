extends Node

const SYNC_TRANSFORM = preload("uid://jnlnvsgv7t3m")

func add_sync_component_to_node(node: Node) -> void:
	node.add_child(SYNC_TRANSFORM.instantiate())
