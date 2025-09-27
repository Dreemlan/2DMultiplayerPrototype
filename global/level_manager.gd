extends Node

const LEVEL_LOBBY = preload("res://level/level_lobby.tscn")
const LEVEL_ICE_BREAK = preload("res://level/level_icebreak.tscn")

var levels = [ LEVEL_ICE_BREAK ]

func _ready() -> void:
	
	if get_child_count() > 0: return
	
	add_child(LEVEL_LOBBY.instantiate())
