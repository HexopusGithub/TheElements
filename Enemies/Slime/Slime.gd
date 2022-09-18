extends "res://Classes/EnemyClass.gd"

func _ready():
	directory_name = "Slime"
	
	randomize()
	health = 3

func move():
	var direction = (target - position).normalized()
	velocity += direction * speed / 10
	velocity *= 0.9

func ShootingTimer():
	if not no_ai:
		var bullet_scene = load("res://Bullets/PistolBullet/PistolBullet.tscn")
		var bullet = bullet_scene.instance()
		bullet.position = global_position
		bullet.look_at(target)
		var offset = rand_range(-confusion, confusion)
		bullet.linear_velocity = Vector2(500, 0).rotated(bullet.rotation + offset)
		bullet.rotation += offset
		bullet.owner_id = get_instance_id()

		if not int(rand_range(0, 3)) and not state:
			bullet.element = element
			element_active = element
			$Sprite.texture = load("res://Art/" + directory_name + "/" + str(element) + ".png")
			elementActiveTimer.start()

		get_parent().add_child(bullet)
