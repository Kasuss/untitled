extends Node3D

signal done

@export var Map : PackedScene
@onready var player = get_node("player")
##const CELL = preload("res://Scenes/Environments/Generator/Cell.tscn")
##const DOOR = preload("res://Scenes/Environments/Generator/CellDoor.tscn")
##const PILLAR = preload("res://Scenes/Environments/Generator/Presets/Pillar.tscn")

var cells = []
var room_size = []
var all_rooms = []

var used_tiles
var rooms
var hallways

var startroom
var endroom

func _ready():
	randomize()
	spawn_map()

func _input(event):
	if event.is_action_pressed("debug_key"):
		var tiles = %Tiles.get_children()
		
		for t in tiles:
			t.queue_free()
		for e in %Enemies.get_children():
			e.queue_free()
		cells.clear()
		spawn_map()
		await get_tree().process_frame
		player.global_position = Vector3(0, 100, 0)

func spawn_map():
	if not Map is PackedScene: return
	var map = Map.instantiate()
	add_child(map)
	map.connect("generation_finished",generate_map) #wait for generator to finish
	await done #wait to set variables
	map.queue_free()
	
	
func generate_map(_tiles,_rooms,_halls):
	used_tiles = _tiles
	rooms = _rooms
	hallways = _halls
	done.emit() #finished setting variables

	
	for tile in used_tiles: #create map tiles
		var cell = CELL.instantiate()
		%Tiles.add_child(cell)
		cell.position = Vector3(tile.x*Global.GRID_SIZE, 0,tile.y*Global.GRID_SIZE)
		cells.append(cell)
	#
	for h in hallways: #connect hallways
		var midpoint = _halls
		if not used_tiles.has(h):
			var hall = DOOR.instantiate()
			%Tiles.add_child(hall)
			hall.position = Vector3(h.x*Global.GRID_SIZE, 0, h.y*Global.GRID_SIZE).floor()
			cells.append(hall)
			used_tiles.append(h)
	##update cell faces
	for c in cells:
		c.update_faces(used_tiles)
	group_rooms()
	print("map generated")
	
#func group_rooms():
	#startroom = null
	#endroom = rooms[-1]
	#for i in (rooms.size()) / 2:
		##optimize array
		#if i == 0:
			#room_size.append(0)
			#room_size.append(1)
		#else:
			#room_size.append(i*2)
			#room_size.append(i*2+1)
	#
	#while room_size:
		#var pos = rooms[room_size[0]]
		#var s = rooms[room_size[1]]
		#if startroom == null:
			#startroom = pos
		#room_size.pop_front()
		#await get_tree().process_frame
		#room_size.pop_front()
		#fill_rooms(pos, s)
	#rooms.clear()
	#room_size.clear()
	#player.global_position = startroom
	#
		#
#func fill_rooms(_pos, _s):
		##get positions
		#var room = AABB(_pos - _s, _s * 2)
		#DebugDraw.draw_box_aabb(AABB(room),Color(0, 1, 0.5),2400) #Debug Bounding Box
		#var center = room.get_center()
		##create light in room
		#var light = OmniLight3D.new()
		#light.omni_range = 5 + room.get_longest_axis_size()
		#light.global_position = center
		#light.light_energy = 10
		#%Tiles.add_child(light)
		##spawn objects
		#var size = ceili((int(_s.x * _s.y)) * 0.1)
		#var bottomleft = room.get_endpoint(0) + Vector3(8,0,8)
		#var topright = room.get_endpoint(7) - Vector3(8,0,8)
		#print(size)
		#if _pos != startroom:
			#var objects = []
			#for i in size:
				#var obj
				#var p
				#if i == 0:
					#obj = PILLAR
					#p = obj.instantiate()
					#p.global_position = center
				#else:
					#obj = load(Global.structure[randi_range(0,Global.structure.size() - 1)])
					#var randx = randf_range(bottomleft.x,topright.x)
					#var randz = randf_range(bottomleft.z,topright.z)
					#p = obj.instantiate()
					#p.global_position = Vector3(randx,0,randz)
					#p.rotation.y = randi() % 360
				#objects.append(p.global_position)
				#add_child(p)
				#i -= 1
			#objects.clear()
		#
		##spawn enemy
		#var enemy = load("res://Scenes/NPCs/enemy.tscn")
		#var spawn = enemy.instantiate()
		#if _pos != startroom:
			#spawn.global_position = center - Vector3(0,2,0)
			#%Enemies.add_child(spawn)
		#all_rooms.append(room)
