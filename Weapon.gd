extends Node3D

var equipped

func _process(delta):
	equipped = GunComponent

func equip(weapon: Animate):
	if equipped:
		weapon.equip(weapon)
		pass

func idle():
	pass
	
func shoot():
	pass

func reload():
	pass
