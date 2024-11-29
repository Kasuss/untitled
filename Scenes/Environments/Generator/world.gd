extends Node3D

signal done
signal doors

const SMALL = preload("res://Scenes/Environments/World1/RoomTemplates/SmallRoom.tscn")
const MED = preload("res://Scenes/Environments/World1/RoomTemplates/MediumRoom.tscn")
const BIG = preload("res://Scenes/Environments/World1/RoomTemplates/LargeRoom.tscn")

var small
var wide
var big
var pos = []
var rot = []

@export var Map : PackedScene

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
		var m = SMALL.instantiate()
		%Rooms.add_child(m)
		m.global_position = Vector3(p[0].x,0,p[0].y)
		p.pop_front()
	for n in w:
		var m = MED.instantiate()
		%Rooms.add_child(m)
		m.global_position = Vector3(p[0].x,0,p[0].y)
		if rot[0] == 0:
			m.global_rotation_degrees.y = -90
		p.pop_front()
		r.pop_front()
	for n in b:
		var m = BIG.instantiate()
		%Rooms.add_child(m)
		m.global_position = Vector3(p[0].x,0,p[0].y)
		p.pop_front()
	doors.emit()
	connect_rooms()

func connect_rooms():
	var starting_room = small[0].global_position
	%player.global_position = Vector3(starting_room.x,6,starting_room.y)
	pass
