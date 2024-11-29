extends Node2D
class_name Walker

const DIRECTIONS = [Vector2(32,0), Vector2(0,-32), Vector2(-32,0), Vector2(0,32)]

var pos = Vector2(32,32)
var direction = Vector2(32,0)
var borders = Rect2()
var step_history = []
var room_size = []
var steps_since_turn = 0

func _init(starting_position, new_borders, rooms):
	assert(new_borders.has_point(starting_position))
	pos = starting_position
	borders = new_borders
	room_size = rooms
	print(room_size)
	
func walk(steps):
	for stepd in steps:
		if randf() <= 0.25 or steps_since_turn >= 2:
			change_direction()
		if step():
			var r = room_size[stepd]
			var c = []
			match r:
				0:
					step_history.append(pos)
					print(str(pos) + "SMOL")
				1:
					step_history.append(pos)
					change_direction()
					var new = pos + direction
					pos = new
					step_history.append(new)
					print(str(new) + "MED")
				2:
					var p = pos
					var d = direction
					step_history.append(p)
					pos += direction
					change_direction()
					step_history.append(pos)
					pos += direction
					step_history.append(pos)
					direction = d*Vector2(-1,-1)
					pos += direction
					step_history.append(pos)
					print(str(pos) + "LORGE")
		else:
			change_direction()
	return step_history
	
func step():
	var target_position = pos + direction
	if borders.has_point(target_position):
		steps_since_turn += 1
		pos = target_position
		return true
	else:
		return false

func change_direction():
	steps_since_turn = 0
	var directions = DIRECTIONS.duplicate()
	directions.erase(direction)
	directions.shuffle()
	direction = directions.pop_front()
	while not borders.has_point(pos + direction):
		direction = directions.pop_front()
