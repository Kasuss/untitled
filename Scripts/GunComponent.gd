extends Node3D
class_name GunComponent

@export var animator : AnimationPlayer
@export var reloaded : float

func animation(animate: Animate, animation):
	var play = animate.animation[animation]
	var length = animator.get_current_animation_length()
	var speedscale = animator.speed_scale
	animator.play(str(play))
	if play == animate.animation[3]:
		length = reloaded
	return (length / speedscale)

func _physics_process(delta):
	if animator.is_playing():
		return
	else:
		animator.play("Animations/idle")


