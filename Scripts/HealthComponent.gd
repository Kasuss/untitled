extends Node3D
class_name HealthComponent

@export var MAX_HEALTH := 100.0
@export var ui = Node3D
var health : float
var number

func _ready():
		health = MAX_HEALTH


func damage(attack: Damage):
	Game.last_damage = attack.attack
	health -= attack.attack
	ui.create_damage()

	if health <= 0:
		get_parent().queue_free()
		
		
func crit(attack: Damage):
	Game.last_damage = attack.crit
	health -= attack.crit
	ui.create_damage()
	
	if health <= 0:
		get_parent().queue_free()
