extends KinematicBody2D
var effectiveness = load("res://Constants/ElementalEffectiveness.gd").new()

signal fog_view

var health = 10
var speed = 3
var element = 0
var element_active = 0
var state
var state_strengh = 1
var no_ai = false
var confusion = 0
var looking_for_player = true
var hit_direction = 0

var move
var velocity = Vector2()

var Animationplayer
var weapon
var hand8_offset
var hand2_offset
var arm7_offset
var arm7_home
var arm3_offset
var arm3_home
func _ready():
	Animationplayer = $VisualController/AnimationPlayer
	weapon = $VisualController/WeaponController/Pistol
	print($VisualController/Part8.global_position)
	hand8_offset = $VisualController/Part8.global_position - weapon.global_position
	hand2_offset = $VisualController/Part2.global_position - weapon.global_position
	arm7_home = $VisualController/Part7.position
	arm3_home = $VisualController/Part3.position
	arm7_offset = Vector2(-30, 10) #$VisualController/Part8".position - $VisualController/Part7".position
	arm3_offset = Vector2(30, 0) #$VisualController/Part8".position - $VisualController/Part7".position
	
func _process(_delta):
#	$Sprite.speed_scale = 1
#	$Sprite.animation = "Idle" + str(element_active)
	if not no_ai:
#		$Sprite.play()
		get_input()
#	else:
#		$Sprite.stop()

	if velocity.length() > 0:
#		$CollisionShape2D.shape = CapsuleShape2D.new()
#		$CollisionShape2D.shape.height = 21.5
#		$CollisionShape2D.shape.radius = 3.5
#		$CollisionShape2D.rotation = PI / 2
#		$CollisionShape2D.position = Vector2(0, 37.552)
		move_and_slide(velocity * 50)
#		$CollisionShape2D.shape = CapsuleShape2D.new()
#		$CollisionShape2D.shape.height = 28.489
#		$CollisionShape2D.shape.radius = 17.288
#		$CollisionShape2D.position = Vector2(0, 9)
		
	if state:
		state_update()
	
	if not position.x == clamp(position.x, 0, get_viewport_rect().size.x):
		position.x = clamp(position.x, 0, get_viewport_rect().size.x)
		velocity.x = -velocity.x / 2
	if not position.y == clamp(position.y, 0, get_viewport_rect().size.y):
		position.y = clamp(position.y, 0, get_viewport_rect().size.y)
		velocity.y = -velocity.y / 2

func get_input():
	move = Vector2()
	if Input.is_action_pressed("right"):
		move.x += 1
	if Input.is_action_pressed("left"):
		move.x -= 1
	if Input.is_action_pressed("down"):
		move.y += 1
	if Input.is_action_pressed("up"):
		move.y -= 1
	move = move.normalized() * speed
	velocity += move
	velocity *= 0.7
	
	if move.x:
		Animationplayer.playback_speed = velocity.length() / 2
		if (move.x > 0) == ($VisualController.scale.x > 0):
			Animationplayer.play("Walk")
		else:
			Animationplayer.play_backwards("Walk")
	elif move.y:
		Animationplayer.playback_speed = velocity.length() / 2
		if move.y < 0:
			Animationplayer.play("WalkSide")
		else:
			Animationplayer.play_backwards("WalkSide")
			
	else:
		Animationplayer.playback_speed = 1
		Animationplayer.play("Idle")

	var aim_direction = position.direction_to(get_global_mouse_position()).angle()
	var hand8_pos = weapon.global_position + hand8_offset.rotated(weapon.global_rotation) * scale
	var hand2_pos = weapon.global_position + hand2_offset.rotated(weapon.global_rotation) * scale
	$VisualController/Part8.global_position = hand8_pos
	$VisualController/Part2.global_position = hand2_pos
	$VisualController/Part7.look_at($VisualController/Part8.global_position)
	$VisualController/Part7.rotation -= PI / 2
	$VisualController/Part7.position = 0.5 * (arm7_offset + $VisualController/Part8.position) - arm7_home
	$VisualController/Part3.look_at($VisualController/Part2.global_position)
	$VisualController/Part3.rotation -= PI / 2
	$VisualController/Part3.position = 0.5 * (arm3_offset + $VisualController/Part2.position) - arm3_home
	if abs(aim_direction) > PI / 2:
		weapon.rotation = PI - aim_direction
		$VisualController.scale.x = -1
	else:
		weapon.rotation = aim_direction
		$VisualController.scale.x = 1
	
	if Input.is_action_pressed("LeftClick"):
		weapon.element = 0
		if weapon.shoot(self):
			Animationplayer.playback_speed = 10 / weapon.cooldown
			Animationplayer.play("Shoot")
	if Input.is_action_pressed("RightClick"):
		weapon.element = get_parent().get_node("Inventory").selected_element
		if weapon.shoot(self):
			Animationplayer.playback_speed = 10 / weapon.cooldown
			Animationplayer.play("Shoot")

func hit(body):
	if body.is_in_group("bullets"):
		if not body.owner_id == get_instance_id():
			var damage = body.damage * effectiveness.table[element][body.element] / 5
			health -= damage
			hit_direction = body.rotation
			if not no_ai:
				velocity = Vector2(body.knockback, 0).rotated(hit_direction)
			
			if body.element and not state == body.element:
				state = body.element
				state_initiate()
			
			body.queue_free()
			update_health()

func update_health():
	get_parent().update_health(health)
	if health <= 0:
		hide()
		no_ai = true

func activate_element(el):
	element = el
	element_active = el
#	$Sprite.texture = load("res://Art/Slime/" + str(element) + ".png")
	$ElementActiveTimer.start()

func _on_ElementActiveTimer_timeout():
	element_active = 0
#	$Sprite.texture = load("res://Art/Slime/0.png")
	for sprite in get_tree().get_nodes_in_group("sprites"):
		sprite.animation = "0"

func state_initiate(time=0):
	state_strengh = effectiveness.table[element_active][state] / 5
	element_active = state
	if not time:
		$StateTimer.wait_time = 2 * state_strengh
	else:
		$StateTimer.wait_time = time
	$StateTimer.start()
	$ElementActiveTimer.stop()
#	$Sprite.texture = load("res://Art/SlimeStates/" + str(state) + ".png")
	for sprite in get_tree().get_nodes_in_group("sprites"):
			sprite.animation = str(state)
	if state == 1:
#		no_ai = true
		velocity = Vector2(3 * state_strengh, 0).rotated(rand_range(-PI, PI))
		$TwirlTimer.start()
	if state == 2:
		velocity = Vector2()
		no_ai = true
	if state == 3:
		velocity = Vector2(50 * state_strengh, 0).rotated(hit_direction)
		health -= 3 * state_strengh
	if state == 4:
		$BurnTimer.start()
	if state == 5:
		emit_signal("fog_view", true)
	if state == 6:
		confusion = PI / 4
	if state == 7:
		velocity = Vector2()
		no_ai = true

func state_update():
	if state == 1:
		velocity = velocity.normalized() * speed * 3
		velocity = velocity.rotated(PI / 32)
#	if state == 7:
#		for enemy in get_parent().get_tree().get_nodes_in_group("enemies"):
#			var distance = (global_position - enemy.global_position).length()
#			if not enemy.element_active == 7 and distance < 100 * state_strengh and $StateTimer.time_left > 0.5:
#				enemy.state = state
#				enemy.state_initiate($StateTimer.time_left)

func state_end():
	if state == 1:
		no_ai = false
		$TwirlTimer.stop()
	if state == 2:
		no_ai = false
	if state == 4:
		$BurnTimer.stop()
	if state == 5:
		emit_signal("fog_view", false)
	if state == 6:
		confusion = 0
	if state == 7:
		no_ai = false

func _on_StateTimer_timeout():
	state_end()
	state = 0
	element_active = 0
#	$Sprite.texture = load("res://Art/Slime/0.png")
	for sprite in get_tree().get_nodes_in_group("sprites"):
			sprite.animation = "0"

func _on_BurnTimer_timeout():
	health -= 1 * state_strengh
	velocity = Vector2()
	update_health()

func _on_TwirlTimer_timeout():
	velocity *= 1.1
	velocity = velocity.rotated(rand_range(-PI, PI))
