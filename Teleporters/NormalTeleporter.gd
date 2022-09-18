extends Area2D

export(String) var type = "Normal"
var in_reach = false

func _ready():
	$AnimatedSprite.animation = type

func _on_NormalTeleporter_body_entered(body):
	if body.is_in_group("Player"):
		in_reach = true

func _on_NormalTeleporter_body_exited(body):
	if body.is_in_group("Player"):
		in_reach = false

func _process(_delta):
	if in_reach:
		get_node("/root/Main").at_teleporter(type)
