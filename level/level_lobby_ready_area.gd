# A player walks into the area and are marked as 'Ready'
# A signal is emitted from that area, telling the lobby which level to load
extends Node2D

@export var target_level: PackedScene
@onready var area_2d: Area2D = $Area2D

signal player_ready(target_level, player_body, ready_status)

func _ready() -> void:
	if multiplayer.is_server():
		area_2d.body_entered.connect(_on_player_ready.bind(true))
		area_2d.body_exited.connect(_on_player_ready.bind(false))

func _on_player_ready(player_body: Node, ready_status: bool) -> void:
	if multiplayer.is_server():
		emit_signal("player_ready", target_level, player_body, ready_status)
