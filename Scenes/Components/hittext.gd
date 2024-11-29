extends Node3D

@onready var number
@onready var player = get_node("/root/world/player")
@onready var world = get_node("/root")


var playerlocation
var enemylocation

func _ready():
	reparent(world, true)
	
func _physics_process(_delta): 
	playerlocation = player.global_position
	look_at(playerlocation,Vector3(0,1,0),true)
	
func _damage(damage, multiplier):
	number = damage * multiplier
	var spawn_location = randf_range(-0.25,0.25)
	global_position += Vector3(spawn_location,0,spawn_location)
	var tweene = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	if multiplier > 1:
		tweene.tween_property(%Text,"modulate",Color.YELLOW,0)
	var drift_location = Vector2(randi_range(-32,32),randi_range(0,64))
	tweene.tween_property(%Text,"text",str(number),0)
	tweene.tween_property(%Text,"offset",drift_location,0.25)
	tweene.tween_property(%Text,"modulate:a",0,2)
	tweene.chain().tween_callback(queue_free)
