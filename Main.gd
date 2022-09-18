extends Node
var game_rules = load("res://Constants/GameRules.gd").new()

var stage_index = 0
var current_stage
var level_number = 1
var current_level

func _ready():
	randomize()
	current_stage = 1 #round(rand_range(1, 10))
	new_level()

func _on_Player_fog_view():
	pass # Replace with function body.

func new_level():
	var new_level_scene
	if level_number <= 10:
		new_level_scene = load("res://Levels/" + str(current_stage) + "/" + game_rules.level_difficulty[stage_index] + "/Level" + str(level_number) + ".tscn")
	elif level_number == 11:
		new_level_scene = load("res://Levels/" + str(current_stage) + "/" + game_rules.level_difficulty[stage_index] + "/Boss.tscn")
	else:
		level_number = 1
		stage_index += 1
		current_stage = round(rand_range(1, 10))
		new_level_scene = load("res://Levels/" + str(current_stage) + "/" + game_rules.level_difficulty[stage_index] + "/Level" + str(level_number) + ".tscn")
	current_level = new_level_scene.instance()
	add_child(current_level)
	level_number += 1

func at_teleporter(type):
	if Input.is_action_just_pressed("Interact"):
		if not len(current_level.get_tree().get_nodes_in_group("Enemies")):
			if type == "Normal":
				current_level.queue_free()
				new_level()
			if type == "Crafting" and not $Inventory/CraftingUI.visible:
				$Player.velocity = Vector2()
				$Player.no_ai = true
				$Inventory/CraftingUI.show()

func _input(event):
	if event.is_action_pressed("ui_cancel") and $Inventory/CraftingUI.visible:
		$Player.no_ai = false
		$Inventory/CraftingUI.hide()

func update_health(health):
	
	$HUD.health_update(health)

#func enemy_killed():
#	current_level
