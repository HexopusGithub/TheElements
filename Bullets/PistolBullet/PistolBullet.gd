extends "res://Classes/BulletClass.gd"

func _ready():
	add_to_group("bullets")
	$Sprite.texture = load("res://Art/PistolBullet/" + str(element) + ".png")

func _on_PistolBullet_body_shape_entered(body_id, body, _body_shape, _local_shape):
	if not body_id == owner_id:
#		if body.is_in_group("Player"):
#			body.hit(self)
		queue_free()
