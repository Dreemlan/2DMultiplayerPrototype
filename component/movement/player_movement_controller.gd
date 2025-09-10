extends Node

const JUMP_FORCE := 200
const MOVE_SPEED := 2000

var movement_vector := Vector2.ZERO

@onready var node = get_parent() as RigidBody2D
@onready var raycast: RayCast2D = $RayCast2D


func _ready() -> void:
	node.linear_damp = 8
	node.angular_damp = 8
	
	raycast.enabled = false
	raycast.target_position = Vector2(0, 12)


func _physics_process(_delta: float) -> void:
	if multiplayer.is_server():
		pass
	elif node.name == str(multiplayer.get_unique_id()):
		movement_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
		if movement_vector != Vector2.ZERO:
			rpc_id(1, "request_move", movement_vector)
		
		if Input.is_action_just_pressed("jump"):
			raycast.global_rotation = 0
			raycast.force_raycast_update()
			if not raycast.is_colliding(): return
			rpc_id(1, "request_jump")


@rpc("any_peer", "unreliable")
func request_move(client_movement_vector: Vector2) -> void:
	if multiplayer.is_server():
		node.apply_central_force(client_movement_vector * MOVE_SPEED)
	else:
		pass


@rpc("any_peer", "reliable")
func request_jump() -> void:
	if multiplayer.is_server():
		raycast.global_rotation = 0
		raycast.force_raycast_update()
		if not raycast.is_colliding(): return
		node.apply_central_impulse(Vector2.UP * JUMP_FORCE)
	else:
		pass
