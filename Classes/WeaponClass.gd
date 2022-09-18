extends Sprite

var damage = 10
var knockback = 10
var cooldown = 0.5
var bullet_speed = 1000
var element = 0

var target = Vector2()

var cooldownTimer
func _ready():
	cooldownTimer = Timer.new()
	cooldownTimer.wait_time = cooldown
	cooldownTimer.one_shot = true
	add_child(cooldownTimer)

func shoot(user):
	if cooldownTimer.time_left == 0:
		cooldownTimer.start()
		var bullet_scene = load("res://Bullets/PistolBullet/PistolBullet.tscn")
		var bullet = bullet_scene.instance()
		bullet.position = global_position
		var offset = rand_range(-user.confusion, user.confusion)
		bullet.rotation = global_rotation + offset
		bullet.linear_velocity = Vector2(1000, 0).rotated(global_rotation + offset)
		bullet.owner_id = user.get_instance_id()
		bullet.damage = damage
		bullet.knockback = knockback
		if not user.state or user.state == element:
			bullet.element = element
			user.activate_element(element)
		
		get_node("/root").add_child(bullet)
		
		return true
	else:
		return false

func NOW():
	print("ajklsdgjkldffga hriüjghre")
