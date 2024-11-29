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
func damage(damage):
	health -= damage

	if health <= 0:
		var drop = PICKUP.instantiate()
		add_child(drop)
		drop.global_position = parent.global_position
		await get_tree().physics_frame
		print(drop.global_position)
		get_parent().queue_free()
