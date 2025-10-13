extends Node2D

@onready var label: Label = $Label
@onready var player_node = get_parent()

func _ready() -> void:
	label.text = player_node.name
	top_level = true

func _physics_process(delta: float) -> void:
	global_position = lerp(global_position, player_node.global_position, 6.0 * delta)
