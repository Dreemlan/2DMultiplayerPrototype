extends Node2D

const JUMP_VELOCITY = -400.0
# How fast we converge to the server’s authoritative state (per second)
const RECON_RATE = 8.0   # try 4‑12 and see what feels good
const RECON_EPS  = 0.5   # distance tolerance for “close enough”
const SPEED = 75.0

@onready var character_body = get_parent() as CharacterBody2D

var next_seq: int = 0
var pending_inputs := []

var _target_position
var _target_velocity
var _target_rotation
var _target_seq: int = -1


func _physics_process(delta: float) -> void:
	if multiplayer.is_server():
		_server_update(delta)
	elif character_body.name == str(multiplayer.get_unique_id()):
		_client_update(delta)
	else:
		if _target_position != null:
			_reconcile(delta)
			return


func _server_update(delta: float) -> void:
	pass


func _client_update(delta: float) -> void:
	
	var horiz = Input.get_axis("move_left", "move_right")
	var jump = Input.is_action_just_pressed("jump") and character_body.is_on_floor()

	var pkt = {"seq": next_seq, "horiz": horiz, "jump": jump}
	next_seq += 1
	pending_inputs.append(pkt)
	
	var fixed_dt = get_physics_process_delta_time()
	_apply_input(pkt, fixed_dt)
	rpc_id(1, "request_move", pkt)
	
	# ---------- reconciliation ----------
	if _target_position != null:
		_reconcile(delta)
		return


func _apply_input(pkt: Dictionary, dt: float) -> void:
	if pkt["horiz"] != 0.0:
		character_body.velocity.x = pkt["horiz"] * SPEED
	else:
		character_body.velocity.x = move_toward(character_body.velocity.x, 0.0, SPEED)
	
	if pkt["jump"] and character_body.is_on_floor():
		character_body.velocity.y = JUMP_VELOCITY
	
	if not character_body.is_on_floor():
		character_body.velocity += character_body.get_gravity() * dt
	
	character_body.move_and_slide()


func _reconcile(delta: float) -> void:
	if _target_position == null:
		return

	# ----- exponential smoothing for position -----
	var pos_error = _target_position - character_body.global_position
	var pos_factor = 1.0 - exp(-RECON_RATE * delta)   # 0‑1 factor based on dt
	character_body.global_position += pos_error * pos_factor

	# ----- exponential smoothing for velocity -----
	var vel_error = _target_velocity - character_body.velocity
	var vel_factor = 1.0 - exp(-RECON_RATE * delta)
	character_body.velocity += vel_error * vel_factor

	# Optional: stop smoothing once we’re “close enough”
	if character_body.global_position.distance_to(_target_position) < RECON_EPS:
		_target_position = null
		_target_velocity = Vector2.ZERO


@rpc("any_peer", "unreliable")
func request_move(pkt: Dictionary) -> void:
	if multiplayer.is_server():
		_apply_input(pkt, get_physics_process_delta_time())
		rpc("sync_transform",
			character_body.global_position,
			character_body.velocity,
			character_body.global_rotation,
			pkt["seq"])


@rpc("authority", "unreliable")
func sync_transform(pos, vel, rot, ack_seq) -> void:
	if multiplayer.is_server():
		pass
	else:
		_target_position = pos
		_target_velocity = vel
		_target_rotation = rot
		_target_seq      = ack_seq
		
		while pending_inputs.size() > 0 and pending_inputs[0]["seq"] <= ack_seq:
			pending_inputs.pop_front()
