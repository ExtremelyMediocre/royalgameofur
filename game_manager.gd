extends Node

var dice_roll: int = 0
var current_player: String = "Player1"
var piece_scene := preload("res://Piece.tscn")

@onready var route1 = $"../Board/PlayerOneRoute"
@onready var route2 = $"../Board/PlayerTwoRoute"
@onready var player1_node = $"../Player1"
@onready var player2_node = $"../Player2"
@onready var turn_label: RichTextLabel = $"../UI/CanvasLayer/CurrentTurn"

var total_to_win := 7
var piece_moved := false

func _ready() -> void:
	randomize()
	spawn_pieces(player1_node, "Player1", route1, preload("res://Player1Piece.png"))
	spawn_pieces(player2_node, "Player2", route2, preload("res://Player2Piece.png"))
	await game_loop()

func spawn_pieces(parent: Node, player_name: String, route: Node, texture: Texture2D) -> void:
	for i in range(7):
		var piece = piece_scene.instantiate()
		piece.set_player_data(player_name, texture, route)
		parent.add_child(piece)
		piece.global_position = route.get_child(0).global_position

func game_loop() -> void:
	while get_score(player1_node) < total_to_win and get_score(player2_node) < total_to_win:
		var player_node = player1_node if current_player == "Player1" else player2_node
		turn_label.text = "It is: %s's Turn" % current_player

		roll_dice()
		print("%s rolled: %d" % [current_player, dice_roll])

		await wait_for_piece_click(player_node)

		current_player = "Player2" if current_player == "Player1" else "Player1"

	var winner = "Player1" if get_score(player1_node) > get_score(player2_node) else "Player2"
	turn_label.text = "%s wins!" % winner
	print("Winner is:", winner)

func roll_dice() -> void:
	dice_roll = randi() % 6 + 1

func get_score(player_node: Node) -> int:
	var score := 0
	for piece in player_node.get_children():
		if piece.route_index >= piece.route.get_child_count() - 1:
			score += 1
	return score

func wait_for_piece_click(player_node: Node) -> void:
	piece_moved = false
	var valid_pieces = []

	for piece in player_node.get_children():
		var target_index = piece.route_index + dice_roll
		if target_index < piece.route.get_child_count():
			valid_pieces.append(piece)

	if valid_pieces.size() == 0:
		print("No valid moves for", current_player)
		await get_tree().create_timer(1.0).timeout
		return

	for piece in valid_pieces:
		piece.can_move = true
		piece.set_process_input(true)
		if not piece.piece_moved.is_connected(_on_piece_moved):
			piece.piece_moved.connect(_on_piece_moved)

	while not piece_moved:
		await get_tree().process_frame

	for piece in valid_pieces:
		piece.can_move = false
		piece.set_process_input(false)
		if piece.piece_moved.is_connected(_on_piece_moved):
			piece.piece_moved.disconnect(_on_piece_moved)

func _on_piece_moved():
	piece_moved = true
