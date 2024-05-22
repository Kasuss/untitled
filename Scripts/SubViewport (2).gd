extends SubViewport


func _on_damage_property_list_changed():
	var rng = randi_range(0,512)
	var tween = get_tree().create_tween()
	tween.tween_property(%Damage,"position:x",rng,0.4)
	tween.tween_property(%Damage,"position:y",rng,2)
