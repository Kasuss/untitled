extends CharacterBody3D

@onready var camera = %Camera3D
@onready var head = $Head
@onready var root = get_tree().get_root()

signal in_air(air)

##State
var slidejumping = false
var sliding = false
var dash = false
var wallriding = false

##Mobility

var dash_cd = 0.0
var speed
var dash_direction = Vector3(0,0,0)
var sliding_direction = Vector3(0,0,0)
const WALK_SPEED = 12.0
const DASH_SPEED = 50.0
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
	
	if Input.is_action_pressed("close"):
		get_tree().quit()
		
	if event.is_action_pressed("slide") and not sliding:
		if not is_on_floor() or dash:
			return
		sliding = true
		sliding_direction = (head.transform.basis * Vector3(movement.x, 0, movement.y)).normalized()
		speed = SLIDE_SPEED
		camera.transform.origin -= Vector3(0,0.25,0)
		
	if event.is_action_pressed("dash") and not dash:
		if dash_cd > 0:
			return
		dash = true
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
	
	var dash_ended = true
	if dash_cd > 0 and not dash_ended:
		if is_on_floor():
			dash_ended = true
		else:
			mobility(delta*2)
	if dash_cd > 0 and dash_ended:
		dash_cd -= delta
	elif dash_cd <= 0:
		dash_ended = false

	
	if sliding and is_on_floor():
		slide(delta)
	elif not dash:
		#if is_on_wall():
			#wallrun(delta)
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

	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if slidejumping == true:
		velocity.y -= (gravity/2) * delta
	if is_on_floor():
		if direction:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 12.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 12.0)
			head.rotation.x = lerp(0.0,clamp(velocity.z*2,deg_to_rad(-10),deg_to_rad(10)),delta)
			camera.rotation.z = lerp(0.0,clamp(-velocity.x*2,deg_to_rad(-10),deg_to_rad(10)),delta)
		else:
			velocity.x = 0
			velocity.z = 0
			head.rotation.x = lerp(head.rotation.x,0.0,delta)
			camera.rotation.z = lerp(camera.rotation.z,0.0,delta)
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
	speed -= DASH_SPEED * (delta * 2)
	velocity.y = 0
	velocity.x = dash_direction.x * speed
	velocity.z = dash_direction.z * speed
	if speed <= WALK_SPEED:
		dash_cd = 3
		dash = false
	# FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, DASH_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 7.0)
	
func wallrun(delta):
	##to be returned to
	if not is_on_wall():
		return
	if Input.is_action_just_pressed("ui_accept"):
		velocity = (head.transform * speed).normalized()
		velocity.y = JUMP_VELOCITY
	move_and_slide()
	speed -= DASH_SPEED * (delta)
	velocity.y = 0
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	velocity.x = lerp(velocity.x, direction.x * speed, delta * 12.0)
	velocity.z = lerp(velocity.z, direction.z * speed, delta * 12.0)
	
	# FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, DASH_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 7.0)
	

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time*BOB_FREQ) * BOB_AMP
	pos.x = cos(time*BOB_FREQ / 2) * BOB_AMP
	return pos

func _on_hitbox_component_area_entered(area):
	if not area.is_in_group("Pickup"):
		return
	var drop = await area.give_item()
	%Weapons.pickup_item(drop)
	
