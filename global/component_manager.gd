extends Node

const TRANSFORM = preload("res://component/networking/component_transform.tscn")
const MOVEMENT_PLATFORMER = preload("res://component/networking/component_movement_platformer.tscn")

var player_components: Dictionary = {}

func setup_player(player_node: Node, level_basename: String) -> void:
	match level_basename:
		"level_lobby":
			var inst_transform = TRANSFORM.instantiate()
			var inst_movement_platformer = MOVEMENT_PLATFORMER.instantiate()
			player_components[player_node] = [
				inst_transform, inst_movement_platformer
			]
			player_node.add_child(inst_transform)
			player_node.add_child(inst_movement_platformer)
		"level_icebreak":
			var inst_transform = TRANSFORM.instantiate()
			var inst_movement_platformer = MOVEMENT_PLATFORMER.instantiate()
			player_components[player_node] = [
				inst_transform, inst_movement_platformer
			]
			player_node.add_child(inst_transform)
			player_node.add_child(inst_movement_platformer)
	
	Helper.log("Adding components to player %s" % player_node.name)


func activate_components(player_node: Node) -> void:
	Helper.log("Activating components for: %s" % player_node)
	for component in player_components[player_node]:
		component.enabled = true
