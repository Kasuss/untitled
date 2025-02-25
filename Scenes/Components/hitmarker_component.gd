extends Node3D
class_name Hitmarker

@onready var player = get_node("/root/world/player")
@onready var weapon = get_node("/root/world/player/Head/Camera3D/Pivot/Weapons")
var parent = get_parent()

#func _ready():
	#weapon.connect("damage",create_damage)
	#parent = get_parent()

#func create_damage(damage,multiplier):
	#const TEXT = preload("res://Scenes/Components/hittext.tscn")
	#var text = TEXT.instantiate()
	#add_child(text)
	#text.global_position = parent.global_position
	#text._damage(damage, multiplier)
