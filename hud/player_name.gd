extends Node2D

@onready var label: Label = $Label
@onready var rigidbody = get_parent() as RigidBody2D

func _ready() -> void:
	label.text = rigidbody.name
	top_level = true

func _physics_process(delta: float) -> void:
	global_position = lerp(global_position, rigidbody.global_position, 30.0 * delta)
