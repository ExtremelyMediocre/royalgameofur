extends Node

var score = 0
var route: Node
var player_one_route: Node
var player_two_route: Node

func _ready() -> void:
	player_one_route = $"../Board/PlayerOneRoute"
	player_two_route = $"../Board/PlayerTwoRoute"

	if name == "Player1":
		route = player_one_route
	else:
		route = player_two_route

	print("Route for", name, ":", route.name)

func get_score() -> int:
	return score
