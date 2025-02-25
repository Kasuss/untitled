extends CanvasLayer

@onready var ammo = %Ammo
@onready var dash = %DashIcon
@onready var dash_n = %DashCD
@onready var enemies = get_node("/root/world/Enemies")


func _on_weapon_update_ammo(_mag, _reserves, _ammo) -> void:
	ammo.text = str(_mag) + " / " + str(_reserves)

func _on_player_dash_used(dash_duration) -> void:
	var dash_cd = dash_duration
	var tween = create_tween()
	if dash_cd > 0:
		var tween_n = create_tween()
		var cd = dash_cd
		tween_n.tween_property(dash_n,"text",str(cd),0)
		print(cd)
		while cd > 0:
			cd -= 1
			tween_n.tween_property(dash_n,"text",str(cd),1)
			if cd == 0:
				tween_n.tween_property(dash_n,"text","",1)
				break
	tween.tween_property(dash,"modulate",Color.html("#434343"),0)
	tween.tween_property(dash,"modulate",Color.html("#FFFFFF"),dash_cd)

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	##Crosshair
	var center = get_viewport().size / 2
	%Crosshair.position = center - Vector2i(20,20)
	
	##Enemy Counter
	var enemy_c = enemies.get_child_count()
	%EnemyCount.text = str(enemy_c) + " Enemies Remaining"
	if enemy_c == 0: %EnemyCount.text = "Level Complete!"
	
