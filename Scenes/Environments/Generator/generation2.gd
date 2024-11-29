extends Node

signal generation_finished(_small,_wide,_big)

var queue = []
var total = []
var totalW = []
var totalB = []
var rooms
var dir = [+1,-1,+10,-10]
var level = 2
var x = 0
var y = 0

var roomVIS = preload("res://Scenes/Environments/Generator/generator.tscn")

const SMALL = preload("res://Scenes/Environments/World1/RoomTemplates/SmallRoom.tscn")
const MED = preload("res://Scenes/Environments/World1/RoomTemplates/MediumRoom.tscn")
const BIG = preload("res://Scenes/Environments/World1/RoomTemplates/LargeRoom.tscn")


func _ready() -> void:
	rooms = randi_range(0,1) + 6 + (level * 2.6)
	rooms = round(rooms)
	print("ROOMS: " + str(rooms))
	await get_tree().create_timer(1).timeout
	total.append(45)
	generate_rooms()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_key"):
		get_tree().reload_current_scene()

func queue_has(n):
	if n in total or totalW or totalB:
		return true
	else: return false
		
func wide_rooms(cell, parent):
	if cell % 10 == 0 or sign(cell) == -1: return
	var roomW = []
	for d in dir:
		roomW.append(cell+d)
	roomW.erase(parent)
	for c in roomW:
		if total.has(c) or totalW.has(c) or totalB.has(c):
			roomW.erase(c)
	roomW.shuffle()
	return roomW[0]
	
func big_rooms(cell):
	if cell % 10 == 0 or sign(cell) == -1: return # stop attempt if cell ends with 0 or is negative
	var roomB = []
	var Broom = [cell]
	for d in dir:
		roomB.append(cell+d)
	roomB.sort()
	roomB.reverse()
	Broom.append_array([roomB[0], roomB[1], (roomB[1]+10)])
	if Broom.any(queue_has):
		return null
	else:
		return Broom

func generate_rooms():
	queue.append_array(total)
	while rooms != 0:
		for r in queue:
			if rooms == 0:
				break
			dir.shuffle()
			var cell = r+dir[0] # cell we are checking 
			var n = []
			if total.has(cell) or totalW.has(cell) or totalB.has(cell): #check rooms for current cell
				continue
			if cell % 10 == 0 or sign(cell) == -1: continue # stop attempt if cell ends with 0 or is negative
			for d in dir: #check for all neighboring cells
				n.append(cell+d)
			n.erase(r) # remove parent cell
			if n.any(queue_has): #check for any neighboring cells
				if randi() % 2 == 0: # 50% chance to stop attempt
					continue
			#check to see if bigger rooms can generate
			if randi() % 3 == 0 and totalW.size() < 6:
				var cellW = wide_rooms(cell,r)
				if cellW:
					#create wide room
					totalW.append_array([cell, cellW])
					queue.append_array([cell, cellW])
					rooms-=1
					continue
			if randi() % 2 == 0 and totalB.size() < 8:
				var cellB = big_rooms(cell)
				if cellB != null:
					#create big room
					totalB.append_array(cellB)
					queue.append_array(cellB)
					rooms-=1
					continue
			total.append(cell)
			rooms -= 1
			queue.append(cell)
	create_rooms(total,totalW,totalB)
	print("FINISHED: " + str(total))
	print("FINISHED WIDE: " + str(totalW))
	print("FINISHED BIG: " + str(totalB))
	
func create_rooms(small,wide,big):
	var room_all = [small.size(),wide.size()/2,big.size()/4]
	var i = 0
	var pos = []
	var rot = []
	print(room_all)
	for s in small:
		var r = roomVIS.instantiate()
		x = 0
		y = 0
		while s > 10:
			y += 32
			s -= 10
		while s > 0:
			x += 32
			s -= 1
		var p = Vector2(x,y)
		r.make_room(p, Vector2(16,16))
		%SRooms.add_child(r)
		r.position = p
		pos.append(r.position)
		#smallroom.position = Vector2(x,y)
		r.freeze = true
	for w in wide:
		if i % 2 == 1:
			i += 1
			continue
		var r = roomVIS.instantiate()
		var cells = [wide[i],wide[i+1]]
		var center = []
		for c in cells:
			x = 0 
			y = 0
			while c > 10:
				y += 32
				c -= 10
			while c > 0:
				x += 32
				c -= 1
			center.append(Vector2(x,y))
		center.sort()
		var s = center[1] - center[0]
		if s.x == 0: 
			s.x = 16
			s.y = 32
			rot.append(0)
		elif s.y == 0: 
			s.y = 16
			s.x = 32
			rot.append(1)
		var p = center[1] - ((center[1] - center[0])/2)
		r.make_room(p, s)
		%WRooms.add_child(r)
		r.position = p
		pos.append(r.position)
		#smallroom.position = Vector2(x,y)
		print(str(x) + ", " + str(y))
		i += 1
		r.freeze = true
	i = 0
	for b in big:
		if i != 0:
			i -= 1
			big.pop_front()
			continue
		var r = roomVIS.instantiate()
		var cells = [big[0],big[1],big[2],big[3]]
		var center = []
		for c in cells:
			x = 0 
			y = 0
			while c > 10:
				y += 32
				c -= 10
			while c > 0:
				x += 32
				c -= 1
			center.append(Vector2(x,y))
		center.sort()
		var p = center[3] - ((center[3] - center[0])/2)
		r.make_room(p, Vector2(32,32))
		%BRooms.add_child(r)
		r.position = p
		pos.append(r.position)
		#smallroom.position = Vector2(x,y)
		print(str(x) + ", " + str(y))
		i = 3
		r.freeze = true
		wide.pop_front()
		
	generation_finished.emit($SRooms.get_children(),$WRooms.get_children(),$BRooms.get_children(),pos,rot)
