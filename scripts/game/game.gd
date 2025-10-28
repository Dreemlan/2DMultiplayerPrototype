extends Node2D

@export var player_scene: PackedScene

@onready var tilemap: TileMapLayer = $World/TileMapLayerIce
@onready var gui: CanvasLayer = %GUI


func _ready() -> void:
	if NetworkManager.is_hosting_game:
		var spawn_manager_scene = load("res://scenes/multiplayer/spawn_manager.tscn")
		var spawn_manager = spawn_manager_scene.instantiate()
		spawn_manager.player_added.connect(_on_player_added)
		add_child(spawn_manager)


func _on_player_added(network_id: int) -> void:
	gui.setup_player_hud(network_id)


func _on_main_menu_pressed() -> void:
	NetworkManager.terminate_connection_load_main_menu()
