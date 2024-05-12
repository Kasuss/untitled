extends Node3D
class_name GunComponent

@export var animator : AnimationPlayer
@export var animationtree : AnimationTree
@export var reloaded : float
@export var shootcd : float
@onready var player = get_node("/root/world/player")
##States
var idle = "parameters/conditions/idle"
var walking = "parameters/conditions/walking"
var animations = [Anim.animations[0],Anim.animations[1],Anim.animations[2],Anim.animations[3],Anim.animations[4]]

func _ready():
	animationtree.active = false
	animator.play("Animations/draw")
	
func _physics_process(_delta):
	if animationtree.active == false:
		return
	
	if player.velocity == Vector3.ZERO:
		animationtree[walking] = false
		animationtree[idle] = true
	else:
		animationtree[walking] = true
		animationtree[idle] = false

@warning_ignore("shadowed_variable")
func animation(animate: Animate, animation):
	animationtree.active = false
	var call = animate.animations[animation]
	## 0 = idle, 1 = walk, 2 = shoot, 3 = reload, 4 = draw ##
	var length = animator.get_current_animation_length()
	var speedscale = animator.speed_scale
	
	if call == animations[3]:
		animator.play(str(call))
		length = reloaded
		return (length / speedscale)
		
	if call == animations[2]:
		animator.play(str(call))
		if shootcd < length:
			animator.stop()
			animator.play(str(call))
			

func _on_animation_animation_finished(anim_name):
	if anim_name == animations[2] or animations[3] or animations[4]:
		animationtree.active = true
