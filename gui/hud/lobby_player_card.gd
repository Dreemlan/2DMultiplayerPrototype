extends VBoxContainer

func _ready() -> void:
	%LabelDisplayName.text = Multiplayer.peer_display_names[int(self.name)]
