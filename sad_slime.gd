extends CharacterBody2D

var speed = 50
var player_chase = false
var player = null

var health = 75
var player_inattack_zone = false
var can_take_damage = true
var is_alive = true
var initial_position = Vector2.ZERO
var time_since_death = 0.0
var is_waiting_to_respawn = false

func _ready():
	initial_position = position

func _physics_process(delta):
	if is_waiting_to_respawn:
		time_since_death += delta
		while time_since_death >= 30.0:
			respawn()
			time_since_death = 0.0
			is_waiting_to_respawn = false
			break
		return

	deal_with_damage()
	update_health()
	
	if not is_alive:
		return

	if player_chase:
		position += (player.position - position) / speed
		$AnimatedSprite2D.play("front_walk")
		if (player.position.x - position.x) < 0:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
	else:
		$AnimatedSprite2D.play("front_idle")

func _on_enemy_detection_area_body_entered(body):
	player = body
	player_chase = true
	print("Player entered detection area")

func _on_enemy_detection_area_body_exited(body):
	player = null
	player_chase = false
	print("Player exited detection area")

func sad_slime():
	return true

func _on_enemy_hitbox_body_entered(body):
	print("Body entered hitbox: ", body.name)
	if body.has_method("player"):
		player_inattack_zone = true
		print("Player entered hitbox")

func _on_enemy_hitbox_body_exited(body):
	if body.has_method("player"):
		player_inattack_zone = false
		print("Player exited hitbox")

func deal_with_damage():
	if player_inattack_zone and global.player_current_attack and can_take_damage:
		health -= 25
		can_take_damage = false
		$take_damage_cooldown.start()
		print("Sad Slime Health = ", health)
		if health <= 0:
			die()

func die():
	is_alive = false
	$AnimatedSprite2D.play("death")
	$CollisionShape2D.disabled = true
	$enemy_detection_area/CollisionShape2D.disabled = true
	$enemy_hitbox/CollisionShape2D.disabled = true
	$AnimatedSprite2D.visible = false
	is_waiting_to_respawn = true
	time_since_death = 0.0

func respawn():
	is_alive = true
	health = 75
	position = initial_position
	$AnimatedSprite2D.visible = true
	$CollisionShape2D.disabled = false
	$enemy_detection_area/CollisionShape2D.disabled = false
	$enemy_hitbox/CollisionShape2D.disabled = false
	$AnimatedSprite2D.play("front_idle")
	print("Sad Slime respawned!")

func _on_take_damage_cooldown_timeout():
	can_take_damage = true
	
func update_health():
	var healthbar = $healthbar
	healthbar.value = health
	
	if health >= 75:
		healthbar.visible = false
	else:
		healthbar.visible = true
	if health <= 0:
		healthbar.visible = false
