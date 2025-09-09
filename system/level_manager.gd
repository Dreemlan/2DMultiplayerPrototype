extends Node

const MINIGAME_LOBBY = preload("res://minigame/minigame_lobby.tscn")
const MINIGAME_ICE_BREAK = preload("res://minigame/minigame_ice_break.tscn")

var minigames = [ MINIGAME_ICE_BREAK ]

func _ready() -> void:
	add_child(MINIGAME_LOBBY.instantiate())
