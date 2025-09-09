extends StaticBody2D

@onready var area_2d: Area2D = $Area2D

var random_goal := randi_range(0, 10)
var random_score := random_goal + 1
var total_score := 0

func _ready() -> void:
	area_2d.body_entered.connect(_on_player_collision)

func _on_player_collision(_player) -> void:
	random_score = randi_range(0, 10)
	
	print("Player collided with ice: ", self.name)
	print("Score is: ", random_score, " and goal is ", random_goal)
	
	if random_score == random_goal:
		total_score = 0
		queue_free() 
	else:
		total_score += 1
