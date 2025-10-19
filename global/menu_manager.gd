# Handles adding and removing menus
# Base layer for menus is 2, as level HUD is 1
# Active menu layer is 99
extends Node

var prev_menu

@onready var active_menu: CanvasLayer = $MenuMain


func _ready() -> void:
	active_menu.layer = 99


func _set_active_menu(menu: CanvasLayer) -> void:
	prev_menu = active_menu
	active_menu.layer = 2
	active_menu = menu
	active_menu.layer = 99

func add_menu(menu_scene: PackedScene) -> void:
	var inst = menu_scene.instantiate()
	add_child(inst)
	_set_active_menu(inst)

func go_back() -> void:
	pass


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_pressed("esc"):
			match active_menu.name:
				"MenuMain":
					var quit_confirm = load("res://gui/menu_quit_confirm.tscn")
					add_menu(quit_confirm)
				"MenuSettings":
					active_menu.queue_free()
					_set_active_menu(prev_menu)
