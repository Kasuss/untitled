extends Area3D

signal item_pickup

@export var preset_path : String
@export var all_weapons : Array[String]
@onready var list = %WeaponList

var drop

func _ready():
	if preset_path != null:
		%Model.mesh = load("res://Models/Weapons/" + preset_path)
		drop = load("res://Resources/Weapons/" + preset_path)
		return 
	drop = await list.item_dropped()
	spawn_item(drop)
	
func spawn_item(item):
	var mesh = load("res://Models/Weapons/" + item)
	%Model.mesh = mesh
		
func give_item():
	return drop


func _on_area_entered(area):
	if area.is_in_group("Player"):
		give_item()
		await give_item()
		queue_free()
