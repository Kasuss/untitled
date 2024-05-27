extends Node2D

@onready var Map = $TileMap

var room = preload("res://Imports/tuts/generator.tscn")

var tile_size = 128
var room_amount = 20
var min_size = 4
var max_size = 8
var hspread = 1
var cull = 0.25

var path

func _ready():
	randomize()
	make_rooms()

func make_rooms():
	for i in range(room_amount):
		var pos = Vector2(randi_range(-hspread,hspread),0)
		var r = room.instantiate()
		var w = min_size + randi() % (max_size - min_size)
		var h = min_size + randi() % (max_size - min_size)
		r.make_room(pos, Vector2(w,h) * tile_size)
		$Rooms.add_child(r)
	#wait
	await get_tree().create_timer(1.1).timeout
	var room_positions = []
	for room in $Rooms.get_children():
		if randf() < cull:
			room.queue_free()
		else:
			room.freeze = true
			room_positions.append(Vector3(room.position.x,room.position.y,0))
	await get_tree().process_frame
	path = find_mst(room_positions)
		
func _draw():
	for room in $Rooms.get_children():
		draw_rect(Rect2(room.position - room.size, room.size * 2),Color(32,228,0), false)
	if path:
		for p in path.get_point_ids():
			for c in path.get_point_connections(p):
				var pp = path.get_point_position(p)
				var cp = path.get_point_position(c)
				draw_line(Vector2(pp.x,pp.y), Vector2(cp.x, cp.y), Color(1,1,0), 15, true)
		
func _process(_delta):
	queue_redraw()
	
func _input(event):
	if event.is_action_pressed('debug_key'):
		for n in $Rooms.get_children():
			n.queue_free()
		make_rooms()
	if event.is_action_pressed('ui_accept'):
		make_map()

func find_mst(nodes):
	var path = AStar3D.new()
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
	for room in $Rooms.get_children():
		var r = Rect2(room.position - room.size,room.get_node("CollisionShape2D").shape.extents*2)
		full_rect = full_rect.merge(r)
		
	var topleft = Map.local_to_map(full_rect.position)
	var bottomright = Map.local_to_map(full_rect.end)
	for x in range(topleft.x,bottomright.x):
		for y in range(topleft.y, bottomright.y):
			Map.set_cell(0, Vector2i(x,y), 0, Vector2i(0,0),0)
	
	var corridors = []
	for room in $Rooms.get_children():
		var s = (room.size / tile_size).floor()
		var pos = Map.local_to_map(room.position)
		var ul = (room.position / tile_size).floor() - s
		for x in range(2, s.x * 2 - 1):
			for y in range(2, s.y * 2 - 1):
				Map.set_cell(0,Vector2i(ul.x + x,ul.y + y), 1, Vector2i(0,0),0)
				
		var p = path.get_closest_point(Vector3(room.position.x, room.position.y,0))
			
		for conn in path.get_point_connections(p):
			if not conn in corridors:
				var start = Map.local_to_map(Vector2(path.get_point_position(p).x,path.get_point_position(p).y))
				var end = Map.local_to_map(Vector2(path.get_point_position(conn).x,path.get_point_position(conn).y))
				carve_path(start,end)
		corridors.append(p)
		
func carve_path(pos1, pos2):
	var x_diff = sign(pos2.x - pos1.x)
	var y_diff = sign(pos2.y - pos1.y)
	if x_diff == 0: x_diff = pow(-1.0, randi() % 3)
	if y_diff == 0: y_diff = pow(-1.0, randi() % 3)
	var x_y = pos1
	var y_x = pos2
	if (randi() % 2) > 0:
		x_y = pos2
		y_x = pos1
	for x in range(pos1.x, pos2.x, x_diff):
		Map.set_cell(0, Vector2i(x, x_y.y), 2, Vector2i(0, 0), 0);
		Map.set_cell(0, Vector2i(x, x_y.y + y_diff), 2, Vector2i(0, 0), 0);
	for y in range(pos1.y, pos2.y, y_diff):
		Map.set_cell(0, Vector2i(y_x.x, y), 2, Vector2i(0, 0), 0);
		Map.set_cell(0, Vector2i(y_x.x + x_diff, y), 2, Vector2i(0, 0), 0);
	
	
	
