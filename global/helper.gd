extends Node

const COLOR_SERVER := "#ff5555"   # bright red
const COLOR_CLIENT := "#55aaff"   # soft cyan

func log(msg) -> void:
	var prefix = _make_prefix()
	print_rich("%s %s" % [prefix, msg])

func _make_prefix() -> String:
	if multiplayer.get_unique_id() == 1:
		return "[color=%s]SERVER[%s][/color]:" % [COLOR_SERVER, multiplayer.get_unique_id()]
	else:
		return "[color=%s]CLIENT[%s][/color]:" % [COLOR_CLIENT, multiplayer.get_unique_id()]
