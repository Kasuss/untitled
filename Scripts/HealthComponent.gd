extends Node3D
class_name HealthComponent

@export var MAX_HEALTH := 100.0
var health : float
var number
const PICKUP = preload("res://Scenes/Pickups/Pickup.tscn")
var parent
var world


func _ready():
		health = MAX_HEALTH
		parent = get_parent()
		
		


@warning_ignore("shadowed_variable")
func damage(damage, multiplier):
	health -= damage * multiplier
	create_damage(damage,multiplier)
	if health <= 0:
		if get_child_count() == 0:
			var drop = PICKUP.instantiate()
			add_child(drop)
			drop.global_position = parent.global_position
			await get_tree().physics_frame
			print(drop.global_position)
		get_parent().queue_free()
		
func create_damage(damage,multiplier):
	const TEXT = preload("res://Scenes/Components/hittext.tscn")
	var text = TEXT.instantiate()
	add_child(text)
	text._damage(damage, multiplier)
