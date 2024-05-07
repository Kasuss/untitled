extends Label

@export var character : CharacterBody3D

func _process(delta):
	text = str(character.mag) + " / " + str(character.reserves)
