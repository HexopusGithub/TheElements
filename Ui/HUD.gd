extends Control

func _on_Player_fog_view(shown):
	$FogSprite.visible = shown

func health_update(health):
	var ind = 0
	for health_point in $TopLeftCorner/HealthBar.get_children():
		if ind < health:
			health_point.show()
		else:
			health_point.hide()
		ind += 1
