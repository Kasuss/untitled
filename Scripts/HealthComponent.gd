extends Node3D
class_name HealthComponent

@export var MAX_HEALTH := 100.0
var health : float


func _ready():
		health = MAX_HEALTH


func damage(attack: Damage):
	health -= attack.attack
	print (health)

	if health <= 0:
		get_parent().queue_free()
