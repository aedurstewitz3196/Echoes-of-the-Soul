extends Node2D

func _ready():
	print("World scene loaded")
	if global.player_node:
		add_child(global.player_node)
		global.player_node.position.x = global.player_start_posx
		global.player_node.position.y = global.player_start_posy
		print("Player reparented to world scene at position: ", global.player_node.position)
	else:
		print("Error: Player node not found in global.player_node")
		var player_scene = load("res://scenes/player.tscn")
		global.player_node = player_scene.instantiate()
		add_child(global.player_node)
		global.player_node.position.x = global.player_start_posx
		global.player_node.position.y = global.player_start_posy
		print("New player instantiated at position: ", global.player_node.position)

func _process(delta):
	change_scene()

func _on_cliffside_transition_point_body_entered(body):
	if body.has_method("player"):
		global.transition_scene = true
		global.player_exit_cliffside_posx = body.position.x
		global.player_exit_cliffside_posy = body.position.y
		global.player_node = body
		print("Player entered transition point, transition_scene = true")

func _on_cliffside_transition_point_body_exited(body):
	if body.has_method("player"):
		global.transition_scene = false
		print("Player exited transition point, transition_scene = false")

func change_scene():
	if global.transition_scene and not global.scene_changed:
		if global.player_node and global.player_node.is_inside_tree():
			global.player_node.get_parent().remove_child(global.player_node)
			print("Player detached from world scene")
		set_process(false)
		get_tree().change_scene_to_file("res://scenes/cliff_side.tscn")
		global.finish_changescene()
		print("Changing scene to cliff_side")
