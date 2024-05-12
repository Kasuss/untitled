extends Node3D
class_name Hitmarker

@export var spawn = Node3D
@onready var player = get_node("/root/world/player")
@onready var textnode = get_node("Text")

func create_damage():
	var pos = spawn.global_position
	const TEXT = preload("res://Scenes/Components/hittext.tscn")
	var text = TEXT.instantiate()
	add_child(text)

