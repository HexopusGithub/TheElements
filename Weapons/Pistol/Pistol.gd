extends "res://Classes/WeaponClass.gd"

func _ready():
	randomize()
	damage = 1
	element = 0 #round(rand_range(0, 10))
	$Cooldown.wait_time = cooldown
	texture = load("res://Art/Pistol/" + str(element) + ".png")

#func _process(delta):
#	var player = get_parent().get_parent()
#	if not player.no_ai:
#		if Input.is_action_pressed("LeftClick") and $Cooldown.time_left == 0:
#			$Cooldown.start()
#
#			player.get_node("AnimationPlayer").playback_speed = 10 / cooldown
#			player.get_node("AnimationPlayer").play("Shoot")
#
#			var bullet_scene = load("res://PistolBullet.tscn")
#			var bullet = bullet_scene.instance()
#			bullet.position = global_position
#			var offset = rand_range(-player.confusion, player.confusion)
#			bullet.rotation = global_rotation + offset
#			bullet.linear_velocity = Vector2(1000, 0).rotated(global_rotation + offset)
#			bullet.owner_id = player.get_instance_id()
#			bullet.damage = damage
#			bullet.knockback = knockback
#			if not player.state or player.state == element:
#				bullet.element = element
#				player.activate_element(element)
#
#			player.get_parent().add_child(bullet)
