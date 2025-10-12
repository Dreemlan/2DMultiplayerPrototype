extends Node

const SPEED = 75.0
const JUMP_VELOCITY = -400.0

var direction

@onready var player = get_parent() as CharacterBody2D

func _physics_process(delta: float) -> void:
	if multiplayer.is_server():
		_server_simulation(delta)
	elif player.name == str(multiplayer.get_unique_id()):
		_client_requests()


func _server_simulation(delta) -> void:
	if not player.is_on_floor():
		player.velocity += player.get_gravity() * delta
	
	if direction:
		player.velocity.x = direction * SPEED
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, SPEED)
	
	player.move_and_slide()


func _client_requests() -> void:
	# Move
	direction = Input.get_axis("move_left", "move_right")
	rpc_id(1, "move", direction)
	# Jump
	if Input.is_action_just_pressed("jump"): rpc_id(1, "jump")


@rpc("any_peer", "unreliable_ordered")
func move(client_direction) -> void:
	if multiplayer && multiplayer.is_server():
		direction = client_direction


@rpc("any_peer", "reliable")
func jump() -> void:
	if multiplayer.is_server() && player.is_on_floor():
		player.velocity.y = JUMP_VELOCITY
