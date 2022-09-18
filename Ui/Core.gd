extends Node2D

var element = 1
var size = 1

func _ready():
	update_texture()

func update_texture():
	if size == 0:
		$TextureRect.texture = load("res://Art/HUD/HotBar/half" + str(element) + ".png")
	if size == 1:
		$TextureRect.texture = load("res://Art/HUD/HotBar/" + str(element) + ".png")
	if size == 2:
		$TextureRect.texture = load("res://Art/HUD/HotBar/plus" + str(element) + ".png")
