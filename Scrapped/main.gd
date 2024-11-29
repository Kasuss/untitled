extends Node2D

signal generation_finished(_tiles,_rooms,_halls)

@onready var Map = $TileMap

var room = preload("res://Scenes/Environments/Generator/generator.tscn")

var tile_size = 2
var room_amount
var min_size = 12
var max_size = 24
var hspread = 0
var s = 0
var p_pos

var path
var rooms = []
var corridors = []
var hallway = []
var room_size = []
var used_size = []
var room_pos = []

func _ready():
	randomize()
	room_amount = randi_range(8,10)
	room_size.append(0)
	for r in room_amount:
		r = randi() % 3
		room_size.append(r)
	#room_size.sort()
	#room_size.reverse()
	make_rooms()
	print(room_size)

func make_rooms():
	for i in room_amount:
		var pos = Vector2(0,0)
		var r = room.instantiate()
		var w
		var h
		var o = randi() % 2
		if i == 0:
			r.make_room(pos, Vector2(1,1))
			%Rooms.add_child(r)
			used_size.append(room_size[0])
			room_size.pop_front()
			p_pos = r.position
			r.freeze = true
		else:
			match room_size[0]:
				0:
					w = 1
					h = 1
					#if i != 1:
						#if used_size[0] == 1 or used_size[0] == 2:
							#pos = Vector2(previous_room.x + w*tile_size,previous_room.y + h*tile_size)
						#else:
							#pos = previous_room
					used_size.append(room_size[0])
					room_size.pop_front()
				1:
					if o == 0: 
						w = 1
						h = 2
						#pos = Vector2(previous_room.x + w*tile_size,previous_room.y - h*tile_size)
					else: 
						w = 2
						h = 1
						#pos = Vector2(previous_room.x - w*tile_size,previous_room.y + h*tile_size)
					used_size.append(room_size[0])
					room_size.pop_front()
				2:
					w = 2
					h = 2
					#match used_size[0]:
						#0:
							#pos = Vector2(previous_room.x + w*tile_size,previous_room.y + h*tile_size)
						#1:
							#pos = Vector2(previous_room.x + w*tile_size,previous_room.y + h)
						#2: 
							#pos = Vector2(previous_room.x + w*tile_size,previous_room.y + h*tile_size)
					used_size.append(room_size[0])
					room_size.pop_front()
			var rngX = randi_range(-1,1)
			var rngY = randi_range(-1,1)
			if i > 0:
				rngX += p_pos.x
				rngY += p_pos.y
			r.make_room(Vector2(rngX,rngY), Vector2(w,h))
			%Rooms.add_child(r)
			await get_tree().create_timer(0.5).timeout
			r.position = r.position.floor().snapped(Vector2(1,1))
			await get_tree().create_timer(0.5).timeout
			r.freeze = true
			p_pos = r.position
		
	#wait
	await get_tree().create_timer(1).timeout
	var room_positions = []
	for room in %Rooms.get_children():
		#match used_size[s]:
			#0:
				#room.position = room.position.floor().snapped(Vector2(1,1))
			#1:
				#var size = Vector2(room.size.x,room.size.y)
				#print(str(size) + "SIZE")
				#if size.y > size.x:
					#room.position = room.position.floor().snapped(Vector2(2,1))
				#else:
					#room.position = room.position.floor().snapped(Vector2(1,2))
			#2:
				#room.position = room.position.floor().snapped(Vector2(2,2))
		#await get_tree().create_timer(1).timeout
		room.position = room.position.floor().snapped(Vector2(1,1))
		s+=1
		print(room.global_position)
		room.freeze = true
		room_positions.append(Vector2(room.position.x,room.position.y))
		rooms.append_array([Vector3(room.position.x,3,room.position.y), Vector3(room.size.x,3,room.size.y)])
			
	await get_tree().process_frame
	path = find_mst(room_positions)
	await get_tree().process_frame
	#make_map()
		
func _draw():
	for room in $Rooms.get_children():
		draw_rect(Rect2(room.position - room.size, room.size * 2),Color(32,228,0), false)
	if path:
		for p in path.get_point_ids():
			for c in path.get_point_connections(p):
				var pp = path.get_point_position(p)
				var cp = path.get_point_position(c)
				draw_line(Vector2(pp.x,pp.y), Vector2(cp.x, cp.y), Color(1,1,0), 0.25, true)
		
func _process(_delta):
	queue_redraw()
	
func find_mst(nodes):
	var path = AStar2D.new()
	path.add_point(path.get_available_point_id(), nodes.pop_front())
	
	while nodes:
		var min_dist = INF #minimun distance
		var min_p = null #position of node
		var p = null # current position
		for p1 in path.get_point_ids():
			var pt = path.get_point_position(p1)
			#loop remaining nodes
			for p2 in nodes:
				if pt.distance_to(p2) < min_dist:
					min_dist = pt.distance_to(p2)
					min_p = p2 
					p = pt
		var n = path.get_available_point_id()
		path.add_point(n, min_p)
		path.connect_points(path.get_closest_point(p), n)
		nodes.erase(min_p)
	return path

func make_map():
	#Create TileMap
	Map.clear()
	var full_rect = Rect2()
	for room in %Rooms.get_children():
		var r = Rect2(room.position - room.size,room.get_node("CollisionShape2D").shape.extents*2)
		full_rect = full_rect.merge(r)
		
		
	var topleft = Map.local_to_map(full_rect.position)
	var bottomright = Map.local_to_map(full_rect.end)
	#var room_size = [topleft, bottomright]
	#rooms.append_array(room_size)
	for x in range(topleft.x,bottomright.x):
		for y in range(topleft.y, bottomright.y):
			Map.set_cell(0, Vector2i(x,y), 0, Vector2i(0,0),0)
			
	print(%Rooms.get_child_count())
	for room in %Rooms.get_children():
		var s = (room.size / tile_size).floor()
		#var pos = Map.local_to_map(room.position)
		var ul = (room.position / tile_size).floor() - s
		for x in range(2, s.x * 2):
			for y in range(2, s.y * 2):
				Map.set_cell(1,Vector2i(ul.x + x,ul.y + y), 1, Vector2i(0,1),0)
	
		var p = path.get_closest_point(Vector2(room.position.x, room.position.y))
			
		for conn in path.get_point_connections(p):
			if not conn in corridors:
				var start = Map.local_to_map(Vector2(path.get_point_position(p).x,path.get_point_position(p).y))
				var end = Map.local_to_map(Vector2(path.get_point_position(conn).x,path.get_point_position(conn).y))
				carve_path(start,end)
			#var begin_end = [(Vector2(path.get_point_position(p).x,path.get_point_position(p).y)),(Vector2(path.get_point_position(conn).x,path.get_point_position(conn).y))]
			#hallway.append_array(begin_end)
			
		corridors.append(p)
	await get_tree().process_frame
	get_tilemap()
	

func carve_path(pos1, pos2):
	var x_diff = sign(pos2.x - pos1.x)
	var y_diff = sign(pos2.y - pos1.y)
	if x_diff == 0: x_diff = pow(-1.0, randi() % 2)
	if y_diff == 0: y_diff = pow(-1.0, randi() % 2)
	var x_y = pos1
	var y_x = pos2
	if (randi() % 2) > 0:
		x_y = pos2
		y_x = pos1
	for x in range(pos1.x, pos2.x, x_diff):
		Map.set_cell(2, Vector2i(x, x_y.y), 0, Vector2i(0, 2), 0);
		Map.set_cell(2, Vector2i(x, x_y.y + y_diff), 0, Vector2i(0, 2), 0);
	for y in range(pos1.y, pos2.y, y_diff):
		Map.set_cell(2, Vector2i(y_x.x, y), 0, Vector2i(0, 2), 0);
		Map.set_cell(2, Vector2i(y_x.x + x_diff, y), 0, Vector2i(0, 2), 0);
	
	

func get_tilemap():
	Map.update_internals()
	generation_finished.emit(Map.get_used_cells(1), rooms, Map.get_used_cells(2))
