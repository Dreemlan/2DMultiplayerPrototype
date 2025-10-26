class_name PlayerInput
extends Node

var input_dir: Vector2


func _physics_process(_delta: float) -> void:
	if is_multiplayer_authority():
		input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
