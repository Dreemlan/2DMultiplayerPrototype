extends Node2D

@export var player_scene: PackedScene

var player_colors: Array = [ Color.RED, Color.GREEN, Color.BLUE, Color.WEB_PURPLE, Color.ORANGE ]

var wins: Dictionary = {}

@onready var gui: CanvasLayer = $GUI
@onready var tilemap: TileMapLayer = $World/TileMapLayerIce


func _ready() -> void:
	if NetworkManager.is_hosting_game:
		var spawn_manager_scene = load("res://scenes/multiplayer/spawn_manager.tscn")
		var spawn_manager = spawn_manager_scene.instantiate()
		spawn_manager.player_scene = player_scene
		spawn_manager.player_added.connect(_on_player_added)
		add_child(spawn_manager)
		
		tilemap.player_won.connect(_on_player_won)


func _on_main_menu_pressed() -> void:
	NetworkManager.terminate_connection_load_main_menu()


func _on_player_added(network_id: int) -> void:
	gui.setup_player_hud(network_id)


func _on_player_won(network_id: int) -> void:
	if not wins.has(network_id):
		wins.set(network_id, 0)
	wins[network_id] += 1
