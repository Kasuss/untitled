extends Node3D
class_name HealthComponent

@export var MAX_HEALTH := 100.0
var health : float
var number

func _ready():
		health = MAX_HEALTH


@warning_ignore("shadowed_variable")
func damage(damage):
	health -= damage

	if health <= 0:
		get_parent().queue_free()
