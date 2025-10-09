extends VBoxContainer

func _ready() -> void:
	%LabelDisplayName.text = Multiplayer.peer_display_names[int(self.name)]

func update_ready_status(new_status: bool) -> void:
	if new_status == true:
		%LabelReadyStatus.text = "Ready"
		%LabelReadyStatus.label_settings.font_color = Color.LAWN_GREEN
	else:
		%LabelReadyStatus.text = "Not ready"
		%LabelReadyStatus.label_settings.font_color = Color.ORANGE_RED
