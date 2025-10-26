extends CharacterBody2D

const SPEED: float = 500.0


func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())


func _physics_process(_delta: float) -> void:
	if not is_multiplayer_authority(): return
	
	velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down") * SPEED
	
	move_and_slide()
