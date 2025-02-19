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
@export var reserves_max:Dictionary
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
	
	
#func _physics_process(delta):
	#if can_shoot == false and not reloading:
		#if equipped == null:
			#return
		#var time = equipped.CanShoot
		#time -= delta
		#if time <= 0:
			#can_shoot = true
#	pass

func _input(event):
	var spawned = get_child_count()
	if event.is_action_pressed("weapon 1"):
		if inventory.is_empty():
			return
		if equipped == all_weapons[inventory[0]]:
			return
		if spawned > 1:
			get_child(1).queue_free()
		update_equip(0)
	if event.is_action_pressed("weapon 2"):
		if inventory.size() <= 1:
			return
		if equipped == all_weapons[inventory[1]]:
			return
		if spawned > 1:
			get_child(1).queue_free()
		update_equip(1)
	if equipped == null:
		return
	if event.is_action_pressed("shoot") and equipped.LoadedAmmo > 0:
		shoot()
	
	if event.is_action_pressed("alt_fire") and equipped.LoadedAmmo > 0:
		alt_fire()
		
	if event.is_action_pressed("reload") and reloading == false:
		if equipped.LoadedAmmo == equipped.AmmoCap:
			return
		reload()
		
		
		
func shoot():
	if can_shoot == false:
		return
	
	if equipped.Type == "Pistol":
		target.force_raycast_update()
		if target.is_colliding() == null:
			return
		if target.is_colliding() and target.get_collider().is_in_group("Hitbox"):
			target.get_collider().damage(equipped.Damage, 1)
			damage.emit(equipped.Damage, 1)
		elif target.is_colliding() and target.get_collider().is_in_group("Headbox"):
			target.get_collider().damage(equipped.Damage, 2)
			damage.emit(equipped.Damage, 2)

	if equipped.Type == "Shotgun":
		for r in raycasts.get_children():
			r.force_raycast_update()
			r.target_position.x = randf_range(spread,-spread)
			r.target_position.y = randf_range(spread,-spread)
			if r.is_colliding() == null:
				return
			if r.is_colliding() and r.get_collider().is_in_group("Hitbox"):
					r.get_collider().damage(equipped.Damage, 1)
					damage.emit(equipped.Damage, 1)
			elif r.is_colliding() and r.get_collider().is_in_group("Headbox"):
					r.get_collider().damage(equipped.Damage, 2)
					damage.emit(equipped.Damage, 2)
	
	equipped.LoadedAmmo -= 1
	ammo_update()
	if equipped.Type == "Shotgun" and equipped.LoadedAmmo % 2 == 0:
		animate.emit(4, 0)
	else:
		animate.emit(3, 0)
	can_shoot = false
	
func alt_fire():
	if can_shoot == false or equipped.AltFire == false:
		return

	if equipped.Type == "Shotgun":
		for r in raycasts.get_children():
			r.force_raycast_update()
			r.target_position.x = randf_range(spread*1.10,-spread*1.10)
			r.target_position.y = randf_range(spread*1.10,-spread*1.10)
			if r.is_colliding() == null:
				return
			if r.is_colliding() and r.get_collider().is_in_group("Hitbox"):
				if equipped.LoadedAmmo > 1: 
					r.get_collider().damage(equipped.Damage, 2)
					damage.emit(equipped.Damage, 2)
				else:
					r.get_collider().damage(equipped.Damage, 1)
					damage.emit(equipped.Damage, 1)
			elif r.is_colliding() and r.get_collider().is_in_group("Headbox"):
				if equipped.LoadedAmmo > 1:
					r.get_collider().damage(equipped.Damage, 4)
					damage.emit(equipped.Damage, 4)
				else:
					r.get_collider().damage(equipped.Damage, 2)
					damage.emit(equipped.Damage, 2)
		if equipped.LoadedAmmo > 1: equipped.LoadedAmmo -= 2
		else: equipped.LoadedAmmo -= 1
		
		ammo_update()
		if equipped.LoadedAmmo % 2 == 0:
			animate.emit(4, 0)
		else:
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
	if equipped == null:
		return
	update_ammo.emit(equipped.LoadedAmmo, reserves[equipped.AmmoType])

	

func pickup_item(item):
	if item == null:
		return 
	if item.Type == "Ammo":
		give_ammo(item.Name)
		ammo_update()
		return
	if inventory.has(item.Name):
		give_ammo(item.AmmoType)
		ammo_update()
		return
	print("Giving " + str(item.Name))
	inventory.push_back(item.Name)
	
func give_ammo(ammo):
	var ammo_give = int(round(float(reserves_max[ammo] / 10)))
	if ammo_give + reserves[ammo] > reserves_max[ammo]:
		while reserves[ammo] < reserves_max[ammo]:
			reserves[ammo] += 1
	else:
		reserves[ammo] += ammo_give

func update_equip(slot):
	camera.play("sheathe")
	await get_tree().create_timer(camera.current_animation_length).timeout
	if get_child_count() > 0:
		gun_node.disconnect("finished", finished)
		await get_tree().process_frame
		get_child(0).queue_free()
	await get_tree().process_frame
	equipped = all_weapons[inventory[slot]]
	ammo_update()
	var equipping = load("res://Scenes/Weapons/" + str(inventory[slot]) + ".tscn")
	var weapon = equipping.instantiate()
	add_child(weapon)
	weapon.global_position = hand.global_position
	weapon.global_rotation = hand.global_rotation
	update_timers.emit(equipped.StartLoading,equipped.AmmoLoaded,equipped.CanShoot,equipped.DrawTime,equipped.CanShoot2)
	gun_node = get_child(0).get_child(0)
	gun_node.connect("finished",finished)
	animate.emit(0,0)
	

func finished():
	can_shoot = true
	ammo_update()

func _on_camera_control_animation_finished(anim_name):
	if anim_name == "sheathe":
		camera.play("RESET")
