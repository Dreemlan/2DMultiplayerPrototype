class_name PlayerInput
extends Node

var input_dir: Vector2

signal player_jumped

func _physics_process(_delta: float) -> void:
	if get_tree().get_multiplayer().has_multiplayer_peer() and is_multiplayer_authority():
		input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
		if Input.is_action_just_pressed("jump"):
			player_jumped.emit()
