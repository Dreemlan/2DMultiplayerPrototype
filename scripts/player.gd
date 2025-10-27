class_name Player
extends CharacterBody2D

var player_colors: Array = [ Color.RED, Color.GREEN, Color.BLUE, Color.WEB_PURPLE, Color.ORANGE ]

const SPEED: float = 50.0

var can_collide: bool = false

@export var player_input: PlayerInput
@export var input_synchronizer: MultiplayerSynchronizer
@onready var sprite: Sprite2D = $Sprite2D


func _enter_tree() -> void:
	player_input.set_multiplayer_authority(str(name).to_int())


func _ready() -> void:
	input_synchronizer.set_visibility_for(1, true)
	
	player_input.player_jumped.connect(_player_jumped)


func _physics_process(delta: float) -> void:
	
	if get_tree().get_multiplayer().has_multiplayer_peer() and is_multiplayer_authority():
		if can_collide:
			_get_player_collision()
			can_collide = false
		
		if not is_on_floor():
			velocity += get_gravity() * delta
			can_collide = true
		
		var direction := player_input.input_dir
		if direction:
			velocity.x = direction.x * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()


func set_color(c: Color) -> void:
	var vec4_suit_color = Vector4(c.r, c.g, c.b, c.a)
	var shader_colors = PackedVector4Array ([
		Vector4(0, 0, 0, 1), # Black
		vec4_suit_color,
		Vector4(0.95, 0.9, 0.85, 1), # Skin
		Vector4(1, 1, 1, 1) # White
	])
	
	var shader_mat := (sprite.material as ShaderMaterial).duplicate() as ShaderMaterial
	sprite.material = shader_mat
	shader_mat.set_shader_parameter("palette_colors", shader_colors)


func _player_jumped() -> void:
	rpc_id(1, "player_jump")


func _get_player_collision() -> void:
	var target_num = randi_range(0, 1)
	var collision_count = get_slide_collision_count()
	if collision_count > 0:
		var random_num = randi_range(0, 1)
		if random_num == target_num:
			for i in collision_count:
				var col: KinematicCollision2D = get_slide_collision(i)
				var tilemap: TileMapLayer = col.get_collider()
				var world_pos: Vector2 = col.get_position()
				var local_pos: Vector2 = tilemap.to_local(world_pos)
				var cell: Vector2i = tilemap.local_to_map(local_pos)
				tilemap.queue_cell_destruction(cell, name.to_int())


@rpc("any_peer", "call_local")
func player_jump() -> void:
	velocity.y -= 400
