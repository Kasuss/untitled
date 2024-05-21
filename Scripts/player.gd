extends CharacterBody3D

@onready var camera = %Camera3D
@onready var head = $Head

signal in_air(air)

##State
var slidejumping = false
var sliding = false

##Script Calls

##Mobility
var dash = false
var dash_cd = 0.3
var speed
var dash_direction = Vector3(0,0,0)
var sliding_direction = Vector3(0,0,0)
const WALK_SPEED = 10.0
const DASH_SPEED = 25.0
const SLIDE_SPEED = 25.0
const CROUCH_SPEED = 3.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.002

const BASE_FOV = 90.0
const FOV_CHANGE = 0.3

var gravity = 9.8

# head bob
const ROTATION_SPEED = -0.5
const BOB_FREQ = 0.0
const BOB_AMP = 0.04
var t_bob = 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	var movement = Input.get_vector("left", "right", "up", "down")
		
	if event.is_action_pressed("slide") and not sliding:
		sliding = true
		sliding_direction = (head.transform.basis * Vector3(movement.x, 0, movement.y)).normalized()
		speed = SLIDE_SPEED
		camera.transform.origin -= Vector3(0,0.25,0)
		
	if event.is_action_pressed("dash") and not dash:
		dash = true
		dash_cd = 0.3
		dash_direction = (head.transform.basis * Vector3(movement.x, 0, movement.y)).normalized()
		speed = DASH_SPEED

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-70), deg_to_rad(70))


func _physics_process(delta):
	if not is_on_floor():
		in_air.emit(true)
	else:
		in_air.emit(false)
	if dash:
		dashing(delta)
		dash_cd -= delta
	
	if sliding and is_on_floor():
		slide(delta)
	elif not dash:
		mobility(delta)


func mobility(delta):
	move_and_slide()
	speed = WALK_SPEED
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		slidejumping = false
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_pressed("close"):
		get_tree().quit()

	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if slidejumping == true:
		velocity.y -= (gravity/2) * delta
	if is_on_floor():
		if direction:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 12.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 12.0)
			head.rotation.x = lerp(0.0,clamp(velocity.z,deg_to_rad(-5),deg_to_rad(5)),delta * 2.0)
			camera.rotation.z = lerp(0.0,clamp(-velocity.x,deg_to_rad(-5),deg_to_rad(5)),delta * 2.0)
		else:
			velocity.x = 0
			velocity.z = 0
			head.rotation.x = 0
			camera.rotation.z = 0
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
		
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	# FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, DASH_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 7.0)
	
	
	
	
func slide(delta):
	move_and_slide()
	if not is_on_floor():
		velocity.y -= (gravity/2) * delta
		
	if is_on_floor():
		if speed >= 4.0:
			speed -= SLIDE_SPEED * delta
			velocity.x = sliding_direction.x * speed
			velocity.z = sliding_direction.z * speed
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY * 2
			speed = speed * 2
			slidejumping = true
			sliding = false
	if speed < 4.0:
		sliding = false
	# FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, SLIDE_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 7.0)
	
	
func dashing(delta):
	move_and_slide()
	speed -= DASH_SPEED * delta
	velocity.y = 0
	velocity.x = dash_direction.x * speed
	velocity.z = dash_direction.z * speed
	if dash_cd <= 0:
		dash_cd = 0
		dash = false
	# FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, DASH_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 7.0)
	

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time*BOB_FREQ) * BOB_AMP
	pos.x = cos(time*BOB_FREQ / 2) * BOB_AMP
	return pos

func update_animation():
	
	pass

