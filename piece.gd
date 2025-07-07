extends Area2D

signal piece_moved

var route: Node
var route_index: int = 0
var player_id: String
var can_move: bool = false
var is_moving: bool = false

@onready var game_manager = get_tree().get_root().get_node("Node2D/GameManager")

func set_player_data(player_name: String, texture: Texture2D, assigned_route: Node):
	player_id = player_name
	route = assigned_route
	$Sprite2D.texture = texture

func _input_event(viewport, event, shape_idx):
	if not can_move:
		return
	if event is InputEventMouseButton and event.pressed:
		move_piece()

func move_piece():
	if is_moving:
		return
	is_moving = true

	var steps = game_manager.dice_roll
	var target_index = route_index + steps

	if target_index >= route.get_child_count():
		print("Invalid move: off the board")
		is_moving = false
		return

	route_index = target_index
	global_position = route.get_child(route_index).global_position
	emit_signal("piece_moved")
	is_moving = false
