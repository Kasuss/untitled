extends CharacterBody3D

@onready var camera = %Camera3D
@onready var head = $Head
@onready var hand = %Pivot
@onready var handle = hand.transform.origin
@onready var hitscan = %hitscan

##Stats
var cd = 0.0
var mag = Game.equipped["Mag"]
var weapons = [Game.pistol]
var mag_max
var inventory = {
	"LightA": 100,
	"MediumA": 50,
	"HeavyA": 25,
}
var reserves = inventory[Game.equipped["Ammo Type"]]

##State
var idle = false
var moving = false
var reloadin = false
var slidejumping = false
var sliding = false

##Script Calls
var gun
var shot = false
var gun_node
var target
var component : GunComponent

##Mobility
var speed
var sliding_direction = Vector3(0,0,0)
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const SLIDE_SPEED = 20.0
const CROUCH_SPEED = 3.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.005

const BASE_FOV = 90.0
const FOV_CHANGE = 0.3

var gravity = 9.8

# head bob
const BOB_FREQ = 3.0
const BOB_AMP = 0.04
var t_bob = 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	var spawned = get_node("Head/Camera3D/Pivot/Weapon").get_child_count()
	var movement = Input.get_vector("left", "right", "up", "down")
	if event.is_action_pressed("weapon 1") and not spawned:
		update_equip()
		var equipping = load("res://Scenes/Weapons/" + str(Game.equipped["Item"]) + ".tscn")
		var weapon = equipping.instantiate()
		get_node("Head/Camera3D/Pivot/Weapon").add_child(weapon)
		weapon.global_position = hand.global_position
		weapon.global_rotation = hand.global_rotation
		gun = get_node("Head/Camera3D/Pivot/Weapon").get_child(0)
		gun_node = gun.get_node("GunComponent")
		cd = gun_node.shootcd

		
	if event.is_action_pressed("shoot") and mag > 0:
		if reloadin:
			return
		shoot(target)
		
	if event.is_action_pressed("reload") and reserves > 0 and not mag == mag_max:
		if shot:
			return
		reloadin = true
		var time = animate(gun_node, 3)
		reloading(time)
		
	if event.is_action_pressed("slide") and sliding == false:
		sliding = true
		sliding_direction = (head.transform.basis * Vector3(movement.x, 0, movement.y)).normalized()
		speed = SLIDE_SPEED
		camera.transform.origin -= Vector3(0,0.25,0)



func update_equip():
	var wep_stats = Game.equipped
	var equip = weapons.front()
	Game.equipped.merge(equip, true)
	mag = wep_stats["Mag"]
	mag_max = wep_stats["Max Size"]
	reserves = inventory[wep_stats["Ammo Type"]]



func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))



@warning_ignore("shadowed_variable")
func shoot(target):
	if shot == true:
		return
		
	mag -= 1
	cd = gun_node.shootcd
	shot = true
	if target != null:
		var attack = Damage.new()
		target.damage(attack)

	animate(gun_node, 2)



@warning_ignore("shadowed_variable")
func animate(gun_node, action):
	var node : GunComponent = gun_node
	var animating = Animate.new()
	if node == null:
		return
	return node.animation(animating, action)

func reloading(time):
	if time == null:
		return
	await get_tree().create_timer(time).timeout
	while reserves > 0 and mag < mag_max:
		mag += 1
		reserves -= 1
	reloadin = false
	pass

func _physics_process(delta):
	target = hitscan.get_collider()
	if shot == true:
		cd -= delta
		
	if cd <= 0:
		shot = false
	
	if sliding and is_on_floor():
		slide(delta)
	else:
		mobility(delta)
		


func mobility(delta):
	move_and_slide()
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

	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if slidejumping == true:
		velocity.y -= (gravity/2) * delta
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
			moving = true
			idle = false
		else:
			velocity.x = 0.0
			velocity.z = 0.0
			moving = false
			idle = true
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
		
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	# FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
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
	

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time*BOB_FREQ) * BOB_AMP
	pos.x = cos(time*BOB_FREQ / 2) * BOB_AMP
	return pos

func update_animation():
	
	pass

