extends CharacterBody2D

var happy_slime_inattack_range = false
var happy_slime_attack_cooldown = true
var sad_slime_inattack_range = false
var sad_slime_attack_cooldown = true
var player_health = 100
var player_alive = true

var attack_ip = false

const speed = 100
var current_dir = "none"

func player():
	return true

func sad_slime():
	return true

func _ready():
	$AnimatedSprite2D.play("front_idle")

func _physics_process(delta):
	player_movement(delta)
	happy_slime_attack()
	sad_slime_attack()
	attack()
	current_camera()
	update_health()
	
	if player_health <= 0:
		player_alive = false
		player_health = 0
		print("Player has been killed!")
		self.queue_free()

func player_movement(delta):
	if attack_ip:
		velocity.x = 0
		velocity.y = 0
		return
	
	if Input.is_action_pressed("ui_right"):
		current_dir = "right"
		play_anim(1)
		velocity.x = speed
		velocity.y = 0
	elif Input.is_action_pressed("ui_left"):
		current_dir = "left"
		play_anim(1)
		velocity.x = -speed
		velocity.y = 0
	elif Input.is_action_pressed("ui_down"):
		current_dir = "down"
		play_anim(1)
		velocity.y = speed
		velocity.x = 0
	elif Input.is_action_pressed("ui_up"):
		current_dir = "up"
		play_anim(1)
		velocity.y = -speed
		velocity.x = 0
	else:
		play_anim(0)
		velocity.x = 0
		velocity.y = 0
	
	move_and_slide()

func play_anim(movement):
	var dir = current_dir
	var anim = $AnimatedSprite2D
	
	if dir == "right":
		anim.flip_h = false
		if movement == 1:
			anim.play("side_walk")
		elif movement == 0:
			if attack_ip == false:
				anim.play("side_idle")
	if dir == "left":
		anim.flip_h = true
		if movement == 1:
			anim.play("side_walk")
		elif movement == 0:
			if attack_ip == false:
				anim.play("side_idle")
	if dir == "down":
		anim.flip_h = true
		if movement == 1:
			anim.play("front_walk")
		elif movement == 0:
			if attack_ip == false:
				anim.play("front_idle")
	if dir == "up":
		anim.flip_h = true
		if movement == 1:
			anim.play("back_walk")
		elif movement == 0:
			if attack_ip == false:
				anim.play("back_idle")

func attack():
	var dir = current_dir
	
	if Input.is_action_just_pressed("Sword_Attack"):
		global.player_current_attack = true
		attack_ip = true
		if dir == "right":
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.play("side_attack")
			$deal_attack_timer.start()
		if dir == "left":
			$AnimatedSprite2D.flip_h = true
			$AnimatedSprite2D.play("side_attack")
			$deal_attack_timer.start()
		if dir == "down":
			$AnimatedSprite2D.play("front_attack")
			$deal_attack_timer.start()
		if dir == "up":
			$AnimatedSprite2D.play("back_attack")
			$deal_attack_timer.start()
		
		$deal_attack_timer.start()

func _on_deal_attack_timer_timeout():
	$deal_attack_timer.stop()
	global.player_current_attack = false
	attack_ip = false
	
	var anim = $AnimatedSprite2D
	if current_dir == "right":
		anim.play("side_idle")
	elif current_dir == "left":
		anim.play("side_idle")
	elif current_dir == "down":
		anim.play("front_idle")
	elif current_dir == "up":
		anim.play("back_idle")

func _on_player_hitbox_body_entered(body): 
	if body.has_method("happy_slime"):
		happy_slime_inattack_range = true
	if body.has_method("sad_slime"):
		sad_slime_inattack_range = true

func _on_player_hitbox_body_exited(body):
	if body.has_method("happy_slime"):
		happy_slime_inattack_range = false
	if body.has_method("sad_slime"):
		sad_slime_inattack_range = false 

func happy_slime_attack():
	if happy_slime_inattack_range and happy_slime_attack_cooldown == true:
		player_health -= 20
		happy_slime_attack_cooldown = false
		$attack_cooldown.start()
		print("Player Health = ", player_health)

func sad_slime_attack():
	if sad_slime_inattack_range and sad_slime_attack_cooldown == true:
		player_health -= 20
		sad_slime_attack_cooldown = false
		$attack_cooldown.start()
		print("Player Health = ", player_health)

func _on_attack_cooldown_timeout():
	happy_slime_attack_cooldown = true
	sad_slime_attack_cooldown = true

func current_camera():
	if global.current_scene == "world":
		$world_camera.enabled = true
		$world_camera.force_update_scroll()
	elif global.current_scene == "cliff_side":
		$world_camera.enabled = false

func update_health():
	var healthbar = $healthbar
	healthbar.value = player_health
	
	if player_health >= 100:
		healthbar.visible = false
	else:
		healthbar.visible = true


func _on_health_regeneration_timer_timeout():
	if player_health < 100:
		player_health = player_health + 20
		if player_health > 100:
			player_health = 100
	if player_health <= 0:
		player_health = 0
