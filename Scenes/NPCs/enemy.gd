extends CharacterBody3D

var speed = 0
var accel = 10
const ASPEED = 4

var active = false
var target

@onready var nav: NavigationAgent3D = $NavigationAgent3D

func _ready():
	await get_tree().create_timer(2).timeout
	reparent(get_node("/root/world/Enemies"))
	
func _physics_process(delta: float) -> void:
	if active == false:
		speed = 0
		return
	else:
		speed = ASPEED
	var direction = Vector3()
	nav.get_navigation_map()
	nav.target_position = target.global_position
	direction = nav.get_next_path_position() - global_position
	direction = direction.normalized()
	velocity = velocity.lerp(direction * speed, accel * delta)
	move_and_slide()


func _on_area_3d_body_entered(body: CharacterBody3D) -> void:
	target = body
	active = true
	print("ENEMY SPOTTED")

@warning_ignore("unused_parameter")
func _on_area_3d_body_exited(body: CharacterBody3D) -> void:
	speed = 0
	active = false
