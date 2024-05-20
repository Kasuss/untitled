extends Node3D
class_name Hitmarker

@export var spawn = Node3D
@onready var player = get_node("/root/world/player")
@onready var weapon = get_node("/root/world/player/Head/Camera3D/Pivot/Weapons")

func _ready():
	weapon.connect("damage",create_damage)

func create_damage(damage,multiplier):
	const TEXT = preload("res://Scenes/Components/hittext.tscn")
	var text = TEXT.instantiate()
	add_child(text)
	text._damage(damage, multiplier)

