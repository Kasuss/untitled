extends Node3D
class_name GunComponent

@export var animator : AnimationPlayer
@export var reloaded : float
@export var shootcd : float

@warning_ignore("shadowed_variable")
func animation(animate: Animate, animation):
	var play = animate.animation[animation]
	var length = animator.get_current_animation_length()
	var speedscale = animator.speed_scale
	var animating = animator.get_current_animation()
	print(play + animating)
	if play == animate.animation[4]:
		animator.stop()
		animator.play(str(play))
		return
	
	if play == animate.animation[3]:
		animator.stop()
		length = reloaded
		animator.play(str(play))
		return (length / speedscale)
		
	if play == animate.animation[2] and length >= shootcd:
		animator.stop()
		animator.play(str(play))
		return 
	
	if animating != play and animating == animate.animation[0] or animate.animation[1]:
		return
	animator.play(str(play))


