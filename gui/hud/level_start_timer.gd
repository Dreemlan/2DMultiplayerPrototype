extends Node

signal timer_finished


func _ready() -> void:
	$Timer.one_shot = true
	$Timer.wait_time = 5.0
	$Timer.timeout.connect(_on_timer_finished)

func _on_timer_finished() -> void:
	emit_signal("timer_finished")


func _process(_delta: float) -> void:
	if $Timer.is_stopped():
		$Label.hide()
		return
	else:
		$Label.show()
	
	$Label.text = str(floori($Timer.time_left))


func start() -> void:
	$Timer.start()
