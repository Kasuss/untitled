extends Area3D

signal item_pickup

@export var all_weapons : Array[String]
@onready var list = %WeaponList
var drop
var color
const BOX = preload("res://Scenes/Pickups/AmmoBox.tscn")
		

func _ready():
	%AnimationPlayer.play("rotate")
	drop = await list.item_dropped()
	spawn_item(drop)
	
	
func spawn_item(item):
	if item == null:
		return
	var res = item[0]
	var type = item[1]
	var mesh
	print(type)
	if type == "Ammo":
		var material = load("res://Models/Pickups/AmmoMat.tres")
		color = res.BoxColor
		material.albedo_color = color
		var box = BOX.instantiate()
		add_child(box)
		box.global_position = global_position
	else:
		var path = "res://Models/Weapons/" + str(res.Name) + ".tres"
		mesh = load(path)
		%Model.mesh = mesh
		
	
	
		
func _on_area_entered(area):
	if area.is_in_group("Player"):
		give_item()
		queue_free()
		
func give_item():
	if drop == null:
		return
	return drop[0]
