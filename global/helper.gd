extends Node

const COLOR_SERVER := "#ff5555"   # bright red
const COLOR_CLIENT := "#55aaff"   # soft cyan
const COLOR_WARN   := "#ffcc00"   # amber
const COLOR_ERR    := "#ff4444"   # darker red

var _is_server : bool = OS.get_cmdline_args().has("--server")

func log(msg: String) -> void:
	"""Prints *msg* with a coloured SERVER/CLIENT prefix."""
	var prefix = _make_prefix()
	print_rich("%s %s" % [prefix, msg])

func warn(msg: String) -> void:
	"""Yellow warning, still shows SERVER/CLIENT prefix."""
	var prefix = _make_prefix()
	print_rich("%s %s[color=%s]%s[/color]" % [
		prefix, "", COLOR_WARN, msg])

func err(msg: String) -> void:
	"""Red error, still shows SERVER/CLIENT prefix."""
	var prefix = _make_prefix()
	print_rich("%s %s[color=%s]%s[/color]" % [
		(prefix if _is_server else ""),   # optional: hide prefix on client errors
		"", COLOR_ERR, msg])

# ----------------------------------------------------------------------
# Private helper – builds the coloured tag once per call
# ----------------------------------------------------------------------
func _make_prefix() -> String:
	if _is_server:
		return "[color=%s]SERVER[0][/color]:" % COLOR_SERVER
	else:
		return "[color=%s]CLIENT[%s][/color]:" % [COLOR_CLIENT, multiplayer.get_unique_id()]
