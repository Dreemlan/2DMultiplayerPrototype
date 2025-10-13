extends VBoxContainer

@onready var label_ready_status: Label = $PanelContainer/MarginContainer/VBoxContainer/LabelReadyStatus
@onready var label_display_name: Label = $PanelContainer/MarginContainer/VBoxContainer/LabelDisplayName

func _ready() -> void:
	multiplayer.peer_disconnected.connect(_on_player_disconnect)

func _on_player_disconnect(peer_id: int) -> void:
	if peer_id == int(self.name):
		queue_free()

func set_card_name(new_name: String) -> void:
	label_display_name.text = new_name
	Helper.log("Set player card name for peer %s to %s" % [self.name, new_name])

func update_ready_status(new_status: bool) -> void:
	if new_status == true:
		label_ready_status.text = "Ready"
		label_ready_status.add_theme_color_override(
			"font_color",
			Color("#7CFC00")   # lawn‑green
		)
	else:
		label_ready_status.text = "Not ready"
		label_ready_status.add_theme_color_override(
			"font_color",
			Color("ff0000ff")   # lawn‑green
		)
	Helper.log("Set player card ready status for %s to %s" % [self.name, new_status])
