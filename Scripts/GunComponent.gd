extends Node3D
class_name GunComponent

signal finished

@export var animator : AnimationPlayer
@export var animationtree : AnimationTree
@onready var player = get_node("/root/world/player")
@onready var weapon = get_parent().get_parent()
##States
var idle = "parameters/conditions/idle"
var walking = "parameters/conditions/walking"
var animations = Anim.animations
var inair = false

var loadedtime
var shoottime
var drawtime
var starttime

func _ready():
	animationtree.active = false
	weapon.connect("update_timers", update_timers)
	weapon.connect("animate",animate)
	player.connect("in_air",in_air)
		
func _physics_process(_delta):
	if animationtree.active == false:
		return
	if player.velocity == Vector3.ZERO:
		animationtree[walking] = false
		animationtree[idle] = true
	else:
		animationtree[walking] = true
		animationtree[idle] = false
		
func in_air(_air):
	inair = _air
	
		
func animate(animation, loops):
	animationtree.active = false
	print(animations[animation])
	animator.play(animations[animation])
	if loops > 0:
		loop_animation(loops)
		return
	if animation == 0:
		await get_tree().create_timer(drawtime).timeout
		finished.emit()
	if animation == 3:
		if animator.current_animation == animations[3]:
			animator.seek(0)
		await get_tree().create_timer(shoottime).timeout
		finished.emit()

func loop_animation(loops):
	loops -= 1
	await get_tree().create_timer(loadedtime).timeout
	while loops != 0:
		print(loops)
		animator.seek(starttime)
		await get_tree().create_timer(loadedtime-starttime).timeout
		loops -= 1
		finished.emit()

func _on_animation_animation_finished(anim_name):
	if anim_name == animations[0] or animations[3] or animations[4] or animations[5]:
		animationtree.active = true
		
func update_timers(start,loaded,shoot,draw):
	starttime = start
	loadedtime = loaded
	shoottime = shoot
	drawtime = draw
	print(start, loaded, shoot, draw)
