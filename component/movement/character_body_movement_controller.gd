extends CharacterBody2D

const JUMP_VELOCITY = -400.0
const SPEED = 75.0

var horizontal_direction = 0.0

@onready var client_player = get_parent()


func _physics_process(delta: float) -> void:
	
	## SERVER
	if multiplayer.is_server():
		rpc("server_send_transform", global_position)
	
	## CLIENT
	elif client_player.name == str(multiplayer.get_unique_id()):
		
		horizontal_direction = Input.get_axis("move_left", "move_right")
		
		if Input.is_action_just_pressed("jump") and client_player.is_on_floor():
			rpc_id(1, "client_request_jump")
		
		# Client-side simulation
		if not client_player.is_on_floor():
			client_player.velocity += get_gravity() * delta
		
		if horizontal_direction != 0.0:
			client_player.velocity.x = horizontal_direction * SPEED
		else:
			client_player.velocity.x = move_toward(client_player.velocity.x, 0.0, SPEED)
		
		client_player.move_and_slide()
		
		rpc_id(1, "client_send_move", horizontal_direction)
		
		if client_player.global_position.distance_to(global_position) > 1.0:
			client_player.global_position = client_player.global_position.lerp(global_position, 1.0 * delta)
		
		return
	
	## BOTH
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if horizontal_direction != 0.0:
		velocity.x = horizontal_direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)
	
	move_and_slide()


@rpc("any_peer", "unreliable")
func client_send_move(client_input) -> void:
	if multiplayer.is_server():
		horizontal_direction = client_input


@rpc("any_peer", "reliable")
func client_request_jump() -> void:
	if multiplayer.is_server():
		velocity.y = JUMP_VELOCITY


@rpc("authority", "unreliable")
func server_send_transform(pos) -> void:
	if multiplayer.is_server():
		pass
	else:
		global_position = pos
