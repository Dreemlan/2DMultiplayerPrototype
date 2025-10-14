extends Node

const SPEED = 75.0
const JUMP_VELOCITY = -400.0

var direction: float = 0.0
var enabled: bool = false

@onready var player = get_parent() as CharacterBody2D


func _enter_tree() -> void:
	enabled = false


func _exit_tree() -> void:
	enabled = false


func _physics_process(delta: float) -> void:
	if multiplayer.is_server():
		_server_simulation(delta)
	elif player.name == str(multiplayer.get_unique_id()):
		_client_requests()


func _server_simulation(delta) -> void:
	if not player.is_on_floor():
		player.velocity += player.get_gravity() * delta
	
	if direction != 0.0:
		player.velocity.x = direction * SPEED
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, SPEED)
	
	player.move_and_slide()


func _client_requests() -> void:
	if not enabled: return
	
	# Move
	var new_direction = Input.get_axis("move_left", "move_right")
	if new_direction != direction:
		direction = new_direction
		rpc_id(1, "move", direction)
	
	# Jump
	if Input.is_action_just_pressed("jump"): rpc_id(1, "jump")


@rpc("any_peer", "unreliable")
func move(client_direction) -> void:
	if not is_instance_valid(player):
		push_warning("move() called after player was freed")
		return
	
	if multiplayer.is_server():
		direction = clamp(client_direction, -1.0, 1.0)


@rpc("any_peer", "reliable")
func jump() -> void:
	if multiplayer.is_server() && player.is_on_floor():
		player.velocity.y = JUMP_VELOCITY
