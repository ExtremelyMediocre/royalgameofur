extends Area2D

signal piece_moved

var route: Node
var route_index: int = 0
var player_id: String
var can_move: bool = false

@onready var game_manager = get_tree().get_root().get_node("Main/GameManager")  # Adjust path as needed

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
	var steps = game_manager.dice_roll
	var target_index = route_index + steps
	if target_index >= route.get_child_count():
		print("Invalid move: off the board")
		return

	route_index = target_index
	global_position = route.get_child(route_index).global_position
	emit_signal("piece_moved")
