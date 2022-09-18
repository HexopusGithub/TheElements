extends Area2D

var directory_name

var health = 100
var speed = 1
export(int) var element = 0
var element_active = 0
var loot = 1

var state = 0
var state_strengh = 1
var no_ai = false
var velocity = Vector2()
var confusion = 0
var looking_for_player = true
var hit_direction = 0
var effectiveness = load("res://Constants/ElementalEffectiveness.gd").new()

var target

var shootingTimer
var elementActiveTimer
var stateTimer
var burnTimer

func _ready():
	shootingTimer = Timer.new()
	shootingTimer.wait_time = 1
	shootingTimer.autostart = true
	shootingTimer.connect("timeout", self, "ShootingTimer")
	add_child(shootingTimer)
	elementActiveTimer = Timer.new()
	elementActiveTimer.wait_time = 1.5
	elementActiveTimer.one_shot = true
	elementActiveTimer.connect("timeout", self, "ElementActiveTimer")
	add_child(elementActiveTimer)
	stateTimer = Timer.new()
	stateTimer.wait_time = 1
	stateTimer.one_shot = true
	stateTimer.connect("timeout", self, "StateTimer")
	add_child(stateTimer)
	burnTimer = Timer.new()
	burnTimer.wait_time = 0.5
	burnTimer.connect("timeout", self, "BurnTimer")
	add_child(burnTimer)
	
	connect("body_entered", self,"hit")

func hit(body):
	if body.is_in_group("bullets"):
		if not body.owner_id == get_instance_id():
			var damage = body.damage * effectiveness.table[element_active][body.element] / 5
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
	if health <= 0:
		drop_bits()
		queue_free()

func drop_bits():
	var inventory = get_node("/root/Main/Inventory")
	var half_loot = int(loot / 2) + round(rand_range(0, 1))
	var half_loot2 = int(loot / 2) + round(rand_range(0, 1))
	if self.element == 1:
		inventory.bits[1] += loot
	if self.element == 2:
		inventory.bits[2] += loot
	if self.element == 3:
		inventory.bits[3] += loot
	if self.element == 4:
		inventory.bits[4] += loot
	if self.element == 5:
		inventory.bits[1] += half_loot
		inventory.bits[2] += half_loot2
	if self.element == 6:
		inventory.bits[1] += half_loot
		inventory.bits[3] += half_loot2
	if self.element == 7:
		inventory.bits[1] += half_loot
		inventory.bits[4] += half_loot2
	if self.element == 8:
		inventory.bits[2] += half_loot
		inventory.bits[3] += half_loot2
	if self.element == 9:
		inventory.bits[3] += half_loot
		inventory.bits[4] += half_loot2
	if self.element == 10:
		inventory.bits[2] += half_loot
		inventory.bits[4] += half_loot2
	
	inventory.update_bits()

func _process(_delta):
		if looking_for_player:
			target = get_node("/root/Main/Player").global_position
		
		if not no_ai:
			call("move")
		if state:
			state_update()
		position += velocity
		if not position.x == clamp(position.x, 0, get_viewport_rect().size.x):
			position.x = clamp(position.x, 0, get_viewport_rect().size.x)
			velocity.x = -velocity.x / 2
		if not position.y == clamp(position.y, 0, get_viewport_rect().size.y):
			position.y = clamp(position.y, 0, get_viewport_rect().size.y)
			velocity.y = -velocity.y / 2

func ElementActiveTimer():
	element_active = 0
	$Sprite.texture = load("res://Art/" + directory_name + "/0.png")

func state_initiate(time=0):
	state_strengh = effectiveness.table[element_active][state] / 5.0
	element_active = state
	if not time:
		stateTimer.wait_time = 2 * state_strengh
	else:
		stateTimer.wait_time = time
	stateTimer.start()
	elementActiveTimer.stop()
	$Sprite.texture = load("res://Art/" + directory_name + "States/" + str(state) + ".png")
	if state == 1:
		velocity = Vector2()
	if state == 2:
		velocity = Vector2()
		no_ai = true
	if state == 3:
		velocity = Vector2(50 * state_strengh, 0).rotated(hit_direction)
		health -= 10 * state_strengh
	if state == 4:
		burnTimer.start()
	if state == 5:
		looking_for_player = false
	if state == 6:
		confusion = PI
	if state == 7:
		velocity = Vector2()
		no_ai = true
	
	if state == 9:
		looking_for_player = false

func state_update():
	if state == 1:
		var direction = get_global_mouse_position() - global_position
		velocity += direction.normalized() / 3 * state_strengh
		position += velocity
	if state == 7:
		for enemy in get_parent().get_tree().get_nodes_in_group("enemies"):
			var distance = (global_position - enemy.global_position).length()
			if not enemy.element_active == 7 and distance < 100 * state_strengh and stateTimer.time_left > 0.5:
				enemy.state = state
				enemy.state_initiate(stateTimer.time_left)
	if state == 9:
		var other_enemies = get_parent().get_tree().get_nodes_in_group("enemies")
		if other_enemies:
			var nearest
			if not other_enemies[0].get_instance_id() == get_instance_id():
				nearest = other_enemies[0]
			else:
				nearest = other_enemies[-1]
			for enemy in other_enemies:
				if global_position.distance_to(enemy.global_position) < global_position.distance_to(nearest.global_position) and not enemy.get_instance_id() == get_instance_id():
					nearest = enemy
			target = nearest.global_position

func state_end():
	if state == 2:
		no_ai = false
	if state == 4:
		burnTimer.stop()
	if state == 5:
		looking_for_player = true
	if state == 6:
		confusion = 0
	if state == 7:
		no_ai = false
	if state == 9:
		looking_for_player = true

func StateTimer():
	state_end()
	state = 0
	element_active = 0
	$Sprite.texture = load("res://Art/" + directory_name + "/0.png")

func BurnTimer():
	health -= 2 * state_strengh
	velocity = Vector2()
	update_health()
