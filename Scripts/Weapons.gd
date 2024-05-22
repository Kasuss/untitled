extends Node3D

@onready var hand = %Pivot
@onready var handle = hand.transform.origin
@onready var raycasts = %Raycasts
@onready var target = %hitscan
@onready var camera = %CameraControl
var gun_node

##Stats
var spread = 5
var can_shoot = false
var shoot_timer
var reloading = false

signal update_ammo
signal animate(animation, loops)
signal damage(damage, multiplier)
signal update_timers(start,loaded,shoot,draw)

var inventory:Array = []
var all_weapons:Dictionary = {}

@export var weapons: Array[WeaponDefaults]
@export var startwep: Array[String]
@export var Light: int
@export var Medium: int
@export var Heavy: int

var reserves:Dictionary 

var equipped: WeaponDefaults = null

func _ready():
	for guns in weapons:
		all_weapons[guns.Name] = guns
		
	for guns in startwep:
		inventory.push_back(guns)
		
	reserves = {
	"Light":Light,
	"Medium":Medium,
	"Heavy":Heavy
	}

func _input(event):
	if event.is_action_pressed("weapon 1"):
		if inventory.is_empty():
			return
		if equipped == all_weapons[inventory[0]]:
			return
		update_equip(0)
	if event.is_action_pressed("weapon 2"):
		if inventory.size() <= 1:
			return
		if equipped == all_weapons[inventory[1]]:
			return
		update_equip(1)
		
	if event.is_action_pressed("shoot") and equipped.LoadedAmmo > 0:
		shoot()
		
	if event.is_action_pressed("reload") and reloading == false:
		reload()
		
		
		
func shoot():
	if can_shoot == false:
		return
	
	if equipped.WeaponType == "Pistol":
		target.force_raycast_update()
		if target.is_colliding() == null:
			return
		if target.is_colliding() and target.get_collider().is_in_group("Hitbox"):
			target.get_collider().damage(equipped.Damage, 1)
			damage.emit(equipped.Damage, 1)
		elif target.get_collider().is_in_group("Headbox"):
			target.get_collider().damage(equipped.Damage, 2)
			damage.emit(equipped.Damage, 2)

	if equipped.WeaponType == "Shotgun":
		for r in raycasts.get_children():
			r.force_raycast_update()
			r.target_position.x = randf_range(spread,-spread)
			r.target_position.y = randf_range(spread,-spread)
			if r.is_colliding() == null:
				return
			if r.is_colliding() and r.get_collider().is_in_group("Hitbox"):
				r.get_collider().damage(equipped.Damage, 1)
				damage.emit(equipped.Damage, 1)
			elif r.get_collider().is_in_group("Headbox"):
				r.get_collider().damage(equipped.Damage, 2)
				damage.emit(equipped.Damage, 2)
	
	equipped.LoadedAmmo -= 1
	ammo_update()
	animate.emit(3, 0)
	can_shoot = false

func reload():
	if reserves[equipped.AmmoType] <= 0:
		return
	can_shoot = false
	reloading = true
	
	if equipped.AmmoIncrement > 0:
		var loops = ceilf(float(equipped.AmmoCap - equipped.LoadedAmmo) / equipped.AmmoIncrement)
		animate.emit(5,loops)
		await get_tree().create_timer(equipped.AmmoLoaded).timeout
		while loops > 0:
			reserves[equipped.AmmoType] -= min(equipped.AmmoIncrement,equipped.AmmoCap-equipped.LoadedAmmo)
			equipped.LoadedAmmo += min(equipped.AmmoIncrement,equipped.AmmoCap-equipped.LoadedAmmo)
			ammo_update()
			loops -= 1
			await get_tree().create_timer(equipped.AmmoLoaded-equipped.StartLoading).timeout
	else:
		animate.emit(5,0)
		await get_tree().create_timer(equipped.AmmoLoaded).timeout
		reserves[equipped.AmmoType] -= min(equipped.AmmoCap-equipped.LoadedAmmo, reserves[equipped.AmmoType])
		equipped.LoadedAmmo += min(equipped.AmmoCap-equipped.LoadedAmmo, reserves[equipped.AmmoType])
		ammo_update()
	can_shoot = true
	reloading = false
		

func ammo_update():
	update_ammo.emit(equipped.LoadedAmmo, reserves[equipped.AmmoType])

	

func pickup_item(item):
	if inventory.has(item):
		print("nuh uh")
		return
	inventory.push_back(item.Name)

func update_equip(slot):
	var spawned = get_child_count()
	camera.play("sheathe")
	await get_tree().create_timer(camera.current_animation_length).timeout
	if spawned:
		%Weapons.get_child(0).queue_free()
		await get_tree().create_timer(0.1).timeout
	var equipping = load("res://Scenes/Weapons/" + str(inventory[slot]) + ".tscn")
	var weapon = equipping.instantiate()
	add_child(weapon)
	weapon.global_position = hand.global_position
	weapon.global_rotation = hand.global_rotation
	equipped = all_weapons[inventory[slot]]
	ammo_update()
	update_timers.emit(equipped.StartLoading,equipped.AmmoLoaded,equipped.CanShoot,equipped.DrawTime)
	gun_node = get_child(0).get_child(0)
	gun_node.connect("finished",finished)
	animate.emit(0,0)
	

func finished():
	can_shoot = true
	ammo_update()

func _on_camera_control_animation_finished(anim_name):
	if anim_name == "sheathe":
		camera.play("RESET")
