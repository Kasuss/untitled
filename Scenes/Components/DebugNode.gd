extends Node3D

@onready var player = get_node("/root/world/player")
@onready var raycast = get_node("/root/world/player/Head/Camera3D/hitscan")

const DROP = preload("res://Scenes/Pickups/Pickup.tscn")

func _input(event):
	if event.is_action_pressed("debug_key"):
		raycast.force_raycast_update()
		var location = raycast.get_collision_point()
		var drop = DROP.instantiate()
		add_child(drop)
		drop.global_position = location
		drop.position.y += 1
		drop.reparent(get_node("/root/world"))
