extends Node

var player_current_attack = false

var current_scene = "world"
var transition_scene = false
var scene_changed = false

var player_exit_cliffside_posx = 0
var player_exit_cliffside_posy = 0
var player_start_posx = 0
var player_start_posy = 0

var player_node = null

func _ready():
	if not player_node:
		print("Warning: player_node is null at game start. Ensure the player is instantiated in the initial scene.")

func finish_changescene():
	if transition_scene:
		transition_scene = false
		scene_changed = false
		if current_scene == "world":
			current_scene = "cliff_side"
		else:
			current_scene = "world"
		print("Scene changed to: ", current_scene)
