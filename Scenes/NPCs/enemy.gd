extends CharacterBody3D

func _ready():
	reparent(get_node("/root/world/Enemies"))
