extends Node3D

signal done

const SMALL = preload("res://Scenes/Environments/World1/RoomTemplates/SmallRoom.tscn")
const MED = preload("res://Scenes/Environments/World1/RoomTemplates/MediumRoom.tscn")
const BIG = preload("res://Scenes/Environments/World1/RoomTemplates/LargeRoom.tscn")

var start
var small
var wide
var big
var pos = []
var rot = []
var ai = NavigationRegion3D.new()
		

@export var Map : PackedScene

@export var SmallF : Array[PackedScene]
@export var WideF : Array[PackedScene]
@export var BigF : Array[PackedScene]

func _ready() -> void:
	randomize()
	spawn_map()


func spawn_map():
	if not Map is PackedScene: return
	var map = Map.instantiate()
	add_child(map)
	map.connect("generation_finished",generate_map) #wait for generator to finish
	await done #wait to set variables
	map.queue_free()
	print(str(small) + "SM, " + str(wide) + "WD, " + str(big))
	create_rooms(small,wide,big,pos,rot)
	
	
func generate_map(_small,_wide,_big,_pos,_rot):
	small = _small
	wide = _wide
	big = _big
	pos = _pos
	rot = _rot
	done.emit() #finished setting variables

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_key"):
		get_tree().reload_current_scene()
		
func create_rooms(s,w,b,pos,rot):
	var p = pos
	var r = rot
	for n in s:
		SmallF.shuffle()
		var m = SMALL.instantiate()
		%Rooms.add_child(m)
		m.global_position = Vector3(p[0].x,0,p[0].y)
		p.pop_front()
		if n == small[0]:
			start = m.global_position
			continue
		var f = SmallF[0].instantiate()
		m.add_child(f)
		match randi() % 3:
			0:
				f.global_rotation_degrees.y = 0
			1:
				f.global_rotation_degrees.y = 90
			2:
				f.global_rotation_degrees.y = 180
			3:
				f.global_rotation_degrees.y = 270
	for n in w:
		WideF.shuffle()
		var f = WideF[0].instantiate()
		var m = MED.instantiate()
		%Rooms.add_child(m)
		m.add_child(f)
		m.global_position = Vector3(p[0].x,0,p[0].y)
		if randi() % 1 == 0: f.global_rotation_degrees.y = 180
		else: f.global_rotation_degrees.y = 0
		if rot[0] == 0 or null:
			m.global_rotation_degrees.y = -90
			if randi() % 1 == 0: f.global_rotation_degrees.y = -90
			else: f.global_rotation_degrees.y = 90
		p.pop_front()
		r.pop_front()
	for n in b:
		BigF.shuffle()
		var f = BigF[0].instantiate()
		var m = BIG.instantiate()
		%Rooms.add_child(m)
		m.add_child(f)
		m.global_position = Vector3(p[0].x,0,p[0].y)
		p.pop_front()
	fill_rooms()

func fill_rooms():
	#for r in %Rooms.get_children():
		##for e in %Enemies:
			##ai.navigation_mesh
	await get_tree().create_timer(5).timeout
	%player.global_position = Vector3(start.x,6,start.z)		
	
