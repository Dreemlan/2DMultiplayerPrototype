extends CanvasLayer

@onready var menu_manager = get_parent()


func _ready() -> void:
	%Yes.pressed.connect(_on_yes_pressed)
	%No.pressed.connect(_on_no_pressed)


func _on_yes_pressed() -> void:
	get_tree().quit()

func _on_no_pressed() -> void:
	menu_manager.go_back()
