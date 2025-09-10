extends StaticBody2D

@onready var area_2d: Area2D = $Area2D

var random_goal := randi_range(0, 10)
var random_score := random_goal + 1
var total_score := 0

signal player_scored(peer_id: int)

func _ready() -> void:
	if multiplayer.is_server():
		area_2d.body_entered.connect(_on_player_collision)

func _on_player_collision(player: RigidBody2D) -> void:
	print("Collision")
	random_score = randi_range(0, 10)
	
	if random_score == random_goal:
		#total_score = 0
		rpc("destroy_entity")
	else:
		emit_signal("player_scored", int(player.name))
		#total_score += 1

@rpc("authority", "call_local", "reliable")
func destroy_entity() -> void:
	if multiplayer.is_server():
		queue_free()
	else:
		queue_free()
