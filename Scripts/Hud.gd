extends CanvasLayer

@onready var ammo = %Ammo


func _on_weapon_update_ammo(_mag, _reserves):
	ammo.text = str(_mag) + " / " + str(_reserves)
	pass 
