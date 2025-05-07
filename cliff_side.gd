extends Node2D

func _ready():
	print("Cliff_side scene loaded")
	if global.player_node:
		add_child(global.player_node)
		global.player_node.position.x = global.player_exit_cliffside_posx
		global.player_node.position.y = global.player_exit_cliffside_posy
		print("Player reparented to cliff_side scene at position: ", global.player_node.position)
		if has_node("cliffside_camera"):
			$cliffside_camera.enabled = true
			$cliffside_camera.position = Vector2.ZERO
			$cliffside_camera.force_update_scroll()
			print("Cliffside camera enabled")
		else:
			print("Error: cliffside_camera node not found in cliff_side scene")
	else:
		print("Error: Player node not found in global.player_node")

func _process(delta):
	change_scene()

func _on_world_transition_point_body_entered(body):
	change_scene()
	if body.has_method("player"):
		global.transition_scene = true
		global.player_node = body
		print("Player entered transition point, transition_scene = true")

func _on_world_transition_point_body_exited(body):
	if body.has_method("player"):
		global.transition_scene = false
		print("Player exited transition point, transition_scene = false")

func change_scene():
	if global.transition_scene and not global.scene_changed:
		if global.player_node and global.player_node.is_inside_tree():
			global.player_node.get_parent().remove_child(global.player_node)
			print("Player detached from cliff_side scene")
		set_process(false)
		get_tree().change_scene_to_file("res://scenes/world.tscn")
		global.finish_changescene()
		print("Changing scene to world")
