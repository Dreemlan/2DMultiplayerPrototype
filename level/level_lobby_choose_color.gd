extends Node2D

@onready var area_2d: Area2D = $Area2D
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var color_vbox: VBoxContainer = $CanvasLayer/Control/PanelContainer/MarginContainer/VBoxContainer


func _ready() -> void:
	area_2d.body_entered.connect(_on_player_entered.bind(true))
	area_2d.body_exited.connect(_on_player_entered.bind(false))
	
	canvas_layer.visible = false


func _on_player_entered(player_node, entered: bool) -> void:
	if multiplayer.is_server(): return
	
	if entered == true:
		populate_color_menu(player_node)
		canvas_layer.visible = true
	else:
		canvas_layer.visible = false


func populate_color_menu(player_node: Node) -> void:
	for child in color_vbox.get_children():
		child.queue_free()
	
	#var peer_id = int(player_node.name)
	
	# Add buttons based on what is free in PlayerManager Dict
	
	for color in PlayerManager.player_color:
		if PlayerManager.player_color[color] == 0:
			
			var inst = TextureButton.new()
			color_vbox.add_child(inst)
			inst.custom_minimum_size = Vector2(32, 32)
			inst.modulate = color
			
			var img = Image.new()
			img.create_empty(1, 1, false, Image.FORMAT_RGBA8)
			img.fill(Color.WHITE)
			
			var tex = ImageTexture.new()
			tex.create_from_image(img)
			
			inst.texture_normal = tex
			inst.texture_hover  = tex   # optional – same texture for hover/pressed
			inst.texture_pressed = tex
	
	Helper.log("Populated color menu")
