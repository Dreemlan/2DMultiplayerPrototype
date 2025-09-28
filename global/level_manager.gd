extends Node

const LEVEL_LOBBY = preload("res://level/level_lobby.tscn")
const LEVEL_ICE_BREAK = preload("res://level/level_icebreak.tscn")

var levels = [ LEVEL_ICE_BREAK ]

func _ready() -> void:
	if get_child_count() > 0:
		pass
		#var level = get_child(0)
	else:
		add_child(LEVEL_LOBBY.instantiate())

func _on_level_finished(prev_level: Node) -> void:
	prev_level.queue_free()
	call_deferred("advance_level")

func advance_level() -> void:
	Helper.log("Loading next level...")
	var new_level: PackedScene = levels[0]
	var level = new_level.instantiate()
	add_child(level)
	level.level_finished.connect(_on_level_finished)
