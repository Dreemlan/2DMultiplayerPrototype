extends Timer

signal timer_finished


func _ready() -> void:
	one_shot = true
	wait_time = 5.0
	timeout.connect(_on_timer_finished)

func _on_timer_finished() -> void:
	emit_signal("timer_finished")


func _process(_delta: float) -> void:
	if is_stopped():
		%LabelTimer.hide()
		return
	else:
		%LabelTimer.show()
	
	%LabelTimer.text = str(floori(time_left))
